# frozen_string_literal: true

require "test_helper"

class NativeAccountSessionsTest < ActionDispatch::IntegrationTest
  def setup
    @temple = create_temple
    @password = "Password123!"
    @user = User.create!(email: "native-#{SecureRandom.hex(3)}@example.com", english_name: "Native User", encrypted_password: User.password_hash(@password))
  end

  # The app's own login path. It verified by re-hashing the input and comparing,
  # which BCrypt's per-call salt makes permanently false -- so this surface would
  # have broken silently if the bcrypt change had only touched the web sessions
  # controllers, as the upstream commit did.
  test "native login accepts a legacy sha256 digest and upgrades it to bcrypt" do
    @user.update_column(:encrypted_password, User.legacy_password_hash(@password))
    assert @user.reload.legacy_password_hash?

    post "/api/v1/account/native/login", params: { temple_slug: @temple.slug, session: { email: @user.email, password: @password }, device: { device_id: "ios-upgrade", platform: "ios" } }
    assert_response :success
    assert @user.reload.bcrypt_password_hash?, "the native login must upgrade a legacy digest too"
  end

  test "native login rejects a wrong password against a bcrypt digest" do
    post "/api/v1/account/native/login", params: { temple_slug: @temple.slug, session: { email: @user.email, password: "wrong" }, device: { device_id: "ios-bad", platform: "ios" } }
    assert_response :unauthorized
  end

  test "login refresh replay and account-only bootstrap contract" do
    post "/api/v1/account/native/login", params: { temple_slug: @temple.slug, session: { email: @user.email, password: @password }, device: { device_id: "ios-1", platform: "ios" } }
    assert_response :success
    session_payload = response.parsed_body.fetch("session")
    assert_equal "Bearer", session_payload.fetch("token_type")
    assert_not response.parsed_body.fetch("user").key?("admin_account")

    get "/api/v1/account/native/bootstrap", params: { temple_slug: @temple.slug }, headers: { "Authorization" => "Bearer #{session_payload.fetch("access_token")}" }
    assert_response :success
    assert_equal @temple.slug, response.parsed_body.dig("temple", "slug")
    assert_not response.parsed_body.key?("payments")

    post "/api/v1/account/native/refresh", params: { temple_slug: @temple.slug, refresh_token: session_payload.fetch("refresh_token") }
    assert_response :success
    replacement = response.parsed_body.dig("session", "refresh_token")

    post "/api/v1/account/native/refresh", params: { temple_slug: @temple.slug, refresh_token: session_payload.fetch("refresh_token") }
    assert_response :unauthorized
    assert_equal "session_replayed", response.parsed_body.fetch("code")

    post "/api/v1/account/native/refresh", params: { temple_slug: @temple.slug, refresh_token: replacement }
    assert_response :unauthorized
  end

  test "tenant is explicit and signed out requests are rejected" do
    get "/api/v1/account/native/profile", params: { temple_slug: @temple.slug }
    assert_response :unauthorized
    assert_equal "session_invalid", response.parsed_body.fetch("code")

    post "/api/v1/account/native/login", params: { temple_slug: "missing", session: { email: @user.email, password: @password } }
    assert_response :not_found
    assert_equal "tenant_not_found", response.parsed_body.fetch("code")
  end

  test "password recovery does not enumerate users and reset revokes prior native sessions" do
    post "/api/v1/account/native/password/recovery", params: { temple_slug: @temple.slug, email: "missing-#{SecureRandom.hex(3)}@example.com" }
    assert_response :accepted
    assert_equal({ "accepted" => true }, response.parsed_body)

    Auth::PasswordMailer.stub(:reset_email, true) do
      post "/api/v1/account/native/password/recovery", params: { temple_slug: @temple.slug, email: @user.email }
    end
    assert_response :accepted
    assert_equal({ "accepted" => true }, response.parsed_body)

    login_payload = native_login
    reset_token = Auth::PasswordReset.request_reset_for(@user)
    post "/api/v1/account/native/password/reset", params: { temple_slug: @temple.slug, token: reset_token, password: "ChangedPassword123!", password_confirmation: "ChangedPassword123!", device: { device_id: "ios-2", platform: "ios" } }
    assert_response :success
    assert response.parsed_body.dig("session", "access_token").present?

    get "/api/v1/account/native/profile", params: { temple_slug: @temple.slug }, headers: bearer(login_payload.fetch("access_token"))
    assert_response :unauthorized
    assert_equal "session_revoked", response.parsed_body.fetch("code")
  end

  test "expired and explicitly revoked native sessions are rejected" do
    session_payload = native_login
    claims = Auth::JwtService.decode(session_payload.fetch("access_token"))

    expired = Auth::JwtService.encode({ "sub" => @user.id, "native_session_id" => claims.fetch("native_session_id"), "scope" => "account" }, expires_in: -(Auth::JwtConfig::LEEWAY + 1))
    get "/api/v1/account/native/profile", params: { temple_slug: @temple.slug }, headers: bearer(expired)
    assert_response :unauthorized
    assert_equal "session_invalid", response.parsed_body.fetch("code")

    ::RefreshToken.find(claims.fetch("native_session_id")).update!(revoked: true)
    get "/api/v1/account/native/profile", params: { temple_slug: @temple.slug }, headers: bearer(session_payload.fetch("access_token"))
    assert_response :unauthorized
    assert_equal "session_revoked", response.parsed_body.fetch("code")
  end

  test "a signed token outside the account scope is rejected" do
    session_payload = native_login
    claims = Auth::JwtService.decode(session_payload.fetch("access_token"))
    wrong_scope = Auth::JwtService.encode({ "sub" => @user.id, "native_session_id" => claims.fetch("native_session_id"), "scope" => "admin" })

    get "/api/v1/account/native/profile", params: { temple_slug: @temple.slug }, headers: bearer(wrong_scope)
    assert_response :unauthorized
    assert_equal "session_invalid", response.parsed_body.fetch("code")
  end

  private

  def native_login
    post "/api/v1/account/native/login", params: { temple_slug: @temple.slug, session: { email: @user.email, password: @password }, device: { device_id: "ios-1", platform: "ios" } }
    assert_response :success
    response.parsed_body.fetch("session")
  end

  def bearer(access_token)
    { "Authorization" => "Bearer #{access_token}" }
  end
end
