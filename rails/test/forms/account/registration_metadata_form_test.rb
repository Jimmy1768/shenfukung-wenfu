require "test_helper"

module Account
  class RegistrationMetadataFormTest < ActiveSupport::TestCase
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
      @registration = create_registration(user: @user, offering: @offering)
    end

    test "editing to a dependent-scoped registration routes contact sync through the shared service" do
      calls = []
      tracker = ->(**kwargs) { calls << kwargs }

      form = nil
      Registrations::DependentContactSync.stub(:call!, tracker) do
        form = RegistrationMetadataForm.new(
          registration: @registration,
          user: @user,
          params: {
            registrant_scope: "dependent",
            dependent_id: @dependent.id,
            contact_name: "Kid",
            contact_phone: "0966666666",
            contact_email: "kid-edit@example.com",
            household_notes: "no nuts"
          }
        )
        assert form.save, form.errors.full_messages.to_sentence
      end

      assert_equal 1, calls.size, "expected the shared DependentContactSync service to be invoked exactly once"
      assert_equal @dependent, calls.first[:dependent]
      assert_equal "0966666666", calls.first[:phone]
      assert_equal "kid-edit@example.com", calls.first[:email]
      assert_equal "no nuts", calls.first[:notes]
    end

    test "editing a self-scoped registration never invokes the dependent contact sync service" do
      calls = []
      tracker = ->(**kwargs) { calls << kwargs }

      form = nil
      Registrations::DependentContactSync.stub(:call!, tracker) do
        form = RegistrationMetadataForm.new(
          registration: @registration,
          user: @user,
          params: { registrant_scope: "self", contact_name: "Patron", contact_phone: "0922222222" }
        )
        assert form.save, form.errors.full_messages.to_sentence
      end

      assert_empty calls
    end
  end
end
