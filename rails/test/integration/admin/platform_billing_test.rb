require "test_helper"

class Admin::PlatformBillingTest < ActionDispatch::IntegrationTest
  test "owner sees the current usage preview and closed statements" do
    temple = create_temple
    owner = create_admin_user(temple:)
    Billing::PlatformStatementCloser.close(
      temple:,
      month: Date.current.prev_month,
      closed_at: Billing::PlatformUsage::TIME_ZONE.now + 1.month
    )

    sign_in_admin(owner)
    get admin_platform_billing_path

    assert_response :success
    assert_includes response.body, "Monthly registration usage"
    assert_includes response.body, "Closed statements"
  end

  test "non-owner cannot view platform billing" do
    temple = create_temple
    admin = create_admin_user(temple:, role: "admin")

    sign_in_admin(admin)
    get admin_platform_billing_path

    assert_redirected_to admin_dashboard_path
  end
end
