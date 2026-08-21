# frozen_string_literal: true

# Second phase of the two-phase monthly billing schedule: dispatches
# (collects/charges) the monthly delivery review left pending for the exact
# billing period reference_time resolves to -- run a few days after review
# on a separate schedule, so mistakes caught in the gap between the two can
# be fixed before a charge fires.
#
# Scoped to exactly one period (via Billing::PlatformUsage.previous_month,
# the same computation the review job uses, so reference_time means the
# same thing in both jobs) rather than "every pending monthly delivery that
# has ever existed". Without that scoping, the first real run after any gap
# in scheduling (including first activation) would collect every
# never-collected delivery across every past month in one pass -- exactly
# the unbounded backlog charge this two-phase design exists to prevent.
#
# Billing::PlatformBillingCollectionDispatcher already no-ops on anything
# that isn't a pending monthly delivery and swallows/logs its own collection
# failures, so this job stays a thin per-delivery loop.
class PlatformBillingMonthlyCollectionJob < ActiveJob::Base
  queue_as :default

  def perform(reference_time: Time.current)
    month = Billing::PlatformUsage.previous_month(reference_time)
    period_start_at = Billing::PlatformUsage.period_start_at_for(month)

    PlatformBillingDelivery.monthly.where(status: "pending", period_start_at:).find_each do |delivery|
      Billing::PlatformBillingCollectionDispatcher.dispatch!(delivery:)
    rescue StandardError => e
      SystemAuditLogger.log!(action: "platform_billing.monthly_collection_failed", target: delivery, temple: delivery.temple,
        metadata: { error_class: e.class.name, message: e.message.to_s.truncate(200), delivery_id: delivery.id,
                    reference_time: reference_time.iso8601 })
    end
  end
end
