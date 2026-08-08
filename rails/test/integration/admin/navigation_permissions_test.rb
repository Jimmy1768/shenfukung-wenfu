require "test_helper"

class AdminNavigationPermissionsTest < ActionDispatch::IntegrationTest
  def nav_label(key)
    I18n.t("admin.nav.items.#{key}.label")
  end

  test "each direct capability controls its corresponding sidebar entries" do
    direct_gates = {
      manage_profile: %i[temple_profile],
      manage_news: %i[news_posts],
      manage_gallery: %i[gallery_entries],
      manage_registrations: %i[registrations orders],
      view_financials: %i[payments],
      manage_permissions: %i[permissions]
    }
    temple = create_temple

    direct_gates.each do |capability, item_keys|
      granted = create_admin_user(
        temple:,
        role: "admin",
        membership_role: "admin",
        permission_overrides: { capability => true }
      )
      denied = create_admin_user(temple:, role: "admin", membership_role: "admin")

      sign_in_admin(granted)
      get admin_dashboard_path
      assert_response :success
      item_keys.each { |item_key| assert_select ".sidebar-link-title", text: nav_label(item_key) }

      sign_in_admin(denied)
      get admin_dashboard_path
      assert_response :success
      item_keys.each { |item_key| assert_select ".sidebar-link-title", text: nav_label(item_key), count: 0 }
    end
  end

  test "Patrons is visible independently through manage registrations" do
    temple = create_temple
    staff = create_admin_user(
      temple:,
      role: "admin",
      membership_role: "admin",
      permission_overrides: {
        manage_registrations: true,
        manage_permissions: false,
        view_financials: false,
        export_financials: false,
      }
    )

    sign_in_admin(staff)
    get admin_dashboard_path

    assert_response :success
    assert_select ".sidebar-link-title", text: nav_label(:patrons)
    assert_select ".sidebar-link-title", text: nav_label(:permissions), count: 0
  end

  test "Patrons is visible independently through manage permissions" do
    temple = create_temple
    staff = create_admin_user(
      temple:,
      role: "admin",
      membership_role: "admin",
      permission_overrides: {
        manage_permissions: true,
        manage_registrations: false,
        view_financials: false,
        export_financials: false
      }
    )

    sign_in_admin(staff)
    get admin_dashboard_path

    assert_response :success
    assert_select ".sidebar-link-title", text: nav_label(:patrons)
    assert_select ".sidebar-link-title", text: nav_label(:registrations), count: 0
  end

  test "Archives is visible independently through export financials" do
    temple = create_temple
    staff = create_admin_user(
      temple:,
      role: "admin",
      membership_role: "admin",
      permission_overrides: { view_financials: false, export_financials: true }
    )

    sign_in_admin(staff)
    get admin_dashboard_path

    assert_response :success
    assert_select ".sidebar-link-title", text: nav_label(:archives)
    assert_select ".sidebar-link-title", text: nav_label(:payments), count: 0
  end

  test "Archives is visible independently through view financials" do
    temple = create_temple
    staff = create_admin_user(
      temple:,
      role: "admin",
      membership_role: "admin",
      permission_overrides: { view_financials: true, export_financials: false }
    )

    sign_in_admin(staff)
    get admin_dashboard_path

    assert_response :success
    assert_select ".sidebar-link-title", text: nav_label(:archives)
    assert_select ".sidebar-link-title", text: nav_label(:payments)
  end

  test "read-only administrators can browse both indexes without authoring controls" do
    temple = create_temple
    staff = create_admin_user(temple:, role: "admin", membership_role: "admin")
    offering = create_offering(temple:)
    gathering = temple.temple_gatherings.create!(
      slug: "navigation-read-only-gathering",
      title: "Navigation read-only gathering",
      currency: "TWD",
      price_cents: 0,
      status: "published"
    )

    sign_in_admin(staff)
    get admin_gatherings_path

    assert_response :success
    assert_select ".sidebar-link-state", text: I18n.t("admin.nav.read_only"), count: 2
    assert_select "a[href='#{new_admin_gathering_path}']", count: 0
    assert_select "a[href='#{edit_admin_gathering_path(gathering)}']", count: 0

    get admin_offerings_path

    assert_response :success
    assert_select ".sidebar-link-state", text: I18n.t("admin.nav.read_only"), count: 2
    assert_select "a[href='#{admin_offering_setup_drafts_path}']", count: 0
    assert_select "a[href='#{new_admin_offering_path}']", count: 0
    assert_select "a[href='#{edit_admin_event_path(offering)}']", count: 0
  end

  test "authoring permission shows controls and removes read-only markers" do
    temple = create_temple
    staff = create_admin_user(
      temple:,
      role: "admin",
      membership_role: "admin",
      permission_overrides: { manage_offerings: true, record_cash_payments: true, view_guest_lists: true }
    )
    offering = create_offering(temple:)
    gathering = temple.temple_gatherings.create!(
      slug: "navigation-authoring-gathering",
      title: "Navigation authoring gathering",
      currency: "TWD",
      price_cents: 0,
      status: "published"
    )

    sign_in_admin(staff)
    get admin_gatherings_path

    assert_response :success
    assert_select ".sidebar-link-state", count: 0
    assert_select "a[href='#{new_admin_gathering_path}']", count: 1
    assert_select "a[href='#{edit_admin_gathering_path(gathering)}']", count: 1

    get admin_offerings_path

    assert_response :success
    assert_select ".sidebar-link-state", count: 0
    assert_select "a[href='#{admin_offering_setup_drafts_path}']", count: 1
    assert_select "a[href='#{edit_admin_event_path(offering)}']", count: 1
    assert_select ".sidebar-link-title", text: /cash payments/i, count: 0
    assert_select ".sidebar-link-title", text: /guest lists/i, count: 0
  end
end
