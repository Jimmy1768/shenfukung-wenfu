require "test_helper"

module Payments
  class TempleRegistrationBuilderTest < ActiveSupport::TestCase
    test "creates registration with defaults" do
      temple = create_temple
      offering = TempleOffering.create!(
        temple:,
        slug: "lamp",
        title: "Lamp",
        currency: "TWD",
        price_cents: 400,
        starts_on: Date.current,
        ends_on: Date.current + 1.day
      )
      admin = create_admin_user(temple:)

      builder = TempleRegistrationBuilder.new(
        temple:,
        offering:,
        admin_user: admin,
        attributes: { quantity: 2 }
      )

      registration = builder.create

      assert registration.persisted?
      assert_equal 800, registration.total_price_cents
      assert_equal offering.slug, registration.event_slug
    end

    test "creating a dependent-scoped registration routes contact sync through the shared service" do
      temple = create_temple
      offering = TempleOffering.create!(
        temple:,
        slug: "lamp",
        title: "Lamp",
        currency: "TWD",
        price_cents: 400,
        starts_on: Date.current,
        ends_on: Date.current + 1.day
      )
      admin = create_admin_user(temple:)
      patron = User.create!(
        email: "patron-#{SecureRandom.hex(2)}@example.com",
        english_name: "Patron",
        encrypted_password: User.password_hash("Password123!")
      )
      dependent = Dependent.create!(english_name: "Kid")
      UserDependent.create!(user: patron, dependent:, role: "family", relationship_label: "Child")

      calls = []
      tracker = ->(**kwargs) { calls << kwargs }

      registration = nil
      Registrations::DependentContactSync.stub(:call!, tracker) do
        builder = TempleRegistrationBuilder.new(
          temple:,
          offering:,
          admin_user: admin,
          attributes: {
            user_id: patron.id,
            quantity: 1,
            contact_payload: { phone: "0977777777", email: "kid-admin@example.com", dependents_notes: "gluten free" },
            metadata: { registrant_scope: "dependent", dependent_id: dependent.id }
          }
        )
        registration = builder.create
      end

      assert registration.persisted?
      assert_equal 1, calls.size, "expected the shared DependentContactSync service to be invoked exactly once"
      assert_equal dependent, calls.first[:dependent]
      assert_equal "0977777777", calls.first[:phone]
      assert_equal "kid-admin@example.com", calls.first[:email]
      assert_equal "gluten free", calls.first[:notes]
    end

    test "creating a self-scoped registration never invokes the dependent contact sync service" do
      temple = create_temple
      offering = TempleOffering.create!(
        temple:,
        slug: "lamp",
        title: "Lamp",
        currency: "TWD",
        price_cents: 400,
        starts_on: Date.current,
        ends_on: Date.current + 1.day
      )
      admin = create_admin_user(temple:)
      patron = User.create!(
        email: "patron-#{SecureRandom.hex(2)}@example.com",
        english_name: "Patron",
        encrypted_password: User.password_hash("Password123!")
      )

      calls = []
      tracker = ->(**kwargs) { calls << kwargs }

      Registrations::DependentContactSync.stub(:call!, tracker) do
        builder = TempleRegistrationBuilder.new(
          temple:,
          offering:,
          admin_user: admin,
          attributes: { user_id: patron.id, quantity: 1 }
        )
        builder.create
      end

      assert_empty calls
    end
  end
end
