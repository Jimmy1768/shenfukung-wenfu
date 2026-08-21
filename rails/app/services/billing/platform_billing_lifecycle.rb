# frozen_string_literal: true

module Billing
  class PlatformBillingLifecycle
    OVERDUE_WINDOW = 7.days
    GRACE_WINDOW = 14.days

    def self.record_success!(...) = new(...).record_success!
    def self.record_failure!(...) = new(...).record_failure!
    def self.advance!(...) = new(...).advance!

    def initialize(delivery:, now: Time.current)
      @delivery = delivery
      @now = now
    end

    def record_success!
      transition!("paid", grace_deadline_at: nil)
    end

    def record_failure!
      transition!("overdue", due_at: now + OVERDUE_WINDOW, grace_deadline_at: now + OVERDUE_WINDOW + GRACE_WINDOW)
    end

    def advance!
      delivery.transaction do
        if delivery.status == "overdue" && delivery.due_at.present? && delivery.due_at <= now
          transition!("grace")
        elsif delivery.status == "grace" && delivery.grace_deadline_at.present? && delivery.grace_deadline_at <= now
          transition!("frozen")
        end
      end

      delivery
    end

    private

    attr_reader :delivery, :now

    def transition!(status, attributes = {})
      return false if delivery.status == status

      previous_status = delivery.status
      delivery.update!(**attributes.merge(status:))
      SystemAuditLogger.log!(action: "platform_billing.delivery_transition", target: delivery, temple: delivery.temple,
        metadata: { delivery_id: delivery.id, from: previous_status, to: status, reference_time: now.iso8601 })
      suspend_entitlement!(delivery) if status == "frozen"
      true
    end

    def suspend_entitlement!(delivery)
      return if delivery.temple.platform_billing_entitlement.blank?

      PlatformBillingEntitlementTransition.transition!(
        temple: delivery.temple,
        delivery:,
        state: "suspended",
        occurred_at: now
      )
    end
  end
end
