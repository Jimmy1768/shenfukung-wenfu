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

  test "the encoded link uses the requesting temple's own origin" do
    sign_in_account(@user, temple_slug: @temple.slug)
    get account_connect_path

    link = Templemate::ConnectionLink.for(request: @request)
    assert link.end_with?(Templemate::ConnectionLink::PATH)
    assert link.start_with?(@request.base_url)
    # And the page really encodes that link, not a hard-coded origin.
    assert_includes response.body, "<svg"
    refute_includes response.body, "localhost:3000"
  end
end
