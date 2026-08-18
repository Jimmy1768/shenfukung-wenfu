require "test_helper"

module Registrations
  # Guards the Phase A1 consolidation itself: proves the four call sites no
  # longer each carry their own "merge phone/email/notes into dependent
  # metadata" implementation, and that they route through
  # Registrations::DependentContactSync instead. The per-call-site specs
  # (registration_intake_form_test.rb, registration_metadata_form_test.rb,
  # temple_registration_builder_test.rb,
  # offering_orders_registrant_flow_test.rb) already prove the shared
  # service is actually invoked with the right arguments at each site; this
  # test additionally proves no site still carries a parallel local
  # merge-and-persist implementation that would silently duplicate it again.
  class DependentContactSyncConsolidationTest < ActiveSupport::TestCase
    CALL_SITES = [
      Rails.root.join("app/forms/account/registration_intake_form.rb"),
      Rails.root.join("app/forms/account/registration_metadata_form.rb"),
      Rails.root.join("app/services/payments/temple_registration_builder.rb"),
      Rails.root.join("app/controllers/admin/offering_orders_controller.rb")
    ].freeze

    # The shape of a local reimplementation: merging a phone/email/notes-ish
    # payload directly into a dependent's metadata and persisting it, instead
    # of delegating to Registrations::DependentContactSync.
    DUPLICATE_MERGE_PATTERN = /dependent.*\.update!\(metadata:.*\.merge\(/

    test "no call site still merges phone/email/notes into dependent metadata itself" do
      CALL_SITES.each do |path|
        source = File.read(path)
        refute_match DUPLICATE_MERGE_PATTERN, source,
          "#{path} appears to merge dependent contact fields directly instead of delegating to Registrations::DependentContactSync"
      end
    end

    test "every call site references the shared DependentContactSync service" do
      CALL_SITES.each do |path|
        source = File.read(path)
        assert_match(/Registrations::DependentContactSync\.call!/, source,
          "#{path} no longer routes dependent contact sync through Registrations::DependentContactSync")
      end
    end
  end
end
