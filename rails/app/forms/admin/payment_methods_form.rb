# frozen_string_literal: true

module Admin
  class PaymentMethodsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    ECPAY_ENVIRONMENTS = %w[stage production].freeze
    DEFAULT_ECPAY_PORTAL_URL = "https://login.ecpay.com.tw/Login?Mode=1&NextURL=https%3A%2F%2Fcashier.ecpay.com.tw%2Fmanage%2Flogin%2Fecpay%2Fcallback"

    attribute :ecpay_merchant_id, :string
    attribute :ecpay_hash_key, :string
    attribute :ecpay_hash_iv, :string
    attribute :ecpay_environment, :string

    validates :ecpay_environment, inclusion: { in: ECPAY_ENVIRONMENTS }, allow_blank: true

    attr_reader :temple

    def initialize(temple:, params: nil)
      @temple = temple
      super(params.presence || extracted_attributes)
    end

    def save(current_admin:)
      return false unless valid?

      previous_snapshot = persisted_snapshot
      temple.assign_attributes(
        payment_mode: temple.payment_mode.presence || "temple",
        payment_provider_settings: merged_provider_settings
      )

      Temple.transaction do
        temple.save!
        SystemAuditLogger.log!(
          action: "admin.payment_methods.updated",
          admin: current_admin,
          target: temple,
          temple: temple,
          metadata: {
            changed_fields: changed_fields(previous_snapshot, snapshot_for_audit),
            ecpay_configured: ecpay_configured?,
            platform_billing_state: temple.platform_billing_state
          }
        )
      end

      true
    rescue ActiveRecord::RecordInvalid => e
      errors.merge!(e.record.errors)
      false
    end

    def ecpay_environment_options
      ECPAY_ENVIRONMENTS.map { |value| [value.titleize, value] }
    end

    def ecpay_configured?
      ecpay_merchant_id.present? && ecpay_hash_key.present? && ecpay_hash_iv.present?
    end

    def stripe_billing_configured?
      Rails.configuration.x.stripe.secret_key.present?
    end

    def billing_card_label
      brand = temple.billing_settings["card_brand"].to_s.titleize.presence
      last4 = temple.billing_settings["card_last4"].presence
      return nil if brand.blank? || last4.blank?

      "#{brand} ending in #{last4}"
    end

    def billing_portal_url
      temple.billing_portal_url
    end

    def billing_monthly_fee_cents
      Billing::PlatformPricingPolicy::BASE_FEE_CENTS
    end

    def billing_monthly_fee_label
      Currency::Symbols.format_amount(billing_monthly_fee_cents, "TWD")
    end

    def billing_onboarding_fee_cents
      Billing::PlatformPricingPolicy::SETUP_FEE_CENTS
    end

    def billing_onboarding_fee_label
      Currency::Symbols.format_amount(billing_onboarding_fee_cents, "TWD")
    end

    # Compact tier summary for the hover-detail panel. The full live
    # breakdown (this month's actual counts/subtotals) already has its
    # own page -- Admin::PlatformBillingController#show -- so this only
    # needs the static rate structure, not usage data.
    def billing_usage_tiers
      policy = Billing::PlatformPricingPolicy
      [
        { range: I18n.t("admin.payment_methods.sections.payment_method.notes.tiers.included_range", count: delimited(policy::INCLUDED_REGISTRATIONS)), unit_fee: I18n.t("admin.payment_methods.sections.payment_method.notes.tiers.included_fee") },
        { range: I18n.t("admin.payment_methods.sections.payment_method.notes.tiers.band_range", from: delimited(policy::INCLUDED_REGISTRATIONS + 1), to: delimited(policy::BAND_ONE_LIMIT)), unit_fee: unit_fee_label(policy::BAND_ONE_UNIT_FEE_CENTS) },
        { range: I18n.t("admin.payment_methods.sections.payment_method.notes.tiers.band_range", from: delimited(policy::BAND_ONE_LIMIT + 1), to: delimited(policy::BAND_TWO_LIMIT)), unit_fee: unit_fee_label(policy::BAND_TWO_UNIT_FEE_CENTS) },
        { range: I18n.t("admin.payment_methods.sections.payment_method.notes.tiers.band_three_range", from: delimited(policy::BAND_TWO_LIMIT + 1)), unit_fee: unit_fee_label(policy::BAND_THREE_UNIT_FEE_CENTS) }
      ]
    end

    # The Stripe entitlement flow's overdue -> grace -> frozen window
    # (Billing::PlatformBillingLifecycle), not Temple#billing_grace_days --
    # that's a separate, legacy grace mechanism for temples with no
    # platform billing entitlement at all (see Temple#payment_settlement_frozen?).
    # This page is entirely about the entitlement flow, so it must describe
    # and count down that flow's own window, not the legacy one.
    def billing_overdue_window_days
      Billing::PlatformBillingLifecycle::OVERDUE_WINDOW.in_days.to_i
    end

    def billing_grace_window_days
      Billing::PlatformBillingLifecycle::GRACE_WINDOW.in_days.to_i
    end

    def billing_total_grace_days
      billing_overdue_window_days + billing_grace_window_days
    end

    def current_monthly_delivery
      @current_monthly_delivery ||= temple.platform_billing_deliveries.monthly.order(created_at: :desc).first
    end

    # Real days remaining until this delivery's own next deadline
    # (PlatformBillingDelivery#due_at while overdue, #grace_deadline_at
    # while in grace) -- nil when there's no live countdown to show
    # (no delivery, or not currently overdue/in grace).
    def billing_days_remaining_in_current_phase
      delivery = current_monthly_delivery
      return nil unless delivery

      deadline =
        case delivery.status
        when "overdue" then delivery.due_at
        when "grace" then delivery.grace_deadline_at
        end
      return nil unless deadline

      [(deadline - Time.current).fdiv(1.day).ceil, 0].max
    end

    def online_payments_frozen?
      temple.platform_billing_state == "frozen"
    end

    def online_payments_state
      return :setup_needed unless ecpay_configured?

      case temple.platform_billing_state
      when "current"
        :active
      when "overdue"
        :overdue
      when "grace"
        :grace_period
      when "frozen"
        :frozen
      else
        :setup_needed
      end
    end

    def billing_payment_method_on_file?
      temple.billing_settings["stripe_payment_method_id"].present?
    end

    def online_payments_status_i18n_key
      case online_payments_state
      when :setup_needed
        "setup_incomplete"
      when :active
        "active"
      when :overdue
        "billing_overdue"
      when :frozen
        "frozen"
      else
        "grace_period"
      end
    end

    def online_payments_status_i18n_options
      return {} unless online_payments_state == :grace_period

      { days: billing_days_remaining_in_current_phase || billing_total_grace_days }
    end

    def online_payments_status_tone
      case online_payments_state
      when :setup_needed
        "neutral"
      when :active
        "success"
      when :frozen
        "danger"
      else
        "warning"
      end
    end

    def ecpay_status_i18n_key
      ecpay_configured? ? "ready_to_test" : "setup_needed"
    end

    def ecpay_status_tone
      ecpay_configured? ? "success" : "warning"
    end

    def ecpay_portal_url
      ENV.fetch("ECPAY_PORTAL_URL", DEFAULT_ECPAY_PORTAL_URL).to_s
    end

    private

    def delimited(number)
      ActiveSupport::NumberHelper.number_to_delimited(number)
    end

    def unit_fee_label(cents)
      Currency::Symbols.format_unit_rate(cents, Billing::PlatformPricingPolicy::CURRENCY)
    end

    def extracted_attributes
      ecpay = temple.payment_gateway_settings_for(:ecpay)

      {
        ecpay_merchant_id: ecpay["merchant_id"],
        ecpay_hash_key: ecpay["hash_key"],
        ecpay_hash_iv: ecpay["hash_iv"],
        ecpay_environment: ecpay["environment"].presence || Rails.configuration.x.ecpay.environment.to_s,
      }
    end

    def persisted_snapshot
      self.class.new(temple: temple).send(:snapshot_for_audit)
    end

    def merged_provider_settings
      base = temple.payment_provider_settings.is_a?(Hash) ? temple.payment_provider_settings.deep_dup : {}
      base["ecpay"] = compact_hash(
        "merchant_id" => ecpay_merchant_id,
        "hash_key" => ecpay_hash_key,
        "hash_iv" => ecpay_hash_iv,
        "environment" => ecpay_environment
      )
      base
    end

    def billing_grace_started_at_value
      temple.billing_grace_started_at&.iso8601
    end

    def compact_hash(hash)
      hash.each_with_object({}) do |(key, value), result|
        normalized = value.is_a?(String) ? value.strip.presence : value
        next if normalized.nil?

        result[key] = normalized
      end
    end

    def snapshot_for_audit
      {
        ecpay: compact_hash(
          "merchant_id" => ecpay_merchant_id,
          "hash_key" => ecpay_hash_key,
          "hash_iv" => ecpay_hash_iv,
          "environment" => ecpay_environment
        ),
        billing: temple.billing_settings
      }
    end

    def changed_fields(before_snapshot, after_snapshot)
      before_snapshot.each_with_object([]) do |(key, value), changed|
        changed << key.to_s if value != after_snapshot[key]
      end
    end
  end
end
