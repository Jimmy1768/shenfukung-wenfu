require "test_helper"

class AdminRegistrationsAccessTest < ActionDispatch::IntegrationTest
  setup do
    @temple = create_temple
    @offering = create_offering(temple: @temple, title: "Lamp Offering")
  end

  test "admin with manage_registrations can view registrations entry page" do
    admin = create_admin_user(temple: @temple)
    permission = AdminPermission.find_by(admin_account: admin.admin_account, temple: @temple)
    permission.update!(manage_registrations: true)

    sign_in_admin(admin)
    get admin_registrations_path

    assert_response :success
    assert_includes response.body, "建立新報名"
    assert_includes response.body, "Lamp Offering"
  end

  test "admin without manage_registrations is redirected from registrations entry page" do
    admin = create_admin_user(temple: @temple)
    permission = AdminPermission.find_by(admin_account: admin.admin_account, temple: @temple)
    permission.update!(manage_registrations: false)

    sign_in_admin(admin)
    get admin_registrations_path

    assert_redirected_to admin_dashboard_path
  end

  test "a real (non-frozen) offering's registration quick-pick card is a live link, not disabled" do
    admin = create_admin_user(temple: @temple, permission_overrides: { manage_registrations: true })

    sign_in_admin(admin)
    get admin_registrations_path

    assert_response :success
    refute_includes response.body, "暫停中"
    assert_select "a.registration-target-card", text: /Lamp Offering/
    refute_select "div.registration-target-card.is-disabled"
  end

  test "registration creation is blocked when the temple's billing is actually frozen, for every registrable type" do
    @temple.adopt_platform_billing_entitlement!.update!(state: "suspended")
    gathering = @temple.temple_gatherings.create!(
      slug: "frozen-gathering",
      title: "Frozen Gathering",
      currency: "TWD",
      price_cents: 0,
      status: "published",
      starts_on: Date.current
    )
    admin = create_admin_user(temple: @temple, permission_overrides: { manage_registrations: true })

    sign_in_admin(admin)
    get admin_registrations_path

    assert_response :success
    assert_includes response.body, "暫停中"
    refute_select "a.registration-target-card", text: /Lamp Offering/
    refute_select "a.registration-target-card", text: /Frozen Gathering/
    # Cards render twice: once in the quick-pick section, again inside the
    # "create new registration" modal listing every offering/gathering.
    assert_select "div.registration-target-card.is-disabled", count: 4

    get new_admin_event_offering_order_path(@offering)
    assert_redirected_to admin_event_offering_orders_path(@offering)
  end

  test "the demo temple bypass unfreezes registration creation even with a suspended entitlement" do
    @temple.adopt_platform_billing_entitlement!.update!(state: "suspended")
    @temple.unlock_demo_registrations!
    admin = create_admin_user(temple: @temple, permission_overrides: { manage_registrations: true })

    sign_in_admin(admin)
    get admin_registrations_path

    assert_response :success
    refute_includes response.body, "暫停中"
    assert_select "a.registration-target-card", text: /Lamp Offering/
  end
end
