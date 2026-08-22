# frozen_string_literal: true

# First phase of the two-phase monthly billing schedule: closes the prior
# month's statement for every temple and creates the (still-pending) monthly
# delivery. Deliberately does not collect/charge -- that is
# PlatformBillingMonthlyCollectionJob's job, run separately a few days later,
# so a mistake caught in this window can be fixed before any charge fires.
#
# Idempotent and safe to re-run: Billing::PlatformStatementCloser and
# Billing::PlatformBillingDeliveryCreator both find-or-create per (temple,
# month), so re-running this job for a month that's already been reviewed is
# a no-op for temples that already succeeded.
#
# Only runs against real clients (Temple.platform_billing_adopted --
# temples that have actually adopted platform billing, not demo/seed/
# synthetic temples that never onboarded to it). If none exist yet, the
# whole run is a deliberate, logged no-op rather than iterating every
# Temple row in the database for nothing.
class PlatformBillingMonthlyReviewJob < ActiveJob::Base
  queue_as :default

  def perform(reference_time: Time.current)
    month = Billing::PlatformUsage.previous_month(reference_time)
    temples = Temple.platform_billing_adopted

    if temples.none?
      SystemAuditLogger.log!(action: "platform_billing.monthly_review_skipped",
        metadata: { reason: "no_real_clients", month: month.iso8601 })
      return
    end

    temples.find_each do |temple|
      result = Billing::PlatformStatementCloser.close(temple:, month:, closed_at: reference_time)
      Billing::PlatformBillingDeliveryCreator.create_monthly!(statement: result.statement)
    rescue StandardError => e
      SystemAuditLogger.log!(action: "platform_billing.monthly_review_failed", target: temple, temple:,
        metadata: { error_class: e.class.name, message: e.message.to_s.truncate(200), month: month.iso8601 })
    end
  end
end
