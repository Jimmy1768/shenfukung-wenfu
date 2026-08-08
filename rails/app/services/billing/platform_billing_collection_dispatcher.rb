# frozen_string_literal: true

module Billing
  class PlatformBillingCollectionDispatcher
    def self.dispatch!(...) = new(...).dispatch!

    def initialize(delivery:)
      @delivery = delivery
    end

    def dispatch!
      return delivery unless delivery.kind == "monthly" && delivery.status == "pending"

      raise ArgumentError, "Only TWD monthly deliveries can be collected" unless delivery.currency == "TWD"

      StripePlatformBillingCollection.collect!(delivery:)
    rescue StandardError => e
      SystemAuditLogger.log!(action: "platform_billing.collection_failed", target: delivery, temple: delivery.temple,
        metadata: { delivery_id: delivery.id, error_class: e.class.name, message: e.message.to_s.truncate(200) })
      delivery
    end

    private

    attr_reader :delivery
  end
end
