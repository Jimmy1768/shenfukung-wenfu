module Auth
  class OmniauthController < ActionController::Base
    protect_from_forgery with: :exception
    skip_before_action :verify_authenticity_token

    def callback
      auth_hash = request.env["omniauth.auth"]
      identity = find_identity(auth_hash)
      raise "Closed account cannot sign in" if identity.user.closed_account?

      establish_account_session!(identity.user)

      if respond_with_json?
        render json: { provider: identity.provider, user_id: identity.user_id }
      else
        redirect_to oauth_redirect_path, notice: "Signed in with #{identity.provider.titleize}."
      end
    rescue StandardError => e
      Rails.logger.error("[OmniauthController] #{e.class}: #{e.message}")
      message = e.message == "Closed account cannot sign in" ? I18n.t("account.sessions.flash.account_closed") : "OAuth login failed. Please try again."
      if respond_with_json?
        render json: { error: message }, status: :unprocessable_content
      else
        redirect_to account_login_path, alert: message
      end
    end

    def failure
      message = params[:message] || "OAuth failure"
      if respond_with_json?
        render json: { error: message }, status: :unauthorized
      else
        redirect_to account_login_path, alert: message
      end
    end

    private

    def respond_with_json?
      request.format.json?
    end

    ACCOUNT_ENTRY_INTENT_SESSION_KEY = AppConstants::Sessions.key(:account_entry_intent)
    ACCOUNT_LOCALE_SESSION_KEY = AppConstants::Sessions.key(:account_locale)

    # Same rule as Auth::CentralOAuthController: the account resolver is the
    # only thing that knows how to turn an entry intent into a destination, and
    # it lives on the account side. Bounce through the login page, which
    # redirects an already-signed-in visitor via that resolver.
    def oauth_redirect_path
      return account_login_path if session[ACCOUNT_ENTRY_INTENT_SESSION_KEY].present?

      request.env["omniauth.origin"].presence || account_dashboard_path
    end

    # reset_session guards against session fixation and wipes everything the
    # visitor arrived with, so what must outlive sign-in is carried across.
    def establish_account_session!(user)
      preserved_intent = session[ACCOUNT_ENTRY_INTENT_SESSION_KEY]
      preserved_locale = session[ACCOUNT_LOCALE_SESSION_KEY]

      reset_session
      session[ACCOUNT_ENTRY_INTENT_SESSION_KEY] = preserved_intent if preserved_intent.present?
      session[ACCOUNT_LOCALE_SESSION_KEY] = preserved_locale if preserved_locale.present?
      session[AppConstants::Sessions.key(:account)] = user.id
    end

    def find_identity(auth_hash)
      provider = auth_hash["provider"].to_s
      uid = auth_hash["uid"].to_s

      result = Auth::OAuthIdentityResolver.resolve_or_link!(
        provider: provider,
        uid: uid,
        email: auth_hash.dig("info", "email"),
        name: auth_hash.dig("info", "name"),
        email_verified: auth_hash.dig("info", "email_verified"),
        credentials: auth_hash["credentials"] || {},
        metadata: {
          "info" => auth_hash["info"],
          "extra" => auth_hash["extra"]
        }
      )

      result.identity
    end
  end
end
