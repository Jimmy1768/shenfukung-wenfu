require "test_helper"

module Auth
  class OAuthIdentityLinkerTest < ActiveSupport::TestCase
    test "ConflictError carries the identity already owned by another user" do
      owner = User.create!(email: "owner@example.test", english_name: "Owner", encrypted_password: User.password_hash("Password123!"), metadata: {})
      other = User.create!(email: "other@example.test", english_name: "Other", encrypted_password: User.password_hash("Password123!"), metadata: {})
      identity = OAuthIdentity.create!(user: owner, provider: "apple", provider_uid: "taken-subject", email: owner.email, credentials: {}, metadata: {})

      error = assert_raises(OAuthIdentityLinker::ConflictError) do
        OAuthIdentityLinker.link!(user: other, provider: "apple", uid: "taken-subject", email: "other@example.test")
      end

      assert_equal identity.id, error.identity.id
      assert_equal owner.id, error.identity.user_id
    end

    test "linking while already signed in requires no password and links immediately" do
      user = User.create!(email: "linker@example.test", english_name: "Linker", encrypted_password: User.password_hash("Password123!"), metadata: {})

      result = OAuthIdentityLinker.link!(user:, provider: "apple", uid: "fresh-subject", email: "linker@example.test")

      assert result.created_identity
      refute result.already_linked
      assert_equal user.id, result.identity.user_id
    end
  end
end
