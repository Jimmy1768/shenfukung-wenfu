# app/services/auth/refresh_token.rb
#
# Auth::RefreshToken
# ------------------------------------------------------------------
# DB-backed native refresh-token lifecycle. Raw token values are returned only
# at issue/rotation time; the database retains a SHA-256 digest.
#
# Responsibilities (once models/migrations exist):
# - Issue refresh tokens (and store hashed versions in DB)
# - Rotate refresh tokens (invalidate old, create new)
# - Revoke tokens per device
# - "Sign out of all devices" for a user
#
# IMPORTANT:
# - This is a sketch for Golden Template.
# - It assumes a future RefreshToken model (not created yet).
# - Do NOT add migrations here; keep schema work separate.
#

require "digest"

module Auth
  class RefreshToken
    Result = Struct.new(:success?, :raw_token, :record, :error, keyword_init: true)

    # Usage idea:
    #
    #   service = Auth::RefreshToken.new(user)
    #   raw_refresh_token = service.issue!(user_agent: ua, ip_address: ip)
    #
    #   # later, to rotate:
    #   new_raw_token = service.rotate!(old_raw_refresh_token)
    #
    #   # sign out all devices:
    #   service.revoke_all!
    #

    def initialize(user)
      @user = user
    end

    # Issue a new refresh token for this user.
    # Returns the *raw* token string to send to the client.
    #
    # Later, you will:
    # - generate a secure random token
    # - store a hashed version in the database (e.g. RefreshToken model)
    # - set an expires_at using Auth::JwtConfig::REFRESH_TOKEN_TTL
    #
    def issue!(user_agent: nil, ip_address: nil, context: nil)
      raw_token = SecureRandom.urlsafe_base64(48)
      context = (context || {}).with_indifferent_access
      record = ::RefreshToken.create!(
        user: @user,
        token_digest: digest(raw_token),
        device_id: context[:device_id].presence,
        device_name: context[:device_name].presence,
        platform: context[:platform].presence,
        expires_at: Auth::JwtConfig::REFRESH_TOKEN_TTL.seconds.from_now,
        metadata: {
          "native" => true,
          "user_agent" => user_agent.to_s.first(500),
          "ip_address" => ip_address.to_s.first(100)
        }.compact
      )
      Result.new(success?: true, raw_token:, record:)
    end

    # Rotate an existing refresh token and return a new raw token.
    #
    # Expected behavior (later):
    # - find the existing RefreshToken by digest
    # - ensure not expired / revoked
    # - delete or mark old token as used
    # - create a new token row and return the raw token
    #
    def rotate!(raw_token)
      digest_value = digest(raw_token)
      record = ::RefreshToken.includes(:user).find_by(token_digest: digest_value)
      return Result.new(success?: false, error: :invalid) unless record

      record.with_lock do
        if !record.active?
          # A previously valid revoked token is a replay. Revoke the user's
          # complete native session set so a stolen token cannot race rotation.
          revoke_all! if record.revoked?
          return Result.new(success?: false, error: record.revoked? ? :replayed : :expired)
        end

        record.update!(revoked: true, last_used_at: Time.current)
        issue!(
          user_agent: record.metadata.to_h["user_agent"],
          ip_address: record.metadata.to_h["ip_address"],
          context: {
            device_id: record.device_id,
            device_name: record.device_name,
            platform: record.platform
          }
        )
      end
    end

    # Revoke all refresh tokens for this user.
    # Used for "sign out of all devices/webapps".
    #
    def revoke_all!
      @user.refresh_tokens.where(revoked: false).update_all(revoked: true, updated_at: Time.current)
    end

    def revoke!(raw_token)
      record = @user.refresh_tokens.find_by(token_digest: digest(raw_token))
      return false unless record

      record.update!(revoked: true, last_used_at: Time.current) unless record.revoked?
      true
    end

    private

    def digest(raw_token)
      Digest::SHA256.hexdigest(raw_token.to_s)
    end
  end
end
