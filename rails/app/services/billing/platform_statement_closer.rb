# frozen_string_literal: true

module Billing
  class PlatformStatementCloser
    Result = Data.define(:statement, :created)

    def self.close(...)
      new(...).close
    end

    def initialize(temple:, month: Billing::PlatformUsage::TIME_ZONE.today, closed_at: Time.current)
      @temple = temple
      @month = month
      @closed_at = closed_at
    end

    def close
      usage = nil
      temple.with_lock do
        usage = PlatformUsage.for_month(temple:, month:)
        raise ArgumentError, "Billing period is not closed yet" if usage.period_end_at > closed_at

        existing = temple.platform_billing_statements.find_by(period_start_at: usage.period_start_at)
        return Result.new(statement: existing, created: false) if existing

        statement = nil
        PlatformBillingStatement.transaction do
          statement = temple.platform_billing_statements.create!(statement_attributes(usage))
          usage.registrations.each do |qualifying_registration|
            registration = qualifying_registration.registration
            statement.platform_billing_usage_records.create!(
              temple:,
              temple_registration: registration,
              registration_created_at: registration.created_at,
              qualifying_at: qualifying_registration.qualifying_at,
              qualification_source: qualifying_registration.qualification_source,
              unit_fee_cents: 0,
              eligibility_snapshot: {
                payment_status: registration.payment_status,
                fulfillment_status: registration.fulfillment_status,
                total_price_cents: registration.total_price_cents,
                qualifying_at: qualifying_registration.qualifying_at.iso8601,
                qualification_source: qualifying_registration.qualification_source
              }
            )
          end
          apply_prior_period_credits!(statement)
          statement.refresh_adjustment_total!
        end

        Result.new(statement:, created: true)
      end
    rescue ActiveRecord::RecordNotUnique
      statement = temple.platform_billing_statements.find_by(period_start_at: usage&.period_start_at)
      return Result.new(statement:, created: false) if statement

      raise
    end

    private

    attr_reader :temple, :month, :closed_at

    def statement_attributes(usage)
      quote = usage.quote
      {
        period_start_at: usage.period_start_at,
        period_end_at: usage.period_end_at,
        pricing_policy_version: PlatformPricingPolicy::VERSION,
        currency: PlatformPricingPolicy::CURRENCY,
        status: "closed",
        idempotency_key: "#{PlatformPricingPolicy::VERSION}:#{temple.id}:#{usage.period_start_at.to_date.iso8601}",
        registration_count: quote.registration_count,
        included_registration_count: quote.included_registration_count,
        band_one_registration_count: quote.band_one_registration_count,
        band_two_registration_count: quote.band_two_registration_count,
        band_three_registration_count: quote.band_three_registration_count,
        base_fee_cents: quote.base_fee_cents,
        band_one_fee_cents: quote.band_one_fee_cents,
        band_two_fee_cents: quote.band_two_fee_cents,
        band_three_fee_cents: quote.band_three_fee_cents,
        usage_total_cents: quote.usage_total_cents,
        total_cents: quote.usage_total_cents,
        closed_at:,
        metadata: { billing_time_zone: PlatformUsage::TIME_ZONE.name }
      }
    end

    def apply_prior_period_credits!(statement)
      temple.platform_billing_usage_records
        .includes(:platform_billing_statement, :temple_registration)
        .where("platform_billing_statements.period_end_at <= ?", statement.period_start_at)
        .joins(:platform_billing_statement)
        .find_each do |usage_record|
          reason = PlatformUsage.ineligible_reason(usage_record.temple_registration)
          next if reason.blank?
          next if PlatformBillingAdjustment.exists?(platform_billing_usage_record: usage_record)

          source_statement = usage_record.platform_billing_statement
          next unless source_statement.temple_id == temple.id && usage_record.temple_id == temple.id && usage_record.temple_registration.temple_id == temple.id

          effective_count = source_statement.registration_count + PlatformBillingAdjustment
            .where(source_platform_billing_statement: source_statement)
            .sum(:registration_count_delta)
          next if effective_count <= 0

          amount_cents = progressive_adjustment_amount(effective_count)
          raise "Platform billing correction must not increase the source quote" if amount_cents.positive?

          statement.platform_billing_adjustments.create!(
            source_platform_billing_statement: source_statement,
            platform_billing_usage_record: usage_record,
            temple:,
            temple_registration: usage_record.temple_registration,
            reason:,
            registration_count_delta: -1,
            amount_cents:,
            recognized_at: closed_at,
            metadata: {
              source_period_start_at: source_statement.period_start_at.iso8601,
              source_registration_count_before_correction: effective_count,
              source_registration_count_after_correction: effective_count - 1
            }
          )
        end
    end

    def progressive_adjustment_amount(effective_count)
      quote_before = PlatformPricingPolicy.quote(effective_count).usage_total_cents
      quote_after = PlatformPricingPolicy.quote(effective_count - 1).usage_total_cents
      quote_after - quote_before
    end
  end
end
