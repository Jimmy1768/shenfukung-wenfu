# frozen_string_literal: true

require "test_helper"
require "base64"
require "json"

module Auth
  class OAuthExchangeIdentityTest < ActiveSupport::TestCase
    test "normalizes nested Google claims into an exact existing identity and shared terms/profile result" do
      user = user_with(email: "shared-google@example.test", name: "Shared Google")
      identity = OAuthIdentity.create!(
        user:,
        provider: "google_oauth2",
        provider_uid: "shared-google-subject",
        email: user.email,
        credentials: {},
        metadata: {}
      )

      result = OAuthExchangeIdentity.resolve!(
        response: {
          "claims" => {
            "provider" => "google",
            "sub" => "shared-google-subject",
            "email" => user.email,
            "name" => user.english_name,
            "email_verified" => true
          },
          "credentials" => { "token" => "central-secret" }
        }
      )

      assert_equal identity.id, result.identity.id
      assert_equal user.id, result.user.id
      assert_equal "google_oauth2", result.provider
      assert_equal "google", result.canonical_provider
      assert_equal false, result.profile_required
      assert_equal "google_oauth2", user.reload.metadata["signup_source"]
      assert_equal AppConstants::Legal.default_terms_version, user.metadata["terms_version"]
    end

    test "links a verified Google email through the existing resolver" do
      user = user_with(email: "shared-link@example.test", name: "Shared Link")

      result = OAuthExchangeIdentity.resolve!(
        response: {
          "identity" => {
            "provider" => "google",
            "provider_uid" => "shared-linked-subject",
            "email" => user.email,
            "email_verified" => "true"
          },
          "user" => { "name" => user.english_name }
        }
      )

      assert_equal user.id, result.user.id
      assert_equal user.id, result.identity.user_id
      assert_equal true, result.link_result.linked_existing_user
      assert_equal "google_oauth2", result.identity.provider
    end

    test "uses Apple nested id-token claims and classifies a first user as profile required" do
      result = OAuthExchangeIdentity.resolve!(
        response: {
          "identity" => { "provider" => "apple" },
          "credentials" => { "id_token" => id_token(sub: "shared-apple-subject", email: "shared-apple@example.test") }
        }
      )

      assert_equal "apple", result.provider
      assert_equal "apple", result.canonical_provider
      assert_equal "shared-apple-subject", result.identity.provider_uid
      assert_equal true, result.profile_required
      assert_equal "OAuth User", result.user.english_name
    end

    test "fails closed for malformed, mismatched, and closed exchange identities" do
      assert_raises(OAuthExchangeIdentity::MissingProvider) { OAuthExchangeIdentity.resolve!(response: {}) }

      assert_no_difference("OAuthIdentity.count") do
        assert_raises(OAuthExchangeIdentity::ProviderMismatch) do
          OAuthExchangeIdentity.resolve!(
            response: { "provider" => "apple", "uid" => "mismatch-subject" },
            expected_provider: "google"
          )
        end
      end

      user = user_with(email: "shared-closed@example.test", name: "Shared Closed")
      OAuthIdentity.create!(user:, provider: "apple", provider_uid: "shared-closed-subject", email: user.email, credentials: {}, metadata: {})
      user.close_account!(reason: "self_service")

      assert_raises(OAuthExchangeIdentity::ClosedAccount) do
        OAuthExchangeIdentity.resolve!(response: { "provider" => "apple", "uid" => "shared-closed-subject", "email" => user.email })
      end
    end

    test "browser and native flows delegate their exchange identity work to this service" do
      assert_includes File.read(Rails.root.join("app/controllers/auth/central_oauth_controller.rb")), "Auth::OAuthExchangeIdentity.resolve!"
      assert_includes File.read(Rails.root.join("app/services/auth/native_oauth_flow.rb")), "Auth::OAuthExchangeIdentity.resolve!"
      refute_includes File.read(Rails.root.join("app/services/auth/oauth_exchange_identity.rb")), "Rails.logger"
    end

    private

    def user_with(email:, name:)
      User.create!(
        email:,
        english_name: name,
        encrypted_password: User.password_hash("Password123!"),
        metadata: {}
      )
    end

    def id_token(sub:, email:)
      payload = Base64.urlsafe_encode64(JSON.generate({ "sub" => sub, "email" => email }), padding: false)
      "header.#{payload}.signature"
    end
  end
end
