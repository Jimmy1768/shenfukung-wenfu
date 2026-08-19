# Expo Temple QR Camera Foundation Plan

Status: accepted for direct implementation dispatch to Control B after this
plan is committed

Created: 2026-08-11

Owner: Wenfu Planning

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted source baseline:
`e5ae5e8fd76b9b152b24e7b3c9e142b12cff2427`

Mature read-only camera reference:
`/Users/jimmy1768/Projects/DojoMate-Expo`

Official compatibility authority:
Expo SDK 54 `expo-camera` documentation, which identifies `~17.0.10` as the
compatible package line.

## Objective

Add the native camera capability required for TempleMate to scan temple QR
codes before the next development-client binary is built. Provide a bounded,
testable QR-only camera foundation without inventing the later live temple
registry, QR payload, trust, or tenant-binding contract.

This phase deliberately precedes the separately authorized EAS-cloud
development-client build so OAuth and camera native modules can enter one new
binary instead of requiring two rebuilds.

## Accepted Direction

- Add only the Expo SDK 54-compatible official `expo-camera` package and lock
  closure, expected at `~17.0.10`.
- Configure the Expo camera plugin with an explicit TempleMate camera-purpose
  message and `recordAudioAndroid: false`. Temple QR scanning requires no
  microphone or audio-recording permission.
- Follow the mature DojoMate interaction pattern: `CameraView`,
  `useCameraPermissions`, rear-facing camera, and
  `barcodeScannerSettings={{ barcodeTypes: ['qr'] }}`.
- Request camera permission only after the user chooses the scan action.
  Loading, grant, denial, cannot-ask-again, cancellation, invalid payload, and
  successful scan states must be explicit and recoverable.
- Keep at most one camera preview active. Unmount or deactivate it when the
  scanner is closed or the screen is not active.
- Accept only the first scan while a result is being validated. Duplicate
  barcode callbacks must not produce duplicate binding actions.

## Tenant And Payload Boundary

The existing tenant scanner/parser seam remains the authority for this phase.
The camera supplies one scanned string to that seam; it does not decide that a
temple is trusted.

The only executable binding journey in this phase remains deterministic dummy
mode using the existing fixture link/parser and cleanup rules. The camera may
scan a fixture QR payload so the next development client can prove the native
camera path end to end.

Real-mode live temple discovery, domain validation, trust registry, tenant
switching, server lookup, signed QR payloads, and permanent tenant binding are
deferred. An unknown or untrusted scanned value must fail safely and must not
change the current tenant, session, cache, or pending OAuth state.

No database change is required or authorized.

## Owned Source Surface

Control B may bound its implementation packet to:

- `mobile/package.json` and `mobile/yarn.lock`;
- `mobile/app.config.js`;
- the existing `mobile/app/tenant/` scanner/binding seam;
- a focused camera/QR UI component and the minimum `mobile/App.js` wiring;
- localized TempleMate camera, permission, cancellation, and failure copy;
- focused mobile tests and existing lint/native-config verification scripts;
- Control B's immutable implementation record.

Generated `android/` and `ios/` projects are not source deliverables.

## Required Evidence

- package and lockfile prove only SDK 54-compatible `expo-camera ~17.0.10` was
  added for this capability;
- public Expo config proves the camera plugin, camera-purpose message,
  `recordAudioAndroid: false`, existing TempleMate scheme, Komainu identifiers,
  `1.0.0`, build values `1`, and API 36;
- source and tests prove permission-state handling, explicit user initiation,
  rear-camera QR-only configuration, cancel/unmount behavior, first-scan lock,
  invalid/untrusted failure, and successful fixture parsing;
- dummy mode remains network-free and real mode gains no live tenant-binding
  behavior;
- OAuth, email login, account surface, storage scope, theme/locale, tenant
  cleanup, and existing functional tests remain green;
- `yarn test`, `yarn lint`, `yarn verify`, project-local/offline Expo Doctor,
  both public config modes, and `git diff --check` pass;
- final canonical and isolated worktrees are clean with staging empty.

No native build or device test is an acceptance requirement for this source
phase. The separately planned EAS/provider/device phase will prove the camera
permission and physical QR scan after it builds one development-client APK
containing both the OAuth and camera native modules.

## Explicit Exclusions

- EAS or local native build, prebuild, Gradle/Xcode, APK/AAB, installation,
  Metro, or device action;
- live tenant registry, QR generation, server endpoint, Rails/Vue/database
  change, domain verification, or production tenant switching;
- provider console, OAuth credentials, secrets, deployment, release, store,
  OTA, production data, or push;
- photo/video capture, gallery/media-library access, microphone/audio
  recording, contact/location permission, or any non-QR barcode type;
- admin, payment/ECPay/Stripe, or native identity-management surfaces.

## Acceptance Criteria

1. `expo-camera ~17.0.10` and its lock closure are present and compatible with
   Expo SDK 54.
2. Expo config adds camera permission for temple QR scanning without adding
   Android audio-recording permission.
3. A user-initiated, rear-facing, QR-only camera surface handles permission,
   cancel, denial, invalid payload, duplicate callback, and successful fixture
   scan safely.
4. The scanned string enters the existing parser/trust seam; camera code does
   not grant tenant trust or mutate real tenant scope.
5. Existing OAuth/account/dummy/real boundaries and TempleMate/Komainu
   identity/version/API constraints remain intact.
6. Required automated checks pass without a native build or device action.

## Current Gate

Current classification: `expo_temple_qr_camera_foundation_authorized`.

First blocker: none for source implementation. Physical camera proof remains
part of the later separately authorized EAS-cloud development-client/device
validation phase.
