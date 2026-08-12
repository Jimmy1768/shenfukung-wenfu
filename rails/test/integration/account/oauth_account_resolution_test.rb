require "test_helper"

module Account
  class OauthAccountResolutionTest < ActionDispatch::IntegrationTest
    FakeCentralOAuthClient = Struct.new(:response) do
      def start(**) = { "redirect_url" => "https://auth.example.test/authorize" }
      def exchange(**) = response
    end

    setup { Config::EntryResolver.upsert!(key: "oauth_account_resolution", value: true) }

    test "unmatched Apple callback creates no user or account session and offers proof choices" do
      temple = create_temple(slug: "resolution-temple")
      get central_oauth_start_path(provider: "apple", surface: "account", temple_slug: temple.slug)
      client = FakeCentralOAuthClient.new({ "provider" => "apple", "uid" => "unmatched-apple", "email" => "relay@example.test", "email_verified" => true })

      assert_difference("::OAuthAccountResolution.count", 1) do
        assert_no_difference("User.count") do
          Auth::CentralOAuthClient.stub(:new, client) { get central_oauth_callback_path(code: "code") }
        end
      end
      assert_redirected_to /account\/oauth\/resolution/
      assert_nil session[AppConstants::Sessions.key(:account)]
      follow_redirect!
      assert_includes response.body, "I already have an account"
      assert_includes response.body, "Create a new account"
    end

    test "existing-account proof links pending Apple identity and consumes it once" do
      temple = create_temple(slug: "resolution-existing-temple")
      user = User.create!(email: "existing@example.test", english_name: "Existing", encrypted_password: User.password_hash("Password123!"), metadata: {})
      pending = Auth::OAuthAccountResolution.create!(provider: "apple", uid: "pending-apple", email: "relay@example.test", name: nil, email_verified: true, surface: "account")

      post account_oauth_resolution_existing_path, params: { token: pending.token, provider: "apple", account: { email: user.email, password: "Password123!" } }
      assert_redirected_to account_dashboard_path
      assert_equal user.id, OAuthIdentity.find_by!(provider: "apple", provider_uid: "pending-apple").user_id
      assert_equal user.id, session[AppConstants::Sessions.key(:account)]
      assert ::OAuthAccountResolution.find(pending.record.id).consumed_at.present?
    end

    test "browser resolution rejects a native-purpose token without consuming it" do
      pending = Auth::OAuthAccountResolution.create!(provider: "apple", uid: "native-only-subject", email: nil, name: nil, email_verified: nil, surface: "native")

      get account_oauth_resolution_path(token: pending.token, provider: "apple")

      assert_redirected_to account_login_path
      assert_nil pending.record.reload.consumed_at
      assert_equal "native", pending.record.surface
    end

    test "admin unmatched OAuth is lookup-only and cannot provision a user" do
      temple = create_temple(slug: "resolution-admin-temple")
      get central_oauth_start_path(provider: "apple", surface: "admin", temple_slug: temple.slug)
      client = FakeCentralOAuthClient.new({ "provider" => "apple", "uid" => "admin-unmatched", "email" => "relay@example.test" })

      assert_no_difference(["User.count", "OAuthIdentity.count", "::OAuthAccountResolution.count"]) do
        Auth::CentralOAuthClient.stub(:new, client) { get central_oauth_callback_path(code: "code") }
      end
      assert_redirected_to admin_login_path
      assert_nil session[AppConstants::Sessions.key(:admin)]
      assert_nil session[AppConstants::Sessions.key(:account)]
    end
  end
end
