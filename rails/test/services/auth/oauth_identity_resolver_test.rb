require "test_helper"

module Auth
  class OAuthIdentityResolverTest < ActiveSupport::TestCase
    test "rejects an unmatched identity instead of provisioning a user" do
      assert_no_difference(["User.count", "OAuthIdentity.count"]) do
        assert_raises(OAuthIdentityResolver::UnmatchedIdentity) do
          OAuthIdentityResolver.resolve_or_link!(
        provider: "google_oauth2",
        uid: "resolver-new-uid",
        email: "resolver.new@example.com",
        name: "Resolver New",
        email_verified: true,
        credentials: { "token" => "abc" },
        metadata: { "source" => "test" }
          )
        end
      end
    end

    test "does not link a new provider identity to an existing user by email" do
      user = create_user("resolver.link@example.com", "Resolver Link")

      assert_raises(OAuthIdentityResolver::UnmatchedIdentity) do
        OAuthIdentityResolver.resolve_or_link!(
        provider: "facebook",
        uid: "resolver-link-uid",
        email: user.email,
        name: "Ignored Name",
        email_verified: true,
        credentials: {},
        metadata: { "source" => "test-link" }
        )
      end
      assert_empty user.oauth_identities
    end

    test "reuses existing identity for provider and uid" do
      user = create_user("resolver.existing@example.com", "Resolver Existing")
      first_identity = OAuthIdentity.create!(user:, provider: "apple", provider_uid: "resolver-existing-uid", email: user.email, credentials: { "token" => "first" }, metadata: { "source" => "first" })

      second = OAuthIdentityResolver.resolve_or_link!(
        provider: "apple",
        uid: "resolver-existing-uid",
        email: "resolver.existing@example.com",
        name: "Resolver Existing",
        credentials: { "token" => "second" },
        metadata: { "source" => "second" }
      )

      assert_equal first_identity.id, second.identity.id
      assert_equal user.id, second.user.id
      assert_equal false, second.created_identity
      assert_equal "second", second.identity.credentials["token"]
      assert_equal "second", second.identity.metadata["source"]
    end

    test "replaces a verified google subject on the existing identity and is idempotent" do
      user = create_user("resolver.google.subject@example.com", "Google Subject")
      identity = OAuthIdentity.create!(
        user: user,
        provider: "google_oauth2",
        provider_uid: "resolver-google-old-subject",
        email: user.email,
        email_verified: true,
        credentials: { "token" => "old-token" },
        metadata: { "source" => "old" }
      )

      result = OAuthIdentityResolver.resolve_or_link!(
        provider: "google_oauth2",
        uid: "resolver-google-new-subject",
        email: "RESOLVER.GOOGLE.SUBJECT@example.com",
        name: "Google Subject",
        email_verified: "true",
        credentials: { "token" => "resolver-google-new-token" },
        metadata: { "source" => "replacement" }
      )

      identity.reload
      audit = SystemAuditLog.find_by!(action: "auth.oauth.google_subject_replaced")
      audit_metadata = audit.metadata.to_json

      assert_equal identity.id, result.identity.id
      assert_equal user.id, result.user.id
      assert_equal "resolver-google-new-subject", identity.provider_uid
      assert_equal user.id, identity.user_id
      assert_equal 1, user.oauth_identities.where(provider: "google_oauth2").count
      assert_equal "resolver-google-new-token", identity.credentials["token"]
      assert_equal "replacement", identity.metadata["source"]
      assert_equal identity, audit.target
      assert_equal user, audit.user
      assert_equal "google_oauth2", audit.metadata["provider"]
      assert_equal user.id, audit.metadata["user_id"]
      assert_equal identity.id, audit.metadata["oauth_identity_id"]
      assert_match(/\A[0-9a-f]{64}\z/, audit.metadata["old_provider_uid_fingerprint"])
      assert_match(/\A[0-9a-f]{64}\z/, audit.metadata["new_provider_uid_fingerprint"])
      %w[resolver-google-old-subject resolver-google-new-subject resolver.google.subject@example.com resolver-google-new-token].each do |raw_value|
        assert_not_includes audit_metadata, raw_value
      end

      repeated = OAuthIdentityResolver.resolve_or_link!(
        provider: "google_oauth2",
        uid: "resolver-google-new-subject",
        email: user.email,
        name: "Google Subject",
        email_verified: true,
        credentials: { "token" => "resolver-google-repeat-token" },
        metadata: { "source" => "repeat" }
      )

      assert_equal identity.id, repeated.identity.id
      assert_equal user.id, repeated.user.id
      assert_equal 1, user.oauth_identities.where(provider: "google_oauth2").count
      assert_equal 1, SystemAuditLog.where(action: "auth.oauth.google_subject_replaced").count
    end

    test "does not replace a stale google subject when email is missing or unverified" do
      user = create_user("resolver.google.unverified@example.com", "Google Unverified")
      identity = create_google_identity(user, "resolver-google-unverified-old")

      [
        { email: nil, email_verified: true, uid: "resolver-google-missing-email-subject" },
        { email: user.email, email_verified: false, uid: "resolver-google-unverified-subject" }
      ].each do |attributes|
        if attributes[:email].nil?
          assert_raises(OAuthIdentityResolver::UnmatchedIdentity) { OAuthIdentityResolver.resolve_or_link!(
            provider: "google_oauth2",
            uid: attributes[:uid],
            email: attributes[:email],
            name: "Google Unverified",
            email_verified: attributes[:email_verified],
            credentials: { "token" => "resolver-unverified-token" },
            metadata: {}
          ) }
        else
          assert_raises(OAuthIdentityResolver::UnmatchedIdentity) do
            OAuthIdentityResolver.resolve_or_link!(
              provider: "google_oauth2",
              uid: attributes[:uid],
              email: attributes[:email],
              name: "Google Unverified",
              email_verified: attributes[:email_verified],
              credentials: { "token" => "resolver-unverified-token" },
              metadata: {}
            )
          end
        end
        assert_equal "resolver-google-unverified-old", identity.reload.provider_uid
      end

      assert_equal 1, user.oauth_identities.where(provider: "google_oauth2").count
      assert_equal 0, SystemAuditLog.where(action: "auth.oauth.google_subject_replaced").count
    end

    test "does not replace a stale identity for a non-google provider or a subject owned by another user" do
      user = create_user("resolver.google.conflict@example.com", "Google Conflict")
      identity = create_google_identity(user, "resolver-google-conflict-old")
      other_user = create_user("resolver.google.owner@example.com", "Google Owner")
      OAuthIdentity.create!(
        user: other_user,
        provider: "google_oauth2",
        provider_uid: "resolver-google-owned-subject",
        email: other_user.email,
        credentials: {},
        metadata: {}
      )

      assert_raises(OAuthIdentityResolver::UnmatchedIdentity) { OAuthIdentityResolver.resolve_or_link!(
        provider: "facebook",
        uid: "resolver-facebook-subject",
        email: user.email,
        name: "Google Conflict",
        email_verified: true,
        credentials: {},
        metadata: {}
      ) }
      assert_equal "resolver-google-conflict-old", identity.reload.provider_uid
      exact_subject = OAuthIdentityResolver.resolve_or_link!(
        provider: "google_oauth2",
        uid: "resolver-google-owned-subject",
        email: user.email,
        name: "Google Conflict",
        email_verified: true,
        credentials: {},
        metadata: {}
      )

      assert_equal other_user.id, exact_subject.user.id
      assert_equal "resolver-google-conflict-old", identity.reload.provider_uid
      assert_equal 0, SystemAuditLog.where(action: "auth.oauth.google_subject_replaced").count
    end

    test "does not replace an ambiguous or closed user's stale google identity" do
      ambiguous_user = create_user("resolver.google.ambiguous@example.com", "Google Ambiguous")
      first_identity = create_google_identity(ambiguous_user, "resolver-google-ambiguous-old-one")
      assert_raises(ActiveRecord::RecordNotUnique) do
        OAuthIdentity.new(
        user: ambiguous_user,
        provider: "google_oauth2",
        provider_uid: "resolver-google-ambiguous-old-two",
        email: ambiguous_user.email,
        credentials: {},
        metadata: {}
        ).save!(validate: false)
      end

      closed_user = create_user("resolver.google.closed@example.com", "Google Closed")
      closed_identity = create_google_identity(closed_user, "resolver-google-closed-old")
      closed_user.close_account!(reason: "self_service")

      [
        [closed_user, "resolver-google-closed-new", "Google Closed"]
      ].each do |candidate, new_uid, name|
        assert_raises(OAuthIdentityResolver::UnmatchedIdentity) do
          OAuthIdentityResolver.resolve_or_link!(
            provider: "google_oauth2",
            uid: new_uid,
            email: candidate.email,
            name: name,
            email_verified: true,
            credentials: {},
            metadata: {}
          )
        end
      end

      assert_equal "resolver-google-closed-old", closed_identity.reload.provider_uid
      assert_equal 1, closed_user.oauth_identities.where(provider: "google_oauth2").count
      assert_equal 0, SystemAuditLog.where(action: "auth.oauth.google_subject_replaced").count
    end

    test "rolls back a google subject replacement when its audit cannot be written" do
      user = create_user("resolver.google.audit.failure@example.com", "Google Audit Failure")
      identity = create_google_identity(user, "resolver-google-audit-old")

      SystemAuditLogger.stub(:log!, ->(**) { raise "audit unavailable" }) do
        assert_raises(RuntimeError) do
          OAuthIdentityResolver.resolve_or_link!(
            provider: "google_oauth2",
            uid: "resolver-google-audit-new",
            email: user.email,
            name: "Google Audit Failure",
            email_verified: true,
            credentials: {},
            metadata: {}
          )
        end
      end

      assert_equal "resolver-google-audit-old", identity.reload.provider_uid
      assert_equal 0, SystemAuditLog.where(action: "auth.oauth.google_subject_replaced").count
    end

    private

    def create_user(email, name)
      User.create!(
        email: email,
        english_name: name,
        encrypted_password: User.password_hash("Resolver!123"),
        metadata: {}
      )
    end

    def create_google_identity(user, uid)
      OAuthIdentity.create!(
        user: user,
        provider: "google_oauth2",
        provider_uid: uid,
        email: user.email,
        credentials: {},
        metadata: {}
      )
    end
  end
end
