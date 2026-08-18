require "test_helper"

module Registrations
  class DependentContactSyncTest < ActiveSupport::TestCase
    setup do
      @dependent = Dependent.create!(english_name: "Family Member", metadata: { "phone" => "0900000000" })
    end

    test "merges only present phone/email/notes values onto dependent metadata" do
      DependentContactSync.call!(dependent: @dependent, phone: "0911111111", email: "member@example.com", notes: "vegetarian")

      @dependent.reload
      assert_equal "0911111111", @dependent.metadata["phone"]
      assert_equal "member@example.com", @dependent.metadata["email"]
      assert_equal "vegetarian", @dependent.metadata["notes"]
    end

    test "ignores blank candidate values and preserves existing metadata for that field" do
      DependentContactSync.call!(dependent: @dependent, phone: "", email: nil, notes: "  ")

      @dependent.reload
      assert_equal "0900000000", @dependent.metadata["phone"]
      assert_nil @dependent.metadata["email"]
      assert_nil @dependent.metadata["notes"]
    end

    test "does nothing when dependent is nil" do
      assert_nothing_raised do
        DependentContactSync.call!(dependent: nil, phone: "0922222222", email: "x@example.com", notes: "n")
      end
    end

    test "does nothing when all candidate values are blank" do
      DependentContactSync.call!(dependent: @dependent, phone: nil, email: nil, notes: nil)

      @dependent.reload
      assert_equal({ "phone" => "0900000000" }, @dependent.metadata)
    end

    test "does not issue a write when the merge produces identical metadata" do
      DependentContactSync.call!(dependent: @dependent, phone: "0900000000")

      @dependent.reload
      assert_equal "0900000000", @dependent.metadata["phone"]
      assert_not @dependent.previously_new_record?
    end

    test "merges partial values without clobbering unrelated existing keys" do
      @dependent.update!(metadata: { "phone" => "0900000000", "email" => "old@example.com", "notes" => "old note" })

      DependentContactSync.call!(dependent: @dependent, email: "new@example.com")

      @dependent.reload
      assert_equal "0900000000", @dependent.metadata["phone"]
      assert_equal "new@example.com", @dependent.metadata["email"]
      assert_equal "old note", @dependent.metadata["notes"]
    end
  end
end
