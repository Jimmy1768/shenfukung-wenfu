# frozen_string_literal: true

require "digest"
require "securerandom"

module Auth
  # Holds an unmatched provider identity until the user deliberately proves an
  # existing account or confirms a new account. The bearer token is stored only
  # as a digest and never enters audit metadata or a session.
  class OAuthAccountResolution
    TOKEN_BYTES = 32

    class Error < StandardError; end
    class InvalidToken < Error; end
    class Expired < Error; end
    class Consumed < Error; end
    class ProviderMismatch < Error; end
    class SurfaceMismatch < Error; end
    class ExistingAccountProofFailed < Error; end
    class AccountClosed < Error; end
    class FeatureDisabled < Error; end

    Result = Struct.new(:record, :token, keyword_init: true)

    def self.create!(provider:, uid:, email:, name:, email_verified:, surface:)
      new.create!(provider:, uid:, email:, name:, email_verified:, surface:)
    end

    def self.create_consolidation_proof_from_exchange!(exchange_identity:, surface: "account")
      new.create_consolidation_proof_from_exchange!(exchange_identity:, surface:)
    end

    def self.consume_existing!(token:, provider:, email:, password:, surface:)
      new.consume_existing!(token:, provider:, email:, password:, surface:)
    end

    def self.consume_new!(token:, provider:, email:, password:, name:, terms_accepted:, surface:)
      new.consume_new!(token:, provider:, email:, password:, name:, terms_accepted:, surface:)
    end

    def self.consume_consolidation_proof!(token:, provider:, uid:, surface:)
      new.consume_consolidation_proof!(token:, provider:, uid:, surface:)
    end

    def self.find!(token:, provider:, surface:)
      new.find!(token:, provider:, surface:)
    end

    def create!(provider:, uid:, email:, name:, email_verified:, surface:)
      raise FeatureDisabled unless unmatched_resolution_enabled?

      token = SecureRandom.urlsafe_base64(TOKEN_BYTES)
      record = ::OAuthAccountResolution.create!(
        token_digest: token_digest(token),
        provider: provider.to_s,
        provider_uid: uid.to_s,
        email: normalized_email(email),
        display_name: name.to_s.strip.presence,
        email_verified: cast_boolean(email_verified),
        surface: surface.to_s,
        purpose: "account_resolution",
        expires_at: ::OAuthAccountResolution::TTL.from_now
      )
      audit!("auth.oauth.resolution_created", record:)
      Result.new(record:, token:)
    end

    def create_consolidation_proof_from_exchange!(exchange_identity:, surface:)
      raise FeatureDisabled unless consolidation_enabled?
      raise InvalidToken unless exchange_identity.is_a?(Auth::OAuthExchangeIdentity::Result)

      identity = exchange_identity.identity
      provider = exchange_identity.provider
      raise InvalidToken unless identity&.persisted? && identity.provider == provider && exchange_identity.user == identity.user

      create_record!(provider:, uid: identity.provider_uid, email: nil, name: nil, email_verified: nil, surface:, purpose: "consolidation")
    end

    def find!(token:, provider:, surface:)
      record = ::OAuthAccountResolution.find_by(token_digest: token_digest(token))
      validate_record!(record, provider:, surface:, purpose: "account_resolution")

      record
    end

    def consume_existing!(token:, provider:, email:, password:, surface:)
      ::OAuthAccountResolution.transaction do
        record = lock_record!(token:, provider:, surface:, purpose: "account_resolution")
        user = User.lock.find_by(email: normalized_email(email))
        raise ExistingAccountProofFailed unless password_matches?(user, password)
        raise AccountClosed if user.closed_account?

        link_to_user!(record, user)
        consume!(record, user:, mode: "existing_account")
        user
      end
    end

    def consume_new!(token:, provider:, email:, password:, name:, terms_accepted:, surface:)
      raise ExistingAccountProofFailed unless ActiveModel::Type::Boolean.new.cast(terms_accepted)
      raise ExistingAccountProofFailed if normalized_email(email).blank? || password.to_s.blank? || name.to_s.strip.blank?

      ::OAuthAccountResolution.transaction do
        record = lock_record!(token:, provider:, surface:, purpose: "account_resolution")
        user = User.create!(
          email: normalized_email(email),
          english_name: name.to_s.strip,
          encrypted_password: User.password_hash(password),
          metadata: {
            "oauth_seeded" => true,
            "signup_source" => record.provider,
            "terms_version" => AppConstants::Legal.default_terms_version,
            "terms_accepted_at" => Time.current.iso8601
          }
        )
        link_to_user!(record, user)
        consume!(record, user:, mode: "new_account")
        user
      end
    end

    public
    def consume_consolidation_proof!(token:, provider:, uid:, surface:)
      ::OAuthAccountResolution.transaction do
        record = lock_record!(token:, provider:, surface:, purpose: "consolidation")
        raise ProviderMismatch unless secure_equal?(record.provider_uid, uid.to_s)

        consume!(record, user: nil, mode: "consolidation")
        record
      end
    end

    private

    def create_record!(provider:, uid:, email:, name:, email_verified:, surface:, purpose:)
      token = SecureRandom.urlsafe_base64(TOKEN_BYTES)
      record = ::OAuthAccountResolution.create!(
        token_digest: token_digest(token),
        provider: provider.to_s,
        provider_uid: uid.to_s,
        email: normalized_email(email),
        display_name: name.to_s.strip.presence,
        email_verified: cast_boolean(email_verified),
        surface: surface.to_s,
        purpose:,
        expires_at: ::OAuthAccountResolution::TTL.from_now
      )
      audit!("auth.oauth.resolution_created", record:)
      Result.new(record:, token:)
    end

    def lock_record!(token:, provider:, surface:, purpose:)
      record = ::OAuthAccountResolution.lock.find_by(token_digest: token_digest(token))
      validate_record!(record, provider:, surface:, purpose:)

      record
    end

    def validate_record!(record, provider:, surface:, purpose:)
      raise InvalidToken unless record
      raise ProviderMismatch unless secure_equal?(record.provider, provider.to_s)
      raise SurfaceMismatch unless secure_equal?(record.surface, surface.to_s)
      raise InvalidToken unless secure_equal?(record.purpose, purpose)
      raise Consumed if record.consumed_at.present?
      raise Expired if record.expired?
    end

    def link_to_user!(record, user)
      Auth::OAuthIdentityLinker.link!(
        user:,
        provider: record.provider,
        uid: record.provider_uid,
        email: record.email,
        email_verified: record.email_verified,
        credentials: {},
        metadata: { "resolution" => "pending" }
      )
    end

    def consume!(record, user:, mode:)
      record.update!(consumed_at: Time.current, consumed_mode: mode, consumed_by_user: user)
      audit!("auth.oauth.resolution_consumed", record:, user:, mode:)
    end

    def audit!(action, record:, user: nil, mode: nil)
      SystemAuditLogger.log!(
        action:,
        admin: user,
        target: record,
        metadata: {
          provider: record.provider,
          oauth_resolution_id: record.id,
          mode: mode
        }.compact
      )
    end

    def unmatched_resolution_enabled?
      FeatureFlags::Evaluator.enabled?("oauth_account_resolution")
    end

    def consolidation_enabled?
      FeatureFlags::Evaluator.enabled?("oauth_account_consolidation")
    end

    def token_digest(token)
      Digest::SHA256.hexdigest("wenfu.oauth.account_resolution.v1:#{token}")
    end

    def normalized_email(value)
      value.to_s.strip.downcase.presence
    end

    def cast_boolean(value)
      return nil if value.nil?

      ActiveModel::Type::Boolean.new.cast(value)
    end

    def password_matches?(user, password)
      return false if user.blank? || password.to_s.blank?

      expected = User.password_hash(password)
      return false unless user.encrypted_password.to_s.bytesize == expected.bytesize

      ActiveSupport::SecurityUtils.secure_compare(user.encrypted_password, expected)
    end

    def secure_equal?(left, right)
      return false unless left.bytesize == right.bytesize

      ActiveSupport::SecurityUtils.secure_compare(left, right)
    end
  end
end
