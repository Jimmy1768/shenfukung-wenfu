# frozen_string_literal: true

require "test_helper"

class RefreshTokenTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "native-#{SecureRandom.hex(3)}@example.com", english_name: "Native User", encrypted_password: User.password_hash("Password123!"))
  end

  test "rotation revokes old token and replay revokes the replacement" do
    service = Auth::RefreshToken.new(@user)
    issued = service.issue!(context: { device_id: "device-a", platform: "ios" })
    rotated = service.rotate!(issued.raw_token)

    assert rotated.success?
    assert_not ::RefreshToken.find(issued.record.id).active?
    assert ::RefreshToken.find(rotated.record.id).active?

    replay = service.rotate!(issued.raw_token)
    assert_not replay.success?
    assert_equal :replayed, replay.error
    assert_not ::RefreshToken.find(rotated.record.id).active?
  end

  test "closed account cannot retain an active refresh session" do
    issued = Auth::RefreshToken.new(@user).issue!
    @user.close_account!(reason: "self_service")
    assert_not ::RefreshToken.find(issued.record.id).active?
  end
end
