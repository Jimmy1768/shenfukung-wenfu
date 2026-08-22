# frozen_string_literal: true

require "digest"

module Auth
  # A deliberately narrow recovery operation. It is not a generic account
  # merge: only a freshly-proven provider identity on an otherwise empty,
  # OAuth-seeded placeholder can move to a freshly-proven keeper account.
  class OAuthEmptyPlaceholderConsolidator
    FINGERPRINT_CONTEXT = "wenfu.oauth.placeholder_consolidation.v1"

    class Error < StandardError; end
    class ProofFailed < Error; end
    class UnsupportedSource < Error; end
    class Conflict < Error; end
    class FeatureDisabled < Error; end

    def self.consolidate!(keeper_user:, keeper_password:, provider:, uid:, source_proof_token:, confirmed:)
      new.consolidate!(keeper_user:, keeper_password:, provider:, uid:, source_proof_token:, confirmed:)
    end

    # Read-only eligibility check, safe to call before offering the recovery
    # journey at all -- same predicate #consolidate! itself re-checks inside
    # its own locked transaction, so this is a UI-offer hint, not the
    # authoritative gate.
    def self.empty_placeholder?(user, identity)
      new.empty_placeholder?(user, identity)
    end

    def consolidate!(keeper_user:, keeper_password:, provider:, uid:, source_proof_token:, confirmed:)
      raise FeatureDisabled unless FeatureFlags::Evaluator.enabled?("oauth_account_consolidation", actor: keeper_user)
      raise ProofFailed unless confirmed && password_matches?(keeper_user, keeper_password)

      User.transaction do
        Auth::OAuthAccountResolution.consume_consolidation_proof!(
          token: source_proof_token,
          provider: provider.to_s,
          uid: uid.to_s,
          surface: "account"
        )
        keeper = User.lock.find(keeper_user.id)
        raise ProofFailed if keeper.closed_account?

        identity = OAuthIdentity.lock.find_by(provider: provider.to_s, provider_uid: uid.to_s)
        raise ProofFailed unless identity
        source = User.lock.find(identity.user_id)
        raise Conflict if source.id == keeper.id
        raise UnsupportedSource unless empty_placeholder?(source, identity)

        identity.update!(user: keeper)
        source.refresh_tokens.update_all(revoked: true, updated_at: Time.current)
        source.close_account!(reason: "operator_action", closed_by: keeper)

        SystemAuditLogger.log!(
          action: "auth.oauth.empty_placeholder_consolidated",
          admin: keeper,
          target: identity,
          metadata: {
            keeper_user_id: keeper.id,
            source_user_id: source.id,
            provider: identity.provider,
            provider_uid_fingerprint: fingerprint(uid)
          }
        )
        identity
      end
    end

    def empty_placeholder?(user, identity)
      metadata = user.metadata.is_a?(Hash) ? user.metadata : {}
      return false unless metadata["oauth_seeded"] == true
      return false unless user.account_status == "active" && user.closed_at.blank? && user.closure_reason.blank?
      return false unless user.english_name.to_s == "OAuth User" && user.native_name.blank?
      return false unless user.oauth_identities.count == 1 && identity.user_id == user.id
      return false if user.admin_account.present? || user.user_dependents.exists? || user.temple_event_registrations.exists? || user.temple_payments.exists?
      return false if user.refresh_tokens.exists? || user.push_tokens.exists? || user.privacy_requests.exists? || user.account_lifecycle_events.exists?
      return false if user.temple_assistance_requests.exists?
      return false if user.user_preference.present? || user.privacy_setting.present?
      return false if meaningful_user_work?(user)

      true
    end

    private

    def meaningful_user_work?(user)
      [
        TempleRegistration,
        AgreementAcceptance,
        ApiUsageLog,
        CacheRepairTask,
        ClientCheckin,
        DataTransferLog,
        MessageDeliveryArchive,
        ClientCacheMetric,
        ClientCacheState,
        NotificationPreference,
        Notification,
        FinancialLedgerEntry,
        UsageBillingSnapshot
      ].any? { |model| model.where(user_id: user.id).exists? }
    end

    def password_matches?(user, password)
      return false if user.blank? || password.to_s.blank?

      expected = User.password_hash(password)
      return false unless expected.bytesize == user.encrypted_password.to_s.bytesize

      ActiveSupport::SecurityUtils.secure_compare(user.encrypted_password, expected)
    end

    def fingerprint(uid)
      Digest::SHA256.hexdigest("#{FINGERPRINT_CONTEXT}:#{uid}")
    end
  end
end
