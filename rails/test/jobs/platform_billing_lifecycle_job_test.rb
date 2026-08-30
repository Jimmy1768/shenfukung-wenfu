require "test_helper"

class PlatformBillingLifecycleJobTest < ActiveSupport::TestCase
  test "advances only due platform deliveries without a provider request" do
    temple = create_temple
    delivery = temple.platform_billing_deliveries.create!(kind: "monthly", status: "overdue", currency: "TWD", idempotency_key: "job-1", due_at: 1.day.ago, grace_deadline_at: 29.days.from_now)
    Stripe::Invoice.stub(:create, ->(*) { flunk "lifecycle must not call Stripe" }) do
      PlatformBillingLifecycleJob.perform_now(reference_time: Time.current)
    end
    assert_equal "grace", delivery.reload.status
  end

  test "suspends an adopted temple only when the lifecycle freezes its delivery" do
    temple = create_temple
    entitlement = temple.adopt_platform_billing_entitlement!
    entitlement.update!(state: "active")
    delivery = temple.platform_billing_deliveries.create!(kind: "monthly", status: "grace", currency: "TWD", idempotency_key: "job-freeze", grace_deadline_at: 1.day.ago)

    Stripe::Invoice.stub(:create, ->(*) { flunk "lifecycle must not call Stripe" }) do
      PlatformBillingLifecycleJob.perform_now(reference_time: Time.current)
    end

    assert_equal "frozen", delivery.reload.status
    assert_equal "suspended", entitlement.reload.state
    assert temple.payment_settlement_frozen?
  end
end
