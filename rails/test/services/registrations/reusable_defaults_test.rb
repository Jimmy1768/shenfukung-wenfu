# frozen_string_literal: true

require "test_helper"

module Registrations
  class ReusableDefaultsTest < ActiveSupport::TestCase
    test "scopes defaults by temple, registrable type, and stable offering id" do
      user = patron
      first_temple = create_temple
      second_temple = create_temple
      first = create_offering(temple: first_temple, slug: "same-slug", metadata: configured_metadata)
      second = create_offering(temple: second_temple, slug: "same-slug", metadata: configured_metadata)

      ReusableDefaults.new(user:, temple: first_temple, offering: first).write!("arrival_window" => "morning")
      ReusableDefaults.new(user:, temple: second_temple, offering: second).write!("arrival_window" => "afternoon")

      assert_equal({ "arrival_window" => "morning" }, ReusableDefaults.new(user:, temple: first_temple, offering: first).read)
      assert_equal({ "arrival_window" => "afternoon" }, ReusableDefaults.new(user:, temple: second_temple, offering: second).read)
    end

    test "keeps same numeric ids separate across registrable types" do
      temple = create_temple
      user = patron
      event = create_offering(temple:, metadata: configured_metadata)
      service = temple.temple_services.create!(slug: "service-#{SecureRandom.hex(3)}", title: "Service", status: "published", price_cents: 100, currency: "TWD", metadata: configured_metadata)
      gathering = temple.temple_gatherings.create!(slug: "gathering-#{SecureRandom.hex(3)}", title: "Gathering", status: "published", price_cents: 0, currency: "TWD", metadata: configured_metadata)

      ReusableDefaults.new(user:, temple:, offering: event).write!("arrival_window" => "event")
      ReusableDefaults.new(user:, temple:, offering: service).write!("arrival_window" => "service")
      ReusableDefaults.new(user:, temple:, offering: gathering).write!("arrival_window" => "gathering")

      assert_equal "event", ReusableDefaults.new(user:, temple:, offering: event).read["arrival_window"]
      assert_equal "service", ReusableDefaults.new(user:, temple:, offering: service).read["arrival_window"]
      assert_equal "gathering", ReusableDefaults.new(user:, temple:, offering: gathering).read["arrival_window"]
    end

    test "does not read or mutate legacy slug metadata and rejects forbidden fields" do
      temple = create_temple
      offering = create_offering(temple:, slug: "lamp", metadata: configured_metadata)
      legacy = { "offerings" => { "lamp" => { "arrival_window" => "legacy", "quantity" => 3 } } }
      user = patron(metadata: legacy)
      defaults = ReusableDefaults.new(user:, temple:, offering:)

      assert_equal({}, defaults.read)
      defaults.write!("arrival_window" => "new", "quantity" => 9, "certificate_number" => "private", "preferred_date" => "2026-01-01")

      assert_equal legacy["offerings"], user.reload.metadata["offerings"]
      assert_equal({ "arrival_window" => "new" }, defaults.read)
    end

    test "rejects forbidden values even when a malformed offering schema renders them" do
      temple = create_temple
      offering = create_offering(
        temple:,
        metadata: configured_metadata.merge(
          "registration_form" => {
            "sections" => { "logistics" => ["arrival_window", "quantity", "payment_status", "preferred_date"], "ritual_metadata" => ["ceremony_notes", "registrant_name"] }
          }
        )
      )
      defaults = ReusableDefaults.new(user: patron, temple:, offering:)

      defaults.write!("arrival_window" => "morning", "ceremony_notes" => "safe", "quantity" => 2, "payment_status" => "paid", "registrant_name" => "Private", "preferred_date" => "2026-01-01")

      assert_equal({ "arrival_window" => "morning", "ceremony_notes" => "safe" }, defaults.read)
    end

    test "uses schema allow_multiple as the only array authority and explicit clear is scoped" do
      temple = create_temple
      offering = create_offering(temple:, metadata: configured_metadata(multiple: true))
      user = patron
      defaults = ReusableDefaults.new(user:, temple:, offering:)

      defaults.write!("incense_option" => "rose", "arrival_window" => "morning")
      defaults.add!(field: "incense_option", value: "lotus")
      assert_equal ["rose", "lotus"], defaults.read["incense_option"]
      defaults.clear!(field: "incense_option", value: "rose")
      defaults.clear!(field: "arrival_window")

      assert_equal({ "incense_option" => ["lotus"] }, defaults.read)
      assert_raises(ArgumentError) { defaults.add!(field: "arrival_window", value: "night") }
      assert_raises(ArgumentError) { defaults.clear!(field: "quantity") }
    end

    private

    def configured_metadata(multiple: false)
      {
        "registration_form" => {
          "sections" => { "logistics" => ["arrival_window", "preferred_date"], "ritual_metadata" => ["incense_option"] },
          "field_settings" => { "incense_option" => { "allow_multiple" => multiple } }
        }
      }
    end

    def patron(metadata: {})
      User.create!(
        email: "patron-#{SecureRandom.hex(3)}@example.com",
        english_name: "Test Patron",
        encrypted_password: User.password_hash("Password123!"),
        metadata:
      )
    end
  end
end
