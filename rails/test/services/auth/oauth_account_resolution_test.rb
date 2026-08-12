require "test_helper"

module Auth
  class OAuthAccountResolutionTest < ActiveSupport::TestCase
    setup { Config::EntryResolver.upsert!(key: "oauth_account_resolution", value: true) }

    test "holds an unmatched identity without creating a user and consumes it once after existing-account proof" do
      keeper = user("keeper@example.test", "Keeper")
      result = OAuthAccountResolution.create!(provider: "apple", uid: "apple-subject", email: "relay@example.test", name: nil, email_verified: true, surface: "account")

      assert_equal 0, OAuthIdentity.count
      assert_equal 1, ::OAuthAccountResolution.count
      refute_includes SystemAuditLog.last.metadata.to_json, "apple-subject"
      refute_includes SystemAuditLog.last.metadata.to_json, "relay@example.test"

      linked = OAuthAccountResolution.consume_existing!(token: result.token, provider: "apple", surface: "account", email: keeper.email, password: "Password123!")
      assert_equal keeper.id, linked.id
      assert_equal keeper.id, OAuthIdentity.find_by!(provider: "apple", provider_uid: "apple-subject").user_id
      assert_raises(OAuthAccountResolution::Consumed) { OAuthAccountResolution.consume_existing!(token: result.token, provider: "apple", surface: "account", email: keeper.email, password: "Password123!") }
    end

    test "fails closed on expiry provider mismatch bad proof and disabled gate" do
      result = OAuthAccountResolution.create!(provider: "apple", uid: "subject", email: nil, name: nil, email_verified: nil, surface: "native")
      assert_raises(OAuthAccountResolution::ProviderMismatch) { OAuthAccountResolution.find!(token: result.token, provider: "google_oauth2", surface: "native") }
      assert_raises(OAuthAccountResolution::SurfaceMismatch) { OAuthAccountResolution.find!(token: result.token, provider: "apple", surface: "account") }
      assert_raises(OAuthAccountResolution::ExistingAccountProofFailed) { OAuthAccountResolution.consume_existing!(token: result.token, provider: "apple", surface: "native", email: "none@example.test", password: "wrong") }
      result.record.update_column(:expires_at, 1.second.ago)
      assert_raises(OAuthAccountResolution::Expired) { OAuthAccountResolution.find!(token: result.token, provider: "apple", surface: "native") }
      Config::EntryResolver.upsert!(key: "oauth_account_resolution", value: false)
      assert_raises(OAuthAccountResolution::FeatureDisabled) { OAuthAccountResolution.create!(provider: "apple", uid: "new", email: nil, name: nil, email_verified: nil, surface: "account") }
    end

    test "new account requires explicit terms and creates atomically" do
      result = OAuthAccountResolution.create!(provider: "apple", uid: "new-subject", email: "new@example.test", name: nil, email_verified: true, surface: "account")
      assert_raises(OAuthAccountResolution::ExistingAccountProofFailed) do
        OAuthAccountResolution.consume_new!(token: result.token, provider: "apple", surface: "account", email: "new@example.test", password: "Password123!", name: "New User", terms_accepted: false)
      end
      user = OAuthAccountResolution.consume_new!(token: result.token, provider: "apple", surface: "account", email: "new@example.test", password: "Password123!", name: "New User", terms_accepted: true)
      assert_equal user.id, OAuthIdentity.find_by!(provider: "apple", provider_uid: "new-subject").user_id
      assert_equal AppConstants::Legal.default_terms_version, user.metadata["terms_version"]
    end

    private

    def user(email, name)
      User.create!(email:, english_name: name, encrypted_password: User.password_hash("Password123!"), metadata: {})
    end
  end
end
