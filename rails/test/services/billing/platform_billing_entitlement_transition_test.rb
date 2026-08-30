# frozen_string_literal: true

require "test_helper"

class Billing::PlatformBillingEntitlementTransitionTest < ActiveSupport::TestCase
  test "activates an adopted temple with matching paid delivery and event context" do
    temple = create_temple
    entitlement = temple.adopt_platform_billing_entitlement!
    delivery = delivery_for(temple:, status: "paid")
    event = event_for(temple:, delivery:)
    occurred_at = Time.utc(2026, 8, 8, 10)

    result = Billing::PlatformBillingEntitlementTransition.transition!(
      temple:, delivery:, event:, state: "active", occurred_at:
    )

    assert_equal entitlement, result
    assert_equal "active", result.reload.state
    assert_equal delivery, result.platform_billing_delivery
    assert_equal event, result.platform_billing_event
    assert_equal occurred_at, result.activated_at
    assert_equal occurred_at, result.transitioned_at
    refute temple.payment_settlement_frozen?

    audit = SystemAuditLog.find_by!(action: "platform_billing.entitlement_transition", target: result)
    assert_equal({ "delivery_id" => delivery.id, "entitlement_id" => result.id, "event_id" => event.id,
      "from" => "pending_setup", "occurred_at" => occurred_at.iso8601, "to" => "active" }, audit.metadata)
  end

  test "repeating an applied transition does not add entitlement audit evidence" do
    temple = create_temple
    entitlement = temple.adopt_platform_billing_entitlement!
    delivery = delivery_for(temple:, status: "paid")
    event = event_for(temple:, delivery:)

    first = Billing::PlatformBillingEntitlementTransition.transition!(temple:, delivery:, event:, state: "active")
    second = Billing::PlatformBillingEntitlementTransition.transition!(temple:, delivery:, event:, state: "active")

    assert_equal first, second
    assert_equal 1, SystemAuditLog.where(action: "platform_billing.entitlement_transition", target: entitlement).count
  end

  test "rejects missing adoption and delivery context that cannot grant entitlement" do
    temple = create_temple
    delivery = delivery_for(temple:, status: "paid")

    error = assert_raises(Billing::PlatformBillingEntitlementTransition::InvalidContextError) do
      Billing::PlatformBillingEntitlementTransition.transition!(temple:, delivery:, state: "active")
    end

    assert_match "has not adopted", error.message
  end

  test "rejects cross-tenant and mismatched delivery-event context" do
    temple = create_temple
    other_temple = create_temple
    temple.adopt_platform_billing_entitlement!
    cross_tenant_delivery = delivery_for(temple: other_temple, status: "paid")
    delivery = delivery_for(temple:, status: "paid")
    cross_tenant_event = event_for(temple: other_temple, delivery: cross_tenant_delivery)

    assert_raises(Billing::PlatformBillingEntitlementTransition::InvalidContextError) do
      Billing::PlatformBillingEntitlementTransition.transition!(temple:, delivery: cross_tenant_delivery, state: "active")
    end
    assert_raises(Billing::PlatformBillingEntitlementTransition::InvalidContextError) do
      Billing::PlatformBillingEntitlementTransition.transition!(temple:, delivery:, event: cross_tenant_event, state: "active")
    end
  end

  test "rejects invalid delivery status and event context" do
    temple = create_temple
    temple.adopt_platform_billing_entitlement!
    pending_delivery = delivery_for(temple:, status: "pending")
    paid_delivery = delivery_for(temple:, status: "paid")
    mismatched_event = event_for(temple:, delivery: pending_delivery)

    assert_raises(Billing::PlatformBillingEntitlementTransition::InvalidContextError) do
      Billing::PlatformBillingEntitlementTransition.transition!(temple:, delivery: pending_delivery, state: "active")
    end
    assert_raises(Billing::PlatformBillingEntitlementTransition::InvalidContextError) do
      Billing::PlatformBillingEntitlementTransition.transition!(temple:, delivery: paid_delivery, event: mismatched_event, state: "active")
    end
  end

  test "suspends only from durable frozen delivery context" do
    temple = create_temple
    temple.adopt_platform_billing_entitlement!
    frozen_delivery = delivery_for(temple:, status: "frozen")

    result = Billing::PlatformBillingEntitlementTransition.transition!(temple:, delivery: frozen_delivery, state: "suspended")

    assert_equal "suspended", result.state
    assert temple.payment_settlement_frozen?
  end

  private

  def delivery_for(temple:, status:)
    temple.platform_billing_deliveries.create!(
      kind: "monthly",
      status:,
      currency: "TWD",
      idempotency_key: "entitlement-#{SecureRandom.hex(4)}"
    )
  end

  def event_for(temple:, delivery:)
    PlatformBillingEvent.create!(
      temple:,
      platform_billing_delivery: delivery,
      provider_event_id: "evt_#{SecureRandom.hex(4)}",
      event_type: "invoice.paid",
      payload: { "safe_reference" => "event" }
    )
  end
end
