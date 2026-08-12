require "test_helper"

module Auth
  class OAuthEmptyPlaceholderConsolidatorTest < ActiveSupport::TestCase
    setup { Config::EntryResolver.upsert!(key: "oauth_account_consolidation", value: true) }
    test "moves only an empty seeded placeholder after dual proof and redacts the audit" do
      keeper = create_user("keeper@example.test", "Keeper")
      source = create_user("placeholder@example.test", "OAuth User", oauth_seeded: true)
      identity = OAuthIdentity.create!(user: source, provider: "apple", provider_uid: "source-subject", email: source.email, credentials: {}, metadata: {})
      proof = provider_proof(identity)

      OAuthEmptyPlaceholderConsolidator.consolidate!(keeper_user: keeper, keeper_password: "Password123!", provider: "apple", uid: "source-subject", source_proof_token: proof.token, confirmed: true)

      assert_equal keeper.id, identity.reload.user_id
      assert source.reload.closed_account?
      audit = SystemAuditLog.find_by!(action: "auth.oauth.empty_placeholder_consolidated")
      refute_includes audit.metadata.to_json, "source-subject"
      assert_match(/\A[0-9a-f]{64}\z/, audit.metadata["provider_uid_fingerprint"])
    end

    test "refuses a source with user work or missing proof" do
      keeper = create_user("keeper-two@example.test", "Keeper")
      source = create_user("placeholder-two@example.test", "OAuth User", oauth_seeded: true)
      identity = OAuthIdentity.create!(user: source, provider: "apple", provider_uid: "source-two", email: source.email, credentials: {}, metadata: {})
      source.refresh_tokens.create!(token_digest: "refresh-token-#{SecureRandom.hex(8)}", expires_at: 1.day.from_now)
      proof = provider_proof(identity)

      assert_raises(OAuthEmptyPlaceholderConsolidator::UnsupportedSource) do
        OAuthEmptyPlaceholderConsolidator.consolidate!(keeper_user: keeper, keeper_password: "Password123!", provider: "apple", uid: identity.provider_uid, source_proof_token: proof.token, confirmed: true)
      end
      assert_equal source.id, identity.reload.user_id
      Config::EntryResolver.upsert!(key: "oauth_account_consolidation", value: false)
      assert_raises(OAuthEmptyPlaceholderConsolidator::FeatureDisabled) do
        OAuthEmptyPlaceholderConsolidator.consolidate!(keeper_user: keeper, keeper_password: "Password123!", provider: "apple", uid: identity.provider_uid, source_proof_token: proof.token, confirmed: true)
      end
    end

    test "rejects a guessed source uid even when the keeper password is valid" do
      keeper = create_user("keeper-three@example.test", "Keeper")
      source = create_user("placeholder-three@example.test", "OAuth User", oauth_seeded: true)
      identity = OAuthIdentity.create!(user: source, provider: "apple", provider_uid: "source-three", email: source.email, credentials: {}, metadata: {})
      proof = provider_proof(identity)

      assert_raises(OAuthAccountResolution::ProviderMismatch) do
        OAuthEmptyPlaceholderConsolidator.consolidate!(keeper_user: keeper, keeper_password: "Password123!", provider: "apple", uid: "guessed-subject", source_proof_token: proof.token, confirmed: true)
      end
      assert_equal source.id, identity.reload.user_id
      assert_nil proof.record.reload.consumed_at
    end

    test "does not mint a consolidation proof from an arbitrary local uid" do
      assert_raises(OAuthAccountResolution::InvalidToken) do
        OAuthAccountResolution.create_consolidation_proof_from_exchange!(
          exchange_identity: Struct.new(:identity, :provider).new(nil, "apple")
        )
      end
    end

    private

    def create_user(email, name, oauth_seeded: false)
      User.create!(email:, english_name: name, encrypted_password: User.password_hash("Password123!"), metadata: { "oauth_seeded" => oauth_seeded })
    end

    def provider_proof(identity)
      exchange_identity = OAuthExchangeIdentity.resolve!(
        response: {
          "provider" => "apple",
          "uid" => identity.provider_uid,
          "email" => identity.email,
          "email_verified" => identity.email_verified
        }
      )
      OAuthAccountResolution.create_consolidation_proof_from_exchange!(
        exchange_identity:
      )
    end
  end
end
