require "test_helper"

# The two job-level test files each prove their own job's query logic in
# isolation, hand-constructing period_start_at with the same helper the job
# itself calls -- self-consistent, but it doesn't prove that a delivery born
# from the *real* path (review job -> Billing::PlatformStatementCloser ->
# Billing::PlatformBillingDeliveryCreator) actually lands on a period_start_at
# that the collection job's query finds. This test pins that seam end to end,
# with no hand-built period_start_at anywhere, so a future change to either
# service's attribute-building can't silently break the pairing without a
# test noticing.
class PlatformBillingMonthlyReviewToCollectionTest < ActiveSupport::TestCase
  test "the delivery review creates through the real closer/creator path is exactly what collection dispatches" do
    temple = create_temple
    temple.adopt_platform_billing_entitlement!.update!(state: "active")
    reference_time = Time.current

    PlatformBillingMonthlyReviewJob.perform_now(reference_time: reference_time)

    assert_equal 1, temple.platform_billing_deliveries.monthly.count
    review_created_delivery = temple.platform_billing_deliveries.monthly.first
    assert_equal "pending", review_created_delivery.status

    dispatched = []
    Billing::PlatformBillingCollectionDispatcher.stub(:dispatch!, ->(delivery:) { dispatched << delivery }) do
      PlatformBillingMonthlyCollectionJob.perform_now(reference_time: reference_time)
    end

    assert_equal [review_created_delivery], dispatched
  end
end
