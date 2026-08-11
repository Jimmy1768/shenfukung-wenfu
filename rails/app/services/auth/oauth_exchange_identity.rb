# frozen_string_literal: true

require "base64"
require "json"

module Auth
  # Applies the central-auth exchange response to Wenfu's existing identity
  # authority. Browser and native callers retain their own session transport,
  # but must share this normalization and account-resolution policy.
  class OAuthExchangeIdentity
    Result = Struct.new(
      :identity,
      :user,
      :link_result,
      :provider,
      :canonical_provider,
      :profile_required,
      keyword_init: true
    )

    class Error < StandardError; end
    class MissingProvider < Error; end
    class MissingIdentity < Error; end
    class ProviderMismatch < Error; end
    class ClosedAccount < Error; end

    PROVIDER_TO_IDENTITY = {
      "google" => "google_oauth2",
      "apple" => "apple",
      "facebook" => "facebook"
    }.freeze

    IDENTITY_TO_CANONICAL_PROVIDER = {
      "google_oauth2" => "google",
      "apple" => "apple",
      "facebook" => "facebook"
    }.freeze

    def self.resolve!(response:, link_user: nil, link: false, expected_provider: nil)
      new(response:, link_user:, link:, expected_provider:).resolve!
    end

    def initialize(response:, link_user:, link:, expected_provider:)
      @response = response.is_a?(Hash) ? response : {}
      @link_user = link_user
      @link = link
      @expected_provider = expected_provider
    end

    def resolve!
      fields = identity_fields
      provider = identity_provider(fields[:provider])
      raise MissingProvider, "OAuth exchange missing provider" if provider.blank?
      raise MissingIdentity, "OAuth exchange missing uid" if fields[:uid].blank?
      canonical_provider = IDENTITY_TO_CANONICAL_PROVIDER.fetch(provider)
      if @expected_provider.present? && canonical_provider != @expected_provider
        raise ProviderMismatch, "OAuth exchange provider mismatch"
      end

      link_result = resolve_identity!(provider, fields)
      user = @link ? @link_user : link_result.user
      raise ClosedAccount, "Closed account cannot sign in" if !@link && user.closed_account?

      ensure_terms_acceptance!(user, provider)
      Result.new(
        identity: link_result.identity,
        user:,
        link_result:,
        provider:,
        canonical_provider:,
        profile_required: profile_required?(user)
      )
    end

    private

    def resolve_identity!(provider, fields)
      if @link
        raise ArgumentError, "You must be signed in to link a provider." if @link_user.blank?

        Auth::OAuthIdentityLinker.link!(
          user: @link_user,
          provider:,
          uid: fields[:uid],
          email: fields[:email],
          email_verified: fields[:email_verified],
          credentials: @response["credentials"] || {},
          metadata: { "central_auth" => @response }
        )
      else
        Auth::OAuthIdentityResolver.resolve_or_link!(
          provider:,
          uid: fields[:uid],
          email: fields[:email],
          name: fields[:name],
          email_verified: fields[:email_verified],
          credentials: @response["credentials"] || {},
          metadata: { "central_auth" => @response }
        )
      end
    end

    def identity_fields
      claims = extract_claims
      id_token_claims = extract_id_token_claims

      {
        provider: first_present(claims["provider"], @response["provider"], id_token_claims["provider"], @response.dig("identity", "provider")),
        uid: first_present(claims["provider_uid"], claims["uid"], claims["sub"], claims["subject"], @response["provider_uid"], @response["uid"], @response["sub"], @response["subject"], @response.dig("identity", "provider_uid"), @response.dig("identity", "uid"), @response.dig("identity", "sub"), id_token_claims["sub"], id_token_claims["uid"]),
        email: first_present(claims["email"], @response["email"], @response.dig("identity", "email"), @response.dig("user", "email"), id_token_claims["email"]),
        name: first_present(claims["name"], @response["name"], @response.dig("identity", "name"), @response.dig("user", "name"), id_token_claims["name"]),
        email_verified: first_present(claims["email_verified"], @response["email_verified"], @response.dig("identity", "email_verified"), @response.dig("user", "email_verified"), id_token_claims["email_verified"])
      }
    end

    def extract_claims
      value = @response["claims"] || @response["user"] || @response["profile"] || @response.dig("identity", "claims") || @response.dig("credentials", "claims") || {}
      value.is_a?(Hash) ? value : {}
    end

    def extract_id_token_claims
      token = @response["id_token"] || @response.dig("credentials", "id_token") || @response.dig("tokens", "id_token")
      return {} if token.blank?

      payload = token.to_s.split(".")[1]
      return {} if payload.blank?

      parsed = JSON.parse(Base64.urlsafe_decode64(payload + ("=" * ((4 - payload.length % 4) % 4))))
      parsed.is_a?(Hash) ? parsed : {}
    rescue StandardError
      {}
    end

    def identity_provider(value)
      PROVIDER_TO_IDENTITY[value.to_s]
    end

    def first_present(*values)
      values.find(&:present?)
    end

    def ensure_terms_acceptance!(user, provider)
      metadata = (user.metadata || {}).with_indifferent_access
      updated_metadata = metadata.merge(
        signup_source: metadata[:signup_source].presence || provider,
        terms_version: metadata[:terms_version].presence || AppConstants::Legal.default_terms_version,
        terms_accepted_at: metadata[:terms_accepted_at].presence || Time.current.iso8601
      )
      user.update!(metadata: updated_metadata) unless updated_metadata == metadata
    end

    def profile_required?(user)
      english_name = user.english_name.to_s.strip
      native_name = user.native_name.to_s.strip
      (english_name.blank? || english_name == "OAuth User") && native_name.blank?
    end
  end
end
