# TempleMate Phase 3 Online Locked Materialization Runtime Plan

Status: accepted for direct execution after commit

Accepted: 2026-08-16

Director authorization: one online frozen-lockfile materialization of the
existing exact mobile dependency closure, followed by the accepted runtime
review.

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`15881da535b7bc69746febe03d62510f59ccb5ba`

Accepted implementation:
`1e37e3853e9d576f07a01cb6f07cebc83ebd6bc2`

## Changed Prerequisite Evidence

Planning directly observed exact serial `39011FDJH00FQ8` as connected Pixel 8
/ `shiba`, ADB `device`, awake, focused on TempleMate DevLauncher, with prior
`stay_on_while_plugged_in=0`. TCP 8081 and exact reverse are unowned.

## Objective

Temporarily keep the Pixel awake, fetch only the dependency versions already
fixed by the canonical lockfile, run the unchanged mobile checks, and attach
the updated dummy bundle for the authenticated-unbound Phase 3 review.

## Target And Temporary Stay-Awake Fence

Control independently verifies clean canonical/isolated state, accepted
ancestry, exact target/package/version `1.0.0`/code `1`/target SDK 36, awake
and visible TempleMate state, prior stay-awake value, and unowned port/reverse.

Record the prior exact numeric/null `stay_on_while_plugged_in` value locally,
set only that exact global setting to USB-only value `2` once, and verify it.
Keep it at `2` through materialization, checks, Metro attachment and Director
review pause.

On failure/final cleanup, restore the exact prior numeric value or delete only
the exact setting when prior state was null, then read back equality. A device
disconnect before restoration is `reconciliation_required`; do not infer
cleanup.

## Authorized Online Dependency Materialization

In a fresh isolated worktree, Control may run exactly one project-local
`yarn install --frozen-lockfile` for `mobile/` with normal registry access.
The command may download only the closure fixed by canonical
`mobile/yarn.lock` and may populate ordinary Yarn cache plus packet-local
`mobile/node_modules`.

Before and after, prove `mobile/package.json` and `mobile/yarn.lock` are
byte-identical to canonical and unchanged. Prove the locked
`expo@54.0.36`/`expo-crypto` runtime closure and project-local toolchain are
present. No second install, manifest/lockfile repair, package addition, version
change, global install, alternate registry/configuration change or source edit
is authorized. Stop and restore device state if the one command fails.

## Required Checks

Run full `yarn test`, `yarn lint`, `yarn verify`, package/lock identity checks,
source cleanliness and `git diff --check`. All must pass before runtime.

## Runtime Review

After reconfirming the Pixel remains awake/focused and the temporary setting
is `2`:

- start one explicit dummy/development localhost Metro on port 8081;
- wait for listener, create only exact serial
  `adb reverse tcp:8081 tcp:8081`, and deliver the established local
  `exp+templemate` URL once;
- reach deterministic authenticated-unbound state;
- verify Header sign-out, QR-first setup guidance, one TempleMate in-app scan
  action, absence of ordinary navigation/account screens/fixture-link
  controls/Contact Temple, CameraView Cancel returning to the same gate, and
  Back unable to expose hidden account content.

Return exactly
`director_action_required: phase3_updated_unbound_gate_review`
only when the updated screen is visibly ready. Leave Metro, exact reverse and
temporary USB stay-awake active while awaiting Director review. Do not ask the
Director to scan a Metro QR or enter input. Do not scan trusted temple QR,
bind a tenant or advance further without later Planning direction.

## Cleanup And Exclusions

On failure/later completion, restore the stay-awake setting first when
connected, then remove packet Metro, exact reverse, packet-local
`mobile/node_modules`, logs and named evidence. Ordinary downloaded Yarn cache
entries may remain; they contain public locked packages and avoid repeating
the authorized download.

No product/source/test/config/manifest/lockfile/native edit, build/install,
version increment, real QR/API/OAuth/provider/email, payment/admin,
production, deployment, release, push, secret or unrelated external action is
authorized.

Current blocker: none.
