# Expo OAuth Native Client Plan

Status: sequenced dependent plan; not implementation authority until the Rails
native OAuth contract is accepted on canonical `main` and Planning dispatches
this plan with that exact contract commit

Created: 2026-08-11

Owner: Wenfu Planning

Future target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Predecessors:

- `ops/docs/plans/EXPO_OAUTH_NATIVE_RAILS_CONTRACT_PLAN.md`
- `ops/docs/handoffs/2026-08-11-expo-oauth-integration-readiness-control-b.md`

## Objective

Make Komainu/TempleMate the first SourceGrid Expo application with Google and
Apple account sign-in by consuming the accepted Wenfu account-native OAuth
contract. Preserve email login, dummy account testing, account-only navigation,
tenant scope, and existing session storage.

Komainu's provider-independent transaction module, contract tests, nonsecret
configuration matrix, redaction checks, and operating notes become the local
reference for later SourceGrid Expo applications. No shared package or
cross-repository extraction is part of this phase.

## Accepted Client Direction

- Both Google and Apple initially use the existing SourceGrid central-auth
  browser flow returned by Rails. This duplicates the working server authority
  instead of introducing a second provider-token verification path.
- The app generates a fresh high-entropy PKCE verifier/S256 challenge, asks
  Rails to start the transaction, opens the returned authorization URL in the
  system authentication browser, and accepts only the expected configured app
  return.
- The app then sends the returned one-time code, opaque Rails transaction token,
  and verifier to Rails. It stores only the resulting existing Wenfu account
  session.
- The first implementation does not use provider client secrets, direct Google
  SDK login, native Apple token verification, or provider tokens in Expo.
- A later distribution plan may decide whether native
  `expo-apple-authentication` is required. That decision must not be folded into
  this first central-browser implementation without new Planning criteria.

## Mode And UI Behavior

### Dummy mode

Remain network-free and deterministic. Add injectable Google/Apple fixture
journeys for success, profile-required, cancellation, denial, failure,
interruption, and reset. Dummy OAuth must not impersonate live provider
configuration and must remain visibly test data.

### Real local/test mode

Use only the accepted Rails start/exchange endpoints. Never call Google, Apple,
or SourceGrid central-auth directly and never fall back to dummy data after a
real error.

The signed-out screen presents Google and Apple alongside existing email
login/signup/recovery. Pending, browser-opened, returned, exchanging,
authenticated, cancelled, denied, failed, invalid/replayed, closed, and
profile-required states must be distinct and recoverable. A profile-required
result enters the existing account profile completion surface after the
session is stored.

Admin surface selection, roles, admin temple choice, payment, and provider
identity-management controls remain absent.

## Transaction And Storage Boundary

- Persist only the minimum interrupted-return record within the existing
  environment-and-tenant scope: expected provider/redirect, opaque transaction
  token, verifier, and creation/expiry metadata.
- Clear pending data on success, cancellation, denial, terminal failure,
  expiry, logout, closure, tenant switch, reset, or session rejection.
- Never persist or log a central code after exchange, provider access/refresh
  token, ID token, client secret, raw upstream body, or admin data.
- Reuse the existing account session storage and fail-closed clearing rules.
- Ignore unsolicited callbacks and callbacks that do not match an active,
  unexpired pending transaction.

## Dependencies And Native Configuration

The implementation packet may add only the SDK-54-compatible official Expo
packages required for the central browser transaction, expected to be
`expo-auth-session`, `expo-web-browser`, and `expo-crypto`, with exact versions
and lockfile evidence selected through Expo's compatibility tooling. It may not
add a provider SDK or `expo-apple-authentication` in this phase.

Use the existing `templemate` app scheme for the development-client return
unless the accepted Rails contract or current Expo configuration evidence
proves it cannot be safely distinguished. Production universal/app-link and
scheme coexistence are distribution decisions, not license to invent a domain.
Both Komainu identifiers remain lowercase and unchanged.

These native modules or redirect configuration may require a new development
client. Source implementation and static tests do not authorize that build.
After source integration, Planning must create a separate provider/EAS/device
validation plan. EAS cloud is the default build path; no local native build is
authorized.

## Reference Deliverables

The accepted implementation must leave Wenfu-local evidence for later apps:

- a provider-independent OAuth transaction/driver interface;
- deterministic state-transition and redaction tests;
- Rails contract fixtures that do not contain credentials;
- a development/production public-configuration matrix with unknown external
  values explicitly marked;
- an operating note explaining central browser authority, PKCE, return handling,
  session storage, cancellation/retry, rebuild requirements, and excluded
  secrets;
- a clear list of TempleMate-specific UI/tenant behavior that later apps must
  not copy blindly.

## Verification

The later Control packet must require:

- dummy Google/Apple success and every named terminal/interrupted state without
  network;
- real adapter start/exchange request and response mapping against the exact
  accepted Rails contract;
- fresh PKCE per attempt, expected-return verification, unsolicited/mismatched
  callback rejection, and deterministic pending cleanup;
- provider cancellation/denial/failure, app restart during pending state,
  expired/tampered/replayed transaction, central failure, closed account, and
  profile-required behavior;
- email login/signup/recovery and functional-stabilization regression tests;
- tenant/environment storage isolation, logout/closure/switch/reset clearing,
  real no-fallback, dummy no-network, and account-only/dual-role exclusions;
- no secrets/provider tokens/raw codes in source, config, logs, fixtures, or
  persisted session data;
- exact dependency/config checks, Komainu identifiers, TempleMate `1.0.0`,
  build values `1`, API 36, test, lint, verify, offline Doctor, both public
  config modes, and `git diff --check`.

No build or device test is an acceptance requirement for this source phase; it
belongs to the later EAS/provider validation plan.

## Explicit Exclusions

- Rails or SourceGrid central-auth changes;
- signed-in OAuth identity list/link/unlink;
- direct provider SDK/token exchange, Facebook, Expo admin, or shared package;
- provider consoles, credentials, accounts, consent verification, or live
  callback mutation;
- payment/ECPay/Stripe;
- local native build, EAS build, APK/AAB, Metro/device action, deployment,
  store/OTA/release, production data, or push.

## Later Acceptance Criteria

1. Dummy and real Google/Apple sign-in use one provider-independent state
   machine and preserve existing email authentication.
2. Real mode calls only the accepted Rails start/exchange contract and stores
   only the resulting account session.
3. PKCE, expected return, transaction correlation, cancellation, interruption,
   mismatch, expiry, replay, and cleanup behavior fail safely and are tested.
4. The client exposes no admin authority and no provider/central secret or token.
5. Exact SDK-54-compatible dependencies/configuration are recorded without a
   native build or build-number change.
6. Reference contracts, tests, configuration matrix, and operating notes are
   attributable and TempleMate-specific behavior is clearly separated.
7. Required automated checks pass and final Git states are clean with staging
   empty.

## Current Gate

Current classification: `awaiting_expo_oauth_native_rails_contract`.

First blocker: the exact accepted Rails start/exchange commit and response/error
contract. Planning must not dispatch this plan before that predecessor is
accepted.
