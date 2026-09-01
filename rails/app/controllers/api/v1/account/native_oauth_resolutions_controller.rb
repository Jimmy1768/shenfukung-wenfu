# frozen_string_literal: true

module Api
  module V1
    module Account
      # Native mirror of Account::OAuthResolutionsController. Consumes the
      # resolution_token NativeOAuthController#exchange issues on a 409
      # account_resolution_required response. No session exists yet for any
      # of these actions, matching oauth/start and oauth/exchange.
      class NativeOAuthResolutionsController < NativeBaseController
        skip_before_action :authenticate_native_user!, only: %i[show existing new_account]

        def show
          resolution = Auth::OAuthAccountResolution.find!(token: params[:token].to_s, provider: params[:provider].to_s, surface: "native")
          # display_name and email are what the provider already told us about
          # this person (Google/Apple claims, captured in create_record!). The
          # app prefills them so a patron never retypes what we were handed.
          # They are hints for a form the patron still confirms, not identity:
          # consume_new! re-reads whatever is submitted.
          render json: {
            resolution: {
              provider: resolution.provider,
              expires_at: resolution.expires_at,
              name: resolution.display_name,
              email: resolution.email
            }
          }
        rescue Auth::OAuthAccountResolution::InvalidToken
          render_error("resolution_invalid", :unauthorized)
        rescue Auth::OAuthAccountResolution::Expired
          render_error("resolution_expired", :unauthorized)
        rescue Auth::OAuthAccountResolution::Consumed
          render_error("resolution_consumed", :unauthorized)
        rescue Auth::OAuthAccountResolution::ProviderMismatch
          render_error("resolution_provider_mismatch", :unprocessable_entity)
        rescue Auth::OAuthAccountResolution::SurfaceMismatch
          render_error("resolution_invalid", :unauthorized)
        rescue Auth::OAuthAccountResolution::FeatureDisabled
          render_error("account_resolution_unavailable", :service_unavailable)
        end

        def existing
          user = Auth::OAuthAccountResolution.consume_existing!(
            token: oauth_params[:token], provider: oauth_params[:provider], surface: "native",
            email: account_params[:email], password: account_params[:password]
          )
          render json: resolved_session_payload(user)
        rescue Auth::OAuthAccountResolution::InvalidToken
          render_error("resolution_invalid", :unauthorized)
        rescue Auth::OAuthAccountResolution::Expired
          render_error("resolution_expired", :unauthorized)
        rescue Auth::OAuthAccountResolution::Consumed
          render_error("resolution_consumed", :unauthorized)
        rescue Auth::OAuthAccountResolution::ProviderMismatch
          render_error("resolution_provider_mismatch", :unprocessable_entity)
        rescue Auth::OAuthAccountResolution::SurfaceMismatch
          render_error("resolution_invalid", :unauthorized)
        rescue Auth::OAuthAccountResolution::AccountClosed
          render_error("account_closed", :unauthorized)
        rescue Auth::OAuthAccountResolution::ExistingAccountProofFailed
          render_error("existing_account_proof_failed", :unauthorized)
        rescue Auth::OAuthAccountResolution::FeatureDisabled
          render_error("account_resolution_unavailable", :service_unavailable)
        rescue Auth::OAuthIdentityLinker::Error
          render_error("oauth_identity_conflict", :conflict)
        end

        def new_account
          user = Auth::OAuthAccountResolution.consume_new!(
            token: oauth_params[:token], provider: oauth_params[:provider], surface: "native",
            email: account_params[:email], password: account_params[:password],
            name: account_params[:name], terms_accepted: account_params[:terms_accepted]
          )
          render json: resolved_session_payload(user), status: :created
        rescue Auth::OAuthAccountResolution::InvalidToken
          render_error("resolution_invalid", :unauthorized)
        rescue Auth::OAuthAccountResolution::Expired
          render_error("resolution_expired", :unauthorized)
        rescue Auth::OAuthAccountResolution::Consumed
          render_error("resolution_consumed", :unauthorized)
        rescue Auth::OAuthAccountResolution::ProviderMismatch
          render_error("resolution_provider_mismatch", :unprocessable_entity)
        rescue Auth::OAuthAccountResolution::SurfaceMismatch
          render_error("resolution_invalid", :unauthorized)
        rescue Auth::OAuthAccountResolution::ExistingAccountProofFailed
          render_error("validation_failed", :unprocessable_entity)
        rescue Auth::OAuthAccountResolution::FeatureDisabled
          render_error("account_resolution_unavailable", :service_unavailable)
        rescue Auth::OAuthIdentityLinker::Error
          render_error("oauth_identity_conflict", :conflict)
        rescue ActiveRecord::RecordInvalid => e
          render_validation_errors(e.record)
        end

        private

        def resolved_session_payload(user)
          {
            user: ::Account::Api::NativeAccountSerializer.user(user),
            session: issue_session_payload(user, context: native_context),
            oauth: { provider: oauth_params[:provider] }
          }
        end

        def oauth_params
          params.fetch(:oauth, {}).permit(:token, :provider)
        end

        def account_params
          params.fetch(:account, {}).permit(:email, :password, :name, :terms_accepted)
        end
      end
    end
  end
end
