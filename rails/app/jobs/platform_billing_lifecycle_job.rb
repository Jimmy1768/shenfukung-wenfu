# frozen_string_literal: true

class PlatformBillingLifecycleJob < ActiveJob::Base
  queue_as :default

  def perform(reference_time: Time.current)
    PlatformBillingDelivery.where(status: %w[overdue grace]).find_each do |delivery|
      Billing::PlatformBillingLifecycle.advance!(delivery:, now: reference_time)
    end
  end
end
