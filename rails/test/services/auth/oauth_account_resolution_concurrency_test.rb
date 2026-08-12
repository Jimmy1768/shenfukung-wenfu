require "test_helper"

module Auth
  class OAuthAccountResolutionConcurrencyTest < ActiveSupport::TestCase
    self.use_transactional_tests = false

    def setup
      Config::EntryResolver.upsert!(key: "oauth_account_resolution", value: true)
      @keeper = User.create!(email: "resolution-race-#{SecureRandom.hex(4)}@example.test", english_name: "Resolution Race", encrypted_password: User.password_hash("Password123!"), metadata: {})
      @pending = OAuthAccountResolution.create!(provider: "apple", uid: "race-#{SecureRandom.hex(4)}", email: nil, name: nil, email_verified: nil, surface: "account")
    end

    def teardown
      OAuthIdentity.where(provider: "apple", provider_uid: @pending&.record&.provider_uid).delete_all
      ::OAuthAccountResolution.where(id: @pending&.record&.id).delete_all
      SystemAuditLog.where(user_id: @keeper&.id).delete_all
      @keeper&.destroy! if @keeper&.persisted?
    end

    test "two independent consumers allow exactly one link and fail closed for the replay" do
      ready = Queue.new
      start = Queue.new
      results = Queue.new

      workers = 2.times.map do
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            ready << true
            start.pop
            OAuthAccountResolution.consume_existing!(token: @pending.token, provider: "apple", surface: "account", email: @keeper.email, password: "Password123!")
            results << :linked
          end
        rescue OAuthAccountResolution::Consumed
          results << :consumed
        rescue StandardError => error
          results << error
        end
      end
      2.times { ready.pop }
      2.times { start << true }
      workers.each(&:join)

      outcomes = 2.times.map { results.pop }
      assert_empty outcomes.grep(StandardError), outcomes.grep(StandardError).map(&:message).join("\n")
      assert_equal 1, outcomes.count(:linked)
      assert_equal 1, outcomes.count(:consumed)
      assert_equal 1, OAuthIdentity.where(user: @keeper, provider: "apple").count
      assert ::OAuthAccountResolution.find(@pending.record.id).consumed_at.present?
    end
  end
end
