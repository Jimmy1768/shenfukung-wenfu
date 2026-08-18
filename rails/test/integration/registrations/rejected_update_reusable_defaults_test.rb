require "test_helper"

# Phase A3 item 9 (second clause): an update that fails validation must not
# have silently written to reusable defaults before failing. The existing
# suite already proves this thoroughly for lifecycle-locked registrations
# (paid/refunded/fulfilled/cancelled/payment-recorded/gathering) via
# test/integration/admin/offering_orders_registrant_flow_test.rb's "admin
# duplicate and noneditable lifecycle paths do not mutate defaults", and for
# a rejected account *create* via
# test/integration/account/registration_payment_flow_test.rb. This file
# closes the one remaining case: a rejected account *update* (validation
# failure on an otherwise-editable, unlocked registration).
module Registrations
  class RejectedUpdateReusableDefaultsTest < ActionDispatch::IntegrationTest
    test "rejected account registration update (duplicate identity) does not mutate reusable defaults" do
      temple = create_temple
      offering = create_offering(
        temple:,
        metadata: { "registration_form" => { "sections" => { "logistics" => ["arrival_window"], "ritual_metadata" => [] } } }
      )
      user = User.create!(
        email: "rejected-update@example.com",
        english_name: "Rejected Update Patron",
        encrypted_password: User.password_hash("Password123!")
      )
      dependent = Dependent.create!(english_name: "Rejected Update Dependent")
      UserDependent.create!(user:, dependent:, role: "family", relationship_label: "Family")

      registration = create_registration(user:, offering:, metadata: { "registrant_scope" => "self" })
      _existing = create_registration(
        user:,
        offering:,
        metadata: { "registrant_scope" => "dependent", "dependent_id" => dependent.id.to_s, "registrant_name" => "Rejected Update Dependent" }
      )

      defaults = Registrations::ReusableDefaults.new(user:, temple:, offering:)
      defaults.write!("arrival_window" => "kept before rejection")

      sign_in_account(user, temple_slug: temple.slug)

      patch account_registration_path(registration), params: {
        account_registration_metadata_form: {
          quantity: 2,
          registrant_scope: "dependent",
          dependent_id: dependent.id,
          contact_name: "Rejected Update Patron",
          arrival_window: "must not write on rejection"
        }
      }

      assert_response :unprocessable_content
      assert_equal "kept before rejection", defaults.read["arrival_window"]
    end
  end
end
