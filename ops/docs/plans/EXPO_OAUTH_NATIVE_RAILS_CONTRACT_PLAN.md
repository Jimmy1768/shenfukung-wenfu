# Expo OAuth Native Rails Contract Plan

Status: accepted for direct implementation dispatch to Control A after this
plan is committed

Created: 2026-08-11

Owner: Wenfu Planning

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Observed canonical baseline:
`5164b18c87817b1ea86d23667892860ee11aec53`

Readiness authority:
`ops/docs/handoffs/2026-08-11-expo-oauth-integration-readiness-control-b.md`

Dependent client plan:
EXPO_OAUTH_NATIVE_CLIENT_PLAN.md (deleted 2026-08-22 in the plans/archive
cleanup; recoverable via `git log --grep`)

## Objective

Add the first account-only native OAuth start/exchange contract to Wenfu Rails.
It must reuse SourceGrid central-auth for Google and Apple provider work and
finish by issuing the same account-scoped JWT plus rotating refresh session
already returned by native email login.

This is a Rails contract and test phase. It does not add Expo UI, access a
provider console, use real credentials, change central-auth, or perform a live
OAuth flow.

## Existing Authority To Preserve

- `Auth::CentralOAuthClient` is the server-held authenticated bridge to
  SourceGrid central-auth.
- Central-auth owns provider credentials, provider callbacks, exact return-URL
  allowlisting, state/nonce, optional S256 PKCE, and one-time code exchange.
- `Auth::OAuthIdentityResolver` owns Google/Apple identity resolution and
  existing-user linkage semantics.
- `Api::V1::Account::NativeBaseController` owns explicit temple resolution,
  account-only JWT scope, refresh-session issuance, and native error shapes.
- Browser account/admin OAuth remains working and behaviorally unchanged.

## Accepted Native Contract

Add two signed-out JSON endpoints under the existing additive account-native
namespace:

- `POST /api/v1/account/native/oauth/start`
- `POST /api/v1/account/native/oauth/exchange`

Neither endpoint accepts browser surface, admin intent, arbitrary origin, or an
arbitrary return URL.

### Start

Accepted request fields:

```text
temple_slug
oauth.provider                google | apple
oauth.pkce_challenge          required S256 challenge
oauth.pkce_method             exactly S256
```

Rails resolves the local temple, selects the exact server-configured native
return URL, and calls central-auth with the server-held tenant credentials,
normalized provider, fixed return URL, tenant slug, and required PKCE values.

Accepted success payload:

```text
oauth.authorization_url
oauth.redirect_uri
oauth.transaction_token
oauth.provider
oauth.expires_in
```

The transaction token is an opaque, purpose-bound, signed, expiring Rails
message. It binds at least the local temple slug, provider, fixed return URL,
PKCE challenge/method, random transaction nonce, contract version, and expiry.
It contains no client secret, provider token, PKCE verifier, email, provider
subject, or admin information. Its lifetime must not exceed the observed
five-minute central-auth state lifetime.

The default mechanism is a signed envelope rather than a new database table.
A migration is outside this plan unless deterministic tests prove that the
central one-time code plus PKCE and signed-envelope contract cannot satisfy the
accepted expiry/replay behavior.

### Exchange

Accepted request fields:

```text
temple_slug
oauth.code
oauth.transaction_token
oauth.pkce_verifier
device.device_id
device.device_name
device.platform
```

Rails verifies the transaction signature, purpose, expiry, temple, provider,
current fixed return URL, and S256 verifier/challenge relationship before
calling central-auth exchange. It sends the exact fixed return URL and verifier
to central-auth and rejects a response whose provider does not match the
transaction.

After a valid central exchange, Rails reuses the existing identity resolver,
terms/profile rules, closed-account protection, native account serializer, and
refresh-session issuer. It never establishes a browser cookie session.

Accepted success payload:

```text
user                         existing native account-safe serializer
session                      existing access/refresh/token_type/expires_in shape
oauth.provider               google | apple
oauth.profile_required       boolean
```

No central ID token, provider access/refresh token, provider subject,
credentials, identity metadata, admin account, role, central tenant secret, or
raw central response may appear in the native response or logs.

## Failure Contract

Return stable account-safe codes without raw upstream bodies or provider
credentials. At minimum the implementation distinguishes:

- unsupported provider or invalid PKCE input;
- missing native OAuth configuration;
- unavailable/malformed central-auth start or exchange;
- invalid, tampered, expired, wrong-tenant, or verifier-mismatched transaction;
- invalid/expired/replayed central grant;
- provider mismatch;
- closed account;
- ordinary identity validation failure.

Provider cancellation and denial occur at the client return boundary and do
not require a successful exchange request. Repeating a consumed central code
must fail without minting another native session.

## Reuse Boundary

Extract only the minimum shared Rails service needed for browser and native
flows to use identical central-response normalization, identity resolution,
terms acceptance, and profile-required rules. The browser controller must not
become native authority, and the native controller must not copy browser
cookie/admin branches.

The resulting service and request contracts should be named and tested clearly
enough to serve as Wenfu-local reference evidence later. Do not create a shared
SourceGrid gem/package or edit SourceGrid Labs.

## Verification

Control A must require focused service/request evidence for:

- Google and Apple start success using a fixed configured return URL;
- unsupported provider, absent configuration, invalid tenant, malformed
  challenge, and any client-supplied redirect/origin rejection;
- exact central client start/exchange arguments, including required S256 PKCE;
- signed transaction tamper, expiry, wrong temple, wrong provider, changed
  server return URL, verifier mismatch, and missing fields;
- Google and Apple exchange into the existing account-safe session shape;
- first user, existing verified-email user, exact existing identity, and
  profile-required outcomes through existing resolver semantics;
- closed-account, central failure/malformed response, provider mismatch,
  invalid grant, replay/double exchange, and no-session-on-failure behavior;
- dual-role users receiving only `scope == "account"` native authority;
- response/log redaction of provider/central tokens, credentials, subjects,
  admin data, raw codes, verifiers, transaction tokens, and secrets;
- unchanged browser account/admin OAuth, email native login/refresh/logout,
  tenant isolation, refresh replay protection, and account API contracts;
- routes, Ruby syntax, focused Rails tests, full relevant regression tests, and
  `git diff --check`.

Tests must stub the central client. No real provider, network, credential, or
production call is part of acceptance.

## Control Ownership

Control A owns one isolated `codex/` branch/worktree from the canonical commit
containing this plan, one immutable implementation packet, one ephemeral
Implementer, conformance review, and local integration.

Expected owned paths are bounded Rails routes, native OAuth controller/service,
the minimum shared identity-normalization service, focused configuration
constant, and Rails tests. Expo, Vue, SourceGrid Labs, provider settings,
deployment, and Planning documents are excluded.

Control A returns one terminal packet to Planning. It does not coordinate with
Control B.

## Explicit Exclusions

- Expo source, dependencies, config, UI, browser launch, deep-link handling, or
  a new development client;
- signed-in native OAuth identity list/link/unlink;
- Facebook or admin OAuth in Expo;
- central-auth source/schema/tenant mutation;
- real provider credentials, consoles, accounts, redirects, or live flows;
- payment/ECPay/Stripe;
- build, Metro, device, EAS, APK/AAB, store, OTA, deployment, production data,
  secrets, or push.

## Acceptance Criteria

1. The two account-native endpoints implement the accepted start/exchange
   shapes and accept only Google or Apple with required S256 PKCE.
2. Rails, not the app, selects the exact configured return URL and central
   tenant credentials; arbitrary return/origin/surface input is impossible.
3. The signed expiring transaction binds temple, provider, return URL, PKCE,
   nonce, version, and lifetime without adding persistent schema.
4. A valid exchange reuses existing identity semantics and issues exactly the
   existing account-scoped native session plus `profile_required`.
5. Tamper, expiry, mismatch, failure, replay, and closed-account paths fail
   without a session or sensitive leakage.
6. Browser OAuth, email native sessions, tenant isolation, refresh rotation,
   account/admin separation, and closure protections remain green.
7. Only bounded Rails source/tests and Control evidence change; final canonical
   and isolated Git states are clean with staging empty.
8. No provider, Expo, native build/device, external, deployment, or push action
   occurs.

## Current Gate

Current classification: `expo_oauth_native_rails_contract_authorized`.

First blocker: none for local implementation. Provider registration and exact
deployed return allowlisting are later external-validation gates, not blockers
to this stubbed contract phase.
