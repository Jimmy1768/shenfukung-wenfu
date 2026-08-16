# TempleMate iOS TestFlight, OTA, And Native OAuth Plan

Status: accepted track roadmap; no EAS, Apple, provider, build, upload, OTA,
account, deployment, or external action is authorized by this document

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target control for later separately committed phase packets: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted planning baseline: canonical `main`
`8e5840e4cb737cd6cba773e955d12d9dd24ab098`

Parallel track: Rails account/admin reusable personal and offering data is
owned by Control A under
`ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`.
That work does not block the existing V1 demo or this iOS distribution track.
TempleMate must not add broader personal-data behavior until the Rails contract
is accepted.

Parent roadmap:
`ops/docs/plans/TEMPLEMATE_DEMO_READINESS_AND_BETA_DISTRIBUTION_ROADMAP.md`.
This plan refines the parent sequence: the production-identity TestFlight
surface is prepared and installed before real native OAuth is physically
validated, because TestFlight is the target surface for the Director's iPhone-
using sales staff. It does not reopen already accepted web OAuth evidence.

## Director Product And Release Decision

- iOS/TestFlight is first. Google Play AAB and optional Android APK/China APK
  remain later, separate authorities.
- The sales demonstration uses a production-identity, production-signed beta,
  not a development client. “Production” here means the real TempleMate app
  identity and runtime surface; TestFlight beta is not public App Store release.
- TempleMate follows the mature DojoMate-Expo operational pattern for EAS build
  profiles, cloud-build package scripts, OTA lanes, version/build ledgers,
  runtime compatibility, release guardrails, and rollback evidence.
- DojoMate supplies structure only. TempleMate keeps its own EAS project,
  identifiers, version, signing, URLs, runtime, secrets, data contract, and
  product behavior.
- The first iOS marketing version remains `1.0.0`. The first uploaded build is
  `1.0.0 (1)`. Later TestFlight rebuilds keep `1.0.0` and increment only the
  iOS build number: `(2)`, `(3)`, and so on.
- Real Google and Apple OAuth are tested after the TestFlight build is
  installed. Web provider behavior is already accepted evidence; this phase
  validates the native browser/return/PKCE/exchange/session surface.
- OTA must be configured before the first TestFlight binary is built because
  the binary embeds its update channel and runtime. Publishing and rollback
  proof occur only after the installed baseline is accepted.

## Objective

Deliver one production-identity TempleMate iOS beta that staff can install from
TestFlight, validate real native Google/Apple login on that exact surface, and
establish a guarded TestFlight OTA lane modeled on DojoMate without exposing
development configuration or publishing to public production.

## Current Source Evidence

### Already accepted

- V1 cash-only demo parity and Director UI refinement are complete.
- Production identity is `TempleMate` / `com.jimmy1768.komainu`; development
  identity remains `TempleMate (Dev)` / `com.jimmy1768.komainu.dev`.
- EAS project `@jimmy1768/templemate` is linked to project UUID
  `c7b8523a-2fad-4123-bc96-0c0c85a23dec`.
- Current version source is `mobile/versioning.js` with `1.0.0`, iOS build `1`,
  and Android code `1`.
- Native OAuth return is `templemate://oauth/complete`; S256 PKCE and the Rails
  native start/exchange contract have focused local evidence.
- Web Google/Apple provider flows have accepted production history. That does
  not itself prove native return, native session, or TestFlight configuration.

### Current release gaps

- `mobile/eas.json` contains only an internal Android development-client APK
  profile.
- `mobile/scripts/verify-native-client.js` intentionally rejects release/AAB/
  auto-increment profiles and hardcodes the initial build values; it must be
  replaced with release-aware deterministic verification rather than bypassed.
- `mobile/app.config.js` does not define an EAS Update URL/runtime policy or
  TestFlight/production channels.
- TempleMate has no guarded TestFlight or production OTA publication scripts,
  lane documentation, update receipt ledger, or rollback rehearsal.
- The current “real” adapter is deliberately local/test-only: it accepts only
  localhost/loopback/`.test`, requires injected local/test transport, and marks
  itself network `local-test`.
- The current real path binds immediately to an explicitly configured local
  tenant. Real camera/QR binding returns `real_camera_binding_deferred`; no
  production trusted-temple QR protocol exists.
- Production API/trust origin, test-tenant binding contract, store record,
  signing state, EAS production environment, and provider registration remain
  unverified until their separately authorized phases.

These gaps are inside Control B's track. They are not reasons to reopen the V1
dummy UI or the Rails personal-data track.

## DojoMate Operational Reference Boundary

Read-only reference repository:
`/Users/jimmy1768/Projects/DojoMate-Expo`.

Transferable structure:

- `testflight` and `production` EAS store profiles with matching channels;
- TestFlight and production channel-to-branch mapping;
- runtime-version compatibility and environment separation;
- cloud EAS builds through reviewed package scripts by default;
- explicit local-build fallbacks only under separate Director authority;
- independent app version, iOS build number, and Android version-code ledgers;
- prebuild/resolved-config verification and refusal of localhost in
  production-like builds;
- guarded OTA commands with required lane/message/source checks;
- release-worktree, clean-state, runtime, channel, and API-origin fences;
- TestFlight OTA as an iPhone QA lane, separate from production OTA; and
- explicit rollback/republication evidence.

Do not copy:

- DojoMate application IDs, EAS project, Apple records, credentials, Firebase,
  API origins, IAP/RevenueCat behavior, China payment behavior, app version,
  dependencies, source branches, or secrets;
- an implementation defect or documentation/command drift merely because it
  exists in the reference repository; or
- DojoMate's product data, navigation, authentication endpoints, or runtime
  business rules.

## Target Lane Model

### `testflight`

- Production TempleMate identity and Release native configuration.
- Staff/QA beta distributed through TestFlight.
- EAS channel `testflight` linked to branch `testflight`.
- Real TempleMate API/native OAuth behavior against the explicitly accepted
  test/demo target.
- Receives only compatible, reviewed JS/assets updates after physical proof.

### `production`

- Reserved for a later public App Store binary and confirmed production OTA.
- EAS channel `production` linked to branch `production`.
- Must never be used as the TestFlight experiment lane.
- No OTA publication or public release is authorized by this roadmap.

### Deferred Android lanes

- Google Play AAB is a later separately accepted profile/build/upload packet.
- Optional direct/China APK is a distinct later lane with its own distribution,
  runtime, update, signing, and support contract.
- Do not create Android/China profiles merely because DojoMate has them.

## Runtime And Version Contract

- Use a reviewed runtime-version policy compatible with the installed binary.
  The default target is app-version policy, yielding runtime `1.0.0` for all
  compatible `1.0.0` TestFlight builds; build number is not part of runtime.
- Any native dependency, plugin, permission, scheme, or native configuration
  change requires a new binary. An OTA must never cross an incompatible native
  runtime boundary.
- Keep `appVersionSource: local` unless a later accepted plan deliberately
  changes authority. Maintain deterministic source and upload-receipt ledgers;
  do not let a failed upload or an unsubmitted cloud build silently consume a
  number.
- The first accepted App Store Connect upload consumes iOS build `1`. Every
  later upload under `1.0.0` uses the next build number. Android code remains
  `1` until its separate first accepted Play upload.
- TestFlight and production profiles must resolve the same production bundle
  identifier but distinct OTA channels and intentional observability levels.

## Production Client Boundary

Before the first TestFlight build, Control B must replace the local/test-only
runtime seam with a production-capable but narrow contract:

- exact HTTPS API/trust origin; no arbitrary host, localhost, loopback, `.test`,
  or silent origin fallback in a production-like profile;
- real network transport with bounded JSON/error behavior and no fallback to
  dummy fixtures;
- environment- and tenant-scoped secure storage;
- explicit test/demo tenant selection and a truthful binding method;
- no embedded secret or provider client secret in public Expo config;
- production release starts without Expo DevLauncher/debug attachment;
- account-only authority remains; no admin mode enters TempleMate.

The readiness phase must decide the smallest truthful tenant-binding contract.
Current accepted UX requires QR-first setup for an unbound authenticated user,
but real QR binding is not implemented. Control must not silently replace it
with fixture trust or accept an arbitrary QR origin. A minimal real protocol
must resolve an exact trusted tenant through Rails, preserve unbound failure,
and retain confirmation-only cleanup when switching. If this requires a new
Rails endpoint or deployment, Planning must issue separate Rails and deployment
authority; it is not inferred from EAS work.

## Phase Map

### Phase B0 — Read-Only Distribution And Runtime Readiness

Control B compares current TempleMate with the exact mature DojoMate release/
OTA/versioning structure and inventories:

- App Store Connect app-record prerequisites;
- Apple team/signing ownership without exporting credentials;
- EAS project/account/session and current build/update state through sanitized
  read-only receipts;
- resolved production/TestFlight identifiers, version/build, scheme,
  permissions, API origin, client mode, tenant binding, and OAuth return;
- current native OAuth provider registrations and callback requirements;
- current `expo-updates` dependency/configuration state;
- stable privacy/help/support/account-deletion URLs and store metadata gaps;
- exact source changes and external actions needed for later phases.

No provider-console, Apple, EAS, account, source, or external mutation occurs
in the readiness packet.

### Phase B1 — Production Runtime, EAS, OTA, And Ledger Source

Implement and locally verify:

- production/TestFlight real transport and strict origin configuration;
- the accepted real test-temple binding contract or return a true Planning gap;
- `testflight` and `production` EAS profiles/channels;
- EAS Update URL and runtime policy;
- production/testflight config resolution with no localhost or dev-client
  residue;
- version/build synchronization and upload-receipt ledger;
- guarded cloud build scripts for iOS TestFlight/production;
- guarded `ota:testflight` and reserved `ota:production` commands;
- channel/branch/runtime/source/API fences and rollback tooling/documentation;
- deterministic source tests, lint, verify, Expo Doctor, resolved-config,
  secret/public-config, and native-boundary checks.

This phase may add the locked Expo Updates dependency and native configuration
needed by OTA. That makes a new iOS binary mandatory. It does not publish an
update or build an artifact.

### Phase B2 — Apple Record, Signing, And EAS External Readiness

Under separate exact external authority:

- create or verify the App Store Connect record for `TempleMate` and
  `com.jimmy1768.komainu`;
- verify Apple Developer/App Store Connect ownership, agreements, roles,
  export-compliance decision, and signing without recording private material;
- create/verify EAS environment-key presence and project signing linkage using
  sanitized output only;
- verify `testflight` and `production` channel/branch existence/mapping;
- verify provider return registration for `templemate://oauth/complete` and
  the accepted central/native bridge without changing provider behavior unless
  separately authorized.

No build or upload is implied by readiness completion.

### Phase B3 — First TestFlight Build And Upload

Use one exact source commit and the reviewed cloud package script to:

1. build the iOS `testflight` profile as TempleMate `1.0.0 (1)`;
2. inspect sanitized resolved config and artifact identity;
3. upload that exact build to the exact App Store Connect record;
4. reconcile processing status and consumed build number; and
5. make it available only to the accepted staff TestFlight group under Apple
   review rules.

Build, upload, group assignment, and any external-tester review submission are
separate protected actions and receipts. A failed or uncertain action is
reconciled before retry. No public App Store submission or release occurs.

### Phase B4 — Native Google And Apple OAuth On TestFlight

On the exact installed TestFlight build, validate the native surface only:

- Google success, cancel/deny, interruption/return, repeat login, logout, and
  session restoration;
- Apple success, cancel/deny, interruption/return, repeat login, logout, and
  session restoration;
- exact return to `templemate://oauth/complete`, PKCE exchange, account-only
  session issuance, selected test-tenant context, and absence of dummy fallback;
- failure states do not create duplicate identities or sessions.

Web provider behavior is not retested as if it were unknown. The matrix proves
that the already accepted backend/provider flow works through the new native
surface. Use approved staff/test accounts and sanitized receipts. Do not
delete, merge, relink, or remediate user 22. The separate Apple account-
resolution rollout remains Rails/production work; a known historical mismatch
must not be used to manufacture a TestFlight success case.

Any required source correction produces a later `1.0.0 (2)`, `(3)`, and so on;
the marketing version remains `1.0.0` unless a separate release decision
changes it.

### Phase B5 — TestFlight OTA Proof

After the baseline build and native OAuth matrix are accepted:

- publish one harmless, reviewable JS/assets-only update to branch
  `testflight` from an exact clean source commit;
- verify the installed TestFlight binary receives only a platform/runtime-
  compatible update from channel `testflight`;
- prove source/update identity, restart/application behavior, and absence of
  production-lane exposure;
- exercise the accepted rollback mechanism and verify return to the prior
  known-good update; and
- record sanitized update IDs, runtime, platform, branch/channel, commit,
  timestamps, and rollback receipt.

No `production` OTA publish is authorized. A production update later requires
its own packet and proof that the exact TestFlight-validated update is safe for
the production lane.

### Phase B6 — Staff Demo Acceptance

Rehearse the production-identity TestFlight demo on staff iPhones:

- install/update through TestFlight;
- real native sign-in and session restoration;
- trusted test-temple binding;
- accepted account-only cash-demo journey;
- no development launcher, Metro, localhost, fake-provider claim, admin mode,
  or secret exposure; and
- a documented reset/support/update procedure for sales meetings.

This accepts a staff beta and sales demonstration. It does not submit the app
for public App Store release.

## Likely TempleMate Paths

Later Control packets may narrow this inventory and must not treat the roadmap
as blanket edit authority:

- `mobile/eas.json`
- `mobile/app.config.js`
- `mobile/package.json`
- `mobile/yarn.lock` only for an accepted locked Expo Updates dependency
- `mobile/versioning.js`
- `mobile/scripts/verify-native-client.js`
- new or existing version-sync, build, OTA guardrail, and release-verification
  scripts under `mobile/scripts/`
- `mobile/app/real/config.js`
- `mobile/app/real/transport.js`
- `mobile/app/real/adapter.js`
- real tenant binding/scanner source only under an accepted contract
- focused native config, real adapter, OAuth, tenant, version, OTA, and build-
  profile tests
- release/OTA/version reference documentation and Control records

Rails, Vue, deployment, provider, Apple/EAS external state, credentials,
accounts, and store records require their own explicit phase authority.

## Acceptance Criteria

The Control B track is complete for staff beta only when:

- the installed build is production-identity TempleMate, not a development
  client;
- TestFlight and production OTA lanes are configured distinctly, while only
  TestFlight has been exercised;
- runtime/version/build ledgers match exact EAS and App Store Connect receipts;
- the first accepted build is `1.0.0 (1)` and later uploads increment only the
  build number;
- no release-like config permits localhost, dummy fallback, DevLauncher,
  development identifiers, or secrets;
- real Google and Apple native surface matrices pass on the installed
  TestFlight build;
- the accepted test-temple binding and account-only demo journey work;
- one TestFlight OTA and rollback are proven against the compatible runtime;
- source, artifact, update, and external receipts are attributable and
  redacted; and
- no public App Store release, Android artifact, production OTA, provider
  mutation, or unrelated Rails data-policy work occurred.

## Explicit Exclusions

- public App Store submission/release or phased rollout;
- Google Play AAB, closed testing, Android version-code consumption, or direct/
  China APK build;
- live ECPay, Stripe platform billing, card/payment movement, refund, or store
  IAP;
- Expo admin mode or broader personal/offering-data UI;
- deletion, merge, relink, or remediation of user 22;
- copying DojoMate identifiers, secrets, product behavior, or release state;
- production OTA publication;
- deployment, production migration/data mutation, push, or other external
  action outside a separately accepted exact packet.

## Track Boundary And Next Owner

Control A and Control B remain independent. Control A's Rails reusable-data
work does not block TestFlight preparation. Control B's distribution work does
not define the Rails personal-data policy.

Next owner/action: Planning may separately commit and dispatch Phase B0, the
read-only TempleMate/DojoMate distribution and production-runtime readiness
scan, to Control B. No EAS, Apple, provider, build, upload, OTA, device, or
external action is active from this roadmap alone.
