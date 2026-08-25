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
    assert_select "a.registration-target-card", text: /Lamp Offering/
    refute_select "div.registration-target-card.is-disabled"
  end

  test "registration creation stays fully available when the temple's billing is frozen, for every registrable type" do
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
    patron = User.create!(email: "frozen-walkin@example.com", english_name: "Walk-in Patron", encrypted_password: User.password_hash("Password123!"))

    sign_in_admin(admin)
    get admin_registrations_path

    # Billing status is never surfaced on this page and never disables a
    # card -- intake is data entry, not a payment step, so a temple's own
    # billing problem must not make registration creation look broken to
    # whoever is at the desk. See Payments::CashPaymentRecorder and
    # Admin::PaymentsController#start_checkout for where the freeze
    # actually bites: the payment step, not intake.
    assert_response :success
    assert_select "a.registration-target-card", text: /Lamp Offering/
    assert_select "a.registration-target-card", text: /Frozen Gathering/
    refute_select "div.registration-target-card.is-disabled"

    assert_difference -> { TempleEventRegistration.count }, 1 do
      post admin_event_offering_orders_path(@offering), params: {
        temple_event_registration: {
          user_id: patron.id,
          quantity: 1,
          registrant_scope: "self",
          contact_details: { primary_contact: "Walk-in Patron", email: patron.email }
        }
      }
    end
    registration = TempleEventRegistration.order(:created_at).last
    assert_redirected_to admin_event_offering_order_path(@offering, registration)
    assert_equal TempleRegistration::PAYMENT_STATUSES[:pending], registration.payment_status
  end
end
