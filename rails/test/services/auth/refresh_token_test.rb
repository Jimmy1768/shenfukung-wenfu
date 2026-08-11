# frozen_string_literal: true

require "test_helper"

class RefreshTokenTest < ActiveSupport::TestCase
  # The concurrent rotation proof uses independent PostgreSQL connections.
  # A transaction-local test would hide the issued token from those workers.
  self.use_transactional_tests = false

  def setup
    @user = User.create!(email: "native-#{SecureRandom.hex(3)}@example.com", english_name: "Native User", encrypted_password: User.password_hash("Password123!"))
  end

  def teardown
    RefreshToken.where(user_id: @user.id).delete_all if @user
    @user.destroy! if @user&.persisted?
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

  test "simultaneous refresh rotations allow one winner and fail closed for the replay" do
    issued = Auth::RefreshToken.new(@user).issue!(context: { device_id: "concurrent-device", platform: "ios" })
    ready = Queue.new
    start = Queue.new
    results = Queue.new

    workers = 2.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          ready << true
          start.pop
          result = Auth::RefreshToken.new(User.find(@user.id)).rotate!(issued.raw_token)
          results << { success: result.success?, error: result.error, replacement_id: result.record&.id }
        end
      rescue StandardError => error
        results << error
      end
    end

    2.times { ready.pop }
    2.times { start << true }
    workers.each(&:join)
    attempts = 2.times.map { results.pop }
    failures = attempts.grep(StandardError)
    assert_empty failures, failures.map(&:message).join("\n")

    outcomes = attempts.reject { |attempt| attempt.is_a?(StandardError) }
    assert_equal 1, outcomes.count { |attempt| attempt[:success] }
    assert_equal [:replayed], outcomes.reject { |attempt| attempt[:success] }.map { |attempt| attempt[:error] }

    # The detected replay revokes the complete native session set, including
    # the winner's replacement, so neither race participant retains a session.
    assert_equal 0, @user.refresh_tokens.active.count
  end
end
