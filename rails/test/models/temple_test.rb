require "test_helper"

class TempleTest < ActiveSupport::TestCase
  test "payment_settlement_frozen? is false with no billing activity at all" do
    temple = create_temple

    refute temple.payment_settlement_frozen?
  end

  test "payment_settlement_frozen? is true once entitlement is adopted but stuck in pending_setup" do
    temple = create_temple
    temple.adopt_platform_billing_entitlement!

    assert temple.payment_settlement_frozen?
  end

  test "payment_settlement_frozen? is false again once entitlement is active" do
    temple = create_temple
    temple.adopt_platform_billing_entitlement!.update!(state: "active")

    refute temple.payment_settlement_frozen?
  end

  test "unlock_demo_registrations! overrides a frozen pending_setup entitlement" do
    temple = create_temple
    temple.adopt_platform_billing_entitlement!
    assert temple.payment_settlement_frozen?

    temple.unlock_demo_registrations!

    refute temple.payment_settlement_frozen?
    assert temple.demo_registration_unlocked?
  end

  test "lock_demo_registrations! reverses the unlock" do
    temple = create_temple
    temple.adopt_platform_billing_entitlement!
    temple.unlock_demo_registrations!
    refute temple.payment_settlement_frozen?

    temple.lock_demo_registrations!

    assert temple.payment_settlement_frozen?
    refute temple.demo_registration_unlocked?
  end

  test "unlocking demo registrations does not disturb other billing settings" do
    temple = create_temple(payment_provider_settings: { "billing" => { "payment_method_on_file" => true }, "ecpay" => { "merchant_id" => "2000132" } })

    temple.unlock_demo_registrations!

    assert temple.billing_payment_method_on_file?
    assert_equal "2000132", temple.payment_provider_settings["ecpay"]["merchant_id"]
    assert temple.demo_registration_unlocked?
  end

  test "Temple.platform_billing_adopted excludes a temple that never adopted platform billing" do
    demo_temple = create_temple

    refute_includes Temple.platform_billing_adopted, demo_temple
  end

  test "Temple.platform_billing_adopted excludes a temple stuck in pending_setup, even if demo-unlocked" do
    stalled_temple = create_temple
    stalled_temple.adopt_platform_billing_entitlement!
    stalled_temple.unlock_demo_registrations!

    refute_includes Temple.platform_billing_adopted, stalled_temple
  end

  test "Temple.platform_billing_adopted includes an active real client" do
    real_client = create_temple
    real_client.adopt_platform_billing_entitlement!.update!(state: "active")

    assert_includes Temple.platform_billing_adopted, real_client
  end

  test "Temple.platform_billing_adopted includes a suspended real client" do
    suspended_client = create_temple
    suspended_client.adopt_platform_billing_entitlement!.update!(state: "active")
    suspended_client.platform_billing_entitlement.update!(state: "suspended")

    assert_includes Temple.platform_billing_adopted, suspended_client
  end
end
