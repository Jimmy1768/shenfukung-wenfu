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
end
