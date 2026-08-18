require "test_helper"

# Phase A3 item 8: a freeform ritual/offering text field that happens to look
# like a person's name must never create or mutate a Dependent/UserDependent
# record. It stays offering-scoped registration metadata unless the patron
# (or admin) separately creates/selects an actual dependent.
module Registrations
  class FreeformNamesNoDependentTest < ActionDispatch::IntegrationTest
    test "account self-scoped registration with freeform person-like text creates no dependent" do
      temple = create_temple
      offering = create_offering(
        temple:,
        metadata: { "registration_form" => { "sections" => { "logistics" => [], "ritual_metadata" => ["ceremony_notes"] } } }
      )
      user = User.create!(
        email: "freeform-account@example.com",
        english_name: "Freeform Account Patron",
        encrypted_password: User.password_hash("Password123!")
      )

      sign_in_account(user, temple_slug: temple.slug)

      dependent_count_before = Dependent.count
      user_dependent_count_before = UserDependent.count

      post account_registrations_path, params: {
        offering: offering.slug,
        account_action: "event",
        account_registration_intake_form: {
          contact_name: "Freeform Account Patron",
          quantity: 1,
          household_notes: "Please also remember my mother Lin Mei-Hua",
          ceremony_notes: "Dedicated to my late grandfather Chen Wen-Shan"
        }
      }

      registration = TempleEventRegistration.order(:id).last
      assert_redirected_to payment_account_registration_path(registration)

      assert_equal dependent_count_before, Dependent.count
      assert_equal user_dependent_count_before, UserDependent.count
      assert_equal "self", registration.metadata["registrant_scope"]
      assert_nil registration.metadata["dependent_id"]
      assert_equal "Please also remember my mother Lin Mei-Hua", registration.contact_payload["dependents_notes"]
      assert_equal "Dedicated to my late grandfather Chen Wen-Shan", registration.metadata["ceremony_notes"]
    end

    test "admin self-scoped registration with freeform ritual metadata text creates no dependent" do
      temple = create_temple
      admin = create_admin_user(temple:)
      AdminPermission.find_by(admin_account: admin.admin_account, temple:).update!(manage_registrations: true)
      event = TempleOffering.create!(
        temple:,
        slug: "freeform-admin-event",
        title: "Freeform Admin Event",
        starts_on: Date.current,
        ends_on: Date.current + 1.day,
        offering_type: "general",
        currency: "TWD",
        price_cents: 500
      )
      patron = User.create!(
        email: "freeform-admin-patron@example.com",
        english_name: "Freeform Admin Patron",
        encrypted_password: User.password_hash("Password123!")
      )

      sign_in_admin(admin)

      dependent_count_before = Dependent.count
      user_dependent_count_before = UserDependent.count

      post admin_event_offering_orders_path(event), params: {
        temple_event_registration: {
          user_id: patron.id,
          quantity: 1,
          registrant_scope: "self",
          ritual_metadata: {
            ancestor_placard_name: "Grandma Chen Su-Mei",
            dedication_message: "In memory of Uncle Wang Chih-Ming"
          }
        }
      }

      registration = event.temple_event_registrations.order(:id).last
      assert_redirected_to admin_event_offering_order_path(event, registration)

      assert_equal dependent_count_before, Dependent.count
      assert_equal user_dependent_count_before, UserDependent.count
      assert_equal "self", registration.metadata["registrant_scope"]
      assert_nil registration.metadata["dependent_id"]
      assert_equal "Grandma Chen Su-Mei", registration.metadata["ancestor_placard_name"]
      assert_equal "In memory of Uncle Wang Chih-Ming", registration.metadata["dedication_message"]

      # And it must not leak into any dependent's own metadata either --
      # confirm no dependent anywhere in the system carries this text.
      refute Dependent.where("metadata::text LIKE ?", "%Grandma Chen Su-Mei%").exists?
    end
  end
end
