# TempleMate Production Runtime, EAS, And OTA Source Implementation Plan

Status: accepted implementation authority; source only

Accepted: 2026-08-17

Owner: Wenfu Planning / Director

Target Control: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted base: canonical `main`
`0ed62ec520c97c50429d484b60379144bdb12539`

Parent track:
`ops/docs/plans/TEMPLEMATE_IOS_TESTFLIGHT_OTA_AND_NATIVE_OAUTH_PLAN.md`

Accepted readiness evidence:
`ops/docs/handoffs/2026-08-16-templemate-ios-testflight-ota-native-oauth-readiness-control-b.md`

Operational reference, read-only:
`/Users/jimmy1768/Projects/DojoMate-Expo`

Required Control record:
`ops/docs/handoffs/2026-08-17-templemate-production-runtime-eas-ota-source-control-b.md`

## Objective

Implement Phase B1: the smallest source foundation that can later support a
production-identity iOS TestFlight binary, a reserved production lane, guarded
EAS Update operations, the Shengfukung demo-temple real runtime, trusted QR
binding, and the already implemented Rails-native Google/Apple OAuth surface.

This packet creates source and local test evidence only. It does not create or
edit EAS channels, branches, environments, credentials, Apple records,
provider records, builds, submissions, updates, devices, or accounts.

Web Google/Apple OAuth is already accepted and must not be reopened. Native
OAuth remains unproven until a later installed TestFlight binary validation.

## Frozen Identity And Sequencing

- EAS owner/project: `@jimmy1768/templemate`, project ID
  `c7b8523a-2fad-4123-bc96-0c0c85a23dec`.
- Production app: `TempleMate`, bundle/package
  `com.jimmy1768.komainu`, scheme `templemate`.
- Development identity remains `TempleMate (Dev)` and
  `com.jimmy1768.komainu.dev`.
- Marketing version remains `1.0.0`.
- iOS build remains `1`; Android version code remains `1`.
- `appVersionSource` remains local and `autoIncrement` remains disabled.
- Native OAuth return remains exactly `templemate://oauth/complete`.
- iOS/TestFlight is first. Android AAB and optional APK/China APK are later
  independent authorities and receive no profile or payment-specific behavior
  in this packet.
- The first binary must be built after this source phase because
  `expo-updates` is a native dependency/configuration change.

## Production/TestFlight EAS Source Profiles

Add exactly these production-identity source profiles while preserving the
existing development-client profile:

### `testflight`

- store distribution;
- iOS Release build configuration;
- channel `testflight`;
- real client mode;
- client environment `testflight`;
- EAS Update channel marker `testflight`;
- exact public demo API origin `https://shengfukung.com.tw`;
- exact tenant slug `shengfukung-wenfu`; and
- no auto-increment, submit, credential, secret, provider, or Apple record
  action.

### `production`

- store distribution;
- iOS Release build configuration;
- channel `production`;
- real client mode;
- client environment `production`;
- EAS Update channel marker `production`;
- the same exact public demo API origin and tenant slug; and
- no Android-specific release assumption beyond keeping the production
  identity reserved for the later Android plan.

Public profile values may live in `eas.json`; no secret may be embedded. Do not
copy DojoMate IDs, versions, Apple image pin, Firebase, RevenueCat, IAP, China
payment, or unrelated flags.

Add cloud-build package entry points for iOS TestFlight and reserved iOS
production. Local-build entry points may exist only as clearly named fallback
commands whose use requires later explicit Director authority. No build or
submit command is executed by this packet.

## EAS Update Runtime And Lane Contract

Add the Expo SDK 54-compatible locked `expo-updates` dependency using the
normal project-local Expo/Yarn compatibility workflow. `package.json` and
`yarn.lock` changes must be restricted to that dependency and its exact lock
closure; no Expo SDK or unrelated package upgrade is allowed.

Configure:

- update URL `https://u.expo.dev/c7b8523a-2fad-4123-bc96-0c0c85a23dec`;
- runtime policy `appVersion`;
- `testflight` channel -> `testflight` branch;
- `production` channel -> `production` branch; and
- development builds isolated from both release lanes.

Implement a TempleMate-specific OTA wrapper and static guardrail, adapted from
DojoMate but limited to these two lanes:

- every publish requires an explicit lane and nonblank message;
- the wrapper resolves and prints lane, branch, runtime/app version, source
  commit, and message before invoking EAS;
- TestFlight publication targets only the `testflight` branch;
- production publication targets only `production` and requires an explicit
  production scope/confirmation token in the command interface;
- local/test/dummy or localhost configuration fails before EAS invocation;
- a dirty worktree, detached/unattributed source, wrong channel/runtime, or
  missing release receipt fails closed;
- no command publishes to both lanes implicitly; and
- rollback is a later explicit republish/reconciliation action, never an
  automatic channel edit.

Add durable source documentation and empty ledgers for version/build/update
receipts. Record `1.0.0`, iOS `1`, Android `1`, no accepted iOS build, and no
published update as the initial truthful state. Do not fabricate an EAS build,
branch, channel, update, artifact, or rollback receipt.

## Production Real Runtime

Keep development behavior unchanged: dummy by default, and real mode only with
explicit localhost/loopback/`.test` configuration.

For `testflight` and `production`:

1. resolve only `real` mode;
2. require exact HTTPS API origin and reject HTTP, localhost, loopback, `.test`,
   embedded credentials, fragments, path confusion, and any origin outside the
   configured public allowlist;
3. use `https://shengfukung.com.tw` and `shengfukung-wenfu` for the first demo
   binary without a dummy or local fallback;
4. use a production transport with JSON/content-type/error handling and a
   bounded timeout/AbortSignal;
5. do not automatically retry mutating requests; any safe GET retry must be
   bounded, deterministic, tested, and unable to duplicate state;
6. retain environment + tenant scoped SecureStore session/pending state,
   logout/revocation/closure clearing, and no admin/payment endpoint exposure;
7. never log tokens, authorization headers, OAuth codes/verifiers,
   registration personal data, raw QR content, or response bodies; and
8. fail closed with a user-safe typed error when production configuration or
   network trust is invalid.

The real adapter may rename its `local-test` labels and accept the production
transport, but its route/body/session authority remains unchanged. Do not add a
direct Google/Apple SDK, provider secret, browser cookie dependency, payment
path, or dummy fallback.

## Trusted Demo-Temple QR Contract

Implement real QR binding without a Rails source change:

- accepted payload is an HTTPS URL with exact origin
  `https://shengfukung.com.tw` and one versioned TempleMate connection path;
- query keys are allowlisted; credentials, fragment, alternate port, lookalike
  host, downgrade, open redirect, arbitrary API base, and unknown fields fail
  closed;
- the client validates the origin against the build's public allowlist, then
  fetches the existing tenant-local public `GET /api/v1/temple` endpoint from
  that exact origin;
- the returned nonblank temple slug must equal `shengfukung-wenfu`; the bound
  tenant name/identity comes from that response, not from untrusted QR text;
- no QR token, pixels, image, or raw payload is persisted or logged;
- successful binding is stored only in the environment-scoped secure storage
  boundary and supplies the same exact API origin/tenant to the real adapter;
- invalid/cancelled/failed scans preserve the prior binding or unbound gate;
- switching retains the prior temple until explicit confirmation, then clears
  prior tenant session/cache/pending state before accepting the candidate; and
- the existing dummy fixture QR behavior and its tests remain unchanged.

Because this first binary is the single public demo temple, no remote trust
registry, arbitrary multi-host discovery, universal link, app link, or Rails
endpoint is required. If the existing `/api/v1/temple` response cannot prove
the contract without Rails work, Control must stop with that exact Planning
gap rather than edit Rails.

## OAuth Boundary

Preserve the existing native OAuth architecture:

- system browser only;
- `templemate://oauth/complete` return;
- current PKCE verifier/challenge and one-use pending transaction;
- Rails native start/exchange/session ownership;
- provider mismatch, expiry, malformed return, replay, cancellation,
  interruption, logout, and restoration fail-closed behavior; and
- no client-side identity merge/link heuristic.

Source tests must prove production config routes OAuth to the exact trusted
Rails origin and never directly to Google, Apple, or Central Auth. Do not test
real OAuth, use user 22, inspect an account, or open a provider browser in this
packet.

## Store-Facing URL Boundary

Do not invent hosted privacy, support, or deletion URLs. Add typed public
configuration slots and verification only where the mobile runtime needs them.
Their production values and App Store Connect records remain a B2 external
readiness requirement. The existing in-app privacy request and account closure
surfaces remain unchanged.

## Likely Owned Paths

Control may refine the exact minimal list after tracing source. Expected owned
paths are limited to:

- `mobile/app.config.js`;
- `mobile/eas.json`;
- `mobile/package.json` and `mobile/yarn.lock` only for `expo-updates`;
- `mobile/versioning.js` only if representation changes without changing any
  value;
- `mobile/scripts/verify-native-client.js`;
- new narrow OTA/build guard scripts under `mobile/scripts/`;
- `mobile/app/real/config.js`, `transport.js`, `adapter.js`, and scoped storage
  seams;
- `mobile/app/tenant/scanner.js`, binding/storage seams, and focused tests;
- native config, real adapter/transport, OAuth, tenant, OTA, and guardrail
  tests;
- TempleMate-specific EAS/OTA/version/build/update reference and ledger docs;
  and
- the required Control record.

No generated `ios/` or `android/` tree is allowed. No Rails, Vue, deployment,
provider, payment, or existing historical Control record is owned.

## Required Local Evidence

Before dependency work, record `mobile/package.json` and `mobile/yarn.lock`
hashes. Materialize one project-local locked tree. A registry read/download is
allowed only for the SDK 54-compatible `expo-updates` selection and exact lock
closure. No global install, CLI upgrade, package update, or EAS mutation is
allowed. Remove only packet-created dependency trees before closeout; ordinary
public package cache entries may remain.

Required proof includes:

1. resolved development, testflight, and production identity/config matrices;
2. no dummy/local/DevLauncher identity or localhost/`.test` origin in either
   production-like profile;
3. exact EAS project/update URL, app-version runtime policy, channel mapping,
   cloud-build default, and no auto-increment;
4. strict production origin and QR parser rejection matrix, public temple
   validation, secure binding persistence, invalid-scan preservation, and
   confirmation-only switch cleanup;
5. production transport timeout, typed error, JSON/content handling, no
   mutating retry, and redacted logging boundaries;
6. native OAuth start/exchange continues to use only the exact trusted Rails
   origin and existing scheme/PKCE/session contract;
7. OTA wrapper dry/static tests prove it would invoke the exact branch only
   after all guards; tests must stub the child process and never call EAS;
8. version/build/update ledgers contain no invented receipt;
9. existing dummy, camera, tenant, storage, OAuth, account, and UI tests remain
   green; and
10. no generated native tree, build artifact, credential, environment value,
    QR content, secret, or external residue exists.

Run focused tests, the full mobile suite, lint, the expanded native-client
verifier, OTA guardrail checks, resolved-config checks, and Expo Doctor.
`git diff --check`, exact changed-path review, lockfile review, secret/localhost/
dummy scan, and canonical/isolated cleanliness are required.

## Acceptance Criteria

- Development remains the accepted dummy/local dev-client surface.
- TestFlight and reserved production resolve truthful production identities,
  real demo-temple runtime, distinct OTA channels, and the same app-version
  runtime policy.
- `expo-updates` is the only new native dependency and version/build values do
  not change.
- Trusted real QR binding is executable and source-tested without Rails edits.
- Production transport has no dummy/local fallback and no direct provider or
  payment path.
- OTA/build commands are guarded source interfaces only; no EAS/Apple/provider/
  device action occurs.
- All local checks pass and canonical integration contains only accepted paths.

## Rollback

Revert the accepted B1 source commit before any binary is built. Once a later
binary embeds a runtime/channel, rollback requires a separately authorized
compatible build or OTA reconciliation; this packet does not pre-authorize
either. No EAS channel/branch/environment cleanup is needed because this packet
creates none.

## Explicit Exclusions

- EAS login/link/init, channel/branch/environment/project/credential mutation,
  build, submit, update publish, channel edit, or artifact access;
- Apple Developer/App Store Connect/provider console action;
- device/simulator/Metro/QR/OAuth runtime work;
- real Google/Apple account use, user 22, account/session/identity mutation;
- generated native projects, build-number/version bump, Android AAB/APK/China
  profile, push notifications, IAP, ECPay, Stripe, or payment work;
- Rails/Vue/deployment/production-data/release-ref/push action; and
- public store release or staff beta acceptance.

## Control Procedure

Control B owns one bounded implementation packet, one ephemeral Implementer,
review, repair authority within unchanged criteria, local integration, and the
terminal record. Implementer returns directly to Control B. Control B must not
coordinate with Control A.

On terminal delivery, Control B returns `accepted_frozen_outcome` or the first
precise evidence-backed design/authority blocker and becomes
`released_terminal_idle`. B2 external readiness remains separately planned.
