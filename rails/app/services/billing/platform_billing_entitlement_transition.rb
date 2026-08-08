# frozen_string_literal: true

module Billing
  class PlatformBillingEntitlementTransition
    class InvalidContextError < ArgumentError; end

    TRANSITION_STATES = %w[active suspended].freeze
    DELIVERY_STATUS_BY_STATE = {
      "active" => "paid",
      "suspended" => "frozen"
    }.freeze

    def self.transition!(...) = new(...).transition!

    def initialize(temple:, delivery:, state:, event: nil, occurred_at: Time.current)
      @temple = temple
      @delivery = delivery
      @state = state.to_s
      @event = event
      @occurred_at = occurred_at
    end

    def transition!
      validate_context!

      PlatformBillingEntitlement.transaction do
        entitlement = temple.platform_billing_entitlement
        raise InvalidContextError, "Temple has not adopted platform billing entitlement" if entitlement.blank?

        entitlement.lock!
        return entitlement if already_applied?(entitlement)

        previous_state = entitlement.state
        entitlement.update!(
          state:,
          transitioned_at: occurred_at,
          activated_at: state == "active" ? occurred_at : entitlement.activated_at,
          suspended_at: state == "suspended" ? occurred_at : entitlement.suspended_at,
          platform_billing_delivery: delivery,
          platform_billing_event: event
        )
        SystemAuditLogger.log!(
          action: "platform_billing.entitlement_transition",
          target: entitlement,
          temple:,
          metadata: audit_metadata(entitlement, previous_state)
        )
        entitlement
      end
    end

    private

    attr_reader :temple, :delivery, :state, :event, :occurred_at

    def validate_context!
      raise InvalidContextError, "Entitlement transition state is invalid" unless TRANSITION_STATES.include?(state)
      raise InvalidContextError, "Billing delivery must be persisted" unless delivery&.persisted?
      raise InvalidContextError, "Billing delivery belongs to another temple" unless delivery.temple_id == temple.id
      raise InvalidContextError, "Billing delivery status cannot transition entitlement" unless delivery.status == DELIVERY_STATUS_BY_STATE.fetch(state)
      return if event.blank?

      raise InvalidContextError, "Billing event must be persisted" unless event.persisted?
      raise InvalidContextError, "Billing event belongs to another temple" unless event.temple_id == temple.id
      raise InvalidContextError, "Billing event does not match delivery" unless event.platform_billing_delivery_id == delivery.id
    end

    def already_applied?(entitlement)
      entitlement.state == state &&
        entitlement.platform_billing_delivery_id == delivery.id &&
        entitlement.platform_billing_event_id == event&.id
    end

    def audit_metadata(entitlement, previous_state)
      {
        entitlement_id: entitlement.id,
        delivery_id: delivery.id,
        event_id: event&.id,
        from: previous_state,
        to: state,
        occurred_at: occurred_at.iso8601
      }.compact
    end
  end
end
