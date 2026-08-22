require "test_helper"

module Account
  class OAuthEmptyPlaceholderConsolidationFlowTest < ActionDispatch::IntegrationTest
    FakeCentralOAuthClient = Struct.new(:response) do
      def start(**) = { "redirect_url" => "https://auth.example.test/authorize" }
      def exchange(**) = response
    end

    setup do
      Config::EntryResolver.upsert!(key: "oauth_account_linking", value: true)
      Config::EntryResolver.upsert!(key: "oauth_account_consolidation", value: true)
      @temple = create_temple(slug: "consolidation-temple")
    end

    test "signed-in keeper is offered consolidation, and confirming moves the identity and closes the orphan" do
      keeper = create_keeper
      orphan = create_orphan
      identity = OAuthIdentity.create!(user: orphan, provider: "apple", provider_uid: "orphan-subject", email: "relay@example.test", credentials: {}, metadata: {})

      token, provider = start_link_and_capture_consolidation_token(keeper, "apple", "orphan-subject")

      assert_response :success
      assert_includes response.body, I18n.t("account.oauth_consolidations.show.submit")

      post account_oauth_consolidation_path, params: { token:, provider:, account: { password: "Password123!", confirmed: "true" } }

      assert_redirected_to account_oauth_identities_path
      assert_equal keeper.id, identity.reload.user_id
      assert orphan.reload.closed_account?
      assert_equal "operator_action", orphan.reload.closure_reason
      refute orphan.oauth_identities.exists?
    end

    test "wrong keeper password does not move the identity or consume the token, and can be retried" do
      keeper = create_keeper
      orphan = create_orphan
      identity = OAuthIdentity.create!(user: orphan, provider: "apple", provider_uid: "wrong-password-subject", email: "relay@example.test", credentials: {}, metadata: {})

      token, provider = start_link_and_capture_consolidation_token(keeper, "apple", "wrong-password-subject")

      post account_oauth_consolidation_path, params: { token:, provider:, account: { password: "not-the-password", confirmed: "true" } }
      assert_redirected_to account_oauth_consolidation_path(token:, provider:)
      assert_equal orphan.id, identity.reload.user_id
      refute orphan.reload.closed_account?

      # the token survives a failed proof attempt and can still be retried
      post account_oauth_consolidation_path, params: { token:, provider:, account: { password: "Password123!", confirmed: "true" } }
      assert_redirected_to account_oauth_identities_path
      assert_equal keeper.id, identity.reload.user_id
    end

    test "does not offer consolidation when the placeholder is not actually empty" do
      keeper = create_keeper
      busy_orphan = create_orphan(email: "busy@example.test")
      identity = OAuthIdentity.create!(user: busy_orphan, provider: "apple", provider_uid: "busy-subject", email: "relay@example.test", credentials: {}, metadata: {})
      busy_orphan.refresh_tokens.create!(token_digest: "refresh-token-#{SecureRandom.hex(8)}", expires_at: 1.day.from_now)

      sign_in_account(keeper, temple_slug: @temple.slug)
      get central_oauth_start_path(provider: "apple", surface: "account", intent: "link", origin: account_oauth_identities_path, temple_slug: @temple.slug)
      client = FakeCentralOAuthClient.new({ "provider" => "apple", "uid" => "busy-subject", "email" => "relay@example.test", "email_verified" => true })

      assert_no_difference("::OAuthAccountResolution.count") do
        Auth::CentralOAuthClient.stub(:new, client) { get central_oauth_callback_path(code: "code") }
      end
      assert_redirected_to account_oauth_identities_path
      assert_equal busy_orphan.id, identity.reload.user_id
    end

    test "does not offer consolidation when the consolidation flag is disabled" do
      Config::EntryResolver.upsert!(key: "oauth_account_consolidation", value: false)
      keeper = create_keeper
      orphan = create_orphan
      identity = OAuthIdentity.create!(user: orphan, provider: "apple", provider_uid: "flag-off-subject", email: "relay@example.test", credentials: {}, metadata: {})

      sign_in_account(keeper, temple_slug: @temple.slug)
      get central_oauth_start_path(provider: "apple", surface: "account", intent: "link", origin: account_oauth_identities_path, temple_slug: @temple.slug)
      client = FakeCentralOAuthClient.new({ "provider" => "apple", "uid" => "flag-off-subject", "email" => "relay@example.test", "email_verified" => true })

      assert_no_difference("::OAuthAccountResolution.count") do
        Auth::CentralOAuthClient.stub(:new, client) { get central_oauth_callback_path(code: "code") }
      end
      assert_redirected_to account_oauth_identities_path
      assert_equal orphan.id, identity.reload.user_id
      refute orphan.reload.closed_account?
    end

    test "provider-form handling is correct for a Google conflict, not just Apple" do
      keeper = create_keeper
      orphan = create_orphan(email: "google-orphan@example.test")
      identity = OAuthIdentity.create!(user: orphan, provider: "google_oauth2", provider_uid: "google-orphan-subject", email: "orphan-gmail@example.test", credentials: {}, metadata: {})

      token, provider = start_link_and_capture_consolidation_token(keeper, "google", "google-orphan-subject", email: "orphan-gmail@example.test")
      assert_equal "google", provider

      post account_oauth_consolidation_path, params: { token:, provider:, account: { password: "Password123!", confirmed: "true" } }
      assert_redirected_to account_oauth_identities_path
      assert_equal keeper.id, identity.reload.user_id
      assert orphan.reload.closed_account?
    end

    test "re-linking the same provider with a different uid still hits the plain conflict path, not consolidation" do
      keeper = create_keeper
      OAuthIdentity.create!(user: keeper, provider: "apple", provider_uid: "keepers-own-subject", email: keeper.email, credentials: {}, metadata: {})

      sign_in_account(keeper, temple_slug: @temple.slug)
      get central_oauth_start_path(provider: "apple", surface: "account", intent: "link", origin: account_oauth_identities_path, temple_slug: @temple.slug)
      client = FakeCentralOAuthClient.new({ "provider" => "apple", "uid" => "a-different-apple-subject", "email" => keeper.email, "email_verified" => true })

      assert_no_difference("::OAuthAccountResolution.count") do
        Auth::CentralOAuthClient.stub(:new, client) { get central_oauth_callback_path(code: "code") }
      end
      assert_redirected_to account_oauth_identities_path
      assert_equal "keepers-own-subject", keeper.oauth_identities.find_by!(provider: "apple").provider_uid
    end

    private

    def create_keeper(email: "keeper@example.test")
      User.create!(email:, english_name: "Keeper", encrypted_password: User.password_hash("Password123!"), metadata: {})
    end

    def create_orphan(email: "orphan@example.test")
      User.create!(email:, english_name: "OAuth User", encrypted_password: User.password_hash("Password123!"), metadata: { "oauth_seeded" => true })
    end

    def start_link_and_capture_consolidation_token(keeper, provider, uid, email: "relay@example.test")
      sign_in_account(keeper, temple_slug: @temple.slug)
      get central_oauth_start_path(provider:, surface: "account", intent: "link", origin: account_oauth_identities_path, temple_slug: @temple.slug)
      client = FakeCentralOAuthClient.new({ "provider" => provider, "uid" => uid, "email" => email, "email_verified" => true })

      Auth::CentralOAuthClient.stub(:new, client) { get central_oauth_callback_path(code: "code") }
      assert_redirected_to %r{/account/oauth/consolidation\?}
      location = URI.parse(response.headers["Location"])
      query = Rack::Utils.parse_nested_query(location.query)
      follow_redirect!
      [query["token"], query["provider"]]
    end
  end
end
