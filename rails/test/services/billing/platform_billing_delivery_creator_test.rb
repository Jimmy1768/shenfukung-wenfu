require "test_helper"
class Billing::PlatformBillingDeliveryCreatorTest < ActiveSupport::TestCase
  test "creates one tenant scoped pending delivery from a closed statement" do
    temple = create_temple
    statement = Billing::PlatformStatementCloser.close(temple:, month: Date.current.prev_month, closed_at: Time.current).statement
    first = Billing::PlatformBillingDeliveryCreator.create_monthly!(statement:)
    assert_equal first, Billing::PlatformBillingDeliveryCreator.create_monthly!(statement:)
    assert_equal "pending", first.status
  end
end
