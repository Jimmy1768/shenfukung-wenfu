# frozen_string_literal: true

module Account
  class OAuthResolutionsController < BaseController
    skip_before_action :authenticate_user!
    skip_before_action :ensure_temple_context

    def show
      @resolution = resolution!
      @provider = @resolution.provider
    rescue Auth::OAuthAccountResolution::Error
      redirect_to account_login_path, alert: "That sign-in request is no longer available."
    end

    def existing
      user = Auth::OAuthAccountResolution.consume_existing!(
        token: params[:token], provider: params[:provider], surface: "account", email: params.dig(:account, :email), password: params.dig(:account, :password)
      )
      establish_user_session!(user)
      redirect_to account_dashboard_path, notice: "Your sign-in method was linked."
    rescue Auth::OAuthAccountResolution::AccountClosed
      redirect_to account_login_path, alert: I18n.t("account.sessions.flash.account_closed")
    rescue Auth::OAuthAccountResolution::Error, Auth::OAuthIdentityLinker::Error
      redirect_to account_oauth_resolution_path(token: params[:token], provider: params[:provider]), alert: "We could not verify that account."
    end

    def new_account
      user = Auth::OAuthAccountResolution.consume_new!(
        token: params[:token], provider: params[:provider], surface: "account", email: params.dig(:account, :email), password: params.dig(:account, :password),
        name: params.dig(:account, :name), terms_accepted: params.dig(:account, :terms_accepted)
      )
      establish_user_session!(user)
      redirect_to account_dashboard_path, notice: "Account created."
    rescue Auth::OAuthAccountResolution::Error, Auth::OAuthIdentityLinker::Error, ActiveRecord::RecordInvalid
      redirect_to account_oauth_resolution_path(token: params[:token], provider: params[:provider]), alert: "We could not create that account."
    end

    private

    def resolution!
      Auth::OAuthAccountResolution.find!(token: params[:token], provider: params[:provider], surface: "account")
    end
  end
end
