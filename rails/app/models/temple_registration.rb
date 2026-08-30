# frozen_string_literal: true

class TempleRegistration < ApplicationRecord
  DEFAULT_HOLD_DURATION_HOURS = 24

  PAYMENT_STATUSES = {
    pending: "pending",
    paid: "paid",
    refunded: "refunded",
    failed: "failed"
  }.freeze

  FULFILLMENT_STATUSES = {
    open: "open",
    fulfilled: "fulfilled",
    cancelled: "cancelled"
  }.freeze

  belongs_to :temple
  belongs_to :registrable, polymorphic: true
  belongs_to :user, optional: true

  has_many :temple_payments,
    foreign_key: :temple_registration_id,
    dependent: :destroy
  has_many :temple_assistance_requests,
    foreign_key: :temple_registration_id,
    dependent: :nullify

  validates :reference_code, presence: true, uniqueness: { scope: :temple_id }
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES.values }
  validates :fulfillment_status, inclusion: { in: FULFILLMENT_STATUSES.values }
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, :total_price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true

  before_validation :assign_reference_code
  before_validation :backfill_currency
  before_validation :calculate_totals
  before_validation :assign_default_expires_at, on: :create
  before_validation :clear_expires_at_when_not_pending

  scope :recent, -> { order(created_at: :desc) }

  # --- Lifecycle stages -------------------------------------------------
  #
  # The Director's nine-stage pipeline collapses to six STATES, of which only
  # two are admin work queues. These are plain scopes rather than a derived
  # Ruby method on purpose: the whole reason this exists is that pending work
  # was unfindable at volume, and a state you cannot filter, sort, index or
  # paginate on solves that with a mechanism that reproduces it.
  #
  # Temple delinquency is deliberately NOT part of these scopes. It is a
  # property of the temple, not of a registration, and every admin queue is
  # already scoped to one temple -- so it relabels a set of rows
  # ("awaiting payment" vs "blocked on billing") rather than selecting a
  # different set. Keeping it out is what lets all six express as SQL without
  # a JSON/association/time-arithmetic join.
  scope :awaiting_admin_completion, -> { where(admin_completed_at: nil, fulfillment_status: FULFILLMENT_STATUSES[:open]) }
  scope :admin_completed, -> { where.not(admin_completed_at: nil) }
  scope :awaiting_payment, lambda {
    admin_completed
      .where(fulfillment_status: FULFILLMENT_STATUSES[:open])
      .where("total_price_cents > 0")
      .where.not(payment_status: PAYMENT_STATUSES[:paid])
  }
  # Free registrations never reach a payment step, so completion is the last
  # thing standing between them and fulfilment.
  scope :awaiting_fulfilment, lambda {
    admin_completed
      .where(fulfillment_status: FULFILLMENT_STATUSES[:open])
      .where("total_price_cents = 0 OR payment_status = ?", PAYMENT_STATUSES[:paid])
  }
  scope :fulfilled, -> { where(fulfillment_status: FULFILLMENT_STATUSES[:fulfilled]) }
  scope :cancelled, -> { where(fulfillment_status: FULFILLMENT_STATUSES[:cancelled]) }
  scope :with_status, ->(status) { where(payment_status: status) }
  scope :active_for_capacity, -> { where.not(fulfillment_status: FULFILLMENT_STATUSES[:cancelled]) }
  scope :expired_pending_payment_holds, lambda { |now = Time.current|
    where(payment_status: PAYMENT_STATUSES[:pending], fulfillment_status: FULFILLMENT_STATUSES[:open])
      .where("total_price_cents > 0")
      .where("expires_at IS NOT NULL AND expires_at <= ?", now)
  }
  scope :with_certificate_number, lambda {
    where(Arel.sql("#{certificate_number_sql} <> ''"))
  }
  scope :without_certificate_number, lambda {
    where(Arel.sql("#{certificate_number_sql} = ''"))
  }

  def self.admin_filtered(filters)
    filters ||= {}
    scope = includes(:user, :temple_payments).preload(:registrable)
    if filters[:offering_type].present?
      type_values = offering_type_filter_values(filters[:offering_type])
      scope = scope.where(registrable_type: type_values)
      scope = scope.where(registrable_id: filters[:offering_id]) if filters[:offering_id].present?
    end
    if filters[:payment_method].present?
      scope = scope.left_outer_joins(:temple_payments).where(temple_payments: { payment_method: filters[:payment_method] })
    end
    # The lifecycle stages come first and are deliberately distinct from
    # paid/unpaid. Before this, a registration awaiting the temple's own
    # review was not merely unfiltered -- it sat inside "unpaid" alongside
    # every registration that was complete and simply waiting on the patron,
    # which is the largest bucket on the page. "Waiting on us" and "waiting
    # on them" were indistinguishable.
    case filters[:status]
    when "awaiting_completion"
      scope = scope.awaiting_admin_completion
    when "awaiting_fulfilment"
      scope = scope.awaiting_fulfilment
    when "fulfilled"
      scope = scope.fulfilled
    when PAYMENT_STATUSES[:paid]
      scope = scope.where(payment_status: PAYMENT_STATUSES[:paid])
    when "unpaid"
      scope = scope.where.not(payment_status: PAYMENT_STATUSES[:paid])
    end
    if filters[:query].present?
      sanitized = ActiveRecord::Base.sanitize_sql_like(filters[:query])
      scope = scope.left_outer_joins(:user).where(
        "#{table_name}.reference_code ILIKE :query OR users.english_name ILIKE :query OR users.email ILIKE :query OR (#{table_name}.contact_payload ->> 'name') ILIKE :query",
        query: "%#{sanitized}%"
      )
    end
    if (start_at = parse_admin_filter_date(filters[:start_date]))
      scope = scope.where(arel_table[:created_at].gteq(start_at))
    end
    if (end_at = parse_admin_filter_date(filters[:end_date], end_of_day: true))
      scope = scope.where(arel_table[:created_at].lteq(end_at))
    end
    scope.distinct
  end

  def paid?
    payment_status == PAYMENT_STATUSES[:paid]
  end

  def no_payment_required?
    total_price_cents.to_i.zero?
  end

  def payment_status_for_display
    return "no_payment_required" if no_payment_required?

    payment_status
  end

  def fulfilled?
    fulfillment_status == FULFILLMENT_STATUSES[:fulfilled]
  end

  # Stage 9: the temple has actually done the thing -- lit the lantern,
  # arranged the ritual, printed the certificate. Idempotent and boolean-
  # returning like mark_admin_completed!, so callers can avoid logging a
  # spurious audit event for an already-fulfilled record.
  def mark_fulfilled!(now = Time.current)
    return false if fulfilled?
    return false unless fulfillment_status == FULFILLMENT_STATUSES[:open]

    update!(fulfillment_status: FULFILLMENT_STATUSES[:fulfilled], fulfilled_at: now)
    true
  end

  # Which of the six lifecycle states this registration is in. Derived for
  # DISPLAY only -- the scopes above are the queryable authority, and this
  # must stay consistent with them. `delinquent:` is passed in by the caller
  # because it is a temple-level fact, not a per-row one.
  def lifecycle_stage(delinquent: false)
    return :cancelled if fulfillment_status == FULFILLMENT_STATUSES[:cancelled]
    return :fulfilled if fulfilled?
    return :awaiting_admin_completion unless admin_completed?
    return :awaiting_fulfilment if no_payment_required? || paid?

    delinquent ? :blocked_on_billing : :awaiting_payment
  end

  def mark_paid!
    update!(payment_status: PAYMENT_STATUSES[:paid], expires_at: nil)
  end

  # The semi-automatic registration checkpoint: a patron's own self-
  # registration is intent, not a finished order (see
  # ops/docs/plans/SEMI_AUTOMATIC_REGISTRATION_WORKFLOW_PLAN.md). This gates
  # only the patron's own online-checkout path -- admin-initiated cash
  # acceptance is unaffected by design, since in practice the same admin
  # often completes a registration and accepts cash in one sitting.
  #
  # Universal since 2026-08-28. A gathering is a sub-type, not a separate
  # flow: same pipeline, it simply carries no offering data to fill in, so
  # the admin's action there is review-and-publish rather than data entry.
  # LifecyclePolicy#gathering_editable? already makes gathering fields
  # read-only after creation, which is consistent with that.
  #
  # The exclusion this replaced was load-bearing, not cosmetic: checkout_ready?
  # demands admin_completed_at once completion is required, so removing it
  # before a gathering completion path existed would have made every gathering
  # registration permanently unpayable. That path (route, helper, button)
  # landed first, deliberately.
  def admin_completion_required?
    true
  end

  def admin_completed?
    admin_completed_at.present?
  end

  def checkout_ready?
    !admin_completion_required? || admin_completed?
  end

  # Returns true only when this call actually completed the registration,
  # false when it was already completed -- callers use this to avoid
  # logging a spurious "completed" event on an already-completed record.
  def mark_admin_completed!
    return false if admin_completed?

    update!(admin_completed_at: Time.current)
    true
  end

  def self.hold_duration
    hours = ENV.fetch("REGISTRATION_HOLD_DURATION_HOURS", DEFAULT_HOLD_DURATION_HOURS).to_i
    hours = DEFAULT_HOLD_DURATION_HOURS if hours <= 0
    hours.hours
  end

  def self.cancel_expired_unpaid!(now: Time.current)
    cancelled = 0
    expired_pending_payment_holds(now).find_each do |registration|
      next unless registration.cancel_pending_hold!(now:)

      cancelled += 1
    end
    cancelled
  end

  def cancel_pending_hold!(now: Time.current)
    return false unless payment_status == PAYMENT_STATUSES[:pending]
    return false unless fulfillment_status == FULFILLMENT_STATUSES[:open]
    return false if total_price_cents.to_i <= 0
    return false if expires_at.blank? || expires_at > now
    return false if temple_payments.exists?

    update!(
      fulfillment_status: FULFILLMENT_STATUSES[:cancelled],
      cancelled_at: now,
      expires_at: nil
    )
    true
  end

  def certificate_number
    metadata_value("certificate_number")
  end

  def certificate_number=(value)
    write_metadata_value("certificate_number", value.presence)
  end

  def event_slug
    metadata_value("event_slug")
  end

  def event_slug=(value)
    write_metadata_value("event_slug", value.presence)
  end

  def temple_offering
    registrable.is_a?(TempleEvent) ? registrable : nil
  end

  def temple_service
    registrable.is_a?(TempleService) ? registrable : nil
  end

  def offering
    registrable
  end

  def registrant_name
    payload = contact_payload || {}
    if dependent_registration?
      metadata_value("registrant_name") ||
        payload["primary_contact"] ||
        payload["contact_name"] ||
        payload["name"] ||
        user&.english_name ||
        user&.email ||
        "訪客"
    else
      user&.english_name ||
        payload["primary_contact"] ||
        payload["contact_name"] ||
        payload["name"] ||
        user&.email ||
        "訪客"
    end
  end

  def registrant_scope
    metadata_value("registrant_scope").presence || (dependent_registration? ? "dependent" : "self")
  end

  def dependent_registration?
    metadata_value("dependent_id").present?
  end

  private

  def assign_reference_code
    self.reference_code ||= "REG-#{SecureRandom.hex(4).upcase}"
  end

  def backfill_currency
    self.currency ||= registrable&.currency || "TWD"
  end

  def calculate_totals
    if unit_price_cents.to_i.zero? && registrable.present?
      self.unit_price_cents = registrable.price_cents
    end
    self.total_price_cents = unit_price_cents.to_i * quantity.to_i
  end

  def assign_default_expires_at
    return if expires_at.present?
    return unless hold_required?

    self.expires_at = Time.current + self.class.hold_duration
  end

  def clear_expires_at_when_not_pending
    return if hold_required?

    self.expires_at = nil
  end

  def hold_required?
    payment_status == PAYMENT_STATUSES[:pending] &&
      fulfillment_status == FULFILLMENT_STATUSES[:open] &&
      total_price_cents.to_i.positive?
  end

  def self.offering_type_filter_values(type)
    normalized = type.to_s
    case normalized
    when TempleService.name
      [TempleService.name]
    when TempleEvent.name, TempleOffering.name
      [TempleEvent.name, TempleOffering.name]
    when TempleGathering.name
      [TempleGathering.name]
    else
      [normalized.presence].compact
    end
  end

  def self.parse_admin_filter_date(value, end_of_day: false)
    return nil if value.blank?

    timestamp = Time.zone.parse(value.to_s)
    return nil unless timestamp

    end_of_day ? timestamp.end_of_day : timestamp.beginning_of_day
  rescue ArgumentError, TypeError
    nil
  end

  def metadata_value(key)
    (metadata || {}).with_indifferent_access[key]
  end

  def write_metadata_value(key, value)
    merged = (metadata || {}).with_indifferent_access.merge(key => value)
    self.metadata = merged
  end

  def self.certificate_number_sql
    "COALESCE((#{table_name}.metadata ->> 'certificate_number'), '')"
  end
end
