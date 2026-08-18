require "test_helper"

module Account
  class RegistrationIntakeFormTest < ActiveSupport::TestCase
    setup do
      @temple = create_temple
      @offering = create_offering(temple: @temple)
      @user = User.create!(
        email: "patron-#{SecureRandom.hex(2)}@example.com",
        english_name: "Patron",
        encrypted_password: User.password_hash("Password123!")
      )
      @dependent = Dependent.create!(english_name: "Kid")
      UserDependent.create!(user: @user, dependent: @dependent, role: "family", relationship_label: "Child")
    end

    test "creating a dependent-scoped registration routes contact sync through the shared service" do
      calls = []
      tracker = ->(**kwargs) { calls << kwargs }

      form = nil
      Registrations::DependentContactSync.stub(:call!, tracker) do
        form = RegistrationIntakeForm.new(
          user: @user,
          offering: @offering,
          params: {
            "registrant_scope" => "dependent",
            "dependent_id" => @dependent.id,
            "contact_name" => "Kid",
            "contact_phone" => "0955555555",
            "contact_email" => "kid@example.com",
            "household_notes" => "vegetarian"
          }
        )
        assert form.save, form.errors.full_messages.to_sentence
      end

      assert_equal 1, calls.size, "expected the shared DependentContactSync service to be invoked exactly once"
      assert_equal @dependent, calls.first[:dependent]
      assert_equal "0955555555", calls.first[:phone]
      assert_equal "kid@example.com", calls.first[:email]
      assert_equal "vegetarian", calls.first[:notes]
    end

    test "creating a self-scoped registration never invokes the dependent contact sync service" do
      calls = []
      tracker = ->(**kwargs) { calls << kwargs }

      form = nil
      Registrations::DependentContactSync.stub(:call!, tracker) do
        form = RegistrationIntakeForm.new(
          user: @user,
          offering: @offering,
          params: { "registrant_scope" => "self", "contact_name" => "Patron", "contact_phone" => "0911111111" }
        )
        assert form.save, form.errors.full_messages.to_sentence
      end

      assert_empty calls
    end
  end
end
