# Expo V1 Dummy OAuth And Temple QR Runtime Validation Plan

Status: accepted for direct runtime dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Director authority: continuing authorization to proceed with the installed
TempleMate development-client dummy and in-app QR validation

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted source baseline:
`a7824ce37093210c4e2d3e5b2c133ae3b12f93f4`

Accepted repair evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-dummy-oauth-success-repair-control-a.md`

Prior runtime evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-dummy-device-validation-after-render-repair-control-b.md`

## Objective

Reuse the installed TempleMate development client to prove that the accepted
Expo PKCE JavaScript repair makes both network-free dummy providers reach the
existing account-only signed-in state. Then complete the still-unconfirmed
TempleMate in-app untrusted/trusted fixture QR and confirmed tenant-switch
subslice.

This is runtime observation only. It does not repair source, repeat the already
accepted broad account smoke, or validate real OAuth.

## Entry Gate

Before runtime setup, Control independently verifies:

- canonical source is the accepted `a7824ce` repair or a descendant containing
  it unchanged;
- the exact supported Expo Crypto `BASE64` plus strict Base64URL conversion is
  present and the rejected `CryptoEncoding.BASE64URL` request is absent;
- focused runtime-boundary/dummy OAuth tests and full `yarn test` pass with 44
  tests, followed by `yarn lint` and `yarn verify`;
- exact Pixel serial `39011FDJH00FQ8`, installed package
  `com.jimmy1768.komainu.dev`, launcher, `1.0.0`/code `1`/target SDK 36, TCP
  8081, reverse-map, dependency-equivalence, and temporary-symlink preconditions
  pass.

Use only the exact accepted TempleMate USB method:

    adb -s 39011FDJH00FQ8 reverse tcp:8081 tcp:8081
    TEMPLEMATE_CLIENT_MODE=dummy BUILD_MODE=development npx expo start --dev-client --localhost --port 8081

Open only Metro's exact local `exp+templemate` URL through target-fenced ADB.
Never ask the Director to scan a Metro/Expo QR code. The standard Back action
may dismiss the expected Expo developer overlay after bundle load.

## Dummy OAuth Runtime Check

From the visible TempleMate signed-out dummy surface:

1. Run one Google dummy success action.
2. Require visible arrival at the existing account-only signed-in state with
   the fixture profile; no provider browser/account, network request, real API,
   or admin surface.
3. Sign out and confirm pending OAuth state is cleared.
4. Run one Apple dummy success action with the same acceptance criteria.
5. Sign out or use the accepted dummy reset path as needed to establish a
   signed-in, unbound fixture state for the QR check.

If either provider fails, capture only the exact visible outcome and minimal
package-scoped evidence, stop the QR path, clean up, and return. Do not repair,
retry repeatedly, switch to real mode, or open a provider browser.

## TempleMate In-App QR Check

Only after both dummy providers pass:

- enter the account-only dummy state with no temple binding;
- open only TempleMate's visible `Scan demo QR` / Expo CameraView action;
- never use the Expo development launcher scanner, Pixel native Camera/QR
  scanner, another application, typed fixture link, simulated scan result, or
  direct QR payload injection;
- camera permission is already granted from accepted evidence. Do not revoke or
  reset it; require the in-app rear-camera QR surface and no microphone/audio
  prompt.

The previously observed scoped CameraView-children warning is retained as a
presentation-source follow-up. Record whether it recurs and whether it affects
scanning; do not repair or suppress it in this packet.

### Required physical-action callback

The physical scan requires the Director to point the connected Pixel at an
image displayed by Planning. This plan explicitly permits only these two
nonterminal Control-to-Planning callbacks:

1. `director_action_required: untrusted_qr` only after TempleMate's own in-app
   camera is visibly ready. Control must keep the exact Metro/reverse/session
   and camera surface open while Planning presents the untrusted image and the
   Director confirms pointing.
2. `director_action_required: trusted_qr` only after TempleMate visibly rejects
   the untrusted scan, preserves the unbound state, and Control activates
   TempleMate's visible `Scan again` action. Control must again keep the in-app
   camera open while Planning presents the trusted image and the Director
   confirms pointing.

These callbacks are required user-input coordination, not status or repair
traffic. Control must not classify the physical scan unconfirmed merely because
Planning has not yet relayed the Director response. While waiting, use recurring
bounded task waits and retain the fenced session; do not invent a fixed camera
window. Clean up only after an explicit stop, device/Metro failure, or the
completed scan sequence.

Planning has independently verified the two rendered fixture PNG files outside
the repository. Control does not open, read, copy, record, or parse the images
or their payloads. The Director presents them physically to TempleMate's camera
only when Planning relays the corresponding callback.

## Required Visible Outcomes

1. The untrusted fixture is rejected inside TempleMate, the camera closes or
   yields the visible safe failure state, and the prior unbound state remains.
2. After visible `Scan again`, the trusted fixture is consumed exactly once,
   the camera closes, and TempleMate binds `竹南鎮聖福宮`.
3. Selecting switch temple shows confirmation before mutation.
4. Confirming the switch clears the prior tenant-scoped dummy state and visibly
   switches to `示範宮廟二號`.
5. No QR image, payload, camera media/frame, provider/browser content, broad
   logs, or secrets are retained in the report.

## Evidence And Cleanup

Control may use one ephemeral Implementer only for immutable report preparation
and static/diff checks. Control retains Metro, target-fenced ADB, device/UI,
callback, acceptance, integration, and cleanup ownership.

Record a precise pass/fail/untested matrix for:

- Google dummy success and sign-out cleanup;
- Apple dummy success and sign-out cleanup;
- in-app camera entry;
- untrusted rejection and preserved binding;
- trusted binding;
- confirmation-only tenant switch and cleanup;
- CameraView warning recurrence/impact;
- exact runtime and repository cleanup.

On terminal, stop only the packet Metro process; remove only the exact serial
`tcp:8081` reverse, temporary dependency symlink, and packet-created ephemeral
UI evidence. Preserve the installed app and accepted camera permission. Prove
no 8081 listener/reverse/symlink/evidence residue and clean Git/staging.

Control integrates only its immutable safe report/packet and sends one terminal
package to Planning after both physical callbacks are resolved or an actual
runtime/device failure prevents continuation.

## Exclusions And Invariants

- no source/config/test/dependency/lockfile/version/native/Rails/Vue edit;
- no rebuild, EAS, prebuild, APK/AAB, signing, install/uninstall, or package
  mutation;
- no version/build increment: `1.0.0 / Android 1 / iOS 1`;
- no real API/OAuth, provider/browser/account/console, secret, deployment,
  production, release, OTA, store, payment, or push;
- no dependent/registration automation retry, CameraView repair, UI refinement,
  or unrelated device action.

## Terminal Classifications

- `dummy_oauth_and_temple_qr_runtime_validation_complete`;
- `dummy_oauth_runtime_defect_found`;
- `temple_qr_runtime_defect_found`;
- `metro_or_device_attachment_failed`;
- `runtime_cleanup_reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

Current classification:
`expo_v1_dummy_oauth_and_temple_qr_runtime_validation_authorized`.

First blocker: none.
