# frozen_string_literal: true

module Payments
  class CashPaymentRecorder
    SettlementError = Class.new(StandardError)

    def initialize(registration:, admin_user:, amount_cents:, currency:, notes: nil)
      @registration = registration
      @admin_user = admin_user
      @amount_cents = parse_amount_cents(amount_cents)
      @currency = currency.presence || registration.currency
      @notes = notes
    end

    def record!
      TemplePayment.transaction do
        @registration = registration.class.lock.find(registration.id)
        validate_settlement!
        completed_at = Time.current
        ledger_entry = create_ledger_entry!
        payment = create_payment!(ledger_entry, completed_at:)
        registration.mark_paid!

        SystemAuditLogger.log!(
          action: "temple.payment.cash_recorded",
          admin: admin_user,
          target: payment,
          metadata: {
            amount_cents: amount_cents,
            currency: currency,
            registration_id: registration.id
          },
          temple: registration.temple
        )

        payment
      end
    end

    private

    attr_reader :registration, :admin_user, :amount_cents, :currency, :notes

    def validate_settlement!
      raise SettlementError, "Cash settlement permission is required" unless cash_permission?
      raise SettlementError, "Cash settlement must use the registration total" unless amount_cents == registration.total_price_cents
      raise SettlementError, "Cash settlement must use the registration currency" unless currency == registration.currency
      raise SettlementError, "Cash settlement is not available for this registration" unless eligible_registration?
      raise SettlementError, "Cash settlement already exists" if registration.temple_payments.completed.where(provider: "manual_cash").exists?
      # Same gate as online checkout (Temple#registration_intake_frozen?):
      # intake is never blocked, but neither payment path -- online or
      # cash -- can settle while the temple's own billing is frozen.
      # Registrations simply stay pending until it clears.
      raise SettlementError, "Cash settlement is not available right now" if registration.temple.registration_intake_frozen?
    end

    def parse_amount_cents(value)
      return value if value.is_a?(Integer)
      return Integer(value, 10) if value.is_a?(String) && /\A\d+\z/.match?(value)

      raise SettlementError, "Cash settlement amount must be a whole number of cents"
    rescue ArgumentError
      raise SettlementError, "Cash settlement amount must be a whole number of cents"
    end

    def cash_permission?
      admin_account = admin_user&.admin_account
      AdminPermission.find_by(admin_account:, temple: registration.temple)&.allow?(:record_cash_payments)
    end

    def eligible_registration?
      registration.payment_status == TempleRegistration::PAYMENT_STATUSES[:pending] &&
        registration.fulfillment_status == TempleRegistration::FULFILLMENT_STATUSES[:open] &&
        registration.total_price_cents.to_i.positive?
    end

    def create_payment!(ledger_entry, completed_at:)
      attrs = {
        temple: registration.temple,
        user: registration.user,
        admin_account: admin_user&.admin_account,
        provider: "manual_cash",
        provider_account: "temple",
        payment_method: TemplePayment::PAYMENT_METHODS[:cash],
        status: TemplePayment::STATUSES[:completed],
        amount_cents: amount_cents,
        currency: currency,
        processed_at: completed_at,
        payment_payload: payment_payload,
        metadata: {}
      }
      attrs[:financial_ledger_entry] = ledger_entry if TemplePayment.column_names.include?("financial_ledger_entry_id")

      registration.temple_payments.create!(attrs)
    end

    def create_ledger_entry!
      FinancialLedgerEntry.create!(
        user: registration.user,
        entry_type: "temple_offering_sale",
        currency: currency,
        country_code: "TW",
        amount: cents_to_decimal(amount_cents),
        tax_amount: 0,
        status: "posted",
        external_reference: external_reference,
        entry_date: Time.current.to_date,
        user_name_snapshot: registration.user&.english_name,
        user_email_snapshot: registration.user&.email,
        details: {
          registration_id: registration.id,
          offering_id: registration.registrable_id,
          payment_method: "cash"
        },
        metadata: {
          recorded_by_admin_id: admin_user&.admin_account&.id
        }
      )
    end

    def cents_to_decimal(cents)
      BigDecimal(cents) / 100
    end

    def external_reference
      registration.reference_code
    end

    def payment_payload
      payload = {}
      payload[:notes] = notes if notes.present?
      payload
    end
  end
end
