# TempleMate Phase 3 Runtime USB Stay-Awake Continuation Plan

Status: accepted for direct runtime continuation after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`12561523844e5f05444bdce41ffd797cd1ee11bc`

Accepted implementation:
`1e37e3853e9d576f07a01cb6f07cebc83ebd6bc2`

Accepted predecessor evidence:

- `ops/docs/handoffs/2026-08-16-templemate-phase3-runtime-dependency-materialization-control-b.md`
- full mobile tests 57/57, lint and verify passed after exact offline frozen-lockfile materialization;
- exact package/lock files remained byte-identical and the required locked
  `expo-crypto` runtime file was present.

## Changed Prerequisite Evidence

Planning directly observed exact serial `39011FDJH00FQ8` on 2026-08-16 as
Pixel 8 / `shiba`, ADB `device`, awake, with
`com.jimmy1768.komainu.dev/expo.modules.devlauncher.launcher.DevLauncherActivity`
current and focused. TCP 8081 and the exact serial reverse were unowned.

## Objective

Prevent the USB-connected Pixel from sleeping between validation and Metro
attachment, rematerialize the already-proven exact offline dependency tree,
and resume the accepted authenticated-unbound gate review. The temporary
device setting must be reconciled to its exact prior value during cleanup.

## Exact Temporary Stay-Awake Fence

Before dependency work, Control independently verifies the exact target,
awake/focused TempleMate state, installed version `1.0.0`, code `1`, target SDK
36, clean source/staging, accepted ancestry and unowned port/reverse.

Control may then, on exact serial only:

1. read and retain only packet-locally the exact current numeric/null value of
   Android global setting `stay_on_while_plugged_in`;
2. set that exact global setting to USB-only numeric value `2` once;
3. verify the setting reads `2` and the device remains awake; and
4. leave it at `2` only for this packet's dependency checks, Metro attachment
   and Director review pause.

On every failure or final cleanup, restore the exact prior value: write the
prior numeric value when one existed, or delete only the exact global setting
when its prior value was null. Read it back to prove equality with the recorded
prior state. If the exact device disconnects before restoration, stop with
`reconciliation_required`; do not infer cleanup.

No other device setting, power state, keyguard, notification, package or app
data may be changed.

## Exact Dependency And Local Checks

In a fresh isolated worktree, run one project-local
`yarn install --frozen-lockfile --offline` using existing cache only. Prove
`mobile/package.json` and `mobile/yarn.lock` are byte-identical before/after,
the locked `expo-crypto` runtime file exists, then run full `yarn test`,
`yarn lint`, `yarn verify` and `git diff --check`.

No registry fallback, copied dependency tree, global install, manifest/lockfile
change, package/version/source/configuration repair or network dependency
action is authorized. Stop and restore the device setting if any check fails.

## Runtime And Director Review Checkpoint

After all checks pass and the Pixel is still awake/focused:

- start one explicit dummy/development localhost Metro session on port 8081;
- wait for listener, create only exact serial
  `adb reverse tcp:8081 tcp:8081`, and deliver the established local
  `exp+templemate` URL once;
- reach deterministic authenticated-unbound state and verify Header sign-out,
  QR-first setup guidance, one TempleMate in-app scan action, absence of
  ordinary navigation/account screens/fixture-link controls/Contact Temple,
  CameraView Cancel returning to the same gate, and Back unable to expose
  hidden account content.

Return exactly
`director_action_required: phase3_updated_unbound_gate_review`
only when the updated gate is visibly ready. Leave packet Metro, exact reverse
and temporary USB-only stay-awake setting active while waiting for Director
review. Do not scan trusted temple QR, bind a temple or advance further without
a later Planning direction.

## Cleanup And Exclusions

On failure or later explicit completion, restore the exact prior stay-awake
setting first when connected, then remove only packet Metro, exact reverse,
packet-local `mobile/node_modules`, logs and named package-scoped evidence.
Preserve the installed client and unrelated device state.

No product/source/test/config/manifest/lockfile/native edit, build/install,
version increment, real QR/API/OAuth/provider/email, payment/admin,
production, deployment, release, push, secret or unrelated external action is
authorized.

Current blocker: none.
