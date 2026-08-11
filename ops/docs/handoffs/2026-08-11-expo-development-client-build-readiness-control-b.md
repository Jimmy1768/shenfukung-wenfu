# Expo development-client build readiness — Control B

Date: 2026-08-11
Scope: read-only readiness scan for one future EAS-cloud Android internal
development-client APK. This report neither authorizes nor performs a cloud
build, deployment, provider action, artifact download, Metro session, ADB
action, or device operation.

## Evidence boundary

The scan branch is `codex/expo-development-client-build-readiness` at
`490b8f31b0d439e523289f0f4d1bc7c7fc78e176`, with accepted source baseline
`b476d42a422f28fbe9918fb8870a93e633486d99` verified as an ancestor. At scan
start, the only worktree change was the Control-owned untracked implementation
packet; this report is the sole Implementer edit.

Terminology below is deliberate:

- **Observed** means a local file or command was inspected during this scan.
- **Configured** means checked-in source declares it; it is not proof that an
  external service currently accepts it.
- **Director-reported** is user-provided evidence, not an ADB observation.
- **Unknown** means answering it requires a later authorized account, provider,
  server, artifact, or device check.

## Readiness verdict

| Surface | Verdict | Evidence and boundary |
| --- | --- | --- |
| Source/native closure | **Source-ready** | Expo 54 / React Native 0.81.5, API 36, `expo-dev-client`, `expo-secure-store`, OAuth (`expo-auth-session`, `expo-web-browser`, `expo-crypto`), and QR camera (`expo-camera`) are all locked in `mobile/package.json` and `mobile/yarn.lock`. `mobile/app.config.js` configures the camera plugin with a purpose string and `recordAudioAndroid: false`. The accepted camera and OAuth tests cover their source contracts. No second known V1 native module is identified by this inventory. |
| Future artifact shape | **Configured** | `mobile/eas.json` defines only `build.development`: `developmentClient: true`, `distribution: internal`, and Android `buildType: apk`, with `BUILD_MODE=development`. The intended artifact is therefore one cloud-built internal APK, not an AAB, store build, OTA, or production binary. |
| EAS cloud linkage/signing | **External unknown / first pre-build gate** | No `extra.eas.projectId`, project identifier, Expo account owner, credentials record, local `eas` binary, or package build wrapper is present in TempleMate source. `eas.json` requires CLI `>= 11.0.2`, but no cloud/account query was allowed. Whether EAS would prompt to create/link a project, which account owns it, and the Android keystore/signing ownership are unknown. EAS-managed Android development signing may be a later option, but is not proven here and requires a bounded protected account/credential check. |
| Development runtime | **Source-ready for dummy; later runtime gate for real** | `mobile/app.config.js` defaults `clientMode` to `dummy`; its default API URL and tenant slug are empty. `mobile/app/real/config.js` permits real mode only when both explicit values exist and the URL is `http` or `https` on `localhost`, loopback, or a `.test` host. The real adapter has no dummy fallback. It rejects a LAN or deployed HTTPS hostname unless it is `.test`; no permanent origin or tenant trust contract is configured or inferred. |
| OAuth server/provider | **Later deployment/provider gate** | Local Rails routes define `POST /api/v1/account/native/oauth/start` and `/exchange`; the controller delegates to `Auth::NativeOAuthFlow`. Rails reads `AUTH_NATIVE_RETURN_URL` only on the server; the mobile client expects the fixed `templemate://oauth/complete` return. Actual deployed Rails configuration, central-auth tenant/start/exchange behavior, native-return allowlisting, and Google/Apple registrations are unknown and require later owner-authorized checks. No provider SDK, Google services file, or client secret is configured in the Expo source. |
| Device/install/physical validation | **Later device gate** | The Director reports the historical Pixel development client has already been uninstalled. This is not Control-observed ADB evidence. Thus the later `com.jimmy1768.komainu.dev` APK is planned as a **clean install**, not update/coexistence; historical wrong-identifier cleanup is no longer a blocker. Device OS, disk, package state, transport, and camera/OAuth behavior remain unobserved. |
| Release | **Out of scope** | Store signing/submission, AAB, production identifiers, OTA, version consumption, and iOS/TestFlight are release-only and do not block this development client. |

## Source closure and immutable build identity

Observed `mobile/package.json` and lockfile entries establish the following
single native-binary inventory:

| Item | Observed locked/configured evidence |
| --- | --- |
| Framework | `expo ~54.0.36`, `react-native 0.81.5`; Android compile/target SDK 36 |
| Development launcher | `expo-dev-client ~6.0.21` and the `expo-dev-client` config plugin |
| Scoped retained data | `expo-secure-store ~15.0.8` |
| Browser PKCE OAuth | `expo-auth-session ~7.0.11`, `expo-web-browser ~15.0.11`, `expo-crypto ~15.0.9` |
| QR camera | `expo-camera ~17.0.10`; rear-facing QR-only `CameraView`, explicit permission state handling, and Android audio disabled |
| Development identity | `TempleMate (Dev)`, `com.jimmy1768.komainu.dev`, development icon, `templemate` scheme |

`mobile/app/oauth/runtime.js` creates S256 PKCE and computes the same native
return URI as the configured `templemate://oauth/complete`; it opens the
central-auth browser flow rather than embedding a Google or Apple SDK.
`mobile/app/tenant/camera_surface.js` passes scan text only to the existing
fixture-only parser/binding seam; it does not make a real tenant lookup.

This supports one future development-client APK containing both accepted native
capabilities. This scan found **no further known V1 native module** that would
require an immediate second rebuild. That conclusion is limited to the current
checked-in dependency/configuration inventory, not a promise about later scope.

## EAS interface and unknown linkage

The exact *configured profile interface* is:

```sh
# Future, separately authorized cloud action only; not run in this scan.
eas build --platform android --profile development
```

It is not yet a TempleMate package script. DojoMate is a read-only process
reference: its `eas.json` uses the same `appVersionSource: local` and an
internal development-client profile; its package scripts wrap named `eas build`
commands and its operator documentation states EAS cloud as the default path.
TempleMate may later add a bounded package-script wrapper if Planning accepts
that source correction; this scan does not add one. It must not copy DojoMate
identifiers, channels, Firebase files, release profiles, or dependencies.

| Question | Local evidence | Status / later check |
| --- | --- | --- |
| Profile validity | Well-formed checked-in `mobile/eas.json`, one `development` APK/internal-dev-client profile | Configured; an EAS CLI/config validation remains a later authorized check. |
| CLI availability | `eas.json` specifies `>= 11.0.2`; no project-local EAS CLI or script wrapper was found | Unknown; later EAS-account/build packet must choose and verify the approved CLI interface without an implicit global download. |
| Project linkage | No TempleMate `extra.eas.projectId` or other project-link field was found | Unknown; later protected preflight must inspect account/project linkage and stop rather than create/link on an ambiguous prompt. |
| Account ownership | No local account identity is authoritative | Unknown; later Director/owner-bound authenticated check. |
| Android signing | No keystore or credential state was inspected | Unknown; later credential-bound packet must establish EAS-managed versus retained signing and safe recovery/rollback. Google Play is not needed for this internal APK, but that does not prove EAS credentials are ready. |
| Artifact retrieval | No artifact exists or was requested | Unknown; later build packet must name the artifact provenance, checksum/location, retention window, and deletion owner. |

## Runtime seam: what the binary fixes and what Metro may select

The development build fixes the development name, Komainu development package,
native scheme, icon, native modules, camera declaration, SDK target, and the
default `BUILD_MODE=development` from `eas.json`. JavaScript served after the
binary is installed can explicitly select only the documented public extras:

- Dummy remains network-free by default.
- Real mode requires *both* `TEMPLEMATE_CLIENT_MODE=real` and explicit
  `TEMPLEMATE_LOCAL_API_BASE_URL` plus `TEMPLEMATE_LOCAL_TENANT_SLUG` at the
  Metro/config invocation. Missing values fail closed.
- The checked-in guard allows only `localhost`, loopback, or a `.test` host.
  It does not authorize or accept a guessed LAN or deployed production origin.

Source identifies a transport seam but **does not identify an Android ADB
reverse port**. Expo/Metro’s usual port and the Rails server port are therefore
not stated as facts here. A later device-runtime packet must derive exact ports
from the selected Metro/Rails commands, then apply target-fenced ADB reverse
mappings only when both needed and remove only those mappings on cleanup.

Because the real guard permits `http`, source alone does not prove that an
Android 16+ device will accept cleartext local HTTP in the generated binary.
The future cloud-build/device packet must inspect the resolved Android network
configuration and either prove the local path works or return a bounded native
configuration correction. It must not substitute a permanent hostname. The
native OAuth return itself is a custom scheme and the source does not require a
provider SDK, Google services file, or provider client secret in the binary.

## Rails and central-auth readiness boundary

Observed server authority:

- `rails/config/routes.rb` exposes the account-native start/exchange routes.
- `NativeOAuthController` validates and maps unsupported provider, bad PKCE,
  invalid/expired transaction, provider mismatch, invalid grant, closed
  account, and upstream/configuration outcomes to bounded errors.
- `Auth::NativeOAuthFlow` takes its return URL from
  `AppConstants::OAuth.native_return_url`; `AUTH_NATIVE_RETURN_URL` is the
  only configured key source. The browser client cannot select that URL.
- `rails/test/integration/account/api/native_oauth_contract_test.rb` is local
  fixture evidence for Google/Apple start/exchange, transaction correlation,
  replay, invalid grant, profile-required, and closed-account behavior. It is
  not proof of deployed configuration or provider registration.

Before any real device OAuth test, a separate server/provider authority must
prove, without exposing credentials: deployed Rails contains the accepted
native endpoint contract; `AUTH_NATIVE_RETURN_URL` is exactly
`templemate://oauth/complete`; central auth accepts the owning tenant’s
start/exchange transaction and return; and Google/Apple registrations permit
the central-browser flow with that return. Existing browser OAuth source does
not prove the final native-return allowlist. Facebook remains excluded.

## Version/build invariant

Observed `mobile/versioning.js`, public config evaluation, and `mobile/eas.json`
all preserve the minor invariant: app version **1.0.0**, Android version code
**1**, iOS build number **1**, `appVersionSource: local`, and no profile or
command with `autoIncrement`. The development APK must not consume the Android
Play release-code ledger or an iOS TestFlight pair. Neither readiness, linkage,
build, failed cloud job, artifact download, installation, nor device testing
may advance these values. This is one invariant only; it does not establish
cloud, provider, or device readiness.

## Future packets and ordered gates

1. **EAS account/project/signing preflight (Director/owner authority).**
   Authenticated, read-mostly inspection of EAS account ownership, project
   linkage, CLI choice, project-creation/link prompt behavior, and Android
   credential ownership. It must stop on an unknown or destructive choice.
   This is the first action blocked by an external unknown.
2. **EAS cloud development APK build and controlled artifact handling
   (EAS authority).** After gate 1 (and only after any separately accepted
   local source correction that preflight proves necessary), use the exact
   `development` profile and Android APK interface. This build is independent
   of Rails, central-auth, and provider readiness. Verify resolved development
   identity, native modules, API 36 target, no version mutation, artifact
   provenance/checksum, low-disk preflight, temporary storage, and deletion of
   the downloaded APK immediately after installation unless the Director asks
   to retain it.
3. **Target-fenced dummy and camera validation (device authority).** After a
   successful gate-2 artifact, independently preflight the intended device and
   free disk; clean-install only `com.jimmy1768.komainu.dev` after confirming
   the prior package’s Director-reported uninstall as actual device state.
   Start dummy mode first, then target-fenced Metro/ADB reverse only for
   source-derived ports, QR camera permission grant/deny/retry/reset, and a
   safe fixture QR scan. Keep app-scoped logs redacted of auth codes, tokens,
   provider payloads, and central response bodies.
4. **Rails/central-auth/provider configuration validation (deployment and
   provider authority).** This may run in parallel with gates 2–3 or later.
   Establish the accepted native server contract and return allowlist in the
   intended non-production validation environment, without exposing client
   secrets. It is required before real local/test API use or a live
   Google/Apple journey, but not before the APK build, clean install, dummy
   smoke, or fixture-QR camera validation.
5. **Real local/test and Google/Apple validation (server/provider plus device
   authority).** Only after gate 4 and the required device preparation, prove
   the explicit real local/test configuration, central-browser success,
   cancellation, denial, profile-required, interruption/restart, and logout
   cleanup with sanitized logs.
6. **Release work remains separate.** Store/AAB, OTA, public production
   distribution, app-store signing/submission, iOS/TestFlight, and version
   advancement are not prerequisites for this Android internal development
   client.

## Pre-build checklist

- [ ] Canonical source still contains the locked native closure above and no
  new native module has been accepted since this scan.
- [ ] `BUILD_MODE=development` resolves the public `TempleMate (Dev)` /
  `com.jimmy1768.komainu.dev` configuration, camera purpose/audio disable,
  `templemate://oauth/complete`, SDK 36, and `1.0.0 / 1 / 1`.
- [ ] An authorized EAS preflight proves project/account/linkage, approved CLI
  interface, internal-APK profile interpretation, and signing ownership.
- [ ] The build packet names a temporary artifact location, low-disk threshold,
  checksum/provenance evidence, and deletion owner.

The following is a **real OAuth/local-test prerequisite**, not a pre-build
invariant:

- [ ] An authorized server/provider preflight proves the deployed native
  start/exchange and exact native return contract; no secret is copied into
  Expo. It is required before real local/test API or Google/Apple validation,
  not before the development APK, clean installation, dummy smoke, or fixture
  QR camera validation.

## Post-build/device acceptance matrix

| Stage | Required evidence | Boundary |
| --- | --- | --- |
| Cloud artifact | Development APK; resolved `TempleMate (Dev)` / `com.jimmy1768.komainu.dev`; API 36; dev-client plus OAuth/camera modules; unchanged `1.0.0 / 1 / 1` | EAS packet only |
| Clean install | Device preflight records OS/API, disk, exact package absence/presence; install is a clean Komainu development package install | Device packet only; Director report is insufficient device proof |
| Dummy smoke | Launcher opens development client and reaches explicit network-free dummy account state | Device/Metro packet only |
| Camera | User-initiated permission; deny has no prompt loop; explicit retry/reset behavior; rear QR scan of a deterministic fixture; untrusted input safely fails | Device packet only |
| Real local/test | Explicit local/test configuration, source-derived Metro/Rails/ADB reverse proof, cleartext result, and no dummy fallback | Requires completed server/provider validation plus device authority; not a build/dummy/camera prerequisite |
| Google/Apple | Central-browser success, cancellation, denial, profile-required, interruption/restart, logout cleanup, and sanitized logs | Provider/server + device authority only |
| Cleanup | Remove target-fenced reverse mappings; delete temporary APK unless explicitly retained; preserve no secrets/log payloads | Device/build packet only |

## Checks and scan result

Passed locally from `mobile/`:

- `yarn test` — 42 tests passed.
- `yarn lint` — passed for 29 mobile app modules.
- `yarn verify` — passed; verifies identities, 1.0.0, SDK 36, build values, and
  OAuth public configuration.
- Direct Node evaluation of both public app-config modes — development and
  production identities, version values, return URL, and camera plugin match
  the tables above.
- Focused package/lockfile, Rails route/controller/test, DojoMate EAS/config/
  documentation, rejected-identifier, secret-token, generated-artifact, and
  version-increment scans — no active rejected identifier, project linkage,
  generated APK/AAB, Google-services file, or `autoIncrement` was found in
  TempleMate source. Test policy strings are not active identifiers.

Doctor evidence (source/config only; not EAS or external readiness):

- In this fresh report worktree, `EXPO_OFFLINE=1 CI=1 yarn doctor` exited 127
  because `mobile/node_modules/.bin/expo-doctor` is absent, even though the
  manifest and lockfile specify `expo-doctor@1.20.1` and
  `yarn list --pattern expo-doctor --depth=0` resolves it. This is a local
  workspace-materialization condition, not a dependency/source gap or a future
  cloud-build blocker; the report-only scope forbids installing dependencies.
- Control separately ran the same project-local offline command in
  `/private/tmp/shengfukung-wenfu-expo-temple-qr-camera/mobile`, whose source
  HEAD is the accepted source-identical baseline
  `b476d42a422f28fbe9918fb8870a93e633486d99`. It passed with exit 0. Its only
  output was the configured, ignored offline `exp.host` schema-metadata
  warning. This proves the locked project-local Doctor source/config check on
  that materialized baseline; it does not prove EAS linkage, signing, cloud
  build, artifact, provider, server, or device readiness.

No network, EAS, provider, secret, runtime, device, build, deployment, or
external action occurred during this scan.

## First blocker and conclusion

There is no blocker to this report. The first blocker to a future cloud build
is the **unverified EAS project/account/linkage and Android signing state**;
the precise next owner is the Director/Planning-authorized EAS preflight
packet. After that preflight (and any separately accepted source correction it
proves necessary), the bounded cloud-build packet may proceed independently of
server/provider readiness. Server/provider validation remains a separate
parallel-or-later gate before real local/test API or Google/Apple validation;
it does not block clean installation, dummy smoke, or physical fixture-QR
camera validation. Source is ready for one future APK, while all external
facts are intentionally left unknown rather than inferred.
