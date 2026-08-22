# Expo V1 Dummy Device Validation After Render Repair Plan

Status: accepted for direct dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Director authority: the continuing explicit instruction to proceed with dummy
device validation

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted source baseline:
`1c312829da54da8fa395e56ae14552b20296e618`

Parent runtime plan:
EXPO_V1_DUMMY_DEVICE_AND_CAMERA_VALIDATION_PLAN.md (deleted 2026-08-22 in the
plans/archive cleanup; recoverable via `git log --grep`)

Observed-failure report:
`ops/docs/handoffs/2026-08-12-expo-v1-dummy-device-camera-usb-validation-control-b.md`

Accepted repair report:
`ops/docs/handoffs/2026-08-12-expo-v1-signed-out-oauth-copy-key-repair-control-a.md`

## Objective

Repeat the parent plan from a clean runtime setup using the accepted JavaScript
repair and the same installed development client. First prove the former fatal
signed-out path now renders; only then resume the bounded dummy account, dummy
OAuth, and TempleMate in-app camera/fixture-QR validation.

All parent-plan criteria, exclusions, exact device/package/fixture values,
permanent USB/ADB attachment rule, in-app-only QR rule, no-repair rule, and
cleanup requirements remain frozen except as narrowed below.

## Renewed Entry Gate

Before Metro, Control independently verifies:

- canonical source includes exactly the accepted
  `t.oauthOutcome[oauthState.phase] || t.oauthOutcome.idle` repair;
- the focused regression proof and full `yarn test`, `yarn lint`, and `yarn
  verify` pass from the accepted source;
- exact Pixel/package/version/SDK, TCP 8081, reverse-map, dependency-equivalence,
  and temporary-symlink preconditions from the parent plan pass.

Use the exact previous TempleMate method only:

    adb -s 39011FDJH00FQ8 reverse tcp:8081 tcp:8081
    TEMPLEMATE_CLIENT_MODE=dummy BUILD_MODE=development npx expo start --dev-client --localhost --port 8081

Open the exact Metro-emitted local `exp+templemate` URL through target-fenced
ADB. Never ask the Director to scan a Metro/Expo QR code. The standard Back
action may dismiss the Expo developer overlay only after the bundle loads, as
in the prior accepted TempleMate evidence.

## Former-Failure Checkpoint

The first runtime gate is the repaired signed-out screen:

- no `Cannot convert undefined value to object` render screen;
- visible TempleMate dummy disclosure and fixture credentials;
- visible Google/Apple buttons and an idle OAuth status label;
- no fatal JS error from the repaired lookup.

If this gate fails, capture only the exact app-scoped error, stop the remaining
journey, clean up, and return. Do not reload repeatedly or repair source.

## Continued Validation

If the former-failure gate passes, execute the parent plan's bounded checks:

- invalid and valid email login;
- account-only navigation, profile, dependent CRUD, registration create/edit,
  paid read-only fixture, collections, preferences, assistance/contact/privacy,
  reset and sign-out;
- one Google and one Apple dummy success journey, network-free;
- TempleMate's own in-app `Scan demo QR` path only: deny/no-loop, explicit
  retry/grant, no microphone prompt, untrusted payload rejection, trusted
  payload binding to `竹南鎮聖福宮`, then confirmed switch to `示範宮廟二號`.

The Expo launcher scanner and Pixel native scanner remain forbidden. The
Director need not touch the device until Control reaches TempleMate's in-app
camera surface. At that point Planning may ask the Director only to point the
Pixel, with TempleMate's in-app scanner visibly open, at the already rendered
untrusted then trusted payload images on the computer. This physical pointing
is not Metro attachment or use of another scanner.

## No Repair And Cleanup

Record functional defects and UI-refinement findings without code/config/test/
dependency/version changes. Stop only packet Metro; remove only exact 8081
reverse, temporary dependency symlink, and packet-created evidence. Preserve
the installed app. Prove clean Git/staging and no residue.

## Exclusions And Invariants

- no rebuild, EAS, prebuild, APK/AAB, dependency or native/config change;
- no version/build increment: `1.0.0 / Android 1 / iOS 1`;
- no real API/OAuth, provider/Rails/server, payment, deployment, production,
  release, OTA, store, or push;
- no product repair or UI refinement in this packet.

## Terminal

- `dummy_device_and_camera_validation_complete`;
- `dummy_runtime_functional_defect_found`;
- `metro_or_device_attachment_failed`;
- `physical_qr_scan_unconfirmed`;
- `runtime_cleanup_reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

Control integrates only its immutable safe report/packet and sends one terminal
package to Planning.

Current classification:
`expo_v1_dummy_device_validation_after_render_repair_authorized`.

First blocker: none.
