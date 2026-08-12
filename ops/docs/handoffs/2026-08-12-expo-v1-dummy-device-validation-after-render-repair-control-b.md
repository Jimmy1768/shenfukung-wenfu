# TempleMate dummy device validation after signed-out render repair — Control packet

## Identity and authority

- Accepted continuation: `ops/docs/plans/EXPO_V1_DUMMY_DEVICE_VALIDATION_AFTER_RENDER_REPAIR_PLAN.md` at `80c79e437556da3c3451275da2871cd7399530c7`.
- Source Control -> Planning: Wenfu Control B `019fe020-e92e-7770-984f-b59acd547ab0` -> Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Worktree/branch/base: `/private/tmp/shengfukung-wenfu-expo-v1-dummy-device-validation-after-render-repair`; `codex/expo-v1-dummy-device-validation-after-render-repair`; `80c79e437556da3c3451275da2871cd7399530c7`.
- Packet and attempt: `2026-08-12-expo-v1-dummy-device-validation-after-render-repair-control-b`, attempt 3.

## Bounded runtime scope

- First gate: source has the accepted `t.oauthOutcome[oauthState.phase] || t.oauthOutcome.idle` correction; focused/full checks pass; then exact Pixel/package/8081/dependency preflight.
- Exact USB attachment only: target serial `39011FDJH00FQ8`; only `adb -s 39011FDJH00FQ8 reverse tcp:8081 tcp:8081`; only `TEMPLEMATE_CLIENT_MODE=dummy BUILD_MODE=development npx expo start --dev-client --localhost --port 8081`; only Metro's emitted local `exp+templemate` URL via target-fenced ADB. No QR attachment, Expo launcher scanner, Pixel scanner, alternate package, LAN/tunnel/cloud, yarn wrapper, `--host`, or `--clear`.
- Continue only after the repaired signed-out checkpoint visibly renders without the former error: account dummy smoke, one Google and Apple dummy success, and only TempleMate's own in-app `Scan demo QR` / CameraView denial/no-loop/retry/grant path.
- When the in-app scanner is visibly ready, Planning may coordinate the Director's physical pointing at the already-rendered untrusted then trusted fixtures. Control records only visible TempleMate outcomes and no QR image, payload, or camera media.
- Sole editable path: this Control packet/receipt. Excluded: product/config/test/dependency/version changes, rebuild/EAS, real API/OAuth/provider/Rails, deployment/release/push, broad logs, other device action, and repair.

## Evidence, allocation, and cleanup

- Required evidence: exact correction source scan; focused regression plus `yarn test`, `yarn lint`, `yarn verify`; package/device/port/reverse/dependency equivalence; app-scoped sanitized hierarchy/screenshot only as needed; precise pass/fail/untested matrix; exact process/reverse/symlink/evidence cleanup; diff and clean state.
- One ephemeral Implementer: `gpt-5.6-terra/medium`, lowest sufficient for report preparation only. It owns this file and static/diff checks only; no ADB, Metro, symlink, device/UI, network, build, source change, staging, or commit. Control retains every runtime, acceptance, integration, and terminal action. No persistent handoff; Luna is ineligible.
- No-repair boundary: a fatal render/functional defect stops its downstream journey, is recorded with minimal app/Metro evidence and likely JS/native/unknown classification, then cleaned up. Planning alone owns any repair continuation.
- Cleanup is limited to the packet Metro process, exact serial `tcp:8081` reverse, exact temporary `mobile/node_modules` symlink, and packet-created UI evidence. The installed app/state are retained.

## Safe receipt

The result matrix is complete with the observed outcomes. Retain only aggregate check results, fenced package/device identity, visible app outcomes, first error text/source location when applicable, nonsecret UI findings, cleanup/Git state, terminal classification, continuation disposition, and next owner. Never retain credentials, raw Metro URL, QR media/payload, camera frames, provider/browser material, or broad logs.

## Control-observed result

### Renewed entry and repaired signed-out gate

- Canonical and isolated source began at the accepted continuation commit with
  empty staging. The accepted repair ancestor was verified, and source contains
  only the intended `t.oauthOutcome[oauthState.phase] || t.oauthOutcome.idle`
  lookup with no remaining `t.oauthState` lookup.
- The exact Pixel 8 / `shiba` target, Komainu development package/launcher,
  Android API 37, version `1.0.0`/code `1`/target SDK `36`, unowned TCP 8081,
  and absent target reverse mapping all matched the fence. The isolated
  manifest/lockfile were byte-identical to the accepted dependency source; the
  sole temporary symlink lifecycle was established.
- Static evidence passed: focused copy-key regression and full `yarn test`
  (43/43), `yarn lint`, and `yarn verify`.
- Only the exact USB reverse and prior accepted local Metro command were used.
  Only its local `exp+templemate` development-client attachment opened the
  fenced package. A standard Back dismissed the expected Expo developer overlay
  after bundle load. No Metro QR, Expo launcher scanner, Pixel/system QR
  scanner, real API, provider, or browser was used.
- **Passed:** the former render error is absent. TempleMate visibly rendered the
  signed-out dummy disclosure, fixture credential presentation, Google/Apple
  buttons, and the idle OAuth status. No fatal JavaScript error appeared.

### Dummy account and settings observation

- **Passed:** invalid fixture credentials produced the visible local rejection;
  valid fixture email sign-in reached the visible account-only home screen.
  Home/menu inspection found account-only navigation and no admin surface.
- **Passed:** profile save, paid fixture presentation as completed/read-only
  without a payment call-to-action, certificate/event/service/gallery rendering,
  zh-TW to English and light to dark preference changes, dummy assistance,
  dummy contact, dummy privacy export, reset, and sign-out were visibly
  exercised. Reset restored the deterministic unbound fixture state.
- **Untested:** deterministic dependent create/edit/delete and registration
  create/edit after repeated targeted keyboard automation did not produce a
  reliably observable list transition in the bounded session. This is recorded
  as an automation-evidence limitation, not a product failure; static tests for
  those dummy operations passed.
- **UI findings:** account menu wrapping, keyboard-safe form surfaces, scroll,
  locale/theme changes, and the loaded edge-to-edge presentation were usable in
  the observed flows. No new UI-refinement defect is asserted from this smoke.

### Dummy OAuth functional defect

- **Failed:** one visible dummy Google action and one visible dummy Apple action
  each returned to the signed-out screen with the generic visible outcome
  `External sign-in did not complete. Start again.` Neither reached the required
  account-only signed-in state.
- Both attempts remained inside the dummy app surface: no provider browser,
  provider account, Central Auth/Rails endpoint, or real OAuth result was used.
  Exact package-scoped recent-log filtering supplied no additional nonsecret
  failure frame, so the underlying mechanism is **unknown** rather than claimed
  JavaScript-only or native-only. The deterministic dummy controller and PKCE
  source tests passed locally; no repair was made.

### In-app camera and fixture QR

- **Passed:** only TempleMate's visible `Scan demo QR` / in-app CameraView was
  opened. Its first camera request was denied once; the visible denied/retry
  state remained stable without a repeat prompt. Only visible Retry produced the
  second request; grant opened the in-app camera surface. No microphone/audio
  prompt appeared. No Expo launcher or Pixel native scanner was opened.
- **Observed follow-up:** the packet-owned Metro process emitted one scoped
  `CameraView` warning that children are unsupported and may cause inconsistent
  behavior. The visible scanner did not crash in this session; classify this as
  a JavaScript presentation-source follow-up, not a native rebuild finding.
- **Untested — `physical_qr_scan_unconfirmed`:** the Director did not present
  the Planning-rendered untrusted fixture during the bounded in-app camera
  window, so no QR result was simulated or consumed. The trusted follow-up and
  confirmation-only switch to `示範宮廟二號` are correspondingly untested. No
  QR image, payload, camera media, or live tenant link was accessed or retained.

### Cleanup and terminal

- **Cleanup passed:** the packet-owned Metro process exited; the exact serial
  `tcp:8081` reverse was removed; the exact temporary dependency symlink and
  only packet-created app-scoped UI evidence were deleted. Final checks found
  no TCP 8081 listener, reverse mapping, temporary symlink, or evidence
  directory. The installed development client, its package, and accepted camera
  permission state are retained.
- Terminal classification: `dummy_runtime_functional_defect_found`.
- Continuation disposition: `accepted_frozen_outcome` for this observation-only
  packet. The first remaining repairable product finding is the provider-
  independent dummy OAuth success failure; QR physical validation is separately
  unconfirmed, not a simulated success.
- Next owner/action: Planning should decide a bounded diagnosis/repair packet
  for dummy OAuth success (with a renewed device validation after acceptance),
  and separately reauthorize the physical in-app QR/switch subslice when the
  fixture presentation is available. No native rebuild is implied by current
  evidence.

## Sanitized runtime result matrix

| Gate | Required visible evidence | Completed status | Sanitized Control result |
| --- | --- | --- | --- |
| Repaired signed-out gate | No former fatal render error; dummy disclosure, fixture sign-in affordances, provider buttons, and idle OAuth label visible | passed | Former render error absent; all required signed-out dummy affordances and idle OAuth label were visible. |
| Dummy account smoke | Invalid sign-in rejection; fixture sign-in; account-only navigation; profile/dependent/registration flows; paid fixture remains read-only; collections, preferences, assistance/contact/privacy, reset, and sign-out | partial / untested | Invalid and valid sign-in, account-only navigation, profile, read-only paid fixture, collections, preferences, assistance/contact/privacy, reset, and sign-out passed; dependent and registration list transitions were not reliably observable under bounded keyboard automation. |
| Dummy Google journey | One network-free dummy Google success reaches the account-only signed-in state and clears on sign-out | failed | Visible dummy Google action returned to signed-out with `External sign-in did not complete. Start again.`; no account-only signed-in state resulted. |
| Dummy Apple journey | One network-free dummy Apple success reaches the account-only signed-in state and clears on sign-out | failed | Visible dummy Apple action returned to signed-out with `External sign-in did not complete. Start again.`; no account-only signed-in state resulted. |
| In-app camera entry | Only TempleMate `Scan demo QR` / CameraView opens; no Expo-launcher or native-scanner use | passed | Only TempleMate's visible in-app `Scan demo QR` / CameraView was opened; no Expo-launcher or Pixel native scanner was used. |
| Camera denial/no-loop | Initial denial yields a visible denied state and explicit Retry without a repeated prompt | passed | First request was denied once; the visible denied/retry state remained stable without a repeat prompt. |
| Camera Retry/grant | One visible Retry then grant produces rear-facing QR-only preview with no microphone/audio prompt | passed | Only visible Retry made the second request; grant opened the in-app camera surface with no microphone/audio prompt. |
| Untrusted fixture QR | TempleMate visibly rejects the first fixture and preserves the pre-scan binding | untested — physical_qr_scan_unconfirmed | The untrusted fixture was not presented during the bounded in-app camera window; no scan result was consumed. |
| Trusted fixture QR | After visible Scan again, exactly one result is consumed, camera closes, and TempleMate visibly binds the trusted fixture tenant | untested — physical_qr_scan_unconfirmed | Untested because the untrusted scan did not occur; no trusted fixture binding was attempted. |
| Confirmed tenant switch | No pre-confirmation switch; visible confirmation clears prior tenant state and then switches to the second fixture tenant | untested — physical_qr_scan_unconfirmed | Untested because no trusted fixture binding occurred; no confirmation-only tenant switch was attempted. |
| UI observations | Layout, keyboard, scrolling, edge-to-edge, touch, copy, and navigation findings recorded separately without repair | passed | Observed account menu, keyboard-safe forms, scroll, locale/theme changes, and edge-to-edge presentation were usable; no new UI-refinement defect is asserted. |
| Defect classification | Any first fatal/functional defect records only its visible app-scoped text plus JS-only/native/unknown assessment; downstream path stops where required | follow-up | Dummy Google and Apple success failed with the recorded generic visible outcome; targeted package-scoped evidence did not classify the mechanism beyond unknown. The scoped CameraView child warning is a JavaScript presentation-source follow-up, not a native rebuild finding. |
| Cleanup | Packet Metro process, exact `tcp:8081` reverse, temporary dependency symlink, and ephemeral evidence removed; app retained | passed | Metro, exact reverse, temporary symlink, and packet-created evidence were removed; no listener, reverse, symlink, or evidence directory remained; installed client retained. |

The runtime report must not retain the raw local dev-client URL, fixture QR payload or image, camera media, credentials, provider/browser content, or broad device/Metro logs.
