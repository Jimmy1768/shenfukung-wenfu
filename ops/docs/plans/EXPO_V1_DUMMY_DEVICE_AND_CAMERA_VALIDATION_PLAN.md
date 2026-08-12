# Expo V1 Dummy Device And Camera Validation Plan

Status: accepted for direct runtime dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Director authorization: explicit instruction to proceed after opening the newly
installed TempleMate development client

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Installed baseline: canonical `main`
`d7349a1465fff25ad093f292700e3b98cf09ba11`

Required receipt:
`ops/docs/handoffs/2026-08-12-expo-eas-android-source-backed-download-install-control-b.md`

## Objective

Attach the installed TempleMate development client to one local Metro process
in explicit network-free dummy mode, exercise the account-only dummy surface on
the exact Pixel, validate Expo Camera permission and fixture-QR behavior, smoke
the provider-independent dummy Google/Apple paths, and report every broken or
unclear runtime path before UI refinement.

This is runtime observation only. It does not rebuild, increment a version or
build, edit or repair source, contact Rails or an OAuth provider, or enter real
mode.

## Frozen Runtime

- package/launcher: `com.jimmy1768.komainu.dev` /
  `com.jimmy1768.komainu.dev/.MainActivity`;
- public name: `TempleMate (Dev)`;
- version/code/target: `1.0.0 / 1 / 36`;
- device: serial `39011FDJH00FQ8`, Pixel 8 / `shiba`, Android 17/API 37;
- Metro: localhost TCP 8081 only;
- client mode: explicit `dummy`;
- dummy credentials: `member@example.test` / `templemate-demo`;
- trusted QR:
  `https://temple.example.test/connect/templemate?token=fixture-token`;
- untrusted QR:
  `https://untrusted.example.test/connect/templemate?token=fixture-token`.

The trusted payload identifies test tenant `竹南鎮聖福宮`; the untrusted
payload must never change the binding.

## Mature Reference

Read-only `/Users/jimmy1768/Projects/DojoMate-Expo/package.json` and
`Build-Notes.md` establish the mature Android dev-client pattern: Metro 8081
with `--dev-client --host localhost` and ADB reverse 8081. TempleMate borrows
only this pattern. It sets its own dummy environment, does not reverse a Rails
port, removes only its exact mapping rather than `--remove-all`, and uses no
DojoMate product/config/dependency/provider behavior.

## Preflight And Materialization

Control records one immutable packet and uses one ephemeral Implementer only
for bounded report/evidence preparation. Control owns Metro, ADB, device input,
and cleanup.

Before runtime mutation, prove:

1. canonical and isolated Git/staging are clean and plan/receipt ancestry is
   exact;
2. the exact Pixel is connected and the installed package still reports the
   frozen identity;
3. TCP 8081 has no unrelated owner and the device has no unattributed reverse
   mapping for 8081; stop rather than kill/adopt/overwrite either;
4. current `mobile/package.json` and `mobile/yarn.lock` are byte-identical to
   `/private/tmp/shengfukung-wenfu-expo-temple-qr-camera/mobile/`, whose
   existing `node_modules` directory remains available;
5. isolated `mobile/node_modules` is absent.

Control may create exactly one ignored isolated `mobile/node_modules` symlink
to that byte-identical dependency directory. No install, copy, package-manager,
registry, manifest, lockfile, source, or config action is authorized.

Run `yarn test`, `yarn lint`, and `yarn verify` before Metro. Record a failure;
do not repair it in this packet.

## Metro Attachment

Create only:

    adb -s 39011FDJH00FQ8 reverse tcp:8081 tcp:8081

From isolated `mobile/`, start one packet-owned process:

    BUILD_MODE=development TEMPLEMATE_CLIENT_MODE=dummy TEMPLEMATE_CLIENT_ENVIRONMENT=development yarn dev-client --clear --port 8081 --host localhost

Require the resolved app to remain dummy mode with no API base URL or tenant
slug. Use only the safe localhost dev-client URL emitted by this Metro process
to attach/reload the exact Komainu package. A target-fenced ADB VIEW intent for
that emitted URL is allowed. Do not invent a URL, use Expo Go/LAN/tunnel/cloud,
or launch another package.

An unexpected network request, real-mode indicator, provider browser, or
source-generation request is a hard failure.

## Dummy Account Smoke

Use targeted ADB UI automation, safe app-scoped screenshots/UI hierarchy, and
the visible Pixel only. Do not read unrelated device data or broad logs.

Classify each path:

1. TempleMate and explicit demo-mode presentation;
2. invalid credential rejection and successful fixture login;
3. account-only navigation with no admin mode/surface;
4. profile name edit;
5. dependent create/edit/delete;
6. registration create/edit, with paid fixture read-only and no payment CTA;
7. certificates/events/services/gallery rendering;
8. zh-TW/English and light/dark preferences with no admin preference;
9. assistance/contact/privacy dummy submissions;
10. reset/sign-out back to deterministic signed-out state.

Record layout, keyboard, scroll, edge-to-edge, touch, copy, and navigation
problems separately as UI-refinement findings. This is smoke validation, not
final visual acceptance.

## Dummy OAuth Smoke

While signed out, exercise one Google and one Apple dummy success journey.
Each must use installed native Crypto for PKCE, remain network-free, return to
the account-only signed-in state, and clear on sign-out.

No provider page/account, Central Auth, Rails endpoint, console, credential,
secret, or real OAuth result may be used. Other deterministic terminal states
remain source-test evidence and need not be exposed through hidden controls.

## Camera And Fixture QR

From an unbound signed-in home state:

1. Open `Scan demo QR`, deny the initial camera prompt once, and prove the
   prompt does not loop; the app must show denied state plus explicit retry.
2. Use only visible Retry, grant camera, and prove rear-facing QR-only camera
   with no microphone/audio prompt.
3. Scan the untrusted QR shown by Planning. Require invalid/untrusted state and
   no binding change.
4. Use `Scan again`, scan the trusted QR shown by Planning, and require exactly
   one consumed result, camera closure, and binding to `竹南鎮聖福宮` from QR.
5. Exercise visible switch-temple confirmation. It must not switch before
   confirmation and must switch to `示範宮廟二號` only after cleanup completes.

The Director may physically point the Pixel at the QR images while Control
observes the app result. Control does not access/record camera media or create a
live tenant link. If physical positioning does not occur in the bounded window,
record `physical_qr_scan_unconfirmed` without simulating success or discarding
other completed evidence.

## No-Repair Findings Report

Return passed paths, reproducible functional defects, actual untested reasons,
and UI-refinement observations. Classify whether each defect appears
JavaScript-only or would require a later native dependency/config build.

Do not change product code, tests, configuration, dependencies, plans, or
versions. Planning owns any later repair/UI plan.

## Cleanup

On every terminal path:

1. stop only the packet-owned Metro process;
2. remove only exact serial mapping `tcp:8081`;
3. remove the exact temporary dependency symlink;
4. delete only packet-created screenshots/UI dumps/QR output;
5. prove no packet Metro process/reverse remains and both worktrees are clean
   with no source/config/artifact/dependency/log residue.

The installed app and accepted camera permission/dummy state may remain. Do not
uninstall, package-manager clear, or alter unrelated device settings.

## Invariants And Exclusions

- `1.0.0 / Android 1 / iOS 1` remains unchanged.
- No build/prebuild/EAS/signing/artifact/AAB/store/OTA/deployment/release/push.
- No real API/OAuth, live QR/trust registry, Rails/Vue/database/provider/
  server/payment/production action, or account/admin expansion.

## Acceptance And Terminal

Accept when Metro attaches in explicit dummy mode, account/OAuth/camera paths
are classified honestly, every observed defect/refinement gap is recorded
without repair, and cleanup passes.

Terminal classifications:

- `dummy_device_and_camera_validation_complete`;
- `dummy_runtime_functional_defect_found`;
- `metro_or_device_attachment_failed`;
- `physical_qr_scan_unconfirmed`;
- `runtime_cleanup_reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

Control integrates only its immutable safe report/packet to canonical main and
sends exactly one terminal package to Planning.

Current classification:
`expo_v1_dummy_device_and_camera_validation_authorized`.

First blocker: none.
