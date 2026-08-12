# Expo V1 Tenant Switch Confirmation Presentation Repair Plan

Status: accepted for direct implementation dispatch to Control A after commit

Created: 2026-08-12

Owner: Wenfu Planning

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`adb4fea710a7a384edddf4e43ba61033739a976a`

Runtime evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-dummy-oauth-and-temple-qr-runtime-validation-control-b.md`

## Objective

Repair the observed TempleMate tenant-switch confirmation presentation so the
currently bound temple remains visibly connected after `切換宮廟` is selected
and until `確認並切換` succeeds. Add focused state/presentation regression proof
without changing cleanup, candidate selection, QR trust, or switch semantics.

## Confirmed Mechanism

The Pixel run proved trusted QR binding to `竹南鎮聖福宮`. Selecting visible
`切換宮廟` then displayed `尚未連結` in the header and temple card before the
visible confirmation action was pressed.

Canonical source narrows the mechanism:

- `requestSwitch()` returns state `switching` while retaining the prior
  `binding.tenant` and placing the next tenant in `binding.candidate`;
- tests already prove the prior tenant object remains present;
- `Header` and the home temple card render a tenant only when
  `binding.state === 'bound'`, so the retained prior tenant is hidden during
  `switching` and shown as `尚未連結`;
- cleanup and `confirmSwitch()` are invoked only from the confirmation button.

Therefore the observed defect is a JavaScript presentation-state mismatch, not
evidence that persisted/scoped tenant state was cleared before confirmation.
The repair must preserve that distinction and must not redesign the state
machine.

## Owned Paths

Control A may authorize one ephemeral Implementer to edit only:

- `mobile/App.js`;
- `mobile/app/tenant/binding.js` only if a small pure presentation selector is
  used as the single authority;
- `mobile/__tests__/tenant-binding.test.js`;
- one existing focused UI test only if necessary to prove `App.js` consumes the
  selector consistently.

Control-owned immutable packet/report paths under `ops/docs/handoffs/` are also
allowed. No other product, dummy repository, OAuth, QR/camera, configuration,
dependency, lockfile, native, Rails, Vue, version, or Planning path is owned.

## Required Implementation

1. Keep the prior bound tenant visibly connected in both the header and home
   temple card while `binding.state === 'switching'` and
   `binding.tenant` remains present.
2. Continue showing the switch explanation and confirmation action while the
   prior tenant remains visible.
3. Do not display the candidate temple as connected before confirmation.
4. Do not clear OAuth/session/cache/pending or call `clearTenantState()` before
   the existing visible confirmation action.
5. On successful confirmation, preserve the existing ordering: clear the prior
   tenant-scoped state, verify the cleared tenant identity, then bind the
   candidate.
6. Preserve initial unbound, invalid/untrusted QR failure, trusted binding,
   failed-switch-with-prior-tenant, and confirmation-required failure states.

Prefer one small pure presentation selector derived from the retained
`binding.tenant` over duplicating state-condition logic in multiple JSX paths.
Do not refactor navigation, copy, layout, QR parsing, or tenant persistence.

## Focused Regression Proof

Tests must prove:

- `requestSwitch(bound, candidate)` retains the prior tenant and candidate
  separately;
- the presentation selector returns the prior tenant for `bound`, `switching`,
  and a failed switch that retains a prior tenant;
- the selector returns no tenant for initial unbound and an untrusted initial
  binding failure;
- the candidate is never presented as active before confirmation;
- `confirmSwitch()` without prior cleanup still fails closed;
- accepted cleanup plus confirmation presents/binds `示範宮廟二號`;
- `App.js` uses the same selector for the header, home temple card, and any
  retained connection-summary path rather than `state === 'bound'` checks that
  recreate the defect;
- cleanup remains callable only from the confirmation action.

## Checks

Control independently runs:

- focused tenant-binding and UI regression tests;
- full `yarn test`;
- `yarn lint`;
- `yarn verify`;
- `git diff --check`, staged diff check, and exact owned-path review;
- focused scans proving no OAuth/dummy repository/QR/camera/config/dependency/
  version/build/native change and no new pre-confirmation cleanup call.

Use only an already available byte-identical dependency tree through the
accepted temporary-symlink method if the isolated worktree lacks
`node_modules`; remove it before acceptance. Do not install or copy
dependencies.

Expo Doctor, export, prebuild, Gradle, EAS, and physical-device evidence are
not acceptance criteria for this JavaScript presentation repair. Renewed device
proof is separately sequenced.

## Acceptance Criteria

1. Before confirmation, `竹南鎮聖福宮` remains visibly connected while the
   switch prompt is displayed.
2. `示範宮廟二號` is not presented as connected before confirmation.
3. Cleanup and candidate binding remain confirmation-only and in the accepted
   order.
4. Focused tests reproduce the rejected presentation and prove the corrected
   state across header/card/summary consumers.
5. Full tests, lint, identity/version guards, and diff checks pass.
6. No QR, OAuth, repository, native, dependency, config, or version/build
   behavior changes.
7. Canonical and isolated Git states are clean with staging empty after Control
   integration.

## Explicit Exclusions

- Metro, ADB, Pixel/device interaction, screenshots, camera, QR, OAuth runtime,
  or physical validation;
- changing `requestSwitch()` candidate semantics, QR trust parsing, dummy data,
  tenant cleanup payload, or `confirmSwitch()` authority;
- dependency/manifest/lockfile/config/version/build/native changes;
- EAS/local build, prebuild, APK/AAB, signing, provider, Rails, deployment,
  release, OTA, store, payment, production, or push;
- CameraView warning repair, UI refinement, dependent/registration work, or
  unrelated cleanup.

## Sequencing

After accepted integration, Planning will separately dispatch Control B to
reuse the installed development client and exact USB Metro method. That runtime
packet will use deterministic already-accepted fixture state to prove the prior
temple remains visible before confirmation, then press confirm and prove the
visible switch to `示範宮廟二號` plus post-confirm cleanup. No native rebuild is
expected.

Current classification:
`expo_v1_tenant_switch_confirmation_presentation_repair_authorized`.

First blocker: none.
