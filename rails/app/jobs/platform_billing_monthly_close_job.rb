# frozen_string_literal: true

class PlatformBillingMonthlyCloseJob < ActiveJob::Base
  queue_as :default

  def perform(reference_time: Time.current)
    zone = Billing::PlatformUsage::TIME_ZONE
    month = reference_time.in_time_zone(zone).to_date.beginning_of_month.prev_month
    Temple.find_each do |temple|
      result = Billing::PlatformStatementCloser.close(temple:, month:, closed_at: reference_time)
      delivery = Billing::PlatformBillingDeliveryCreator.create_monthly!(statement: result.statement)
      Billing::PlatformBillingCollectionDispatcher.dispatch!(delivery:)
    rescue StandardError => e
      SystemAuditLogger.log!(action: "platform_billing.monthly_close_failed", target: temple, temple:,
        metadata: { error_class: e.class.name, message: e.message.to_s.truncate(200), month: month.iso8601 })
    end
  end
end
