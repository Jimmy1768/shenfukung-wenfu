# frozen_string_literal: true

module Billing
  class StripePlatformBillingEventIngest
    def self.ingest!(...) = new(...).ingest!

    def initialize(event:, now: Time.current)
      @event, @now = event, now
    end

    def ingest!
      existing = PlatformBillingEvent.find_by(provider_event_id: event.id)
      return existing if existing
      object = event.data.object
      metadata = object.metadata || {}
      temple = Temple.find_by(id: metadata["temple_id"] || object.client_reference_id)
      raise ArgumentError, "Platform event temple is missing" if temple.blank?
      delivery = temple.platform_billing_deliveries.find_by(id: metadata["delivery_id"])
      raise ArgumentError, "Platform event delivery does not match temple" if delivery.blank? || !provider_match?(delivery, object)

      PlatformBillingEvent.transaction do
        record = PlatformBillingEvent.create!(temple:, platform_billing_delivery: delivery, provider_event_id: event.id,
          event_type: event.type, payload: sanitized_payload(object, metadata))
        transition!(delivery, event.type, record)
        record
      end
    rescue ActiveRecord::RecordNotUnique
      PlatformBillingEvent.find_by!(provider_event_id: event.id)
    end

    private

    attr_reader :event, :now
    def provider_match?(delivery, object)
      reference = object.respond_to?(:id) ? object.id : object["id"]
      delivery.provider_reference.blank? || delivery.provider_reference == reference
    end
    def transition!(delivery, type, record)
      case type
      when "checkout.session.completed", "invoice.paid", "invoice.payment_succeeded"
        PlatformBillingLifecycle.record_success!(delivery:, now:)
        activate_entitlement!(delivery, record)
      when "invoice.payment_failed", "invoice.payment_action_required"
        PlatformBillingLifecycle.record_failure!(delivery:, now:)
      end
      SystemAuditLogger.log!(action: "platform_billing.event_processed", target: delivery, temple: delivery.temple,
        metadata: { delivery_id: delivery.id, event_type: type, status: delivery.status })
    end

    def activate_entitlement!(delivery, record)
      return if delivery.temple.platform_billing_entitlement.blank?

      PlatformBillingEntitlementTransition.transition!(
        temple: delivery.temple,
        delivery:,
        event: record,
        state: "active",
        occurred_at: now
      )
    end
    def sanitized_payload(object, metadata)
      { object_id: object.respond_to?(:id) ? object.id : object["id"], customer: object.respond_to?(:customer) ? object.customer : nil,
        metadata: metadata.slice("temple_id", "delivery_id", "purpose") }.compact
    end
  end
end
