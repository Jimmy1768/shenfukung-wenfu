# Google OAuth Subject Compatibility Repair Plan

## Status

Accepted for bounded implementation. This plan repairs a Wenfu-local identity
compatibility failure only. It does not authorize a production database edit,
provider configuration change, credential inspection, deployment, restart, or
other external action.

## Observed Diagnosis

On 2026-08-08, Central Auth successfully exchanged the Google authorization
code and returned mapped provider, provider-subject, and email claims. Its
read-only evidence found no central validation failure.

Wenfu's hash-only local correlation found that the returned email resolves to
an existing Wenfu user which already has a `google_oauth2` identity, while the
returned provider subject matches neither that identity nor any other local
Google identity. `Auth::OAuthIdentityResolver` therefore tries to attach a
second Google identity to the same user; the existing one-per-provider user
constraint raises `ActiveRecord::RecordInvalid`, and the callback shows the
generic failure message.

No raw provider subject, email, authorization code, token, credential, secret,
or production record is recorded in this plan.

## Phase 1 — Bounded Resolver Repair

Implement a narrow, auditable compatibility path in the local OAuth identity
resolver:

1. Keep the ordinary exact provider/subject lookup unchanged.
2. Consider subject replacement only for Google, after a successful Central
   Auth exchange supplies a nonblank, provider-verified email.
3. Resolve that email to exactly one local user whose only existing Google
   identity is not owned by any other user. Atomically replace that identity's
   obsolete provider subject with the authenticated current subject.
4. Record a Wenfu system audit event using non-reversible subject fingerprints
   and the identity/user references needed for local accountability. Never log
   raw subjects, access tokens, or credentials.
5. Fail closed with no mutation for missing or unverified email, an ambiguous
   user/identity state, a non-Google provider, or a subject owned by another
   user. Do not introduce email-based automatic merges.

The Control implementation packet selects the exact code paths, audit event
name/metadata contract, migration need (if any), and tests. No existing
identity is to be hand-edited in production as a substitute for the tested
code path.

## Acceptance Criteria

- Existing Google login with an exact subject continues unchanged.
- A verified Central Auth Google email that maps to a user with one stale local
  Google subject updates that existing identity atomically and allows sign-in.
- The compatibility path writes one appropriate audit record without raw
  provider subjects, emails, tokens, or secrets.
- Repeated callback with the new subject is idempotent and does not create a
  second identity or another migration audit record.
- A missing/unverified email, a different provider, a conflicting current
  subject, or ambiguous local identity state fails safely without relinking.
- Tenant isolation, owner/admin authority, account closure, password-login,
  existing OAuth linking/unlinking, and user-work protections remain intact.
- Focused resolver/controller or integration tests, relevant audit tests, and
  `git diff --check` pass locally.

## Phase 2 — Separate Production Workflow (Not Authorized Here)

After local integration, a separate explicit production workflow must name the
release commit, live target, deployment/rollback steps, validation account and
expected result, monitoring window, and approval. It must not print or copy
OAuth credentials, provider identifiers, emails, or subjects. A successful
local implementation does not itself authorize release promotion or a
production-data change.

## Preserved Boundaries

- SourceGrid owns Central Auth registration and provider exchange; this plan
  neither changes it nor reopens that completed registration repair.
- Wenfu remains responsible only for its local account/identity records and
  post-exchange account handling.
- Payment, Stripe, ECPay, temple/tenant routing, deployment, provider
  credentials, and product/runtime work are out of scope.
