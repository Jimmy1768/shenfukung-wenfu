# frozen_string_literal: true

module Account
  # Narrow, signed-in-only review/confirm step for moving an OAuth identity
  # off an empty, OAuth-seeded placeholder account onto the current keeper.
  # See ops/docs/reference/oauth_account_resolution.md and
  # ops/docs/plans/OAUTH_APPLE_USER_22_RECOVERY_ROADMAP.md Phase 7 for why
  # this exists and what it deliberately does not do (no generic account
  # merge/list/search surface, no unlink-and-retry, keeper password required
  # every time).
  class OAuthConsolidationsController < BaseController
    def show
      @resolution = resolution!
      @provider = @resolution.provider
    rescue Auth::OAuthAccountResolution::Error
      redirect_to account_oauth_identities_path, alert: I18n.t("account.oauth.flash.consolidation_unavailable")
    end

    def create
      record = resolution!
      Auth::OAuthEmptyPlaceholderConsolidator.consolidate!(
        keeper_user: current_user,
        keeper_password: params.dig(:account, :password),
        provider: record.provider,
        uid: record.provider_uid,
        source_proof_token: params[:token],
        confirmed: ActiveModel::Type::Boolean.new.cast(params.dig(:account, :confirmed))
      )
      redirect_to account_oauth_identities_path, notice: I18n.t("account.oauth.flash.consolidation_complete")
    rescue Auth::OAuthEmptyPlaceholderConsolidator::ProofFailed
      redirect_to account_oauth_consolidation_path(token: params[:token], provider: params[:provider]),
        alert: I18n.t("account.oauth.flash.consolidation_proof_failed")
    rescue Auth::OAuthEmptyPlaceholderConsolidator::Error, Auth::OAuthAccountResolution::Error
      redirect_to account_oauth_identities_path, alert: I18n.t("account.oauth.flash.consolidation_failed")
    end

    private

    def resolution!
      Auth::OAuthAccountResolution.find_consolidation!(token: params[:token], provider: params[:provider])
    end
  end
end
