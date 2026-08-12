# frozen_string_literal: true

require "test_helper"
require "base64"
require "json"

class NativeOauthContractTest < ActionDispatch::IntegrationTest
  FakeCentralOAuthClient = Struct.new(:start_response, :exchange_response, :start_error, :exchange_error) do
    attr_reader :start_calls, :exchange_calls

    def start(**arguments)
      (@start_calls ||= []) << arguments
      raise start_error if start_error
      start_response
    end

    def exchange(**arguments)
      (@exchange_calls ||= []) << arguments
      raise exchange_error if exchange_error
      exchange_response
    end
  end

  def setup
    @temple = create_temple(slug: "native-oauth-temple")
    Config::EntryResolver.upsert!(key: "oauth_account_resolution", value: true)
    @return_url = "templemate://oauth/complete"
    @verifier = "v" * 43
    @challenge = Auth::NativeOAuthTransaction.s256_challenge(@verifier)
  end

  test "Google start uses only server selected return URL and exact S256 arguments" do
    central = FakeCentralOAuthClient.new({ "redirect_url" => "https://central.example.test/google" }, nil)

    with_return_url do
      Auth::CentralOAuthClient.stub(:new, central) do
        post native_start_path, params: start_params(provider: "google").merge(return_url: "https://attacker.test", origin: "https://attacker.test", surface: "admin")
      end
    end

    assert_response :created
    oauth = response.parsed_body.fetch("oauth")
    assert_equal "google", oauth.fetch("provider")
    assert_equal @return_url, oauth.fetch("redirect_uri")
    assert_equal "https://central.example.test/google", oauth.fetch("authorization_url")
    refute_includes response.body, @challenge
    assert_equal [
      {
        provider: "google",
        return_url: @return_url,
        tenant_slug: @temple.slug,
        pkce_challenge: @challenge,
        pkce_method: "S256",
        context: { "native_oauth_contract" => "v1" }
      }
    ], central.start_calls
  end

  test "Apple exchange creates only account scoped native session and redacts central credentials" do
    dual_role_user = create_admin_user(temple: @temple)
    OAuthIdentity.create!(user: dual_role_user, provider: "apple", provider_uid: "apple-native-subject", email: dual_role_user.email, credentials: {}, metadata: {})
    central = FakeCentralOAuthClient.new(
      { "redirect_url" => "https://central.example.test/apple" },
      identity_response(provider: "apple", uid: "apple-native-subject", email: dual_role_user.email, name: "Admin User", token: "provider-secret-token")
    )
    transaction_token = start_transaction(central, provider: "apple")

    with_return_url do
      Auth::CentralOAuthClient.stub(:new, central) do
        post native_exchange_path, params: exchange_params(transaction_token)
      end
    end

    assert_response :success
    body = response.parsed_body
    assert_equal "apple", body.dig("oauth", "provider")
    assert_equal false, body.dig("oauth", "profile_required")
    assert_not body.fetch("user").key?("admin_account")
    assert_not_includes response.body, "provider-secret-token"
    assert_not_includes response.body, "apple-native-subject"
    claims = Auth::JwtService.decode(body.dig("session", "access_token"))
    assert_equal "account", claims.fetch("scope")
    assert_equal dual_role_user.id, claims.fetch("sub")
    assert_nil session[AppConstants::Sessions.key(:account)]
    assert_equal @return_url, central.exchange_calls.fetch(0).dig(:params, :return_url)
    assert_equal @verifier, central.exchange_calls.fetch(0).dig(:params, :pkce_verifier)
    assert_equal "apple", central.exchange_calls.fetch(0).dig(:params, :provider)
  end

  test "existing identity and profile-required outcomes reuse resolver semantics" do
    user = User.create!(email: "existing-native@example.test", english_name: "Existing Native", encrypted_password: User.password_hash("Password123!"), metadata: {})
    OAuthIdentity.create!(user:, provider: "google_oauth2", provider_uid: "existing-google-subject", email: user.email, credentials: {}, metadata: {})
    central = FakeCentralOAuthClient.new({ "redirect_url" => "https://central.example.test/google" }, identity_response(provider: "google", uid: "existing-google-subject", email: user.email, name: "Existing Native"))

    token = start_transaction(central, provider: "google")
    with_return_url { Auth::CentralOAuthClient.stub(:new, central) { post native_exchange_path, params: exchange_params(token) } }
    assert_response :success
    assert_equal user.id, response.parsed_body.dig("user", "id")
    assert_equal false, response.parsed_body.dig("oauth", "profile_required")

    profile_central = FakeCentralOAuthClient.new({ "redirect_url" => "https://central.example.test/apple" }, identity_response(provider: "apple", uid: "profile-apple-subject", email: "profile-native@example.test", name: nil))
    profile_token = start_transaction(profile_central, provider: "apple")
    with_return_url { Auth::CentralOAuthClient.stub(:new, profile_central) { post native_exchange_path, params: exchange_params(profile_token) } }
    assert_response :conflict
    assert_equal "account_resolution_required", response.parsed_body.fetch("code")
    assert_nil response.parsed_body["session"]
    assert response.parsed_body.dig("oauth", "resolution_token").present?
    assert_nil session[AppConstants::Sessions.key(:account)]
  end

  test "native exchange uses shared nested Google claims and Apple id-token fallbacks" do
    google = FakeCentralOAuthClient.new(
      { "redirect_url" => "https://central.example.test/google" },
      {
        "claims" => {
          "provider" => "google",
          "sub" => "nested-google-subject",
          "email" => "nested-google@example.test",
          "name" => "Nested Google",
          "email_verified" => true
        },
        "credentials" => { "token" => "central-token" }
      }
    )
    google_token = start_transaction(google, provider: "google")
    with_return_url { Auth::CentralOAuthClient.stub(:new, google) { post native_exchange_path, params: exchange_params(google_token) } }
    assert_response :conflict
    assert_equal "google", response.parsed_body.dig("oauth", "provider")
    refute OAuthIdentity.exists?(provider: "google_oauth2", provider_uid: "nested-google-subject")

    apple = FakeCentralOAuthClient.new(
      { "redirect_url" => "https://central.example.test/apple" },
      {
        "identity" => { "provider" => "apple" },
        "credentials" => { "id_token" => id_token(sub: "nested-apple-subject", email: "nested-apple@example.test") }
      }
    )
    apple_token = start_transaction(apple, provider: "apple")
    with_return_url { Auth::CentralOAuthClient.stub(:new, apple) { post native_exchange_path, params: exchange_params(apple_token) } }
    assert_response :conflict
    assert_equal "apple", response.parsed_body.dig("oauth", "provider")
    refute OAuthIdentity.exists?(provider: "apple", provider_uid: "nested-apple-subject")
  end

  test "a verified email user is not linked without an explicit proof flow" do
    user = User.create!(email: "verified-link@example.test", english_name: "Verified Link", encrypted_password: User.password_hash("Password123!"), metadata: {})
    central = FakeCentralOAuthClient.new(
      { "redirect_url" => "https://central.example.test/google" },
      identity_response(provider: "google", uid: "verified-link-subject", email: user.email, name: "Verified Link")
    )
    token = start_transaction(central)

    with_return_url { Auth::CentralOAuthClient.stub(:new, central) { post native_exchange_path, params: exchange_params(token) } }

    assert_response :conflict
    assert_equal "account_resolution_required", response.parsed_body.fetch("code")
    assert_nil OAuthIdentity.find_by(provider: "google_oauth2", provider_uid: "verified-link-subject")
  end

  test "start rejects unsupported or malformed input missing configuration unknown temple and ignores client redirect fields" do
    post native_start_path, params: start_params(provider: "facebook")
    assert_response :unprocessable_entity
    assert_equal "unsupported_oauth_provider", response.parsed_body.fetch("code")

    post native_start_path, params: start_params(pkce_method: "plain")
    assert_response :unprocessable_entity
    assert_equal "invalid_pkce", response.parsed_body.fetch("code")

    post native_start_path, params: { temple_slug: @temple.slug, oauth: { provider: "google", pkce_challenge: @challenge, pkce_method: "S256" } }
    assert_response :service_unavailable
    assert_equal "native_oauth_unavailable", response.parsed_body.fetch("code")

    with_return_url do
      post native_start_path(temple_slug: "not-a-temple"), params: { oauth: { provider: "google", pkce_challenge: @challenge, pkce_method: "S256" } }
    end
    assert_response :not_found
    assert_equal "tenant_not_found", response.parsed_body.fetch("code")
  end

  test "exchange rejects tamper wrong temple changed return verifier mismatch and provider mismatch without a session" do
    central = FakeCentralOAuthClient.new({ "redirect_url" => "https://central.example.test/google" }, identity_response)
    token = start_transaction(central)

    with_return_url do
      Auth::CentralOAuthClient.stub(:new, central) do
        post native_exchange_path, params: exchange_params("#{token}x")
        assert_response :unauthorized
        assert_equal "invalid_oauth_transaction", response.parsed_body.fetch("code")

        post native_exchange_path(temple_slug: create_temple.slug), params: exchange_params(token)
        assert_response :unauthorized
        assert_equal "invalid_oauth_transaction", response.parsed_body.fetch("code")

        post native_exchange_path, params: exchange_params(token, verifier: "x" * 43)
        assert_response :unauthorized
        assert_equal "invalid_oauth_transaction", response.parsed_body.fetch("code")
      end
    end
    assert_empty central.exchange_calls.to_a
    assert_nil session[AppConstants::Sessions.key(:account)]

    mismatch = FakeCentralOAuthClient.new({ "redirect_url" => "https://central.example.test/google" }, identity_response(provider: "apple", uid: "mismatch"))
    mismatch_token = start_transaction(mismatch)
    with_return_url { Auth::CentralOAuthClient.stub(:new, mismatch) { post native_exchange_path, params: exchange_params(mismatch_token) } }
    assert_response :unprocessable_entity
    assert_equal "oauth_provider_mismatch", response.parsed_body.fetch("code")
    assert_nil session[AppConstants::Sessions.key(:account)]
  end

  test "exchange rejects a missing code before contacting central auth" do
    central = FakeCentralOAuthClient.new({ "redirect_url" => "https://central.example.test/google" }, identity_response)
    token = start_transaction(central)

    with_return_url do
      Auth::CentralOAuthClient.stub(:new, central) do
        post native_exchange_path, params: exchange_params(token).deep_merge(oauth: { code: "" })
      end
    end

    assert_response :unprocessable_entity
    assert_equal "invalid_oauth_grant", response.parsed_body.fetch("code")
    assert_empty central.exchange_calls.to_a
    assert_nil session[AppConstants::Sessions.key(:account)]
  end

  test "central start exchange malformed invalid grant replay and closed account fail without a session" do
    malformed_start = FakeCentralOAuthClient.new({}, nil)
    with_return_url { Auth::CentralOAuthClient.stub(:new, malformed_start) { post native_start_path, params: start_params } }
    assert_response :bad_gateway
    assert_equal "oauth_start_failed", response.parsed_body.fetch("code")

    central_failure = FakeCentralOAuthClient.new({ "redirect_url" => "https://central.example.test/google" }, nil, nil, Auth::CentralOAuthClient::RequestError.new(code: "invalid_grant"))
    failure_token = start_transaction(central_failure)
    with_return_url { Auth::CentralOAuthClient.stub(:new, central_failure) { post native_exchange_path, params: exchange_params(failure_token) } }
    assert_response :unprocessable_entity
    assert_equal "invalid_oauth_grant", response.parsed_body.fetch("code")
    assert_not_includes response.body, "provider-body"

    generic_failure = FakeCentralOAuthClient.new(
      { "redirect_url" => "https://central.example.test/google" },
      nil,
      nil,
      Auth::CentralOAuthClient::RequestError.new("arbitrary-upstream-detail")
    )
    generic_token = start_transaction(generic_failure)
    with_return_url { Auth::CentralOAuthClient.stub(:new, generic_failure) { post native_exchange_path, params: exchange_params(generic_token) } }
    assert_response :bad_gateway
    assert_equal "oauth_exchange_failed", response.parsed_body.fetch("code")
    assert_not_includes response.body, "arbitrary-upstream-detail"

    replay_user = User.create!(email: "native-oauth@example.test", english_name: "Native OAuth", encrypted_password: User.password_hash("Password123!"), metadata: {})
    OAuthIdentity.create!(user: replay_user, provider: "google_oauth2", provider_uid: "google-native-subject", email: replay_user.email, credentials: {}, metadata: {})
    replay = FakeCentralOAuthClient.new({ "redirect_url" => "https://central.example.test/google" }, identity_response)
    replay_token = start_transaction(replay)
    with_return_url { Auth::CentralOAuthClient.stub(:new, replay) { post native_exchange_path, params: exchange_params(replay_token) } }
    assert_response :success
    replay.exchange_error = Auth::CentralOAuthClient::RequestError.new(code: "invalid_grant")
    issued_sessions = RefreshToken.where(user: User.find_by!(email: "native-oauth@example.test")).count
    with_return_url { Auth::CentralOAuthClient.stub(:new, replay) { post native_exchange_path, params: exchange_params(replay_token) } }
    assert_response :unprocessable_entity
    assert_equal "invalid_oauth_grant", response.parsed_body.fetch("code")
    assert_equal issued_sessions, RefreshToken.where(user: User.find_by!(email: "native-oauth@example.test")).count

    closed = User.create!(email: "closed-native@example.test", english_name: "Closed Native", encrypted_password: User.password_hash("Password123!"), metadata: {})
    OAuthIdentity.create!(user: closed, provider: "apple", provider_uid: "closed-native-subject", email: closed.email, credentials: {}, metadata: {})
    closed.close_account!(reason: "self_service")
    closed_central = FakeCentralOAuthClient.new({ "redirect_url" => "https://central.example.test/apple" }, identity_response(provider: "apple", uid: "closed-native-subject", email: closed.email, name: "Closed Native"))
    closed_token = start_transaction(closed_central, provider: "apple")
    with_return_url { Auth::CentralOAuthClient.stub(:new, closed_central) { post native_exchange_path, params: exchange_params(closed_token) } }
    assert_response :unauthorized
    assert_equal "account_closed", response.parsed_body.fetch("code")
  end

  private

  def native_start_path(temple_slug: @temple.slug)
    "/api/v1/account/native/oauth/start?temple_slug=#{temple_slug}"
  end

  def native_exchange_path(temple_slug: @temple.slug)
    "/api/v1/account/native/oauth/exchange?temple_slug=#{temple_slug}"
  end

  def start_params(provider: "google", pkce_method: "S256")
    { oauth: { provider:, pkce_challenge: @challenge, pkce_method: } }
  end

  def exchange_params(transaction_token, verifier: @verifier)
    { oauth: { code: "central-code", transaction_token:, pkce_verifier: verifier }, device: { device_id: "native-1", platform: "ios" } }
  end

  def start_transaction(central, provider: "google")
    with_return_url do
      Auth::CentralOAuthClient.stub(:new, central) { post native_start_path, params: start_params(provider:) }
    end
    assert_response :created
    response.parsed_body.dig("oauth", "transaction_token")
  end

  def identity_response(provider: "google", uid: "google-native-subject", email: "native-oauth@example.test", name: "Native OAuth", token: nil)
    { "provider" => provider, "uid" => uid, "email" => email, "email_verified" => true, "name" => name, "credentials" => { "token" => token || "central-token" } }
  end

  def id_token(sub:, email:)
    payload = Base64.urlsafe_encode64(JSON.generate({ "sub" => sub, "email" => email }), padding: false)
    "header.#{payload}.signature"
  end

  def with_return_url(&)
    AppConstants::OAuth.stub(:native_return_url, @return_url, &)
  end
end
