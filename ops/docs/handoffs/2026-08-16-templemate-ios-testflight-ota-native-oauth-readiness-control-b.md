# TempleMate iOS TestFlight, OTA, and native OAuth readiness scan

Date: 2026-08-16
Packet: `2026-08-16-templemate-ios-testflight-ota-native-oauth-readiness-control-b`

## Evidence boundary

This is a source/history and read-only DojoMate inventory. No EAS, Apple,
provider, account, device, build, OTA, deployment, or remote Git action was
issued by this Implementer. No credential, token, session, account data, QR
content, environment value, or artifact URL is recorded.

| Item | Result | Label |
| --- | --- | --- |
| Isolated head / accepted base | `4620012c2ba53913297a4354ea1785537f4217f8` | observed |
| Worktree / branch | `/private/tmp/shengfukung-wenfu-templemate-ios-testflight-ota-native-oauth-readiness`; `codex/templemate-ios-testflight-ota-native-oauth-readiness` | observed |
| Initial tracked/staged state | clean; only the Control packet was untracked | observed |
| Dependency closure | no materialization by this Implementer; `mobile/package.json` SHA-256 `fbf7bb994999718194f09d6d0bc18e292fb7525a8dac42d9f7e09a28c6bdf7da`; `mobile/yarn.lock` SHA-256 `36bc809675e8fd2caa5bba321feec0276a514ec573478964d472f388b4a264c6` | observed |
| Tests, lint, verify, Doctor | not run by this static/report-only Implementer; Control owns the plan-authorized materialization and checks | documented |
| External project/account/build/channel/signing/environment state | no safe live query made here | unknown |

## TempleMate identity and configuration

Sources: `mobile/app.config.js`, `mobile/versioning.js`,
`mobile/app/lib/app_constants/project.js`, `mobile/eas.json`, and
`mobile/scripts/verify-native-client.js`.

| Surface | Development | Production-like `BUILD_MODE=production` | Label |
| --- | --- | --- | --- |
| Public/internal identity | `TempleMate (Dev)` / `komainu` | `TempleMate` / `komainu` | configured |
| Owner / slug / EAS project | `jimmy1768` / `templemate` / `c7b8523a-2fad-4123-bc96-0c0c85a23dec` | same | configured |
| iOS / Android IDs | `com.jimmy1768.komainu.dev` / same | `com.jimmy1768.komainu` / same | configured |
| Scheme / native OAuth return | `templemate`; `templemate://oauth/complete` | same | configured |
| Version source | `1.0.0`, iOS build `1`, Android code `1`; local authority | same | configured |
| Native target | Expo `~54.0.36`; Android API 36 | same | configured |
| Assets/permissions | dev icon, portrait, tablet support; QR-camera text; Android audio disabled | production icon; same | configured |
| Client mode/API/tenant | dummy, empty local API/tenant, `development` environment | **also** dummy, empty local API/tenant, `development` | configured; not a TestFlight-real resolution |
| EAS profile | internal Android dev-client APK only | no TestFlight or production profile | configured/absent |
| EAS Update | no `expo-updates`, update URL, runtime policy, channel, branch, OTA scripts, receipt ledger, or rollback source | same | absent |

The resolved production identity is truthful, but the first prevented resolution
is a **missing TestFlight/production EAS profile**. Do not invent one:
`mobile/eas.json` contains only `build.development`; it has no iOS
distribution/profile, channel, release flag, or production environment. The
verifier intentionally rejects release/AAB/auto-increment configuration.

## Production real-runtime and trusted-tenant matrix

| Requirement | Evidence | Classification |
| --- | --- | --- |
| Origin/transport | `mobile/app/real/config.js` accepts real mode only for localhost, loopback, or `.test`; `mobile/app/real/transport.js` is `localTestTransport`; adapter reports `network: 'local-test'` | local/test-only |
| Fallback/error | real config fails without explicit values; real adapter has no fallback to dummy on transport failure; typed errors clear invalid/replayed/revoked/closed state | implemented and covered locally by `mobile/__tests__/real-adapter.test.js` |
| Timeout/cancellation/retry | transport calls fetch without timeout, AbortSignal, or retry policy | absent for production |
| Storage/restoration | `storage_scope.js` and `real/storage.js` scope session/cache/pending by environment and tenant; logout/invalid-session clears all | implemented/covered locally; TestFlight secure-store behavior unproven |
| Account authority | routes are account-only; source tests reject admin/provider/checkout paths | implemented/covered locally |
| Tenant binding | real mode binds immediately from explicit local tenant slug | local/test-only |
| Real QR trust | `tenant/scanner.js` returns `real_camera_binding_deferred` in real mode | absent |
| Switch safety | prior tenant remains presented until confirmation follows cleanup in `tenant/binding.js` | fixture-covered; real protocol absent |
| Support/privacy/deletion | client screens/routes exist, but no public privacy/support/deletion URL is source-configured | local client surface only; external/store URL unknown |

B1 must supply an accepted real HTTPS origin with no localhost/loopback/`.test`
or dummy fallback in production-like resolution, bounded transport semantics,
environment/tenant secure storage, and a trusted real tenant-binding contract.
If that contract requires Rails endpoint or deployment work, it requires
separate Rails/deployment authority.

## Web-accepted versus native-unproven OAuth

Web Google/Apple acceptance is historical evidence only; it is not native
TestFlight evidence. The client calls only Rails native endpoints
(`mobile/app/real/adapter.js`), never Google, Apple, or Central Auth directly.

| Surface | Current source/test evidence | Native TestFlight status |
| --- | --- | --- |
| Callback | fixed `templemate://oauth/complete`; `AuthSession.makeRedirectUri` equality in `oauth/runtime.js` | configured/unit-covered; signed-iOS allowlisting unknown |
| PKCE | Expo Crypto 32-byte verifier; SHA-256 Base64-to-Base64URL S256 challenge | implemented/covered by `expo-oauth-runtime.test.js`, unproven on iOS |
| Start/exchange | Rails `/api/v1/account/native/oauth/start` then exchange with provider/token/verifier correlation | local-contract-covered; production deployment contract unknown |
| Browser/return | `WebBrowser.openAuthSessionAsync`; Linking is recovery-only when interrupted | implemented/covered; iOS browser handoff unproven |
| Replay/interruption | expected return/provider/token/expiry checks; pending is consumed before exchange; one in-flight return | implemented/covered locally |
| Cancel/deny/malformed/expiry | fail closed and clear pending/session except valid interrupted return | implemented/covered locally; physical behavior unproven |
| Session/restoration | malformed/provider-mismatched exchange clears applied session; real scoped restore bootstraps | local evidence only |
| Google vs Apple resolution | generic provider/profile-required envelope; client has no merge/relink rule | native responses/duplicate-prevention unproven |
| Secrets/logging | no provider client secret/client ID appears in public OAuth config; copy states provider credentials are not retained | source-backed; production observability policy unknown |

No user record, including historical user 22, was inspected or changed. A known
historical account-resolution mismatch must not be used as a native test account.

## Sanitized EAS and App Store readiness

Historical, non-live source receipt
`ops/docs/handoffs/2026-08-12-expo-eas-project-creation-and-link-control-b.md`
records EAS CLI `18.12.2`, account label `jimmy1768`, and the linked project
UUID above. It does not prove today's project, build, channel, signing, or
environment state.

| Surface | Finding | Label |
| --- | --- | --- |
| Existing EAS builds/artifacts/channels/updates | no safe live query in this preparation | unknown |
| iOS signing/credentials | earlier preflight found no proven non-mutating inspection and excluded `eas credentials` | unknown |
| EAS environment keys/presence | no value-suppressing safe query used | unknown |
| App Store Connect record/team/roles/agreements | no Apple login/query authorized | unknown |
| Store metadata | production identity configured; SKU/category/age rating/review notes/screenshots/tester groups absent from source | identity configured; remainder unknown |
| Privacy/support/deletion URLs | public hosted records absent from config/docs examined | absent/unknown |
| First upload version | parent roadmap specifies `1.0.0 (1)`; later same-marketing-version uploads increment only iOS build | documented, no upload observed |
| TestFlight versus public production | roadmap requires a distinct `testflight` QA lane and reserved `production` lane; Android remains deferred | documented; source absent |

The smallest B2 packet must safely inspect or create only separately authorized
EAS/Apple/project/signing/provider-return/environment/store records, return
sanitized presence/status receipts, and treat uncertainty as
`reconciliation_required`. It must not solicit credentials or private output.

## Control-observed completion evidence

Observation date: 2026-08-17. The Implementer performed no live observation;
the following bounded checks and EAS observations were performed by Control.

| Surface | Sanitized result | Label |
| --- | --- | --- |
| Dependency materialization | Pre/post manifest SHA-256 `fbf7bb99…bf7da`; lock SHA-256 `36bc8096…264c6`; an initial sandbox-DNS attempt did not complete the closure, then the one successful frozen-lockfile materialization used the existing exact lock closure. `expo-crypto` runtime file was present. | observed |
| Mobile checks | Full `yarn test` 58/58; `yarn lint`; `yarn verify`; all passed. Offline Doctor completed with only its configured nonfatal Expo metadata DNS warning. | observed |
| Resolved public config | Development and `BUILD_MODE=production` resolve the configured identities, `1.0.0` / iOS `1` / Android `1`, scheme, QR-only camera/no audio, and project ID. Production-like resolution remains dummy with no API or tenant value. | observed/configured |
| EAS CLI/account/project | Installed CLI is `18.12.2`; authenticated account label is `jimmy1768`; read-only project query confirms `@jimmy1768/templemate` and the configured project ID. Upgrade advice was not acted on. | observed |
| EAS iOS builds | Read-only iOS build list is empty. Artifact availability is therefore absent, not queried. | observed |
| EAS Update | Read-only channel, branch, and recent-update lists are empty. No channel/branch/update exists to map or inspect. | observed |
| EAS development config | Only the existing internal development-client profile resolves; EAS reported no remote plain-text or sensitive variables for that development environment. The report intentionally retains no key/value. | observed/sanitized |
| TestFlight config | Resolving profile `testflight` stops with missing-profile evidence; only `development` exists. | observed |
| Signing/environment inspection | `eas credentials --help` exposes management/configuration, not a proven non-mutating signing inspection. `eas env:list` supports output modes that can reveal values. Neither was invoked; iOS signing and production environment presence remain unknown. | documented/unknown |

The existing development profile is explicitly internal and development-client
only. It is not iOS TestFlight evidence. No EAS login, init/link, credentials,
environment, channel, branch, build, submit, or update mutation occurred.

### Official current operational constraints

Accessed 2026-08-17: Expo documents that native-code changes require a new
compatible binary and that runtime versions govern update compatibility
([runtime versions](https://docs.expo.dev/eas-update/runtime-versions/));
channels are embedded at build time and linked to update branches
([channels and branches](https://docs.expo.dev/eas-update/eas-cli/)). Expo's
current iOS submission guidance requires an Apple Developer account, a bundle
identifier, an authenticated EAS session, a production IPA, and an explicit
submit action ([EAS Submit for iOS](https://docs.expo.dev/submit/ios/)).

Apple documents that TestFlight builds may be tested for up to 90 days;
internal testing is distinct from external testing, and external testing can
require beta App Review ([TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/)).
Apple also requires a privacy-policy URL for apps and requires apps that offer
account creation to offer in-app account-deletion initiation
([app privacy](https://developer.apple.com/help/app-store-connect/reference/app-privacy/),
[account deletion](https://developer.apple.com/support/offering-account-deletion-in-your-app/)).
These are B2/B3 external prerequisites, not observed TempleMate records.

## Read-only DojoMate comparison

| DojoMate source pattern | Disposition | TempleMate reason |
| --- | --- | --- |
| `eas.json` store `testflight` and `production` profiles/channels | adapt | TempleMate needs its own iOS profiles/channels/identifiers, not copied config |
| `scripts/publish-ota.mjs`: explicit branch, scope, message, environment | adopt | guard TempleMate TestFlight/production OTA with own commit/runtime/lane receipts |
| `scripts/check-ota-lane-guardrails.mjs`: profile/script/doc assertions | adapt | compact guards for TestFlight/reserved production only; exclude IAP/China assertions |
| `app.config.js` + env config rejects localhost in production-like contexts | adapt | current TempleMate real path is intentionally local/test-only and must reject local origins in B1 |
| version ledger/sync structure | adapt | retain TempleMate local authority and `1.0.0 (1)`; do not copy version/files |
| cloud EAS package scripts with separately gated local fallback | adopt | B1 can add reviewed TempleMate cloud entry points only |
| branch/channel/runtime separation and receipt attribution | adapt | required for TestFlight/production OTA; no TempleMate implementation exists |
| Firebase/RevenueCat/IAP/China payment, IDs, secrets, dependencies | reject | out of scope and explicitly non-transferable |

## Ordered authority graph

1. **B1 source (Control B):** production runtime origin/transport/tenant
   contract; TestFlight/reserved-production profiles/channels/update runtime;
   release-aware verifier; OTA guardrails/ledgers; support/privacy/deletion URL
   wiring; fake-boundary checks only. Stop if Rails/deployment semantics emerge.
2. **B2 external readiness:** authorized sanitized EAS/Apple/signing/environment/
   provider-return/store metadata inspection or creation; no secrets in receipts.
3. **B3 first upload:** exact production-identity iOS TestFlight build/upload
   `1.0.0 (1)` with source/commit/profile/channel/runtime receipts.
4. **B4 native OAuth:** installed-binary Google/Apple browser-return/PKCE/
   exchange/session/cancel/replay/repeat/logout/restoration validation using
   approved nonhistorical test identities.
5. **B5 TestFlight OTA:** compatible installed baseline, testflight-only update
   and rollback/republication proof; never publish to reserved production.
6. **B6 staff acceptance:** authorized testers, staff journey, support/privacy/
   deletion visibility, and beta acceptance; distinguish internal/external
   review implications.

## Verdict and protected follow-up

**Terminal classification:**
`templemate_ios_testflight_ota_native_oauth_ready_for_source_phase`.

This means B0 has identified a minimal, source-backed B1 scope. It does **not**
mean TestFlight, OTA, production runtime, signing, App Store Connect, provider
return registration, or real native Google/Apple OAuth is ready.

Likely B1-owned paths are `mobile/app.config.js`, `mobile/eas.json`,
`mobile/package.json`, `mobile/scripts/verify-native-client.js`, focused
tests/guardrail scripts/docs, and the narrow real config/transport/tenant
boundary files. Rails/deployment paths are protected separate authority if the
real API/trusted-tenant contract proves them necessary.

**First blocker:** B1 source authority is required. Current source has no
truthful TestFlight/production EAS profile or OTA runtime lane, and its only
real-runtime configuration is deliberately local/test-only. B2 external
readiness must remain separate from B1 and precede any B3 build/upload.

## Packet closeout

- Report and Control packet are the only changed paths in the isolated
  worktree. No source, dependency manifest, lockfile, native configuration,
  version, or product test was changed.
- The packet-created `mobile/node_modules` tree is removed before terminal
  delivery. Shared Yarn cache entries are not repository state.
- `git diff --check` and untracked-report whitespace checks pass. Canonical
  `main` remains unchanged and clean at the accepted base.
- **Next owner/action:** Planning may decide whether to author the narrow B1
  production-runtime/EAS/OTA/ledger source plan. No B2 external mutation, B3
  build/upload, B4 native OAuth execution, B5 OTA publication, or B6 staff
  acceptance is implied by this report.

No source/configuration/dependency/version/native/project/account/provider/
device/build/release surface was changed by this report preparation.
