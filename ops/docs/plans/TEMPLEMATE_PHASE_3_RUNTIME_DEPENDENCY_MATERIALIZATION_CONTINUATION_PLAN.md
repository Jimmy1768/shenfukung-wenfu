# TempleMate Phase 3 Runtime Dependency Materialization Continuation Plan

Status: accepted for direct continuation after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`bd565b985dee40c0724f01de38cbb4101cc04ac2`

Accepted implementation:
`1e37e3853e9d576f07a01cb6f07cebc83ebd6bc2`

Parent runtime plan:
`ops/docs/plans/TEMPLEMATE_PHASE_3_TENANT_GATE_RUNTIME_AFTER_WAKE_PLAN.md`

Failed entry report:
`ops/docs/handoffs/2026-08-16-templemate-phase3-tenant-gate-runtime-after-wake-control-b.md`

## Objective

Materialize the exact locked mobile dependency closure locally without network
or manifest/lockfile mutation, rerun the unchanged runtime entry checks, and—
only if they pass—resume the accepted authenticated-unbound tenant-gate review
on the already installed Pixel development client.

## Dependency Materialization Authority

In Control's fresh isolated worktree, Control may run exactly one project-local
`yarn install --frozen-lockfile --offline` for `mobile/` using only the
existing Yarn cache. Before and after the command it must prove byte identity
of `mobile/package.json` and `mobile/yarn.lock` to canonical baseline and prove
that neither file changed.

The materialized tree must contain the locked `expo-crypto` runtime file
required by the existing OAuth test and resolve the project-local Expo/test
toolchain. No registry request, online fallback, global install, package
addition, version change, lockfile repair, copied dependency tree, or source
configuration change is authorized. If the exact offline closure is
unavailable, stop before Pixel/Metro action and report that first blocker.

## Required Local Checks

After successful exact materialization, run:

- full `yarn test`;
- `yarn lint`;
- `yarn verify`;
- package/lock byte-identity and source cleanliness checks; and
- `git diff --check`.

An environment/setup failure may be diagnosed within this packet, but no
source or dependency repair is authorized. All checks must pass before any
device action.

## Runtime Continuation

Then apply the unchanged parent runtime authority:

- reverify exact awake/unlocked Pixel 8 serial `39011FDJH00FQ8`, installed
  `com.jimmy1768.komainu.dev` version `1.0.0`, code `1`, target SDK 36 and
  visible TempleMate package/dev-launcher surface;
- confirm TCP 8081 and exact serial reverse are unowned;
- start explicit dummy/development localhost Metro on 8081;
- wait for listener, create only the exact serial reverse, and deliver the
  established local `exp+templemate` URL once;
- reach deterministic authenticated-unbound state and verify the parent
  tenant-gate matrix.

Return exactly
`director_action_required: phase3_updated_unbound_gate_review`
only when the updated unbound gate is visibly ready. Leave packet Metro and
exact reverse running and wait. Never ask the Director to scan a Metro QR or
enter app/device input. Do not scan trusted temple QR or advance further
without later Planning direction.

## Cleanup And Exclusions

On failure or later explicit completion, remove only packet Metro, exact
reverse, packet-local `mobile/node_modules`, caches created solely by the
packet, logs, and named package-scoped evidence. Preserve the installed client
and unrelated device state.

No product/source/test/config/manifest/lockfile/native edit, build/install,
version increment, real QR/API/OAuth/provider/email, payment/admin,
production, deployment, release, push, secret or external action is
authorized.

Current blocker: none before the exact offline frozen-lockfile attempt.
