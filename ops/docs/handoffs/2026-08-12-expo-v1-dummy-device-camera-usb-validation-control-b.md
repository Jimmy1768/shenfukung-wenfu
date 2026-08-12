# TempleMate USB dummy device and in-app camera validation — Control packet

## Identity

- Accepted plan and immutable criteria:
  `ops/docs/plans/EXPO_V1_DUMMY_DEVICE_AND_CAMERA_VALIDATION_PLAN.md` at
  `5c7072cb7978d15adf62d59193dfbb9e4ad4f05a`.
- Control and Planning tasks: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0` -> Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Repository/worktree/branch/base:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`;
  `/private/tmp/shengfukung-wenfu-expo-v1-dummy-device-camera-usb-validation`;
  `codex/expo-v1-dummy-device-camera-usb-validation`;
  `5c7072cb7978d15adf62d59193dfbb9e4ad4f05a`.
- Packet identity and implementation attempt:
  `2026-08-12-expo-v1-dummy-device-camera-usb-validation-control-b`, attempt 2
  (fresh corrected attachment method).

## Frozen scope

- Objective: use the accepted USB-only TempleMate method to attach the exact
  installed development client to one dummy localhost Metro process, classify
  the bounded dummy account/OAuth and TempleMate in-app camera/fixture-QR
  journeys, and leave no packet runtime residue.
- Sole editable path:
  `ops/docs/handoffs/2026-08-12-expo-v1-dummy-device-camera-usb-validation-control-b.md`.
- Exact device/package fence: serial `39011FDJH00FQ8`, Pixel 8 / `shiba`, only
  `com.jimmy1768.komainu.dev` / `.MainActivity`, `1.0.0` / code `1` / target
  SDK `36`.
- Exact attachment: only `adb -s 39011FDJH00FQ8 reverse tcp:8081 tcp:8081`,
  then only `TEMPLEMATE_CLIENT_MODE=dummy BUILD_MODE=development npx expo start
  --dev-client --localhost --port 8081`, then only that Metro process's exact
  local `exp+templemate` URL via target-fenced ADB. No yarn wrapper, `--host`,
  `--clear`, QR attachment, Expo launcher scanner, Pixel scanner, LAN/tunnel,
  cloud, or alternate package.
- Temple QR boundary: after TempleMate loads and signs in, the physical Pixel
  reads only the Planning-provided untrusted then trusted fixture PNGs through
  TempleMate's visible `Scan demo QR` / in-app Expo CameraView. No camera media
  or QR images are recorded, no live link is created, and no other scanner is
  opened.
- Exclusions: no source/config/test/dependency/version edit, rebuild/EAS,
  real API/OAuth/provider/Rails, deployment/release/push, broad logs, unrelated
  device action, or repair.

## Evidence and execution

- Required preflight: exact ancestry and clean/staging-empty canonical and
  isolated state; exact device/package; unowned 8081/reverse; byte-identical
  `mobile/package.json` and `yarn.lock` vs accepted camera dependency tree;
  absent isolated `node_modules` before one temporary symlink; `yarn test`,
  `yarn lint`, and `yarn verify`.
- Required runtime classification: signed-out/demo UI; invalid and fixture
  email sign-in; account-only navigation; profile/dependents/registrations
  (paid read-only); content; preferences; dummy support/privacy; reset/signout;
  dummy Google/Apple successes; one-denial/no-loop/retry/grant camera path;
  untrusted/trusted fixture QR outcomes; switch confirmation and cleanup.
- Evidence is app-scoped and sanitized only. Screenshots/UI hierarchy may be
  temporary packet evidence; no camera media, broad logs, URLs, tokens,
  credentials, provider, or unrelated device data may be retained.
- Required cleanup: stop only this Metro process; remove only target `tcp:8081`
  reverse and the temporary symlink; delete only packet-created UI evidence;
  prove no residue and clean/staging-empty worktrees.

## Handoff and Implementer

- Persistent Handoff: no; no Luna allocation.
- One ephemeral Implementer: `gpt-5.6-terra/medium`, selected because it only
  prepares the safe runtime-report matrix. Control retains all Metro/ADB/UI,
  attachment, observation, cleanup, acceptance, integration, and terminal
  authority.
- Implementer owns only this packet, may perform static/diff checks only, and
  must not touch device, ADB, Metro, symlink, sources, staging, commit, merge,
  push, secrets, providers, or external systems.

## Closeout

- Control will send one immutable terminal packet directly to Planning only
  after acceptance, a real frozen-plan functional defect, or other truthful
  terminal disposition; no intermediate Planning status is permitted.
- Planning owns any subsequent repair or UI/refinement authority. `AGENTS.md`,
  plans, product source, and configuration are excluded.

## Safe runtime receipt

All results are Control-observed pending. Each runtime assertion will be
recorded `passed`, `failed` with a likely JavaScript/native/unknown surface, or
`untested` with the actual direct reason. Physical QR results retain only the
visible TempleMate state—never camera media. The final receipt will identify
only sanitized preflight, attach, UI, cleanup, Git, classification, and next
owner/action evidence.

### Pending evidence matrix

This matrix is a report scaffold only. It does not assert that any runtime
action has occurred, and it must be filled only by Control from the fenced
USB/Pixel observation.

| Area | Required observation | Pending result | Sanitized evidence to retain |
| --- | --- | --- | --- |
| Git fence | Canonical and isolated ancestry, status, and staging meet the packet fence. | pending | Commit IDs and clean/empty result only. |
| Device fence | The one serial identifies Pixel 8 / `shiba`, Android 17/API 37, with only the frozen Komainu development package. | pending | Serial, model/codename, Android API, package/version/code/target SDK. |
| Port/reverse fence | TCP 8081 has no unrelated owner and no unattributed target reverse before packet creation. | pending | Free/occupied classification and target-only reverse classification. |
| Dependency fence | Isolated manifests match the accepted camera dependency source and the isolated `node_modules` path was absent before the temporary symlink. | pending | Byte-identical/pass-fail result and symlink lifecycle only. |
| Static checks | `yarn test`, `yarn lint`, and `yarn verify` complete before Metro; failures are recorded without repair. | pending | Command outcome/counts and first nonsecret failure line only. |
| Dummy-mode fence | Metro uses the exact USB command and the loaded app visibly reports demo/dummy mode without API base URL, tenant slug, provider browser, or network request. | pending | Metro start/attach classification and visible dummy indicator only; never the dev-client URL. |
| Account entry | TempleMate opens signed out; invalid fixture credentials reject; `member@example.test` / fixture password reaches signed-in account state. | pending | Visible state/error classification only; no credential text. |
| Account-only scope | Navigation exposes account-only UI and no admin mode or surface. | pending | Visible menu/screen classification. |
| Account mutations | Profile name edit, dependent create/edit/delete, and registration create/edit work; paid fixture remains read-only and no payment CTA appears. | pending | Per-action visible outcome; no personal values. |
| Account content | Certificates, events, services, and gallery render. | pending | Per-screen render classification. |
| Preferences | zh-TW/English and light/dark work; no admin preference appears. | pending | Visible locale/theme result only. |
| Dummy support/privacy | Assistance, contact, and privacy submissions show deterministic dummy outcomes. | pending | Visible success/error classification. |
| Reset/sign-out | Reset/sign-out returns to deterministic signed-out state. | pending | Visible signed-out result only. |
| Dummy Google | Signed-out dummy Google success remains network-free, uses the installed native Crypto/PKCE path, and returns account-only signed-in state; sign-out clears it. | pending | Visible transition and no-browser/no-network classification only. |
| Dummy Apple | Signed-out dummy Apple success remains network-free, uses the installed native Crypto/PKCE path, and returns account-only signed-in state; sign-out clears it. | pending | Visible transition and no-browser/no-network classification only. |
| Camera denial | `Scan demo QR` requests once; one denial produces a visible denied state and no repeat prompt. | pending | Prompt count and denied-state classification; no camera media. |
| Camera retry/grant | Only visible Retry produces one further request; grant opens rear-facing QR-only CameraView with no microphone/audio prompt. | pending | Retry/request count and visible camera/no-audio classification; no camera media. |
| Untrusted fixture QR | TempleMate in-app camera reads the Planning-provided untrusted fixture; app shows invalid/untrusted and leaves binding unchanged. | pending | Visible result and binding-unchanged classification only; no QR image/media/payload retention. |
| Trusted fixture QR | After `Scan again`, TempleMate consumes one trusted fixture result, closes camera, and binds to `竹南鎮聖福宮`. | pending | Visible app result and tenant label only; no QR image/media/payload retention. |
| Tenant switch | Visible confirmation prevents premature switch, then switches to `示範宮廟二號` only after cleanup. | pending | Pre-confirmation/post-confirmation labels and cleanup classification only. |
| UI refinement | Layout, keyboard, scrolling, edge-to-edge, touch, copy, and navigation concerns are logged separately from functional outcomes. | pending | Concise observation and likely JavaScript/native/unknown surface. |
| Cleanup | Only packet Metro, exact 8081 reverse, temporary symlink, and packet-created UI evidence are removed; app state/package remains. | pending | Process/reverse/symlink/evidence-absence and Git cleanliness classifications. |

### Result conventions

- `passed`: Control observed the specified bounded behavior on the fenced app
  and Pixel.
- `failed`: Control records the visible symptom, reproducibility, and a likely
  JavaScript, native, or unknown surface without changing source.
- `untested`: Control records the concrete direct reason, including
  `physical_qr_scan_unconfirmed` when the Director cannot position a Planning
  fixture in front of TempleMate's in-app camera in the bounded window.

The report excludes raw Metro/dev-client URLs, QR payloads/images, camera
media, credentials, provider/browser material, broad logs, and unrelated
device information.

## Control-observed runtime result

### Preflight and attachment

- The corrected plan/base and canonical `main` were exact at packet start;
  both canonical and isolated staging were empty. The isolated branch began at
  `5c7072cb7978d15adf62d59193dfbb9e4ad4f05a`.
- The only connected target matched the exact Pixel 8 / `shiba` fence at Android
  API 37. The installed Komainu development package and launcher matched
  `com.jimmy1768.komainu.dev`, `1.0.0`, code `1`, and target SDK `36`.
- Port 8081 and the target reverse mapping were unowned before setup. The
  isolated manifest and lockfile were byte-identical to the accepted dependency
  source. One temporary symlink was created exactly as authorized.
- `yarn test` passed 42/42; `yarn lint` and `yarn verify` passed.
- The exact corrected target reverse and USB Metro command were used. The
  target-fenced local development-client attach reached the frozen TempleMate
  package. A pre-existing device notification shade, containing a system
  quick-setting label for QR scanning, was dismissed with Back; that system
  scanner was never selected. No Expo launcher scanner, Pixel Camera, or QR
  payload was used.

### Fatal render defect

- **Result:** failed before signed-out dummy UI rendered. The app-scoped visible
  error was `Render Error` / `Cannot convert undefined value to object`, at
  `App.js (99:1264)`, with component stack `SignedOut` at `App.js:97` and
  `App` at `App.js:30`.
- **Minimal packet-owned runtime evidence:** Metro successfully bundled Android
  entry code, then emitted the same `TypeError` and `App.js` source location.
  No broad log collection occurred.
- **Classification:** JavaScript-only source defect; no native dependency,
  configuration, or rebuild evidence is implicated. Static local inspection
  shows `SignedOut` dereferences `t.oauthState` at `mobile/App.js:99`, whereas
  both locale objects define `oauthOutcome` in `mobile/app/ui/copy.js` and no
  `oauthState` copy key. This is evidence only; no code was changed.
- **Untested due fatal render:** all signed-out/account, dummy Google/Apple,
  in-app CameraView permission, untrusted/trusted fixture QR, and tenant-switch
  assertions. No reload, dismissal of the render error, navigation, account
  mutation, browser, provider, camera, QR, or real API/OAuth action occurred
  after the fatal error. The Director's later manual attach observation confirms
  the same visible error.

### Cleanup and terminal

- The packet-owned Metro process exited; the exact serial `tcp:8081` reverse
  was removed; the exact temporary `node_modules` symlink was removed; and only
  packet-created app-scoped screenshot/UI-hierarchy evidence was deleted from
  the exact temporary paths. No camera media was retained.
- Final verification found no listener on TCP 8081, no target reverse mapping,
  no temporary dependency symlink, and no retained packet UI evidence. The
  installed development client and its package state were retained unchanged.
- `git diff --check` passed. This isolated branch changes only this immutable
  Control record; canonical source/configuration were not changed.
- Terminal classification: `dummy_runtime_functional_defect_found`.
- Continuation disposition: `accepted_frozen_outcome` for this observation-only
  packet; the first defect is fully evidenced and requires a separate Planning
  repair authority.
- Next owner/action: Wenfu Planning should authorize a bounded JavaScript-only
  SignedOut copy-key repair, with a focused regression test and renewed device
  validation afterward. No EAS/native build is indicated by current evidence.
