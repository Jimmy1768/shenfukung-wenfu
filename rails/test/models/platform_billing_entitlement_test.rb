# frozen_string_literal: true

require "test_helper"

class PlatformBillingEntitlementTest < ActiveSupport::TestCase
  test "allows only the three durable entitlement states" do
    entitlement = PlatformBillingEntitlement.new(
      temple: create_temple,
      state: "not_a_state",
      adopted_at: Time.current,
      transitioned_at: Time.current
    )

    refute entitlement.valid?
    assert_not_empty entitlement.errors[:state]
  end

  test "requires one entitlement authority per temple" do
    temple = create_temple
    temple.adopt_platform_billing_entitlement!

    duplicate = PlatformBillingEntitlement.new(
      temple:,
      state: "pending_setup",
      adopted_at: Time.current,
      transitioned_at: Time.current
    )

    refute duplicate.valid?
    assert_not_empty duplicate.errors[:temple_id]
  end

  test "adoption is explicit, idempotent, and never activates access" do
    temple = create_temple
    adopted_at = Time.utc(2026, 8, 8, 9)

    entitlement = temple.adopt_platform_billing_entitlement!(adopted_at:)
    repeated = temple.adopt_platform_billing_entitlement!(adopted_at: adopted_at + 1.hour)

    assert_equal entitlement, repeated
    assert_equal "pending_setup", entitlement.state
    assert_equal adopted_at, entitlement.adopted_at
    assert temple.payment_settlement_frozen?
    assert_equal 1, SystemAuditLog.where(action: "platform_billing.entitlement_adopted", target: entitlement).count
  end

  test "an adopted temple permits registration intake only while active" do
    temple = create_temple(payment_provider_settings: { "billing" => { "payment_method_on_file" => true } })
    entitlement = temple.adopt_platform_billing_entitlement!

    assert temple.payment_settlement_frozen?
    entitlement.update!(state: "active")
    refute temple.payment_settlement_frozen?
    entitlement.update!(state: "suspended")
    assert temple.payment_settlement_frozen?
  end

  test "missing entitlement preserves the legacy registration intake decision" do
    legacy_open = create_temple
    legacy_frozen = create_temple(payment_provider_settings: {
      "billing" => { "grace_started_at" => 31.days.ago.iso8601, "grace_days" => 30 }
    })

    refute legacy_open.payment_settlement_frozen?
    assert legacy_frozen.payment_settlement_frozen?
  end

  test "billing presentation gives an entitlement precedence over legacy Stripe settings" do
    temple = create_temple(payment_provider_settings: {
      "billing" => { "stripe_payment_method_id" => "pm_historical" }
    })
    temple.platform_billing_deliveries.create!(
      kind: "monthly", status: "overdue", currency: "TWD", idempotency_key: "entitlement-state-overdue"
    )

    entitlement = temple.adopt_platform_billing_entitlement!
    assert_equal "setup_needed", temple.platform_billing_state

    entitlement.update!(state: "suspended")
    assert_equal "frozen", temple.platform_billing_state

    entitlement.update!(state: "active")
    assert_equal "overdue", temple.platform_billing_state
  end

  test "billing presentation retains its legacy result without an entitlement" do
    temple = create_temple(payment_provider_settings: {
      "billing" => { "stripe_payment_method_id" => "pm_legacy" }
    })
    temple.platform_billing_deliveries.create!(
      kind: "monthly", status: "overdue", currency: "TWD", idempotency_key: "legacy-state-overdue"
    )

    assert_nil temple.platform_billing_entitlement
    assert_equal "overdue", temple.platform_billing_state
  end
end
