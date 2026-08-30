# frozen_string_literal: true

require "test_helper"

module Registrations
  class UserMetadataUpdaterTest < ActiveSupport::TestCase
    setup do
      @temple = create_temple
      @offering = create_offering(temple: @temple)
      @user = User.create!(
        email: "updater-#{SecureRandom.hex(3)}@example.com",
        english_name: "Profile Owner",
        encrypted_password: User.password_hash("Password123!"),
        metadata: { "phone" => "0900-000-000", "notes" => "patron's own note", "city" => "Miaoli" }
      )
    end

    def run_updater(contact:)
      UserMetadataUpdater.new(
        user: @user, offering: @offering,
        contact_payload: contact, logistics_payload: {}, ritual_metadata: {}
      ).update!
      @user.reload
    end

    test "a registration never overwrites the patron's own profile phone or notes" do
      run_updater(contact: { "phone" => "0911-111-111", "notes" => "took payment at desk" })

      assert_equal "0900-000-000", @user.metadata["phone"]
      assert_equal "patron's own note", @user.metadata["notes"]
      assert_equal "Miaoli", @user.metadata["city"]
    end

    test "registration contact is cached under its own namespace" do
      run_updater(contact: { "phone" => "0911-111-111", "notes" => "took payment at desk" })

      scoped = @user.metadata[UserMetadataUpdater::NAMESPACE]
      assert_equal "0911-111-111", scoped["phone"]
      assert_equal "took payment at desk", scoped["notes"]
    end

    test "dependents_notes never lands on the patron -- it belongs to the dependent" do
      run_updater(contact: { "dependents_notes" => "about the child", "notes" => "about the patron" })

      scoped = @user.metadata[UserMetadataUpdater::NAMESPACE]
      # Previously both mapped to "notes" and hash order silently dropped one.
      assert_equal "about the patron", scoped["notes"]
      refute_equal "about the child", scoped["notes"]
      assert_equal "patron's own note", @user.metadata["notes"]
    end

    test "blank registration values never clear a cached value" do
      run_updater(contact: { "phone" => "0911-111-111" })
      run_updater(contact: { "phone" => "" })

      assert_equal "0911-111-111", @user.metadata[UserMetadataUpdater::NAMESPACE]["phone"]
    end
  end

  class ReusableContactTest < ActiveSupport::TestCase
    def user_with(profile: {}, registration: nil)
      metadata = profile.dup
      metadata[UserMetadataUpdater::NAMESPACE] = registration if registration
      User.create!(
        email: "contact-#{SecureRandom.hex(3)}@example.com",
        english_name: "Reader",
        encrypted_password: User.password_hash("Password123!"),
        metadata: metadata
      )
    end

    test "prefers the most recently captured registration contact" do
      user = user_with(profile: { "phone" => "0900-000-000" }, registration: { "phone" => "0911-111-111" })

      assert_equal "0911-111-111", ReusableContact.read(user, :phone)
    end

    test "falls back to the patron's profile when no registration value exists" do
      user = user_with(profile: { "phone" => "0900-000-000" })

      assert_equal "0900-000-000", ReusableContact.read(user, :phone)
    end

    test "falls back when the registration value is blank rather than returning blank" do
      user = user_with(profile: { "phone" => "0900-000-000" }, registration: { "phone" => "" })

      assert_equal "0900-000-000", ReusableContact.read(user, :phone)
    end

    test "returns nil for fields outside the contact set" do
      user = user_with(profile: { "city" => "Miaoli" })

      assert_nil ReusableContact.read(user, :city)
    end

    test "tolerates a user with no metadata at all" do
      user = user_with

      assert_nil ReusableContact.read(user, :phone)
    end
  end
end
