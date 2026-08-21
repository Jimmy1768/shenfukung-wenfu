# frozen_string_literal: true

module Billing
  class PlatformUsage
    TIME_ZONE = ActiveSupport::TimeZone["Asia/Taipei"]

    QualifyingRegistration = Data.define(:registration, :qualifying_at, :qualification_source)
    Result = Data.define(:period_start_at, :period_end_at, :registrations, :quote)

    # The calendar month a reference time's billing cycle covers: the month
    # prior to whatever month reference_time itself falls in. Both the
    # monthly-review job (which closes this month) and the monthly-collection
    # job (which must dispatch only deliveries from this exact month, not an
    # unbounded backlog) need this same value -- centralized here so the two
    # can't silently drift out of sync with each other.
    def self.previous_month(reference_time)
      reference_time.in_time_zone(TIME_ZONE).to_date.beginning_of_month.prev_month
    end

    def self.period_start_at_for(month)
      date = month.to_date
      TIME_ZONE.local(date.year, date.month, 1).beginning_of_day
    end

    def self.for_month(temple:, month: TIME_ZONE.today)
      period_start_at = period_start_at_for(month)
      period_end_at = period_start_at + 1.month
      registrations = qualifying_registrations(temple:)
        .select { |entry| entry.qualifying_at >= period_start_at && entry.qualifying_at < period_end_at }
        .sort_by { |entry| [entry.qualifying_at, entry.registration.id] }

      Result.new(
        period_start_at:,
        period_end_at:,
        registrations:,
        quote: PlatformPricingPolicy.quote(registrations.count)
      )
    end

    def self.qualifying_registrations(temple:)
      temple.temple_registrations.includes(:temple_payments).filter_map do |registration|
        qualification = qualification_for(registration, temple:)
        next unless qualification

        qualifying_at, qualification_source = qualification
        QualifyingRegistration.new(registration:, qualifying_at:, qualification_source:)
      end
    end

    def self.qualification_for(registration, temple:)
      return nil unless registration.temple_id == temple.id
      return nil if ineligible_reason(registration).present?

      if registration.no_payment_required?
        return [registration.created_at, "free_registration"]
      end

      return nil unless registration.payment_status == TempleRegistration::PAYMENT_STATUSES[:paid]

      completed_payment = registration.temple_payments
        .select { |payment| payment.temple_id == temple.id && payment.completed? }
        .min_by { |payment| [payment.processed_at || payment.created_at, payment.id] }
      return nil unless completed_payment

      [completed_payment.processed_at || completed_payment.created_at, "completed_#{completed_payment.payment_method}"]
    end

    def self.ineligible_reason(registration)
      return "cancelled" if registration.fulfillment_status == TempleRegistration::FULFILLMENT_STATUSES[:cancelled]
      return "refunded" if registration.payment_status == TempleRegistration::PAYMENT_STATUSES[:refunded]
      return "failed" if registration.payment_status == TempleRegistration::PAYMENT_STATUSES[:failed]

      nil
    end
  end
end
