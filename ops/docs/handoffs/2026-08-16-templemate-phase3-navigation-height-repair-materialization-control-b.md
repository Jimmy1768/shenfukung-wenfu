# Wenfu Control Navigation Height Repair Materialization Packet

## Identity

- Accepted continuation: `ops/docs/plans/TEMPLEMATE_PHASE_3_NAVIGATION_HEIGHT_REPAIR_MATERIALIZATION_CONTINUATION_PLAN.md` at `8f93cc95b4c9b6745507869a1c84a7060ebcb095`; parent plan `ab08b4b2b71ff63df784c3849ba7df37fece925f`.
- Preserved candidate record: `68a8f0ec4710b5ac1a69533385bcc8b4eaa6cc5b` on `codex/templemate-phase3-single-line-navigation-height-repair`.
- Control: Wenfu Control B / `019fe020-e92e-7770-984f-b59acd547ab0`; Planning: `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Continuation attempt: 15. Worktree: `/private/tmp/shengfukung-wenfu-templemate-phase3-single-line-navigation-height-repair`.

## Scope

- Objective: materialize the unchanged locked closure exactly once, complete the required checks, then accept and integrate only the preserved two-path candidate plus Control records if every frozen criterion passes.
- Candidate source scope: `mobile/App.js` and `mobile/__tests__/ui-refinement.test.js` only. Control records are the only other paths.
- Allowed mutation: one project-local `mobile/yarn install --frozen-lockfile` and its packet-local `mobile/node_modules`; only shared locked Yarn cache entries may remain. Node modules must be removed after checks.
- No Implementer: this continuation contains no source implementation absent a concrete completed-tree conformance defect. Control owns one materialization, check review, acceptance, and integration.
- Excluded: dependency/manifest/lock/config/global changes; device/runtime; source expansion; Rails/Vue; native/build/version; provider/production/deployment/release/push/external action.

## Evidence And Terminal Boundary

- Before/after package and lock SHA-256 equality, exact two-path candidate scope, locked Expo Crypto runtime existence, focused/full/lint/verify, parent style/state/static proof, staged/diff/path review, and clean canonical/isolated state are required.
- A changed tracked dependency file, different closure, second install need, or failed product assertion stops acceptance. A completed-tree source defect within unchanged criteria is a Control-owned bounded repair.
- One direct terminal to Planning will report the materialization result, integration status, cleanup, boundaries, and next owner/action.

## Control Review And Closeout

- Before and after the one allowed install, candidate and canonical package/lock SHA-256 values were identical: `fbf7bb994999718194f09d6d0bc18e292fb7525a8dac42d9f7e09a28c6bdf7da` and `36bc809675e8fd2caa5bba321feec0276a514ec573478964d472f388b4a264c6`.
- Exactly one project-local `yarn install --frozen-lockfile` completed; the locked `expo-crypto/build/Crypto.types.js` existed before checks. No manifest, lockfile, script, configuration, or version changed.
- Focused account-surface/UI-refinement tests passed 10/10; full mobile suite passed 58/58; `yarn lint`, `yarn verify`, and `git diff --check` passed.
- The only product diff is the accepted two-path repair: the navigation ScrollView shell has `flexGrow: 0`; its existing non-wrapping content row has `alignItems: 'center'`; the focused presentation test directly asserts both. Header utilities, five-item ordering, one-line scrolling/no truncation, `minHeight: 40`, padding, labels, and screen behavior remain unchanged.
- The packet-created isolated `mobile/node_modules` tree was removed after checks. Shared Yarn cache remains as permitted.
- Acceptance decision: accepted for local integration. Control staged/committed only `mobile/App.js`, `mobile/__tests__/ui-refinement.test.js`, and the preserved/current Control records, then integrates the candidate over the clean continuation-plan canonical main.
