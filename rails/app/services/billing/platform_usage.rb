# frozen_string_literal: true

module Billing
  class PlatformUsage
    TIME_ZONE = ActiveSupport::TimeZone["Asia/Taipei"]

    Result = Data.define(:period_start_at, :period_end_at, :registrations, :quote)

    def self.for_month(temple:, month: TIME_ZONE.today)
      date = month.to_date
      period_start_at = TIME_ZONE.local(date.year, date.month, 1).beginning_of_day
      period_end_at = period_start_at + 1.month
      registrations = eligible_registrations(temple:, period_start_at:, period_end_at:).order(:created_at, :id)

      Result.new(
        period_start_at:,
        period_end_at:,
        registrations:,
        quote: PlatformPricingPolicy.quote(registrations.count)
      )
    end

    def self.eligible_registrations(temple:, period_start_at:, period_end_at:)
      temple.temple_registrations
        .where(created_at: period_start_at...period_end_at)
        .where.not(fulfillment_status: TempleRegistration::FULFILLMENT_STATUSES[:cancelled])
        .where(
          "#{TempleRegistration.table_name}.total_price_cents = 0 OR #{TempleRegistration.table_name}.payment_status = ?",
          TempleRegistration::PAYMENT_STATUSES[:paid]
        )
    end

    def self.ineligible_reason(registration)
      return "cancelled" if registration.fulfillment_status == TempleRegistration::FULFILLMENT_STATUSES[:cancelled]
      return "failed" if registration.payment_status == TempleRegistration::PAYMENT_STATUSES[:failed]
      return "refunded" if registration.payment_status == TempleRegistration::PAYMENT_STATUSES[:refunded]

      nil
    end
  end
end
