require "test_helper"
class PlatformBillingMonthlyCloseJobTest < ActiveSupport::TestCase
  test "closes locally, creates one delivery, and dispatches it" do
    temple = create_temple
    dispatched = []
    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(delivery:) { dispatched << delivery }) do
      PlatformBillingMonthlyCloseJob.perform_now(reference_time: Time.current)
    end
    assert_equal 1, temple.platform_billing_deliveries.monthly.count
    assert_equal [temple.platform_billing_deliveries.monthly.first], dispatched

    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(delivery:) { dispatched << delivery }) do
      PlatformBillingMonthlyCloseJob.perform_now(reference_time: Time.current)
    end
    assert_equal 1, temple.platform_billing_deliveries.monthly.count
    assert_equal 2, dispatched.size
  end

  test "one collection failure does not prevent another temple dispatch" do
    failed_temple = create_temple
    successful_temple = create_temple
    Billing::StripePlatformBillingCollection.stub(:collect!, ->(delivery:) do
      raise "collector unavailable" if delivery.temple == failed_temple

      delivery.update!(status: "collecting")
    end) do
      PlatformBillingMonthlyCloseJob.perform_now(reference_time: Time.current)
    end

    failed_delivery = failed_temple.platform_billing_deliveries.monthly.first
    successful_delivery = successful_temple.platform_billing_deliveries.monthly.first
    assert_equal "pending", failed_delivery.status
    assert_equal "collecting", successful_delivery.status
    assert_equal 1, SystemAuditLog.where(action: "platform_billing.collection_failed", target: failed_delivery).count
  end
end
