# frozen_string_literal: true

# Second phase of the two-phase monthly billing schedule: dispatches
# (collects/charges) every monthly delivery left pending by
# PlatformBillingMonthlyReviewJob, run a few days after review on a
# separate schedule -- so mistakes caught in the gap between the two can be
# fixed before a charge fires.
#
# Billing::PlatformBillingCollectionDispatcher already no-ops on anything
# that isn't a pending monthly delivery and swallows/logs its own collection
# failures, so this job stays a thin per-delivery loop.
class PlatformBillingMonthlyCollectionJob < ActiveJob::Base
  queue_as :default

  def perform(reference_time: Time.current)
    PlatformBillingDelivery.monthly.where(status: "pending").find_each do |delivery|
      Billing::PlatformBillingCollectionDispatcher.dispatch!(delivery:)
    rescue StandardError => e
      SystemAuditLogger.log!(action: "platform_billing.monthly_collection_failed", target: delivery, temple: delivery.temple,
        metadata: { error_class: e.class.name, message: e.message.to_s.truncate(200), delivery_id: delivery.id,
                    reference_time: reference_time.iso8601 })
    end
  end
end
