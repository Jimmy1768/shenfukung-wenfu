# frozen_string_literal: true

require "digest"
require "securerandom"

module Auth
  class OAuthIdentityResolver
    GOOGLE_PROVIDER = "google_oauth2"
    GOOGLE_SUBJECT_FINGERPRINT_CONTEXT = "wenfu.google_oauth2.subject.v1"

    Result = Struct.new(:identity, :user, :created_identity, :linked_existing_user, keyword_init: true)

    def self.resolve_or_link!(provider:, uid:, email:, name:, credentials: {}, metadata: {}, email_verified: nil)
      new(
        provider: provider,
        uid: uid,
        email: email,
        name: name,
        credentials: credentials,
        metadata: metadata,
        email_verified: email_verified
      ).resolve_or_link!
    end

    def initialize(provider:, uid:, email:, name:, credentials:, metadata:, email_verified:)
      @provider = provider.to_s
      @uid = uid.to_s
      @email = normalized_email(email)
      @name = name.to_s.strip
      @credentials = credentials.is_a?(Hash) ? credentials : {}
      @metadata = metadata.is_a?(Hash) ? metadata : {}
      @email_verified = cast_boolean(email_verified)
    end

    def resolve_or_link!
      raise ArgumentError, "provider is required" if @provider.blank?
      raise ArgumentError, "uid is required" if @uid.blank?

      exact_identity = OAuthIdentity.find_by(provider: @provider, provider_uid: @uid)
      return update_identity_result(exact_identity, exact_identity.user, created_identity: false, linked_existing_user: false) if exact_identity

      replacement_result = replace_google_subject_if_eligible
      return replacement_result if replacement_result

      identity = OAuthIdentity.new(provider: @provider, provider_uid: @uid)

      linked_existing_user = false
      user, linked_existing_user = resolve_user
      identity.user = user

      update_identity_result(identity, user, created_identity: true, linked_existing_user: linked_existing_user)
    end

    private

    def replace_google_subject_if_eligible
      return unless google_subject_replacement_candidate?

      OAuthIdentity.transaction do
        users = users_for_normalized_email(lock: true)
        raise ActiveRecord::RecordInvalid, User.new unless users.one?

        user = users.first
        raise ActiveRecord::RecordInvalid, user if user.closed_account?

        identities = user.oauth_identities.where(provider: GOOGLE_PROVIDER).lock.to_a
        raise ActiveRecord::RecordInvalid, user unless identities.one?

        identity = identities.first
        conflicting_identity = OAuthIdentity.lock.find_by(provider: GOOGLE_PROVIDER, provider_uid: @uid)
        raise ActiveRecord::RecordInvalid, conflicting_identity if conflicting_identity && conflicting_identity.id != identity.id

        old_provider_uid = identity.provider_uid
        identity.provider_uid = @uid
        update_identity_result(identity, user, created_identity: false, linked_existing_user: true)

        SystemAuditLogger.log!(
          action: "auth.oauth.google_subject_replaced",
          admin: user,
          target: identity,
          metadata: {
            provider: GOOGLE_PROVIDER,
            user_id: user.id,
            oauth_identity_id: identity.id,
            old_provider_uid_fingerprint: subject_fingerprint(old_provider_uid),
            new_provider_uid_fingerprint: subject_fingerprint(@uid)
          }
        )

        Result.new(identity: identity, user: user, created_identity: false, linked_existing_user: true)
      end
    end

    def google_subject_replacement_candidate?
      return false unless @provider == GOOGLE_PROVIDER && @uid.present? && @email.present? && @email_verified == true

      users = users_for_normalized_email
      return false unless users.one?

      user = users.first
      !user.closed_account? && user.oauth_identities.where(provider: GOOGLE_PROVIDER).count == 1
    end

    def users_for_normalized_email(lock: false)
      scope = User.where("LOWER(email) = ?", @email).limit(2)
      lock ? scope.lock.to_a : scope.to_a
    end

    def update_identity_result(identity, user, created_identity:, linked_existing_user:)
      identity.email = @email
      set_if_supported(identity, :email_verified, @email_verified) unless @email_verified.nil?
      merge_credentials(identity)
      merge_metadata(identity)
      stamp_link_timestamps(identity)
      identity.save!

      Result.new(
        identity: identity,
        user: user,
        created_identity: created_identity,
        linked_existing_user: linked_existing_user
      )
    end

    def subject_fingerprint(provider_uid)
      Digest::SHA256.hexdigest("#{GOOGLE_SUBJECT_FINGERPRINT_CONTEXT}:#{provider_uid}")
    end

    def resolve_user
      if @email.present?
        existing = User.find_by(email: @email)
        return [existing, true] if existing
      end

      user = User.new(
        email: @email.presence || generated_email,
        english_name: @name.presence || "OAuth User",
        encrypted_password: User.password_hash(SecureRandom.hex(16)),
        metadata: {
          oauth_seeded: true,
          provider: @provider,
          oauth_identity_linked_at: Time.current.iso8601
        }
      )
      user.save!
      [user, false]
    end

    def generated_email
      "#{@provider}_#{SecureRandom.hex(8)}@#{AppConstants::Project.slug}.oauth"
    end

    def merge_credentials(identity)
      if @credentials.present?
        identity.credentials = @credentials
      else
        identity.credentials ||= {}
      end
    end

    def merge_metadata(identity)
      base = identity.metadata.is_a?(Hash) ? identity.metadata : {}
      identity.metadata = base.merge(@metadata).merge("updated_at" => Time.current.iso8601)
    end

    def stamp_link_timestamps(identity)
      now = Time.current
      set_if_supported(identity, :linked_at, identity.read_attribute(:linked_at) || now)
      set_if_supported(identity, :last_login_at, now)
    end

    def set_if_supported(identity, attribute, value)
      return unless identity.has_attribute?(attribute)

      identity[attribute] = value
    end

    def normalized_email(value)
      email = value.to_s.strip.downcase
      email.presence
    end

    def cast_boolean(value)
      return nil if value.nil?

      lowered = value.to_s.strip.downcase
      return true if %w[true 1 yes y].include?(lowered)
      return false if %w[false 0 no n].include?(lowered)

      nil
    end
  end
end
