require "test_helper"
class PlatformBillingMonthlyCloseJobTest < ActiveSupport::TestCase
  test "closes locally and creates a pending delivery without Stripe" do
    temple = create_temple
    Stripe::Invoice.stub(:create, ->(*) { flunk "job must not call Stripe" }) do
      PlatformBillingMonthlyCloseJob.perform_now(reference_time: Time.current)
    end
    assert_equal 1, temple.platform_billing_deliveries.monthly.count
    PlatformBillingMonthlyCloseJob.perform_now(reference_time: Time.current)
    assert_equal 1, temple.platform_billing_deliveries.monthly.count
  end
end
