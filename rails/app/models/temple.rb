# frozen_string_literal: true

class Temple < ApplicationRecord
  has_many :temple_pages,
    inverse_of: :temple,
    dependent: :destroy
  has_many :temple_sections,
    through: :temple_pages
  has_many :temple_offering_setup_drafts,
    dependent: :destroy
  has_many :media_assets,
    dependent: :destroy
  has_many :admin_temple_memberships,
    dependent: :destroy
  has_many :admin_accounts,
    through: :admin_temple_memberships
  has_many :system_audit_logs,
    dependent: :nullify
  has_many :temple_events,
    dependent: :destroy
  has_many :temple_assistance_requests,
    dependent: :destroy
  has_many :temple_services,
    dependent: :destroy
  has_many :temple_gatherings,
    dependent: :destroy
  has_many :temple_offerings,
    class_name: "TempleEvent",
    dependent: :destroy
  has_many :temple_registrations,
    dependent: :destroy
  has_many :temple_event_registrations,
    class_name: "TempleEventRegistration",
    dependent: :destroy
  has_many :temple_payments,
    through: :temple_registrations
  has_many :platform_billing_statements,
    dependent: :restrict_with_exception
  has_many :platform_billing_usage_records,
    dependent: :restrict_with_exception
  has_many :platform_billing_adjustments,
    dependent: :restrict_with_exception
  has_many :platform_billing_deliveries, dependent: :restrict_with_exception
  has_many :platform_billing_events, dependent: :restrict_with_exception
  has_one :platform_billing_entitlement, dependent: :restrict_with_exception
  has_many :admin_permissions,
    dependent: :destroy
  has_many :temple_news_posts,
    dependent: :destroy
  has_many :temple_gallery_entries,
    dependent: :destroy

  scope :published, -> { where(published: true) }
  scope :for_admin, lambda { |admin_account|
    joins(:admin_temple_memberships)
      .where(admin_temple_memberships: { admin_account_id: admin_account.id })
      .distinct
  }
  # A real, billable platform-billing client: entitlement present AND past
  # "pending_setup" (i.e. active or suspended -- has actually completed the
  # Stripe setup checkout at some point). Demo/seed/synthetic temples never
  # adopt at all, so they're excluded by the join alone; a temple that
  # started onboarding but never finished (pending_setup, no payment method
  # on file, nothing for Stripe to actually charge) is excluded too --
  # deliberately, so an incomplete or demo-purposed setup attempt can't
  # silently make the monthly billing jobs treat it as a real client. This
  # is the real-client signal the monthly billing jobs use to skip
  # everything else without needing a separate "is this temple real" flag.
  scope :platform_billing_adopted, -> {
    joins(:platform_billing_entitlement)
      .where.not(platform_billing_entitlements: { state: "pending_setup" })
  }

  validates :slug, :name, presence: true

  # One hero per page of the public site, ordered to match its nav
  # (vue/src/components/site/SiteHeader.vue navItems) so the admin reads in the
  # same sequence a visitor sees.
  PAGE_HERO_TABS = %w[home about news services events archive contact].freeze

  # NOT a page. This is the picture an event detail page falls back to when
  # that event has no hero_image_url of its own, so it is presented in its own
  # section of the admin rather than as an eighth page tab -- calling it a page
  # is what made the count look wrong (seven nav buttons, eight tabs).
  EVENT_FALLBACK_TAB = "event"

  # The floor of the hero fallback chain. Nothing renders below this, so
  # every tab -- home included -- always resolves to something.
  DEFAULT_HERO_IMAGE = AppConstants::TempleProfilePlaceholders.default_hero_image

  # Every valid storage key. Kept whole because param slicing, upload
  # validation and the seed normalizer all gate on it; only the admin's
  # PRESENTATION is split.
  HERO_TABS = (PAGE_HERO_TABS + [EVENT_FALLBACK_TAB]).freeze

  def contact_details
    contact_info.presence || {}
  end

  def service_schedule
    service_times.presence || {}
  end

  def visit_info
    data = metadata.is_a?(Hash) ? metadata : {}
    info = data["visit_info"]
    info.is_a?(Hash) ? info : {}
  end

  def about_content
    data = metadata.is_a?(Hash) ? metadata : {}
    about = data["about"]
    about.is_a?(Hash) ? about : {}
  end

  def registration_periods
    data = metadata.is_a?(Hash) ? metadata : {}
    periods = Array(data["registration_periods"])
    periods.map do |entry|
      entry = entry.with_indifferent_access rescue { key: entry }
      {
        "key" => entry[:key] || entry["key"] || entry,
        "label_zh" => entry[:label_zh] || entry["label_zh"],
        "label_en" => entry[:label_en] || entry["label_en"]
      }.with_indifferent_access
    end
  end

  def registration_period_options(locale = I18n.locale)
    registration_periods.map do |entry|
      [registration_period_label(entry, locale), entry[:key]]
    end
  end

  def registration_period_keys
    registration_periods.map { |entry| entry[:key].to_s }.reject(&:blank?)
  end

  def registration_period_label(entry, locale = I18n.locale)
    entry = entry.with_indifferent_access
    case locale
    when :"zh-TW"
      entry[:label_zh].presence || entry[:label_en].presence || entry[:key]
    else
      entry[:label_en].presence || entry[:label_zh].presence || entry[:key]
    end
  end

  def registration_period_label_for(key, locale = I18n.locale)
    entry = registration_periods.find { |period| period[:key].to_s == key.to_s }
    entry ? registration_period_label(entry, locale) : key
  end

  def hero_images
    value = self[:hero_images]
    value.present? ? value.stringify_keys : {}
  end

  # ONE render path. hero_images[tab] is the only thing consulted when
  # rendering; a MediaAsset is the upload record (what file, when, by whom,
  # which storage key) and is never a lookup. Two representations both feeding
  # the read path is what made an uploaded hero impossible to remove -- the
  # admin cleared one and the other kept winning -- and it forced every new
  # consumer to remember both. Same shape TempleGathering already uses.
  #
  # The floor is applied here and never persisted, so "no image" is stored as
  # absent rather than as a placeholder URL. That is what removes the need to
  # recognise a placeholder by pattern.
  def hero_image_for(tab)
    tab_key = tab.to_s
    hero_images[tab_key].presence || hero_images["home"].presence || DEFAULT_HERO_IMAGE
  end

  # True when this tab has an image OF ITS OWN rather than inheriting the home
  # image -- so only then is there anything to remove.
  def hero_image_set?(tab)
    hero_images[tab.to_s].present?
  end

  def hero_images_with_fallback
    HERO_TABS.each_with_object({}) do |tab, buffer|
      buffer[tab] = hero_image_for(tab)
    end
  end

  def profile_complete?
    details = contact_details
    [name, tagline, hero_copy, details["phone"], details["mapUrl"]].all?(&:present?)
  end

  # Provenance lookup, used when unlinking or replacing an upload. Not on the
  # render path -- see hero_image_for.
  def hero_media_asset_for(tab)
    media_assets.hero.where("metadata ->> 'hero_tab' = ?", tab.to_s).first
  end

  def payment_gateway_settings_for(provider)
    settings = payment_provider_settings.is_a?(Hash) ? payment_provider_settings : {}
    value = settings[provider.to_s]
    value.is_a?(Hash) ? value.deep_stringify_keys : {}
  end

  def billing_settings
    payment_gateway_settings_for(:billing)
  end

  def billing_portal_url
    billing_settings["portal_url"].presence || ENV.fetch("BILLING_PORTAL_URL", nil).to_s.presence
  end

  def billing_payment_method_on_file?
    ActiveModel::Type::Boolean.new.cast(billing_settings["payment_method_on_file"])
  end

  def platform_billing_state(_reference_time = Time.current)
    entitlement = platform_billing_entitlement
    return "setup_needed" if entitlement&.state == "pending_setup"
    return "frozen" if entitlement&.state == "suspended"

    delivery = platform_billing_deliveries.monthly.order(created_at: :desc).first
    return "setup_needed" unless billing_settings["stripe_payment_method_id"].present?
    return "current" if delivery.blank? || delivery.paid?
    return delivery.status if %w[overdue grace frozen].include?(delivery.status)

    "current"
  end

  def billing_grace_days
    billing_settings["grace_days"].presence&.to_i || 30
  end

  def billing_grace_started_at
    raw = billing_settings["grace_started_at"].presence
    return nil if raw.blank?

    Time.zone.parse(raw)
  rescue ArgumentError
    nil
  end

  def billing_grace_deadline
    started_at = billing_grace_started_at
    return nil if started_at.blank?

    started_at + billing_grace_days.days
  end

  def billing_grace_remaining_days(reference_time = Time.current)
    deadline = billing_grace_deadline
    return nil if deadline.blank?

    remaining_seconds = deadline - reference_time
    return 0 if remaining_seconds <= 0

    (remaining_seconds / 1.day).ceil
  end

  def online_payments_frozen?(reference_time = Time.current)
    return false if billing_payment_method_on_file?

    deadline = billing_grace_deadline
    deadline.present? && deadline <= reference_time
  end

  # Whether this temple may currently SETTLE a patron payment -- online via
  # ECPay, or by an admin pressing "cash received". Both rails, deliberately:
  # blocking only the automated one would leave the manual one as a free
  # bypass for a delinquent temple.
  #
  # It does NOT gate registration intake. Creating a registration is data
  # entry, not a money-changing-hands step, and turning a temple's own
  # billing problem into a patron being told to come back later aims the
  # friction at the wrong person. Registrations are always created; they
  # simply stay pending until settlement is possible.
  #
  # Renamed from `registration_intake_frozen?` on 2026-08-30. That name
  # described what it did before intake and settlement were separated, and
  # by the time it was renamed every one of its call sites was a payment
  # site -- the name asserted the opposite of the behaviour.
  def payment_settlement_frozen?(reference_time = Time.current)
    return false if demo_registration_unlocked?

    entitlement = platform_billing_entitlement
    return !entitlement.active? if entitlement.present?

    online_payments_frozen?(reference_time)
  end

  # A narrow, explicit override for demo/sales temples that need to take
  # payment before (or without ever) completing platform billing setup --
  # e.g. a temple whose entitlement is sitting in "pending_setup" from an
  # earlier setup attempt, which would otherwise freeze settlement via
  # payment_settlement_frozen? above. Deliberately does not touch the
  # entitlement itself: unlocking this way must not make the temple look
  # like a real, onboarded billing client (see Temple.platform_billing_adopted).
  #
  # The setting key and rake task keep the `demo_registration_unlocked`
  # name: it is persisted in billing_settings on live records, so renaming
  # it is a data migration rather than a rename, and is not worth it.
  def demo_registration_unlocked?
    ActiveModel::Type::Boolean.new.cast(billing_settings["demo_registration_unlocked"])
  end

  def unlock_demo_registrations!
    update_billing_settings!("demo_registration_unlocked" => true)
    SystemAuditLogger.log!(action: "platform_billing.demo_registrations_unlocked", target: self, temple: self)
  end

  def lock_demo_registrations!
    update_billing_settings!("demo_registration_unlocked" => false)
    SystemAuditLogger.log!(action: "platform_billing.demo_registrations_locked", target: self, temple: self)
  end

  def adopt_platform_billing_entitlement!(adopted_at: Time.current)
    PlatformBillingEntitlement.transaction do
      entitlement = platform_billing_entitlement
      return entitlement if entitlement.present?

      entitlement = create_platform_billing_entitlement!(
        state: "pending_setup",
        adopted_at:,
        transitioned_at: adopted_at
      )
      SystemAuditLogger.log!(
        action: "platform_billing.entitlement_adopted",
        target: entitlement,
        temple: self,
        metadata: {
          entitlement_id: entitlement.id,
          state: entitlement.state,
          adopted_at: adopted_at.iso8601
        }
      )
      entitlement
    end
  rescue ActiveRecord::RecordNotUnique
    reload.platform_billing_entitlement || raise
  end

  def online_payments_hold_message(reference_time = Time.current)
    return nil if billing_payment_method_on_file?

    remaining_days = billing_grace_remaining_days(reference_time)
    return nil if remaining_days.blank?
    return "Online payments are paused until a payment method is added." if remaining_days.zero?

    "Add a payment method within #{remaining_days} days to keep online payments active."
  end

  private

  def update_billing_settings!(changes)
    base = payment_provider_settings.is_a?(Hash) ? payment_provider_settings.deep_dup : {}
    base["billing"] = (base["billing"].is_a?(Hash) ? base["billing"] : {}).merge(changes)
    update!(payment_provider_settings: base)
  end
end
