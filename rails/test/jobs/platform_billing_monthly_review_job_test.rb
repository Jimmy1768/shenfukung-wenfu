require "test_helper"

class PlatformBillingMonthlyReviewJobTest < ActiveSupport::TestCase
  test "closes locally and creates one pending delivery, without dispatching it" do
    temple = create_temple

    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(**) { flunk "review must not dispatch/collect" }) do
      PlatformBillingMonthlyReviewJob.perform_now(reference_time: Time.current)
    end

    assert_equal 1, temple.platform_billing_deliveries.monthly.count
    assert_equal "pending", temple.platform_billing_deliveries.monthly.first.status
  end

  test "re-running for the same month is idempotent" do
    temple = create_temple

    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(**) { flunk "review must not dispatch/collect" }) do
      PlatformBillingMonthlyReviewJob.perform_now(reference_time: Time.current)
      PlatformBillingMonthlyReviewJob.perform_now(reference_time: Time.current)
    end

    assert_equal 1, temple.platform_billing_deliveries.monthly.count
  end

  test "one temple's review failure does not prevent another temple's review" do
    failed_temple = create_temple
    successful_temple = create_temple
    original_close = Billing::PlatformStatementCloser.method(:close)

    Billing::PlatformStatementCloser.stub(:close, ->(temple:, month:, closed_at:) do
      raise "closer unavailable" if temple == failed_temple

      original_close.call(temple:, month:, closed_at:)
    end) do
      PlatformBillingMonthlyReviewJob.perform_now(reference_time: Time.current)
    end

    assert_equal 0, failed_temple.platform_billing_deliveries.monthly.count
    assert_equal 1, successful_temple.platform_billing_deliveries.monthly.count
    assert_equal 1, SystemAuditLog.where(action: "platform_billing.monthly_review_failed", target: failed_temple).count
  end
end
