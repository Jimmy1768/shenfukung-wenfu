# Current Wenfu Codex Work Mode Coordination

## Local Coordination

- Ordinary repository route: Planning -> authoritative Control A/B -> one ephemeral Implementer.
- Planning commits an accepted plan, records immutable criteria, and sends them
  directly to Control; it does not select implementation details, receive
  intermediate repair/status traffic, or monitor the Implementer.
- Strategy receives Planning traffic only for cross-repository decisions
  affecting another Planning task, Strategy-owned lifecycle action, or changed
  evidence requiring registered-gate re-evaluation. Local status, cleanup,
  closeout, terminal packets, and receipts stay between Planning and Control.
- A local-only packet misrouted to Strategy receives exactly: `Route this
  packet to the local Planning owner.`
- A Control conformance defect within unchanged criteria is a nonterminal
  bounded repair with an immutable repair packet, direct mechanism, and checks;
  at most one ephemeral Implementer is active. Planning receives no packet
  until terminal disposition.
- One immutable Control terminal packet identifies its delivery, attempt,
  source/target, continuation disposition, and next owner/action. Planning's
  paired direct receipt is `released_terminal_idle`, after which Planning
  classifies the parent and continues known authorized local work. No
  `active_packet: none` is allowed without the exact missing decision/owner.
- Protected validation requires a registered immutable policy and a trusted
  local credential-bearing validator that verifies the manifest, performs one
  exact one-use match, and returns only a typed safe receipt. Missing policy,
  validator, or tool is `protected_validator_unavailable`; human output is
  evidence, not follow-on authority.
- Active allocation: Strategy `gpt-5.6-sol/xhigh`; Planning
  `gpt-5.6-sol/high`; Control `gpt-5.6-terra/high` by default; normal
  ephemeral Implementer `gpt-5.6-terra/medium`. Terra/high requires explicit
  immutable-packet complexity rationale. Handoff eligibility precedes model
  choice; Luna is never ephemeral and legacy 5.5 allocation is absent.
- Current coordination authority and task status are read from the active Codex
  task and its file-backed records; this snapshot is not historical evidence.

## Product-Roadmap Pointers

- `ops/docs/plans/DEPLOYMENT_READINESS.md`
- `ops/docs/plans/DOCUMENTATION_HOUSEKEEPING_AND_FUTURE_WORK_PLAN.md`
- `ops/docs/plans/EXPO_ACCOUNT_APP_READINESS_AND_PARITY_PLAN.md`
- `ops/docs/plans/EXPO_ACCOUNT_JSON_API_TRACK_PLAN.md`
- `ops/docs/plans/EXPO_NATIVE_CLIENT_INFRA_TRACK_PLAN.md`
- `ops/docs/plans/EXPO_ACCOUNT_NATIVE_INTEGRATION_PLAN.md`
- `ops/docs/plans/EXPO_V1_DEV_CLIENT_UI_REFINEMENT_PLAN.md`
- `ops/docs/plans/EXPO_V1_FINAL_UI_REFINEMENT_READINESS_SCAN_PLAN.md`
- `ops/docs/plans/EXPO_V1_FINAL_UI_REFINEMENT_IMPLEMENTATION_PLAN.md`
- `ops/docs/plans/EXPO_V1_FINAL_UI_REFINEMENT_RUNTIME_VALIDATION_PLAN.md`
- `ops/docs/plans/EXPO_V1_FUNCTIONAL_STABILIZATION_PLAN.md`
- `ops/docs/plans/EXPO_OAUTH_INTEGRATION_READINESS_SCAN_PLAN.md`
- `ops/docs/plans/EXPO_OAUTH_PHASE_PLAN.md`
- `ops/docs/plans/EXPO_OAUTH_NATIVE_RAILS_CONTRACT_PLAN.md`
- `ops/docs/plans/EXPO_OAUTH_NATIVE_CLIENT_PLAN.md`
- `ops/docs/plans/EXPO_TEMPLE_QR_CAMERA_FOUNDATION_PLAN.md`
- `ops/docs/plans/EXPO_DEVELOPMENT_CLIENT_BUILD_READINESS_SCAN_PLAN.md`
- `ops/docs/plans/EXPO_EAS_PROJECT_AND_SIGNING_PREFLIGHT_PLAN.md`
- `ops/docs/plans/EXPO_EAS_PROJECT_CREATION_AND_LINK_PLAN.md`
- `ops/docs/plans/EXPO_EAS_ANDROID_DEVELOPMENT_CLIENT_BUILD_PLAN.md`
- `ops/docs/plans/EXPO_EAS_ANDROID_DEVELOPMENT_CLIENT_DOWNLOAD_INSTALL_PLAN.md`
- `ops/docs/reference/future_work.md`

The Expo readiness scan remains the gap inventory. Both parallel V1 inputs are
now accepted and terminal: Track A at `740aa39bb38806d2207636bb391167c2fee6a9b1`
provides the Rails account JSON/native-email contract, and Track B at
`274dd7f763b7d95274a28f5241b0766cbea1d853` provides the Expo infrastructure,
interactive dummy account client, tenant/client interfaces, and local API 36
debug-build evidence. Both Controls received `released_terminal_idle`.

The separate account-native integration phase is complete on canonical `main`
at `6cab3f1b52ebaeaf68667f19a3c804f8d9c43079`. That commit contains the exact
Track A and Track B checkpoint ancestry plus the accepted real local/test
adapter candidate `bccd60f9f3372edfb95bb15d4402da965c5b5281`. The integrated
TempleMate `1.0.0` local source baseline passed the required Rails, mobile,
version/API 36, contract, and offline Expo Doctor checks. Control A and Control
B are both `released_terminal_idle`.

The separately scoped development-client UI refinement phase is recorded under
`ops/docs/plans/EXPO_V1_DEV_CLIENT_UI_REFINEMENT_PLAN.md`. It is complete and
accepted on canonical `main` at
`7410daa70b0e8bea72af8508c43132ca0b12c4ff`, with pinned project-local
`expo-doctor@1.20.1`, refined account-only screens, and the deterministic dummy
journey evidence from the Pixel 8. Control B received
`released_terminal_idle`.

The Director superseded the plan's permissive local-rebuild clause. TempleMate
now follows the mature DojoMate rule: reuse the compatible installed
development client for Metro/UI work; use EAS cloud by default only when a new
native artifact is actually required and separately authorized; use a local
native build only after an explicit Director request or an accepted concrete
local native-debugging reason. Confirmed disposable Android build trees were
deleted after the installed `tw.com.templemate.dev` 1.0.0/build 1 package was
verified. No EAS build is authorized or running. Live API, real tenant
QR/camera, OAuth, payment, AAB/store/release, deployment, production, and push
remain excluded.

The internal project name is `komainu`; the public app name remains
`TempleMate`. The accepted native identifiers are
`com.jimmy1768.komainu` for production and
`com.jimmy1768.komainu.dev` for development on both platforms. The
source/config/test correction is integrated. No native build or device action
is authorized.

The parallel stabilization/readiness tracks are complete. Control A's Expo V1
functional stabilization is accepted on canonical `main` at
`58b03c6af26a6f7ec3329372c762ccd772743fa6`. Control B's OAuth readiness report
is accepted and canonically integrated at
`5164b18c87817b1ea86d23667892860ee11aec53`.

Komainu is the first SourceGrid OAuth-enabled Expo app. The active OAuth
sequence is recorded in `ops/docs/plans/EXPO_OAUTH_PHASE_PLAN.md`. The Rails
native start/exchange contract is complete and accepted on canonical `main` at
`a0f4888c749835f648a5f716237efef89ef29900`, including the typed
`invalid_grant` repair. Current implementation authority is
`ops/docs/plans/EXPO_OAUTH_NATIVE_CLIENT_PLAN.md` through Control B against
that exact predecessor. Provider registration plus EAS-cloud
development-client/device validation remains a later separately planned gate.
No shared package, provider action, native build, deployment, release, or push
is authorized.

The Expo OAuth native-client source phase is complete and accepted on
canonical `main` at `e5ae5e8fd76b9b152b24e7b3c9e142b12cff2427`; Control B
received `released_terminal_idle`. The next authorized source phase is
`ops/docs/plans/EXPO_TEMPLE_QR_CAMERA_FOUNDATION_PLAN.md` through Control B.
It adds the Expo SDK 54 camera dependency, QR-only permission/UI foundation,
and fixture-backed scanner evidence before the later single EAS-cloud
development-client build. It does not authorize that build, device action,
live temple binding, provider configuration, deployment, release, or push.

The Temple QR camera foundation, including the explicit permission-denial
repair, is complete and accepted on canonical `main` at
`b476d42a422f28fbe9918fb8870a93e633486d99`; Control B received
`released_terminal_idle`. The current authorized phase is the report-only
`ops/docs/plans/EXPO_DEVELOPMENT_CLIENT_BUILD_READINESS_SCAN_PLAN.md` through
Control B. It prepares one later EAS-cloud Android development-client APK that
contains both OAuth and camera native modules. It does not authorize EAS,
provider, deployment, artifact, Metro, or device action. Version `1.0.0`,
Android code `1`, and iOS build `1` remain unchanged as one minor invariant
within the broader readiness scan.

The development-client build readiness report, including the corrected
provider/build gate ordering, is accepted on canonical `main` at
`84ca6f8c5f4afbd6d29cc29751f49977ef452158`; Control B received
`released_terminal_idle`. The authenticated EAS preflight is accepted on
canonical `main` at `dfa44bf50c3bab3060af96f3bcd34f509504681a`; Control B
received `released_terminal_idle`. It observed the existing authenticated
account `jimmy1768`, an unlinked TempleMate source tree, no configured EAS
project, and unknown signing state without mutation.

The EAS project creation/link phase is complete and accepted on canonical
`main` at `55af65306fb19317416c468bfc3d07b1c31bd543`; Control B received
`released_terminal_idle`. Exactly one project was created as
`@jimmy1768/templemate` and linked through nonsecret project ID
`c7b8523a-2fad-4123-bc96-0c0c85a23dec`. Read-only EAS reconciliation and the
mobile checks passed, with TempleMate/Komainu identity, API 36, and
`1.0.0 / 1 / 1` preserved. No signing/credential configuration, build,
artifact, provider/deployment action, device work, release action, or push is
authorized by that completed phase.

The EAS cloud Android development-client build is complete and accepted on
canonical `main` at `be4165da2c45e9fd9b74ad35057ef539d69a3397`; Control A
received `released_terminal_idle`. Exactly one build,
`ca45b77c-cb45-458c-a298-6be449a9e396`, finished for
`@jimmy1768/templemate` as an Android internal `development` artifact. EAS
created and retained one managed development keystore without exposing private
material. The remote APK is available, and `1.0.0 / 1 / 1` remains unchanged.
No APK was downloaded or installed. The exact missing Director/Planning
decision was authorization for a target-fenced APK download/install and device
validation packet; provider/server real-OAuth validation remains separate.

The Director explicitly authorized the target-fenced download and installation
on Pixel 8 serial `39011FDJH00FQ8`. The current plan is
`ops/docs/plans/EXPO_EAS_ANDROID_DEVELOPMENT_CLIENT_DOWNLOAD_INSTALL_PLAN.md`
through Control B. It permits one exact temporary application-archive download,
APK identity inspection, one fresh install of
`com.jimmy1768.komainu.dev`, read-only installed-package verification, and
mandatory immediate local artifact deletion. App launch, Metro, ADB reverse,
dummy/camera/OAuth runtime testing, another build, and release/provider/
deployment actions remain excluded.

The first Control B download packet closed as
`artifact_download_or_identity_failed` before any device mutation because its
local zsh wrapper assigned to the reserved read-only variable `status`. It
removed the empty temporary directory and all incidental residue; the Komainu
development package remains absent. The still-current Director instruction is
continued through
`ops/docs/plans/EXPO_EAS_ANDROID_DEVELOPMENT_CLIENT_DOWNLOAD_INSTALL_CONTINUATION_PLAN.md`.
This continuation permits one direct, wrapper-free build-ID download followed
by the unchanged APK identity fence, one fresh exact-device install, read-only
verification, and mandatory immediate artifact cleanup. It still excludes app
launch, Metro, runtime validation, another build, and version/build increments.

That wrapper-free continuation also stopped before artifact/device mutation:
the installed EAS CLI requires a linked Expo project as its process working
directory. Planning then inspected the installed `eas-cli` 18.12.2 source and
confirmed that the working directory supplies only ProjectId/config context;
the APK is written independently to a deterministic EAS temporary-cache path.
The current authorized packet is
`ops/docs/plans/EXPO_EAS_ANDROID_DEVELOPMENT_CLIENT_SOURCE_BACKED_DOWNLOAD_INSTALL_PLAN.md`.
It permits a byte-identical existing dependency-tree symlink in a fresh
isolated worktree, one exact build-ID download from that linked `mobile/`
directory, exact cache-path inspection, one fresh Pixel install, and immediate
cache/link cleanup. App launch, runtime validation, another build, source or
dependency change, and version/build increments remain excluded.

The source-backed download/install packet is complete and accepted on
canonical `main` at `d7349a1465fff25ad093f292700e3b98cf09ba11`;
Control B received `released_terminal_idle`. Exact EAS build
`ca45b77c-cb45-458c-a298-6be449a9e396` produced the inspected Komainu
development APK, and exactly one ordinary install succeeded on Pixel 8 serial
`39011FDJH00FQ8`. Independent Planning verification confirms installed package
`com.jimmy1768.komainu.dev`, version `1.0.0`, Android code `1`, target SDK 36,
and `.MainActivity` launcher resolution. The app was not launched. The exact
cached APK and temporary dependency symlink were deleted; no local artifact or
source residue remains. A later dummy-mode launch/fixture-camera validation
phase requires separate authorization; real API/OAuth validation remains
separately gated.

The Director opened the installed development client and explicitly authorized
the next step. The current runtime-only packet is
`ops/docs/plans/EXPO_V1_DUMMY_DEVICE_AND_CAMERA_VALIDATION_PLAN.md` through
Control B. It reuses the exact previously accepted TempleMate Pixel method:
`adb reverse tcp:8081 tcp:8081`, explicit dummy/development
`npx expo start --dev-client --localhost --port 8081`, and the exact local
`exp+templemate` URL opened through target-fenced ADB on the USB-connected
Pixel. Asking the Director to scan a Metro/Expo QR code is permanently banned;
temple QR feature testing is separate and must use only TempleMate's in-app
`Scan demo QR` / Expo CameraView surface, never the Expo development launcher
scanner or Pixel native scanner. The packet then validates the account-only
dummy surface, dummy Google/Apple native seams, camera denial/retry, untrusted
and trusted fixture QR scans, and tenant switching on the exact Pixel. It
records functional defects and UI-refinement gaps without repairing source.
No rebuild, version/build increment, real API/OAuth, provider, deployment,
release, or push is authorized.

The first corrected USB/ADB runtime attempt reached TempleMate but failed before
the signed-out dummy UI with `Cannot convert undefined value to object` at the
`SignedOut` component. The accepted runtime report is canonical at
`6445945248c4d51f7e48382d7f61f901506174cb`. Source evidence identifies a
JavaScript-only key mismatch: `App.js` reads `t.oauthState` while both locale
dictionaries define `oauthOutcome`. The current source phase is
`ops/docs/plans/EXPO_V1_SIGNED_OUT_OAUTH_COPY_KEY_REPAIR_PLAN.md` through
Control A. It permits only the exact lookup correction and focused regression
proof. No Metro/device, dependency, native build, EAS, version/build, provider,
deployment, release, or push action is authorized by the repair.

The signed-out copy-key repair is complete and accepted at canonical
`1c312829da54da8fa395e56ae14552b20296e618`; Control A received
`released_terminal_idle`. The renewed runtime phase in
`ops/docs/plans/EXPO_V1_DUMMY_DEVICE_VALIDATION_AFTER_RENDER_REPAIR_PLAN.md`
is complete. Its corrected result report is accepted on canonical `main` at
`11511d35d4fd807e4bd68c7c757c7fa206ff4529`; Control B received
`released_terminal_idle`. The former render failure, email/account dummy paths,
and camera permission deny/retry/grant path passed. Dummy Google and Apple each
failed to complete with the generic fixture outcome; dependent/registration
list transitions and physical fixture QR/binding/switch remain unconfirmed.

The current source phase is
`ops/docs/plans/EXPO_V1_DUMMY_OAUTH_SUCCESS_REPAIR_PLAN.md` through Control A.
It is complete and accepted on canonical `main` at
`a7824ce37093210c4e2d3e5b2c133ae3b12f93f4`; Control A received
`released_terminal_idle`. Direct evidence identified the unsupported Expo
Crypto `BASE64URL` request; the accepted JavaScript repair uses supported
standard Base64 output and strict Base64URL conversion while preserving S256,
real-mode behavior, dependencies, native configuration, and `1.0.0 / 1 / 1`.

The current runtime phase is
`ops/docs/plans/EXPO_V1_DUMMY_OAUTH_AND_TEMPLE_QR_RUNTIME_VALIDATION_PLAN.md`
is complete. Its runtime report is accepted on canonical `main` at
`adb4fea710a7a384edddf4e43ba61033739a976a`; Control B received
`released_terminal_idle`. Dummy Google/Apple success, untrusted rejection, and
trusted binding to `竹南鎮聖福宮` passed. Selecting the switch action then
visibly showed `尚未連結` before confirmation, so Control stopped before
confirming or switching to `示範宮廟二號`.

The current source phase is
`ops/docs/plans/EXPO_V1_TENANT_SWITCH_CONFIRMATION_PRESENTATION_REPAIR_PLAN.md`
is complete and accepted on canonical `main` at
`874cad0a2712cf1f596a59165cb7efcad82dae92`; Control A received
`released_terminal_idle`. A shared pure presentation selector now retains the
prior temple across header/home/connection consumers while switching, without
presenting the candidate or moving cleanup before confirmation.

The current runtime phase is
`ops/docs/plans/EXPO_V1_TENANT_SWITCH_CONFIRMATION_RUNTIME_VALIDATION_PLAN.md`
is complete. Its accepted report is canonical at
`9d3fcc5ef28aadb56c3889cb721f9ba2f40a419e`; Control B received
`released_terminal_idle`. The installed client retained `竹南鎮聖福宮` before
confirmation, kept the candidate inactive, and switched once to
`示範宮廟二號` after confirmation with no failure. Source-correlated cleanup
remains confirmation-only.

The V1 dummy development-client functional-stabilization parent is complete.
This does not complete real API/OAuth, payments, distribution, production, or
final visual acceptance. The report-only final UI readiness scan is complete
and accepted on canonical `main` at
`74ffad700af204d6c839db6fa5e6227099d41fcf`; Control B received
`released_terminal_idle`. It found two concrete JavaScript presentation
defects: transient Settings feedback crosses unrelated screen/reset/locale
boundaries, and Android Back from TempleMate's active CameraView exits to the
Pixel launcher instead of returning home. Dependent and registration CRUD
transitions remain device-evidence gaps, not accepted implementation defects.

The final UI refinement source phase is complete and accepted on canonical
`main` at `46e8f3f94059fb7faf070e345c3df4bd54b4a9f2`; Control A received
`released_terminal_idle`. Transient feedback now has screen ownership and
locale-stable keys, and active CameraView Back closes only the scanner to home.
The implementation changed no dependency, configuration, native, adapter,
OAuth, QR trust, CRUD, version, or build behavior.

The current runtime phase is
`ops/docs/plans/EXPO_V1_FINAL_UI_REFINEMENT_RUNTIME_VALIDATION_PLAN.md` through
Control B. It reuses the installed development client and exact USB Metro
method to validate the two repaired behaviors and complete the remaining
dependent create/edit/delete and draft-registration create/edit visible
transition evidence. It authorizes no source repair, QR scan, real API/OAuth,
provider, payment, dependency, native rebuild, version/build increment,
deployment, release, or push.

## Current Authorized Documentation Housekeeping

`ops/docs/plans/DOCUMENTATION_HOUSEKEEPING_AND_FUTURE_WORK_PLAN.md` is the
current authorized documentation-only phase through Planning -> Wenfu Control
B. It archives completed plan evidence, refreshes durable references, and
creates the future-work record without changing runtime or activation
authority. It is accepted at `2a5f0efdd3b15ca2578eda69bcde6546e5d7269b`; the
documentation-housekeeping phase is complete.

## Current Codex Work Mode Policy Propagation

`ops/docs/plans/CODEX_WORK_MODE_CURRENT_V1_POLICY_PROPAGATION_PLAN.md` records
the current unchanged-v1 local package and policy propagation. It is the
current authorized builder-governance phase through Planning -> Wenfu Control
B; it is accepted at `9ef996431054f7bacb4765b72b7d04a9e8460a48`. The local
policy propagation and registered gate `codex_work_mode.package.f737dc3.v1`
are accepted. Product/runtime and external boundaries remain unchanged.
