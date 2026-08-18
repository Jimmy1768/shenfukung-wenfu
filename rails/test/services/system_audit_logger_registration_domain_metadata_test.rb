require "test_helper"

# Phase A3 item 10: audit records in the registration/reusable-defaults
# domain must carry actor/source/changed-field *names* (or counts), never
# the actual submitted values. Exercises the real controller actions named
# by the packet (patron_metadata_values_controller, offering_orders_controller,
# registration create/update paths, dependents controller) and inspects the
# persisted SystemAuditLog row itself.
class SystemAuditLoggerRegistrationDomainMetadataTest < ActionDispatch::IntegrationTest
  SENSITIVE_VALUE = "Please arrive by 9am for check-in, ask for Mrs. Chen"

  test "admin patron metadata value add/clear audits only the field name, never the value" do
    temple = create_temple
    admin = create_admin_user(temple:)
    AdminPermission.find_by(admin_account: admin.admin_account, temple:).update!(manage_registrations: true)
    offering = create_offering(temple:)
    patron = User.create!(email: "audit-metadata@example.com", english_name: "Audit Metadata Patron", encrypted_password: User.password_hash("Password123!"))

    sign_in_admin(admin)

    post admin_patron_metadata_values_path(patron), params: {
      field: "arrival_window", value: SENSITIVE_VALUE, offering_kind: "event", offering_id: offering.id
    }
    assert_response :created

    log = SystemAuditLog.where(action: "temple.registration_defaults.add").order(:created_at).last
    assert_equal ["arrival_window"], log.metadata["changed_reusable_fields"]
    refute_includes log.metadata.to_s, SENSITIVE_VALUE

    delete admin_patron_metadata_value_path(patron, "arrival_window"), params: {
      field: "arrival_window", offering_kind: "event", offering_id: offering.id
    }
    assert_response :success

    clear_log = SystemAuditLog.where(action: "temple.registration_defaults.clear").order(:created_at).last
    assert_equal ["arrival_window"], clear_log.metadata["changed_reusable_fields"]
    refute_includes clear_log.metadata.to_s, SENSITIVE_VALUE
  end

  test "admin offering order update audits only changed reusable field names, never the values" do
    temple = create_temple
    admin = create_admin_user(temple:)
    AdminPermission.find_by(admin_account: admin.admin_account, temple:).update!(manage_registrations: true)
    event = TempleOffering.create!(
      temple:,
      slug: "audit-admin-event",
      title: "Audit Admin Event",
      starts_on: Date.current,
      ends_on: Date.current + 1.day,
      offering_type: "general",
      currency: "TWD",
      price_cents: 500,
      metadata: { "registration_form" => { "sections" => { "logistics" => ["arrival_window"], "ritual_metadata" => [] } } }
    )
    patron = User.create!(email: "audit-order-update@example.com", english_name: "Audit Order Patron", encrypted_password: User.password_hash("Password123!"))
    registration = create_registration(user: patron, offering: event, metadata: { "registrant_scope" => "self" })

    sign_in_admin(admin)

    patch admin_event_offering_order_path(event, registration), params: {
      temple_event_registration: {
        user_id: patron.id,
        quantity: 1,
        registrant_scope: "self",
        logistics_details: { arrival_window: SENSITIVE_VALUE }
      }
    }
    assert_redirected_to admin_event_offering_order_path(event, registration)

    log = SystemAuditLog.where(action: "temple.registration.update").order(:created_at).last
    assert_equal ["arrival_window"], log.metadata["changed_reusable_fields"]
    refute_includes log.metadata.to_s, SENSITIVE_VALUE
  end

  test "account dependent update audits only field names, never the submitted values" do
    temple = create_temple
    user = User.create!(email: "audit-dependent@example.com", english_name: "Audit Dependent Patron", encrypted_password: User.password_hash("Password123!"))
    dependent = Dependent.create!(english_name: "Original Name")
    link = UserDependent.create!(user:, dependent:, role: "family", relationship_label: "Family")

    sign_in_account(user, temple_slug: temple.slug)

    patch account_dependent_path(link), params: {
      account_dependent_form: {
        english_name: "Updated Name",
        relationship_label: "Family",
        phone: SENSITIVE_VALUE
      }
    }

    log = SystemAuditLog.where(action: "account.dependents.updated").order(:created_at).last
    assert_equal %w[english_name relationship_label phone], log.metadata["changed_fields"]
    refute_includes log.metadata.to_s, SENSITIVE_VALUE
  end

  test "account registration create and update audits only field names, never the submitted values" do
    temple = create_temple
    offering = create_offering(
      temple:,
      metadata: { "registration_form" => { "sections" => { "logistics" => ["arrival_window"], "ritual_metadata" => [] } } }
    )
    user = User.create!(email: "audit-registration@example.com", english_name: "Audit Registration Patron", encrypted_password: User.password_hash("Password123!"))

    sign_in_account(user, temple_slug: temple.slug)

    post account_registrations_path, params: {
      offering: offering.slug,
      account_action: "event",
      account_registration_intake_form: { contact_name: "Audit Registration Patron", quantity: 1, arrival_window: SENSITIVE_VALUE }
    }
    registration = TempleEventRegistration.order(:id).last
    assert_redirected_to payment_account_registration_path(registration)

    create_log = SystemAuditLog.where(action: "account.registrations.created").order(:created_at).last
    refute_includes create_log.metadata.to_s, SENSITIVE_VALUE
    assert_includes create_log.metadata["changed_fields"], "arrival_window"

    patch account_registration_path(registration), params: {
      account_registration_metadata_form: { contact_name: "Audit Registration Patron", quantity: 1, arrival_window: "#{SENSITIVE_VALUE} v2" }
    }
    assert_redirected_to account_registration_path(registration)

    update_log = SystemAuditLog.where(action: "account.registrations.updated").order(:created_at).last
    refute_includes update_log.metadata.to_s, SENSITIVE_VALUE
    assert_includes update_log.metadata["changed_fields"], "arrival_window"
  end
end
