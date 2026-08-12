# Expo V1 Tenant Switch Confirmation Runtime Validation Plan

Status: accepted for direct runtime dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Director authority: continuing authorization to finish the installed
development-client confirmation/switch validation

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted source baseline:
`874cad0a2712cf1f596a59165cb7efcad82dae92`

Accepted repair evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-tenant-switch-confirmation-presentation-repair-control-a.md`

Accepted QR/runtime evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-dummy-oauth-and-temple-qr-runtime-validation-control-b.md`

## Objective

Reuse the installed TempleMate development client to prove only the repaired
tenant-switch confirmation flow: the prior temple remains visibly connected
before confirmation, the candidate remains inactive, and confirmation then
clears prior tenant-scoped dummy state and visibly switches to
`示範宮廟二號`.

Google/Apple dummy success and both physical QR scans are already accepted.
This packet does not repeat them and requires no Director physical action.

## Entry Gate

Before runtime setup, Control independently verifies:

- canonical source contains accepted commit `874cad0` or retains its selector
  and tests unchanged;
- `activePresentationTenant(binding)` is used by all three App connection
  summaries;
- `requestSwitch()` retains prior tenant and candidate separately;
- `clearTenantState()` occurs exactly once and only inside the visible
  confirmation action;
- focused tenant-binding/UI tests, full `yarn test` with 46 tests, `yarn lint`,
  and `yarn verify` pass;
- exact Pixel serial `39011FDJH00FQ8`, installed package
  `com.jimmy1768.komainu.dev`, launcher, `1.0.0`/code `1`/target SDK 36, TCP
  8081, reverse-map, dependency-equivalence, and temporary-symlink preconditions
  pass.

Use only the exact accepted USB attachment:

    adb -s 39011FDJH00FQ8 reverse tcp:8081 tcp:8081
    TEMPLEMATE_CLIENT_MODE=dummy BUILD_MODE=development npx expo start --dev-client --localhost --port 8081

Open only Metro's emitted local `exp+templemate` URL through target-fenced ADB.
Never ask for or use a Metro/Expo QR scan. The standard Back action may dismiss
the expected developer overlay after bundle load.

## Deterministic Starting State

Establish the smallest deterministic dummy state without repeating camera or
OAuth validation:

1. Use the accepted fixture email credentials to reach the account-only home.
2. Use the accepted dummy reset if needed to obtain `尚未連結`.
3. Use the already-present, prefilled trusted fixture connection link and the
   visible `使用連結連結` action to bind `竹南鎮聖福宮`.

This link action is allowed only to isolate the switch repair. It is not new QR
evidence and does not replace or weaken the already accepted physical untrusted
and trusted QR validation. Do not type/change the link, invoke CameraView, or
scan any QR.

## Required Runtime Sequence

1. Confirm header and temple card visibly show `竹南鎮聖福宮`.
2. Activate only visible `切換宮廟`.
3. Before confirmation, require all of the following simultaneously:
   - header still shows `已連結 · 竹南鎮聖福宮`;
   - temple card still shows `竹南鎮聖福宮`;
   - switch explanation and visible `確認並切換` action are present;
   - `示範宮廟二號` is not presented as connected;
   - no unbound/disconnected presentation and no visible prior-state cleanup.
4. Activate visible `確認並切換` exactly once.
5. Require the header and temple card to visibly show `示範宮廟二號`, with
   the prior temple no longer active and no failure state.
6. Correlate that visible outcome with the unchanged source/test evidence that
   prior tenant-scoped session/cache/pending cleanup occurs before
   `confirmSwitch()` binds the candidate. Do not inspect storage broadly or
   invent a runtime persistence claim unavailable from the dummy UI.

If any required state fails, capture only the exact visible outcome and minimal
package-scoped evidence, do not retry repeatedly or repair source, then clean up
and return.

## Evidence And Cleanup

Control may use one ephemeral Implementer only for immutable report preparation
and static/diff checks. Control owns exact Metro, target-fenced ADB, device/UI,
acceptance, cleanup, and integration.

The result matrix must explicitly record:

- deterministic bound starting state;
- prior tenant visibility before confirmation in header and card;
- candidate not active before confirmation;
- confirmation action performed once;
- visible final switch to `示範宮廟二號`;
- source-correlated confirmation-only cleanup ordering;
- exact runtime and repository cleanup.

At terminal, stop only the packet Metro process; remove only exact serial
`tcp:8081` reverse, temporary dependency symlink, and packet-created ephemeral
UI evidence. Preserve installed app and camera permission. Prove no listener,
reverse, symlink, evidence, Git, or staging residue.

Control integrates only its immutable safe report/packet and sends one terminal
package directly to Planning.

## Exclusions And Invariants

- no physical QR callback, CameraView, Expo launcher scanner, Pixel native
  scanner, payload injection, or typed/changed connection link;
- no Google/Apple OAuth repeat, real API/OAuth, provider/browser/account,
  Rails/server, secret, or broad log;
- no source/config/test/dependency/lockfile/version/native edit;
- no rebuild, EAS, prebuild, APK/AAB, signing, install/uninstall, package
  mutation, deployment, production, release, OTA, store, payment, or push;
- no version/build increment: `1.0.0 / Android 1 / iOS 1`;
- no CameraView warning, dependent/registration, UI refinement, or unrelated
  device work.

## Terminal Classifications

- `tenant_switch_confirmation_runtime_validation_complete`;
- `tenant_switch_confirmation_runtime_defect_found`;
- `metro_or_device_attachment_failed`;
- `runtime_cleanup_reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

Current classification:
`expo_v1_tenant_switch_confirmation_runtime_validation_authorized`.

First blocker: none.
