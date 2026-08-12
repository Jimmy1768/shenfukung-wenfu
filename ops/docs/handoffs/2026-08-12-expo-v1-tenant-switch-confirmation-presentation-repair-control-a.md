# Expo V1 Tenant Switch Confirmation Presentation Repair — Control A Packet

Status: immutable before Implementer dispatch

Date: 2026-08-12

## Identity

- Accepted plan: `ops/docs/plans/EXPO_V1_TENANT_SWITCH_CONFIRMATION_PRESENTATION_REPAIR_PLAN.md`
  at `35bc56d8f4dd176d4f4d6259f76f8a06cc1907c1`.
- Control: Wenfu Control A `019fc08d-676b-7ca2-be32-3efe42fa2fca`,
  `gpt-5.6-terra/high`.
- Repository/worktree/branch: `/Users/jimmy1768/Projects/shengfukung-wenfu` /
  `/private/tmp/shengfukung-wenfu-expo-v1-tenant-switch-confirmation-presentation-repair` /
  `codex/expo-v1-tenant-switch-confirmation-presentation-repair`.
- Accepted runtime-report baseline:
  `adb4fea710a7a384edddf4e43ba61033739a976a`.
- Packet identity and attempt:
  `wenfu-control-a-expo-v1-tenant-switch-confirmation-presentation-repair-attempt-1`.

## Scope

- Objective: retain the already-bound temple visibly in every connection
  presentation while a switch awaits visible confirmation, without changing
  tenant-switch authority or cleanup semantics.
- Direct mechanism: `requestSwitch()` correctly retains `binding.tenant` as
  the prior temple and records the candidate separately, but the header, home
  temple card, and connection summary each display a name only when
  `binding.state === 'bound'`. They consequently hide the retained prior tenant
  during `switching` and incorrectly show the unconnected copy.
- Implementer-owned paths only: `mobile/App.js`,
  `mobile/app/tenant/binding.js`, `mobile/__tests__/tenant-binding.test.js`,
  and `mobile/__tests__/ui-refinement.test.js`. The binding module may gain
  only one pure active-presentation selector; all lifecycle/QR/fixture
  semantics remain unchanged.
- Control-owned paths: this immutable packet and final safe receipt under
  `ops/docs/handoffs/` only.
- Required behavior/proof: selector returns the retained prior tenant for
  bound, switching, and prior-tenant-preserving failure states; returns none
  for initial unbound and untrusted initial failure; candidate is never active
  before confirmation; App uses that selector at header, home, and connection
  summary; `clearTenantState()` stays callable only from the visible
  confirmation action; existing cleanup-before-confirm ordering and
  fail-closed confirmation stay intact.
- Required checks: focused tenant-binding/UI regressions, full `yarn test`,
  `yarn lint`, `yarn verify`, `git diff --check`, staged diff check, exact
  owned-path review, and scans for excluded OAuth/dummy-repository/QR/camera/
  configuration/dependency/native/version/build changes and pre-confirmation
  cleanup. A byte-identical temporary `node_modules` symlink is permitted only
  when needed and must be removed before review.
- Explicit exclusions: OAuth, dummy repository, QR/camera, configuration,
  dependencies/lockfile, native, Rails, Vue, version/build, Metro, ADB/device,
  EAS/build, provider, deployment/release/push, secrets, and external action.
- First blocker: none; the confirmed source mechanism is directly repairable
  within the accepted JavaScript/test subset.

## Incident-Correction Placement

- Incident correction: yes; this is a narrow mobile presentation selector and
  regression-proof change, not a state-machine or governance redesign.
- `AGENTS.md` is excluded; no persistent governance change is introduced.

## Repair And Terminal Boundary

- Bounded nonterminal repair within unchanged criteria: no; attempt 1.
- Any observed in-scope conformance defect requires a new Control repair packet;
  Planning receives no intermediate status.
- One immutable terminal goes directly to Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6` only after accepted local integration
  or another truthful terminal disposition.

## Handoff Eligibility And Implementer Dispatch

- Persistent Handoff requested: no. This is one short, pure JavaScript
  presentation/test packet with no continuity requirement; Luna eligibility is
  absent.
- Selected Implementer: `gpt-5.6-terra/medium`. The direct mechanism is
  diagnosed and the bounded selector/consumer/test work has no persistence,
  migration, concurrency, or destructive cleanup; medium is sufficient.
- The Implementer edits only the packet-owned paths, does not stage, commit,
  merge, push, deploy, access secrets/providers, perform external action, or
  broaden scope, and returns evidence directly to this Control.

## Control Review And Closeout

- Control independently verifies selector semantics, all three App consumers,
  confirmation-only cleanup/order, candidate non-presentation, exact diff,
  required checks, staging, and clean states before commit and local main
  integration.
- Next owner after accepted integration: Planning may separately dispatch the
  already-sequenced Control B runtime validation. No runtime/device action
  follows here.
- Authority confirmation: only local JavaScript/test work is authorized; no
  external, provider, secret, deployment, release, or product-runtime action
  is used.
