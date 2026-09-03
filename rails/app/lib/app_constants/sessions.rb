# frozen_string_literal: true

module AppConstants
  module Sessions
    module_function

    def key(scope)
      case scope.to_s
      when "admin", "real_admin"
        :admin_user_id
      when "demo", "marketing_admin"
        :demo_admin_user_id
      when "user", "account"
        :user_id
      when "account_temple"
        # The tenant a signed-in patron is browsing. Was a bare
        # "account_active_temple_slug" literal repeated in three files, which is
        # how the OAuth path came to preserve it while the omniauth path did not.
        # Session keys are compared stringified, so the symbol reads the same
        # entries the literal wrote.
        :account_active_temple_slug
      when "account_entry_intent"
        # What the visitor was trying to do before being asked to sign in.
        :account_entry_intent
      else
        "#{scope}_session".to_sym
      end
    end
  end
end
