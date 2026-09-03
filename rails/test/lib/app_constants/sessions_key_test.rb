# frozen_string_literal: true

require "test_helper"

module AppConstants
  class SessionsKeyTest < ActiveSupport::TestCase
    # These strings are written into live browser sessions. Changing one signs
    # every current visitor out, or worse, silently loses the tenant they were
    # browsing. They were bare literals repeated across three files until
    # 2026-09-03 -- which is how the OAuth path came to preserve the temple slug
    # while the omniauth path did not.
    test "session keys keep the values already written into live sessions" do
      assert_equal :account_active_temple_slug, AppConstants::Sessions.key(:account_temple)
      assert_equal :account_entry_intent, AppConstants::Sessions.key(:account_entry_intent)
      assert_equal :user_id, AppConstants::Sessions.key(:account)
      assert_equal :admin_user_id, AppConstants::Sessions.key(:admin)
    end

    test "the temple key has one definition, not one per caller" do
      assert_equal AppConstants::Sessions.key(:account_temple),
                   Account::BaseController::ACCOUNT_TEMPLE_SESSION_KEY
      assert_equal AppConstants::Sessions.key(:account_temple),
                   Auth::CentralOAuthController::ACCOUNT_TEMPLE_SESSION_KEY
      assert_equal AppConstants::Sessions.key(:account_temple),
                   TempleContextResolver::ACCOUNT_TEMPLE_SESSION_KEY
    end
  end
end
