require "test_helper"

class PlatformBillingMonthlyCollectionJobTest < ActiveSupport::TestCase
  test "dispatches every pending monthly delivery" do
    temple = create_temple
    delivery = temple.platform_billing_deliveries.create!(kind: "monthly", status: "pending", currency: "TWD", idempotency_key: "collection-1")
    dispatched = []

    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(delivery:) { dispatched << delivery }) do
      PlatformBillingMonthlyCollectionJob.perform_now(reference_time: Time.current)
    end

    assert_equal [delivery], dispatched
  end

  test "does not touch a delivery that is not a pending monthly delivery" do
    temple = create_temple
    temple.platform_billing_deliveries.create!(kind: "setup", status: "pending", currency: "TWD", idempotency_key: "collection-setup")
    temple.platform_billing_deliveries.create!(kind: "monthly", status: "collecting", currency: "TWD", idempotency_key: "collection-already-collecting")
    dispatched = []

    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(delivery:) { dispatched << delivery }) do
      PlatformBillingMonthlyCollectionJob.perform_now(reference_time: Time.current)
    end

    assert_empty dispatched
  end

  test "one delivery's collection failure does not prevent another delivery's dispatch" do
    failed_temple = create_temple
    successful_temple = create_temple
    failed_delivery = failed_temple.platform_billing_deliveries.create!(kind: "monthly", status: "pending", currency: "TWD", idempotency_key: "collection-failed")
    successful_delivery = successful_temple.platform_billing_deliveries.create!(kind: "monthly", status: "pending", currency: "TWD", idempotency_key: "collection-success")

    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(delivery:) do
      raise "dispatcher unavailable" if delivery == failed_delivery

      delivery.update!(status: "collecting")
    end) do
      PlatformBillingMonthlyCollectionJob.perform_now(reference_time: Time.current)
    end

    assert_equal "pending", failed_delivery.reload.status
    assert_equal "collecting", successful_delivery.reload.status
    assert_equal 1, SystemAuditLog.where(action: "platform_billing.monthly_collection_failed", target: failed_delivery).count
  end
end
