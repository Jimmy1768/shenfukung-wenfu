# Apple OAuth Account Resolution Readiness And Implementation Plan

Status: Planning recommendation for Director review; not accepted for
implementation or dispatch

Created: 2026-08-12

Owner: Wenfu Planning

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Diagnosis baseline:
`44815e184b08f6fe57deb6c16607f5abfb8e1779`

## Objective

Explain the observed Apple-only account without guessing that two records
belong to the same human, then define the smallest safe product and server
work needed for:

- an existing Wenfu user who wants to add Apple as another sign-in method;
- a genuinely new Apple user whose provider response has a relay address or no
  usable name;
- an already-provisioned Apple identity that is attached to a different Wenfu
  user record;
- browser account, browser admin, legacy callback, and native account flows
  that currently share identity-resolution code.

This document is a readiness and implementation recommendation only. It does
not authorize source changes, provider or credential access, production-data
inspection or mutation, deployment, account changes, or Control dispatch.

## Sanitized Observed Facts

Director-supplied read-only production evidence establishes:

- the supplied Gmail normalizes to exactly one Wenfu user, one Google identity,
  and one Google-linked user;
- internal user 22 is a different user with one Apple identity and no Google
  identity;
- neither user 22's user email nor its Apple identity email equals the Gmail;
- the Apple-only user presents the generic name `OAuth User`;
- the read-only verification changed no production data.

These facts do **not** prove that the records belong to the same human. They
prove that Wenfu has one Google-linked account and one distinct Apple-linked
account with no trustworthy local correlation between them.

## Exact Current Path

### Shared exchange normalization

`Auth::OAuthExchangeIdentity` is shared by the central browser callback and
the native OAuth exchange. It:

1. accepts Central Auth's normalized provider, provider subject, optional
   email, optional name, and optional `email_verified` claim from supported
   response locations;
2. maps canonical `apple` to local provider `apple` and canonical `google` to
   local provider `google_oauth2`;
3. sends an explicit signed-in linking request to
   `Auth::OAuthIdentityLinker`;
4. sends an ordinary signed-out authentication to
   `Auth::OAuthIdentityResolver`;
5. classifies the resulting user as `profile_required` when both native name
   is blank and English name is blank or exactly `OAuth User`.

### Signed-out resolver

`Auth::OAuthIdentityResolver` currently resolves in this order:

1. exact local `(provider, provider_uid)` identity;
2. a narrow, already-accepted Google subject-compatibility path;
3. a new OAuth identity attached to a user found by exact normalized returned
   email;
4. otherwise, a newly provisioned user and identity.

The newly provisioned user receives:

- the returned email, or a generated local OAuth address when email is absent;
- the returned name, or persisted `english_name = "OAuth User"` when name is
  absent;
- `metadata.oauth_seeded = true` and a random local password hash.

Therefore a new Apple subject with an Apple-returned address that does not
equal the Gmail cannot resolve to the Gmail/Google user. The resolver creates a
new Apple-only user. When no name is available, it persists `OAuth User`.
This exactly explains the supplied production shape without assuming a
provider defect, client defect, or database corruption.

### Browser behavior

`Auth::CentralOAuthController#callback` resolves the exchange before choosing
the account or admin session branch. For an ordinary account sign-in it:

- establishes the account cookie session for the resolved user;
- redirects `profile_required` users to account profile edit;
- displays the complete-profile notice.

For explicit linking, the existing account UI starts OAuth with
`intent=link` only while a user is already signed in. The linker attaches the
new provider subject to that authenticated user and rejects a subject already
owned by another user. It performs no merge.

The admin branch checks active admin authority only after shared resolution.
Consequently an unmatched signed-out admin OAuth callback can provision a user
before failing the admin-authority check. That is a separate readiness gap: an
admin login must never be an account-provisioning path.

### Native behavior

`POST /api/v1/account/native/oauth/start` and `/exchange` are signed-out
account-only endpoints. Native exchange uses the same resolver, then issues the
existing account-scoped JWT/refresh session immediately. It returns
`profile_required`, and TempleMate navigates that signed-in user to Profile.

The native response mapper selects `native_name`, then `english_name`, then
email. Therefore visible `OAuth User` is the persisted Rails value selected by
the client; it is not a TempleMate-only fallback.

The native API and TempleMate currently have no authenticated provider-linking
contract or sign-in-method management surface.

### Legacy callback

`Auth::OmniauthController` also calls `OAuthIdentityResolver` directly. It
creates an account session but does not use the shared `profile_required`
redirect behavior. It must be aligned, constrained, or retired as part of any
resolver-policy change; leaving it unchanged would preserve a second account-
creation policy.

## Trust And Inference Boundary

Wenfu may safely treat the successful Central Auth result as proof of the
returned provider identity within the accepted exchange contract. Locally,
that means:

- exact Apple provider subject proves the same Apple identity on repeat login;
- exact Google provider subject proves the same Google identity on repeat
  login;
- a fresh provider authorization performed while an existing Wenfu account is
  authenticated proves possession of both that Wenfu session and that provider
  identity for an explicit link attempt;
- Central Auth's optional email, verification flag, and name are provider
  claims useful for display or onboarding under a separately accepted policy.

Wenfu cannot infer that an Apple relay address and a Gmail belong to the same
human. It also must not infer account equivalence from:

- name or `OAuth User` presentation;
- an email string alone, including an exact match across different providers;
- a relay-domain pattern or guessed hidden address;
- temple membership, registrations, dependents, payments, role, device, IP,
  locale, or staff familiarity;
- an administrator selecting two records without user proof of both sign-in
  methods.

The existing narrow Google subject-compatibility repair is provider-specific
historical behavior for one Google identity and is not authority to merge an
Apple identity or two users. This plan does not broaden it.

## Verified Placeholder Mechanism

The placeholder is fully explained by current source and tests:

- the resolver persists `OAuth User` only when it creates a user and the
  exchange contains no usable name;
- the shared exchange marks that user `profile_required`;
- the browser redirects that signed-in user to profile edit;
- native returns `profile_required` and TempleMate navigates to Profile;
- TempleMate displays the server's nonblank `english_name` before considering
  email.

Focused tests explicitly cover Apple ID-token claims with no name, persisted
`OAuth User`, browser profile-edit redirection, and native
`profile_required`. The observed label is not evidence of a UI-only fallback.

What remains unknown from local evidence is why the particular Apple exchange
did not contain a usable name. That provider-history question is unnecessary
to diagnose Wenfu's deterministic behavior and must not be answered by guess.

## Safe Desired Behavior

### Existing user adding Apple

The ordinary safe journey is:

1. sign in to the existing Wenfu account using an existing method;
2. open Sign-in methods;
3. choose Link Apple;
4. complete a fresh Apple authorization in a purpose-bound link transaction;
5. attach the Apple subject to the already-authenticated user only if that
   subject is unowned;
6. retain account, temple, role, profile, registrations, dependents, payments,
   and other user work unchanged.

The current web account-linking flow already implements the core ownership
proof and conflict behavior. It should be the initial supported recovery path
when the Apple subject is unowned. Native parity requires a separate
authenticated link endpoint and TempleMate Sign-in methods UI; signed-out
native exchange must not be reused as a link request.

### Apple identity already attached to another user

The existing linker correctly stops. It must continue to stop. Resolution
requires proof of both sides, not an inferred merge:

- a recent authenticated session for the intended keeper account;
- a fresh Apple authorization for the already-owned Apple subject;
- an explicit consolidation confirmation describing the affected accounts;
- a read-only inventory of the source user's user work and lifecycle state;
- an auditable, transactional server operation approved under a separate data
  policy.

If the source user has any meaningful work, admin authority, unresolved
privacy/closure state, registrations, dependents, payments, certificates,
support activity, or other ownership-sensitive records, automatic
consolidation is prohibited. The case requires an explicit adjudication and
record-by-record policy. No implementation may guess which user record wins.

Even for an otherwise empty OAuth-seeded placeholder, the safe operation is to
move the exact Apple identity only after dual proof, revoke source sessions,
preserve an audit/tombstone, and close or otherwise retire the source user
according to an accepted lifecycle policy. It must not delete the source user
or rewrite user work silently.

### Genuinely new Apple user

An unmatched Apple subject should not be mistaken for an existing account from
email or relay heuristics. The recommended target contract is a short-lived,
server-held pending resolution rather than immediate permanent provisioning:

- Central Auth exchange proves the Apple identity, but Wenfu returns
  `account_resolution_required` and no account session when the subject is
  unmatched;
- the user chooses either **I already have an account** or **Create a new
  account**;
- existing-account choice requires successful authentication of that Wenfu
  account before the pending Apple identity can be linked;
- new-account choice requires explicit confirmation and required profile/
  terms input before the user and identity are created atomically;
- the pending record/token is purpose-bound, short-lived, one-use, redacted,
  and contains no provider credential in the client.

This avoids manufacturing a second permanent account merely because an
existing user selected Apple from a signed-out screen. If the Director rejects
pending resolution as too broad for the first repair, the fallback is to retain
provisional OAuth-seeded users but add an explicit existing-account recovery
flow before any user work. That fallback still needs the dual-proof conflict
operation above and therefore has more cleanup complexity.

## Recommended Implementation Sequence

No phase below is authorized until the Director accepts the open decisions and
Planning commits a bounded implementation plan.

### Phase 1 — Resolution policy and server contract

- Separate exact-identity login, explicit signed-in link, unmatched-identity
  onboarding, and admin lookup into named resolver modes.
- Remove generic signed-out cross-provider attachment by returned email from
  the new policy. Preserve exact provider-subject login.
- Keep the narrow Google subject compatibility path isolated and unchanged
  unless separately reopened by the Director.
- Make admin OAuth lookup-only: no user or identity provisioning, no linking,
  and no account session; require an existing active admin user after exact
  identity resolution.
- Decide whether to align or disable the legacy OmniAuth callback.
- If pending resolution is accepted, add its server-side model/service,
  expiration, one-use consumption, redaction, and transaction behavior.
- Add a database uniqueness constraint for one identity per user/provider if a
  compatibility inventory proves existing data clean; the model validation
  exists, but the database currently guarantees only unique
  `(provider, provider_uid)`.

Likely Rails surfaces include the shared exchange/resolver/linker services,
browser central callback, native OAuth controller/flow, legacy OmniAuth
controller, routes, feature/config gates, audit services, schema/model if
pending resolution is accepted, and focused service/integration tests.

### Phase 2 — Browser account UX

- Preserve existing signed-in Sign-in methods linking for an unowned Apple
  subject.
- Present actionable conflict copy when the Apple identity already belongs to
  another user; do not tell the user to create another account.
- Add the accepted existing-versus-new resolution choice for signed-out account
  OAuth.
- Require profile completion before a genuinely new Apple account enters the
  ordinary account console.
- Keep the UI entirely in the account namespace. Admin receives no merge or
  identity-management UI from this phase.

### Phase 3 — Native account UX

- Add only an account-authenticated native provider-link transaction if the
  Director requires TempleMate parity in this phase.
- Teach TempleMate to handle `account_resolution_required` without applying a
  user snapshot or storing a session.
- Add Sign-in methods and the existing-versus-new proof journey using system
  browser OAuth; retain strict transaction/provider/return correlation and no
  dummy fallback in real mode.
- Preserve email login, account-only navigation, temple binding, QR behavior,
  and the current Google/Apple provider-independent client controller.
- Determine whether this remains JavaScript-only for the installed client after
  dependency/config review; do not assume a native rebuild.

### Phase 4 — Explicit consolidation capability, if accepted

- Implement a dedicated service, never a general `User.merge` shortcut.
- Require keeper session reauthentication plus fresh source-provider proof.
- Lock both users and identities; fail closed on closure, admin authority,
  identity conflict, changed inventory, concurrent session, or unsupported
  user work.
- Move only records covered by an accepted ownership policy.
- Revoke source refresh/browser sessions, preserve the exact audit trail, and
  produce an idempotent receipt without raw provider subject, email, token, or
  credential.
- Do not expose a generic admin merge button.

This phase is unnecessary for future cases if unmatched identities are held
pending before provisioning, but it is required to safely resolve already-
created separate accounts such as the observed shape.

### Phase 5 — Runtime and production rollout

- Validate locally with stubbed Central Auth and test database only.
- Validate account browser, admin browser, legacy policy, native account, email
  login, exact Google login, exact Apple login, closure, linking/unlinking,
  tenant context, and concurrent link attempts.
- Use a separately authorized staging/provider workflow for real Apple and
  Google journeys. Do not access provider consoles or credentials from the
  implementation packet.
- Deploy behind separate account-resolution and consolidation feature flags.
- Perform production read-only inventory before any historical-account action.
- Run any production consolidation as its own exact-target workflow with
  approved records, impact, backup/reconciliation evidence, rollback boundary,
  monitoring, and Director approval.

## Data And Cleanup Readiness

No blanket migration or production cleanup is justified by the supplied facts.
Before any action on an existing Apple-only user, a read-only report must
classify at least:

- identities and verified/returned-address metadata;
- password/login methods and active refresh/browser sessions;
- closure/privacy/export/deletion state;
- dependents, registrations, certificates, assistance/contact activity, and
  other account-owned records;
- payments, refunds, accounting references, and provider references without
  accessing payment-provider credentials;
- admin account and temple memberships/permissions;
- temple context and audit history.

The report must use IDs, counts, typed states, and non-reversible fingerprints
where possible. Raw provider subjects, tokens, credentials, and private relay
addresses must not enter durable planning or audit records.

Possible schema work is limited to the accepted design: pending-resolution
storage, a database-level user/provider uniqueness constraint, and any explicit
retirement marker required by the lifecycle policy. Do not add a generic merge
flag or repurpose account closure without defining its semantics.

## Boundary Requirements

- OAuth identities are global to a Wenfu user; linking must not grant temple
  membership, admin authority, or a different namespace session.
- Account and admin sessions remain separate. A dual-role user authenticated
  from the account surface receives account authority only.
- Closed users cannot sign in or serve as automatic link/consolidation targets.
- Password/email login and password-addition behavior remain usable throughout
  rollout.
- User work is never moved, overwritten, or deleted merely to resolve a login
  conflict.
- Payment/ECPay/Stripe behavior, provider credentials, and tenant billing are
  outside this plan.
- SourceGrid/Central Auth remains provider-exchange authority. Any required
  cross-repository response-contract change must route through Strategy to the
  affected Planning task; Wenfu Controls must not coordinate it directly.
- No name/email/relay heuristic may merge or link two users.

## Acceptance Evidence For Later Implementation

Required automated evidence must include:

- exact Apple and Google subject repeat-login behavior;
- unmatched Apple with relay address and no name;
- unmatched Apple with no email and no name;
- existing-account explicit Apple link when unowned;
- owned-Apple conflict with no mutation;
- existing-account proof flow and new-account confirmation flow;
- pending transaction expiry, replay, tamper, provider mismatch, and concurrent
  consumption, if that design is accepted;
- no session issuance before resolution; account-only session after success;
- admin unmatched identity produces no user/identity/session;
- legacy callback follows the accepted policy;
- closed account, unlink-last-method, password addition, tenant isolation,
  dual-role account/admin separation, refresh-token revocation, and audit
  redaction regressions;
- database uniqueness/concurrency evidence if the index is added;
- browser and native response shapes with no provider credential leakage;
- Google compatibility regression proving no accidental widening;
- `git diff --check` and clean/staging-empty Control outcome.

Runtime evidence must separately prove the accepted browser and TempleMate
journeys. Production evidence must be sanitized and must not claim a historical
account was consolidated until the exact production workflow has succeeded.

## Rollback

Source rollout must be feature-gated so unmatched provider sign-in can be
disabled while existing exact-identity, email/password, and already-linked
sign-ins remain available. Rollback of source must not delete pending or
historical audit data.

An identity move or user retirement is not safely reversible after either
account accumulates new work. Its production workflow must capture the exact
pre-state, stop on drift, and define a narrow immediate transaction rollback.
After user activity resumes, correction is a forward reconciliation, not a
blind database restore.

## Director Decisions Required Before Dispatch

1. Accept the recommended pending-resolution design, or retain provisional
   OAuth-seeded users and accept the additional consolidation burden.
2. Decide whether generic signed-out exact-email attachment is removed for all
   providers. Planning recommends removing it; exact provider-subject login and
   the narrow existing Google compatibility repair remain separate.
3. Decide whether native Sign-in methods/linking is part of this implementation
   sequence or follows after the browser/server policy is accepted.
4. Define whether an empty OAuth-seeded placeholder may be consolidated after
   dual proof, and which source-user states require manual adjudication.
5. Decide the legacy OmniAuth endpoint disposition: align, gate, or retire.
6. Confirm lookup-only admin OAuth with zero provisioning.
7. Decide whether production remediation of the observed records is desired
   after implementation and rollout; it is not implied by fixing future flows.

## Current Readiness Classification

`apple_oauth_account_resolution_design_decision_required`

First blocker: Director acceptance of the account-resolution model and the
seven decisions above. There is no source, provider, or production-action
authority yet.
