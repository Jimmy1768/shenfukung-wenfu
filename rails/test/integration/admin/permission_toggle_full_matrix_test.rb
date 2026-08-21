# frozen_string_literal: true

require "test_helper"

# Director asked two things directly: (1) flip on each permission checkbox
# one at a time and confirm exactly which sidebar items appear, (2) whether
# a hidden nav item is *actually* enough to block the admin from the
# underlying feature, or just a cosmetic hide. Both proven here with real
# HTTP requests, not inferred from reading the helper/controllers.
class AdminPermissionToggleFullMatrixTest < ActionDispatch::IntegrationTest
  BASELINE_ITEMS = ["掌握指標與待辦", "社群活動", "供品管理"].freeze # Dashboard, Gatherings, Offerings -- always visible, read-only without manage_offerings

  def visible_titles
    css_select(".sidebar-link-title").map(&:text).map(&:strip)
  end

  # capability => [real i18n nav labels it additionally unlocks beyond baseline, one real protected action it should unblock]
  CAPABILITY_MATRIX = {
    manage_registrations: { nav_adds: ["報名", "訂單", "信眾與管理員"], protected_get: :admin_registrations_path },
    view_financials: { nav_adds: ["收款資料", "年度資料"], protected_get: :admin_payments_path },
    manage_permissions: { nav_adds: ["信眾與管理員", "管理員權限"], protected_get: :admin_permissions_path },
    manage_profile: { nav_adds: ["宮廟資料"], protected_get: :admin_temple_profile_path },
    manage_news: { nav_adds: ["最新消息"], protected_get: :admin_news_posts_path },
    manage_gallery: { nav_adds: ["活動回顧"], protected_get: :admin_gallery_entries_path }
  }.freeze

  test "each single capability unlocks exactly its own nav items, nothing more" do
    temple = create_temple

    CAPABILITY_MATRIX.each do |capability, expectation|
      admin = create_admin_user(temple:, role: "admin", membership_role: "admin", permission_overrides: { capability => true })
      sign_in_admin(admin)
      get admin_dashboard_path
      assert_response :success

      expected = (BASELINE_ITEMS + expectation[:nav_adds]).sort
      assert_equal expected, visible_titles.sort, "capability #{capability} should show exactly baseline + #{expectation[:nav_adds]}"
    end
  end

  test "export_financials alone (without view_financials) still unlocks Archives in nav" do
    temple = create_temple
    admin = create_admin_user(temple:, role: "admin", membership_role: "admin", permission_overrides: { export_financials: true })
    sign_in_admin(admin)
    get admin_dashboard_path
    assert_response :success
    assert_equal (BASELINE_ITEMS + ["年度資料"]).sort, visible_titles.sort
  end

  test "manage_offerings unlocks editing (create) but adds no new nav item -- Gatherings/Offerings were already visible read-only" do
    temple = create_temple
    admin = create_admin_user(temple:, role: "admin", membership_role: "admin", permission_overrides: { manage_offerings: true })
    sign_in_admin(admin)
    get admin_dashboard_path
    assert_response :success
    assert_equal BASELINE_ITEMS.sort, visible_titles.sort
  end

  test "record_cash_payments and view_guest_lists have no standalone nav item, confirmed" do
    temple = create_temple
    %i[record_cash_payments view_guest_lists].each do |capability|
      admin = create_admin_user(temple:, role: "admin", membership_role: "admin", permission_overrides: { capability => true })
      sign_in_admin(admin)
      get admin_dashboard_path
      assert_response :success
      assert_equal BASELINE_ITEMS.sort, visible_titles.sort, "#{capability} should not add any nav item"
    end
  end

  test "zero permissions shows exactly the baseline three items" do
    temple = create_temple
    admin = create_admin_user(temple:, role: "admin", membership_role: "admin")
    sign_in_admin(admin)
    get admin_dashboard_path
    assert_response :success
    assert_equal BASELINE_ITEMS.sort, visible_titles.sort
  end

  test "Billing is gated by real temple-owner membership, not any capability -- fixed, 2026-08-20" do
    temple = create_temple

    # Real bug found and fixed: this used to check the manage_permissions
    # *capability* instead of actual owner membership (owner_admin_for_current_temple?
    # -> AdminAccount#owner_for_temple?), despite every caller's own naming/flash
    # text already stating "owner_only" / "Only the temple owner can view
    # platform billing." Billing means real money (Stripe owed to SourceGrid)
    # and ECPay provider credentials -- deliberately not delegable via any
    # capability grant, only actual ownership.
    admin_with_every_other_capability = create_admin_user(
      temple:, role: "admin", membership_role: "admin",
      permission_overrides: {
        manage_offerings: true, manage_registrations: true, view_financials: true, export_financials: true,
        view_guest_lists: true, manage_permissions: true, manage_profile: true, manage_news: true,
        manage_gallery: true, record_cash_payments: true
      }
    )
    sign_in_admin(admin_with_every_other_capability)
    get admin_dashboard_path
    assert_response :success
    assert_not_includes visible_titles, "帳務設定", "no capability grant, including manage_permissions, should unlock Billing"
    get admin_payment_methods_path
    assert_redirected_to admin_dashboard_path
    get admin_platform_billing_path
    assert_redirected_to admin_dashboard_path

    owner = create_admin_user(temple:, role: "owner", membership_role: "owner")
    sign_in_admin(owner)
    get admin_dashboard_path
    assert_response :success
    assert_includes visible_titles, "帳務設定"
    get admin_payment_methods_path
    assert_response :success
    get admin_platform_billing_path
    assert_response :success
  end

  # --- Part 2: does hiding the button actually block the feature? ---

  test "hiding a nav item corresponds to a real backend block, not just a cosmetic hide" do
    temple = create_temple

    CAPABILITY_MATRIX.each do |capability, expectation|
      denied = create_admin_user(temple:, role: "admin", membership_role: "admin")
      sign_in_admin(denied)
      get send(expectation[:protected_get])
      assert_redirected_to admin_dashboard_path, "#{capability} should block direct access, not just hide the nav item"

      granted = create_admin_user(temple:, role: "admin", membership_role: "admin", permission_overrides: { capability => true })
      sign_in_admin(granted)
      get send(expectation[:protected_get])
      assert_response :success, "#{capability} should actually unblock the real action once granted"
    end
  end

  test "export_financials specifically blocks the export action even when view_financials already grants list access" do
    temple = create_temple
    view_only = create_admin_user(temple:, role: "admin", membership_role: "admin", permission_overrides: { view_financials: true })
    sign_in_admin(view_only)
    get admin_payments_path
    assert_response :success, "view_financials should grant list access"
    get export_admin_payments_path
    assert_redirected_to admin_dashboard_path, "view_financials alone must not grant export -- that needs export_financials specifically"

    exporter = create_admin_user(temple:, role: "admin", membership_role: "admin", permission_overrides: { export_financials: true })
    sign_in_admin(exporter)
    get export_admin_payments_path
    assert_response :success, "export_financials should actually unblock the export action"
  end

  test "manage_offerings actually gates creating an offering, not just the nav read-only marker" do
    temple = create_temple
    denied = create_admin_user(temple:, role: "admin", membership_role: "admin")
    sign_in_admin(denied)
    get admin_offerings_path
    assert_response :success, "browsing offerings must stay open without the capability"
    get new_admin_offering_path
    assert_redirected_to admin_dashboard_path, "creating an offering must be blocked without manage_offerings"

    granted = create_admin_user(temple:, role: "admin", membership_role: "admin", permission_overrides: { manage_offerings: true })
    sign_in_admin(granted)
    get new_admin_offering_path
    assert_response :success
  end
end
