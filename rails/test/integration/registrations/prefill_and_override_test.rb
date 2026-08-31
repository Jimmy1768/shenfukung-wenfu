require "test_helper"

# Phase A3 (Control A, Account/Admin Offering-Data Contract) verification:
#
# 1. Self and dependent prefill actually renders/serializes on both the
#    account and admin surfaces (not just "the service can read a value" --
#    the real form/JSON payload a human or the picker JS consumes).
# 2. An explicit value submitted on a registration always wins over a
#    previously cached reusable value, on both surfaces.
module Registrations
  class PrefillAndOverrideTest < ActionDispatch::IntegrationTest
    test "new account registration form prefills reusable account contact and offering defaults for self" do
      temple = create_temple
      offering = create_offering(
        temple:,
        metadata: { "registration_form" => { "sections" => { "logistics" => ["arrival_window"], "ritual_metadata" => [] } } }
      )
      user = User.create!(
        email: "self-prefill@example.com",
        english_name: "Self Prefill Patron",
        encrypted_password: User.password_hash("Password123!"),
        # The note is seeded where a prior registration would have cached it.
        # It is deliberately NOT a top-level profile "notes" value -- that
        # field was removed on 2026-08-31 as scaffold residue, so the profile
        # is no longer a prefill source for notes (phone still is).
        metadata: {
          "phone" => "0911-234-567",
          Registrations::UserMetadataUpdater::NAMESPACE => { "notes" => "Peanut allergy, seat near exit" }
        }
      )
      Registrations::ReusableDefaults.new(user:, temple:, offering:).write!("arrival_window" => "reserved morning slot")

      sign_in_account(user, temple_slug: temple.slug)

      get new_account_registration_path(offering: offering.slug, account_action: "event")
      assert_response :success
      assert_select "input[name='account_registration_intake_form[contact_phone]'][value=?]", "0911-234-567"
      assert_select "input[name='account_registration_intake_form[arrival_window]'][value=?]", "reserved morning slot"
      assert_includes response.body, "Peanut allergy, seat near exit"
    end

    test "new account registration form prefills dependent's own reusable contact defaults when dependent scope selected" do
      temple = create_temple
      offering = create_offering(temple:)
      user = User.create!(
        email: "dependent-prefill@example.com",
        english_name: "Dependent Prefill Patron",
        encrypted_password: User.password_hash("Password123!")
      )
      dependent = Dependent.create!(
        english_name: "Family Member",
        metadata: { "phone" => "0922-999-888", "email" => "family@example.com", "notes" => "Wheelchair access needed" }
      )
      UserDependent.create!(user:, dependent:, role: "family", relationship_label: "Sibling")

      sign_in_account(user, temple_slug: temple.slug)

      get new_account_registration_path(
        offering: offering.slug,
        account_action: "event",
        registrant_scope: "dependent",
        dependent_id: dependent.id
      )
      assert_response :success
      assert_select "input[name='account_registration_intake_form[contact_phone]'][value=?]", "0922-999-888"
      assert_select "input[name='account_registration_intake_form[contact_email]'][value=?]", "family@example.com"
      assert_includes response.body, "Wheelchair access needed"
    end

    test "admin patron picker payload prefills both the patron's own and their dependent's reusable contact defaults" do
      temple = create_temple
      admin = create_admin_user(temple:)
      AdminPermission.find_by(admin_account: admin.admin_account, temple:).update!(manage_registrations: true)
      offering = create_offering(temple:)
      patron = User.create!(
        email: "admin-prefill-patron@example.com",
        english_name: "Admin Prefill Patron",
        encrypted_password: User.password_hash("Password123!"),
        metadata: {
          "phone" => "0933-444-555",
          Registrations::UserMetadataUpdater::NAMESPACE => { "notes" => "Prefers Mandarin" }
        }
      )
      dependent = Dependent.create!(
        english_name: "Admin-side Family",
        metadata: { "phone" => "0933-111-222", "email" => "admin-dep@example.com", "notes" => "Bring wheelchair" }
      )
      UserDependent.create!(user: patron, dependent:, role: "family", relationship_label: "Parent")

      sign_in_admin(admin)

      get admin_patrons_path(format: :json, q: patron.email, offering_kind: "event", offering_id: offering.id)
      assert_response :success
      entry = response.parsed_body.fetch("patrons").find { |p| p["id"] == patron.id }
      assert_equal "0933-444-555", entry["phone"]
      assert_equal "Prefers Mandarin", entry["notes"]

      dependent_entry = entry.fetch("dependent_entries").find { |d| d["id"] == dependent.id }
      assert_equal "0933-111-222", dependent_entry["phone"]
      assert_equal "admin-dep@example.com", dependent_entry["email"]
      assert_equal "Bring wheelchair", dependent_entry["notes"]
    end

    test "explicit account registration params override a previously cached reusable offering default" do
      temple = create_temple
      offering = create_offering(
        temple:,
        metadata: { "registration_form" => { "sections" => { "logistics" => ["arrival_window"], "ritual_metadata" => [] } } }
      )
      user = User.create!(
        email: "override-account@example.com",
        english_name: "Override Patron",
        encrypted_password: User.password_hash("Password123!")
      )
      Registrations::ReusableDefaults.new(user:, temple:, offering:).write!("arrival_window" => "cached morning")

      form = Account::RegistrationIntakeForm.new(
        user:,
        offering:,
        params: { "contact_name" => "Override Patron", "arrival_window" => "explicit afternoon" }
      )

      assert_equal "explicit afternoon", form.arrival_window
      assert form.save, form.errors.full_messages.to_sentence
      assert_equal "explicit afternoon", form.registration.logistics_payload["arrival_window"]
    end

    test "explicit admin registration params override a previously cached reusable offering default" do
      temple = create_temple
      admin = create_admin_user(temple:)
      AdminPermission.find_by(admin_account: admin.admin_account, temple:).update!(manage_registrations: true)
      event = TempleOffering.create!(
        temple:,
        slug: "override-admin-event",
        title: "Override Admin Event",
        starts_on: Date.current,
        ends_on: Date.current + 1.day,
        offering_type: "general",
        currency: "TWD",
        price_cents: 500
      )
      patron = User.create!(
        email: "override-admin-patron@example.com",
        english_name: "Override Admin Patron",
        encrypted_password: User.password_hash("Password123!")
      )
      defaults = Registrations::ReusableDefaults.new(user: patron, temple:, offering: event)
      defaults.write!("arrival_window" => "cached morning")

      sign_in_admin(admin)

      post admin_event_offering_orders_path(event), params: {
        temple_event_registration: {
          user_id: patron.id,
          quantity: 1,
          registrant_scope: "self",
          logistics_details: { arrival_window: "explicit evening" }
        }
      }

      registration = event.temple_event_registrations.order(:id).last
      assert_redirected_to admin_event_offering_order_path(event, registration)
      assert_equal "explicit evening", registration.logistics_payload["arrival_window"]
    end
  end
end
