# frozen_string_literal: true

require "test_helper"

class Account::ConnectQrTest < ActionDispatch::IntegrationTest
  setup do
    @temple = create_temple
    @user = User.create!(
      email: "connect-qr@example.com", english_name: "Connect QR",
      encrypted_password: User.password_hash("Password123!")
    )
  end

  test "the page renders a QR the app will accept" do
    sign_in_account(@user, temple_slug: @temple.slug)

    get account_connect_path
    assert_response :success
    assert_includes response.body, "<svg"

    # The exact contract in mobile/app/tenant/binding.js.
    url = URI.parse(Templemate::ConnectionLink.for(request: @request))
    assert_equal Templemate::ConnectionLink::PATH, url.path
    assert_nil url.fragment
    assert_nil url.userinfo
    assert_nil url.query
  end

  test "it requires a signed-in patron" do
    get account_connect_path
    assert_response :redirect
    refute_includes response.body.to_s, "<svg"
  end

  # nginx serves www.<domain> directly instead of redirecting it, and the app
  # compares the origin to its configured apiBaseUrl exactly -- so a code
  # generated on www was rejected as invalid_connection_link with no visible
  # reason. The link must always carry the canonical apex.
  test "the encoded link strips www so the app's exact-origin check passes" do
    sign_in_account(@user, temple_slug: @temple.slug)
    get account_connect_path
    assert_response :success

    # Rails' integration host is www.example.com.
    assert_equal "www.example.com", URI.parse(@request.base_url).host

    link = Templemate::ConnectionLink.for(request: @request)
    assert_equal "example.com", URI.parse(link).host, "www must be stripped"
    assert link.end_with?(Templemate::ConnectionLink::PATH)
    refute_includes link, "www."

    # The page shows the encoded link, so a failed scan is diagnosable.
    assert_includes response.body, link
    assert_includes response.body, "<svg"
  end
end
