# frozen_string_literal: true

require "securerandom"

module Auth
  class CentralOAuthController < ActionController::Base
    protect_from_forgery with: :exception
    skip_before_action :verify_authenticity_token

    PENDING_CONTEXT_SESSION_KEY = "central_oauth_pending"
    ACCOUNT_TEMPLE_SESSION_KEY = AppConstants::Sessions.key(:account_temple)
    ACCOUNT_ENTRY_INTENT_SESSION_KEY = AppConstants::Sessions.key(:account_entry_intent)
    ACCOUNT_LOCALE_SESSION_KEY = AppConstants::Sessions.key(:account_locale)
    ACCOUNT_SESSION_KEY = AppConstants::Sessions.key(:account)
    ADMIN_TEMPLE_SESSION_KEY = AppConstants::Sessions.key(:admin_temple)

    PROVIDER_ALIASES = {
      "google" => "google",
      "google_oauth2" => "google",
      "apple" => "apple",
      "facebook" => "facebook"
    }.freeze

    def start
      provider = normalize_provider_param(params[:provider])
      raise ArgumentError, "Unsupported provider" unless provider.present?

      pending = {
        "surface" => requested_surface,
        "temple_slug" => requested_temple_slug,
        "origin" => params[:origin].presence,
        "intent" => normalized_intent(params[:intent]),
        "after_sign_in" => normalized_after_sign_in(params[:after_sign_in]),
        "nonce" => SecureRandom.hex(8)
      }.compact
      session[PENDING_CONTEXT_SESSION_KEY] = pending

      response = central_auth_client.start(
        provider: provider,
        return_url: central_oauth_callback_url,
        tenant_slug: central_tenant_slug(pending),
        context: pending
      )

      redirect_url =
        response["redirect_url"].presence ||
        response["authorization_url"].presence ||
        response["auth_url"].presence ||
        response["url"].presence ||
        response["authorize_url"].presence

      raise Auth::CentralOAuthClient::RequestError, "Missing redirect URL from central auth" if redirect_url.blank?

      redirect_to redirect_url, allow_other_host: true
    rescue StandardError => e
      Rails.logger.error("[CentralOAuthController#start] #{e.class}: #{e.message}")
      redirect_to fallback_login_path(requested_surface), alert: "OAuth login is unavailable right now."
    end

    def callback
      account_user = current_account_user
      pending = session.delete(PENDING_CONTEXT_SESSION_KEY) || {}

      if link_intent?(pending) && !oauth_account_linking_enabled_for?(account_user)
        return redirect_to(
          fallback_redirect_path(pending),
          alert: I18n.t("account.oauth.flash.disabled")
        )
      end

      if params[:error].present?
        return redirect_to(
          fallback_redirect_path(pending),
          alert: "OAuth login failed: #{params[:error]}"
        )
      end

      exchange_payload = {
        code: params[:code],
        state: params[:state],
        provider: normalize_provider_param(params[:provider]),
        return_url: central_oauth_callback_url,
        query: request.query_parameters
      }.compact

      response = central_auth_client.exchange(params: exchange_payload, tenant_slug: central_tenant_slug(pending))
      exchange_identity = resolve_identity_from_exchange!(response, pending, account_user)
      if exchange_identity.account_resolution.present?
        return redirect_to(
          account_oauth_resolution_path(token: exchange_identity.account_resolution.token, provider: exchange_identity.canonical_provider),
          notice: "Choose how you would like to continue."
        )
      end

      identity = exchange_identity.identity
      user = exchange_identity.user
      link_result = exchange_identity.link_result

      unless link_intent?(pending)
        establish_session_for(user, pending)
      end

      log_oauth_event(
        link_intent?(pending) ? "account.oauth.linked" : "account.oauth.signed_in",
        user: user,
        pending: pending,
        provider: identity.provider,
        identity_id: identity.id,
        linked_existing_user: link_result.respond_to?(:linked_existing_user) ? link_result.linked_existing_user : nil
      )

      redirect_to success_redirect_path(pending, profile_required: exchange_identity.profile_required), notice: success_notice(pending, link_result, identity, profile_required: exchange_identity.profile_required)
    rescue Auth::OAuthIdentityLinker::ConflictError => e
      handle_link_conflict(response, e, pending, account_user)
    rescue Auth::OAuthIdentityLinker::ProviderAlreadyLinkedError => e
      Rails.logger.warn("[CentralOAuthController#callback] #{e.class}: #{e.message}")
      log_oauth_event(
        "account.oauth.link_conflict",
        user: account_user,
        pending: pending,
        provider: normalize_provider_param(params[:provider]),
        error: e.message
      )
      redirect_to fallback_redirect_path(pending), alert: e.message
    rescue StandardError => e
      Rails.logger.error("[CentralOAuthController#callback] #{e.class}: #{e.message}")
      alert =
        if e.message == "Closed account cannot sign in"
          I18n.t("account.sessions.flash.account_closed")
        else
          "OAuth callback failed. Please try again."
        end
      redirect_to fallback_redirect_path(pending), alert: alert
    end

    private

    # A "link" attempt that collides with an existing identity owned by
    # someone else is, most of the time, just a genuine conflict -- send the
    # plain alert. The one narrow exception: the colliding identity sits on
    # an empty, OAuth-seeded placeholder account (the "OAuth User" orphan
    # left behind by the pre-resolver unmatched-signin bug). For that case
    # only, offer the signed-in keeper a reviewable consolidation instead of
    # a dead end -- see ops/docs/reference/oauth_account_resolution.md and
    # ops/docs/plans/OAUTH_APPLE_USER_22_RECOVERY_ROADMAP.md Phase 7.
    def handle_link_conflict(response, error, pending, account_user)
      Rails.logger.warn("[CentralOAuthController#callback] #{error.class}: #{error.message}")
      identity = error.identity

      if account_user && identity && consolidation_enabled_for?(account_user) &&
         Auth::OAuthEmptyPlaceholderConsolidator.empty_placeholder?(identity.user, identity)
        return offer_consolidation(response, error, pending, account_user, identity)
      end

      log_oauth_event(
        "account.oauth.link_conflict",
        user: account_user,
        pending: pending,
        provider: normalize_provider_param(params[:provider]),
        error: error.message
      )
      redirect_to fallback_redirect_path(pending), alert: error.message
    end

    def offer_consolidation(response, error, pending, account_user, identity)
      exchange_identity = Auth::OAuthExchangeIdentity.resolve!(response:, resolution_surface: "account")
      resolution = Auth::OAuthAccountResolution.create_consolidation_proof_from_exchange!(exchange_identity:, surface: "account")

      log_oauth_event(
        "account.oauth.link_conflict",
        user: account_user,
        pending: pending,
        provider: identity.provider,
        error: error.message,
        offered_consolidation: true
      )
      redirect_to(
        account_oauth_consolidation_path(token: resolution.token, provider: exchange_identity.canonical_provider),
        notice: I18n.t("account.oauth.flash.consolidation_offered")
      )
    rescue Auth::OAuthAccountResolution::Error, Auth::OAuthExchangeIdentity::Error
      log_oauth_event(
        "account.oauth.link_conflict",
        user: account_user,
        pending: pending,
        provider: normalize_provider_param(params[:provider]),
        error: error.message
      )
      redirect_to fallback_redirect_path(pending), alert: error.message
    end

    def consolidation_enabled_for?(user)
      FeatureFlags::Evaluator.enabled?("oauth_account_consolidation", actor: user)
    end

    def central_auth_client
      @central_auth_client ||= Auth::CentralOAuthClient.new
    end

    def requested_surface
      surface = params[:surface].to_s
      surface == "admin" ? "admin" : "account"
    end

    def normalized_after_sign_in(value)
      value.to_s == "settings" ? "settings" : nil
    end

    def fallback_login_path(surface)
      surface.to_s == "admin" ? admin_login_path : account_login_path
    end

    def resolve_post_login_path(pending)
      if pending["surface"].to_s == "admin"
        return admin_dashboard_path
      end

      return account_settings_path if pending["after_sign_in"].to_s == "settings"

      # There is ONE account resolver, and it lives on the account side where
      # current_user and current_temple exist. Account::SessionsController#new
      # runs redirect_authenticated_user_with_intent!, which resolves the
      # preserved intent to the offering the patron actually clicked. A second
      # copy of that lookup here is what left this path able to reach nothing
      # but the dashboard.
      return account_login_path if session[ACCOUNT_ENTRY_INTENT_SESSION_KEY].present?

      account_dashboard_path
    end

    def establish_session_for(user, pending)
      surface = pending["surface"].to_s

      if surface == "admin"
        unless user.admin_account&.active?
          raise "User does not have active admin access"
        end

        reset_session
        session[AppConstants::Sessions.key(:admin)] = user.id
        session[ADMIN_TEMPLE_SESSION_KEY] = default_admin_temple_slug(user)
        return
      end

      temple_slug = pending["temple_slug"].presence

      # reset_session prevents session fixation, and it also wipes everything
      # the visitor arrived with. Anything that must outlive sign-in is read
      # before and written back after. Preserving only the temple slug is why
      # signing in with Google dropped the entry intent -- the offering the
      # patron had clicked -- and their chosen locale, landing them on the
      # dashboard instead of the registration they asked for.
      preserved_intent = session[ACCOUNT_ENTRY_INTENT_SESSION_KEY]
      preserved_locale = session[ACCOUNT_LOCALE_SESSION_KEY]

      reset_session
      session[ACCOUNT_TEMPLE_SESSION_KEY] = temple_slug if temple_slug.present?
      session[ACCOUNT_ENTRY_INTENT_SESSION_KEY] = preserved_intent if preserved_intent.present?
      session[ACCOUNT_LOCALE_SESSION_KEY] = preserved_locale if preserved_locale.present?
      session[AppConstants::Sessions.key(:account)] = user.id
    end

    def default_admin_temple_slug(user)
      return nil unless user&.admin_account

      user.admin_account.temples.order(:name).limit(1).pluck(:slug).first
    end

    def resolve_identity_from_exchange!(response, pending, account_user)
      Auth::OAuthExchangeIdentity.resolve!(
        response:,
        link: link_intent?(pending),
        link_user: account_user,
        resolution_surface: "account",
        lookup_only: pending["surface"].to_s == "admin"
      )
    end

    def central_tenant_slug(pending)
      ENV["AUTH_TENANT_SLUG"].presence || pending["tenant_slug"].presence || pending["temple_slug"].presence
    end

    def requested_temple_slug
      normalize_slug(params[:temple_slug]) || normalize_slug(params[:tenant_slug]) || normalize_slug(params[:temple])
    end

    def normalize_slug(value)
      return unless value.respond_to?(:to_str)

      value.to_str.strip.presence
    end

    def normalized_intent(value)
      intent = value.to_s
      intent == "link" ? "link" : nil
    end

    def link_intent?(pending)
      pending["intent"].to_s == "link"
    end

    def current_account_user
      user_id = session[ACCOUNT_SESSION_KEY]
      return nil if user_id.blank?

      User.find_by(id: user_id)
    end

    def oauth_account_linking_enabled_for?(user)
      FeatureFlags::Evaluator.enabled?("oauth_account_linking", actor: user)
    end

    def fallback_redirect_path(pending)
      origin = pending["origin"].to_s
      return origin if origin.start_with?("/")

      fallback_login_path(pending["surface"])
    end

    def success_redirect_path(pending, profile_required:)
      return fallback_redirect_path(pending) if link_intent?(pending)
      return edit_account_profile_path if profile_required

      resolve_post_login_path(pending)
    end

    def success_notice(pending, link_result, identity, profile_required:)
      return I18n.t("account.oauth.flash.complete_profile") if !link_intent?(pending) && profile_required
      return "Signed in successfully." unless link_intent?(pending)
      return "Your #{identity.provider.titleize} account is already linked." if link_result&.respond_to?(:already_linked) && link_result.already_linked

      "Linked #{identity.provider.titleize} to your account."
    end

    def log_oauth_event(action, user:, pending:, provider:, **metadata)
      temple = Temple.find_by(slug: pending["temple_slug"]) if pending["temple_slug"].present?
      actor = user || current_account_user
      return if actor.blank?

      SystemAuditLogger.log!(
        action: action,
        admin: actor,
        target: actor,
        metadata: metadata.merge(provider: provider, surface: pending["surface"], intent: pending["intent"]),
        temple: temple
      )
    end

    def normalize_provider_param(value)
      PROVIDER_ALIASES[value.to_s]
    end

  end
end
