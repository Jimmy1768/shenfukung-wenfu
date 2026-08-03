# frozen_string_literal: true

module Billing
  class PlatformBillingLifecycle
    OVERDUE_WINDOW = 7.days
    GRACE_WINDOW = 30.days

    def self.record_failure!(...) = new(...).record_failure!
    def self.advance!(...) = new(...).advance!

    def initialize(delivery:, now: Time.current)
      @delivery = delivery
      @now = now
    end

    def record_failure!
      transition!("overdue", due_at: now + OVERDUE_WINDOW, grace_deadline_at: now + OVERDUE_WINDOW + GRACE_WINDOW)
    end

    def advance!
      return delivery if delivery.status == "overdue" && delivery.due_at.present? && delivery.due_at <= now && transition!("grace")
      return delivery if delivery.status == "grace" && delivery.grace_deadline_at.present? && delivery.grace_deadline_at <= now && transition!("frozen")

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
      true
    end
  end
end
