# Wenfu Control TempleMate Single-Line Navigation Height Repair Packet

## Identity

- Accepted plan: `ops/docs/plans/TEMPLEMATE_PHASE_3_SINGLE_LINE_NAVIGATION_HEIGHT_REPAIR_PLAN.md` at `ab08b4b2b71ff63df784c3849ba7df37fece925f`; accepted baseline `05d63bc3b6460eb0e62f96779950a936cad2cb74`; parent navigation source `1fdf5911ce8217587e0489d4c6a571a5e9dd2eb8`.
- Control: Wenfu Control B / `019fe020-e92e-7770-984f-b59acd547ab0`; target Planning: `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Worktree/branch/base: `/private/tmp/shengfukung-wenfu-templemate-phase3-single-line-navigation-height-repair`, `codex/templemate-phase3-single-line-navigation-height-repair`, `ab08b4b2b71ff63df784c3849ba7df37fece925f`.
- Immutable packet identity: `2026-08-16-templemate-phase3-single-line-navigation-height-repair-control-b`; attempt 14.

## Scope

- Objective: apply only the direct React Native style/test repair that prevents the horizontal business-navigation ScrollView from vertically growing and centers its row children on the cross axis.
- Editable paths: `mobile/App.js`, `mobile/__tests__/ui-refinement.test.js`, and this Control record only.
- Required evidence: static shell/content-row compact-height proof; retained Header/bound-unbound/five-item/non-wrap/no-truncation/touch-height proof; focused/full tests, lint, verify, identity/config/lock scans, diff/path/staging review.
- Excluded: Header/content/copy/state/adapters/tenant/OAuth/camera/QR/registration/payment changes; dependencies/lockfile/config/native/version/build; Metro/ADB/device/runtime; Rails/Vue; provider/production/deployment/release/push/external actions.

## Dispatch And Repair Boundary

- One ephemeral Implementer: `gpt-5.6-terra` / medium, selected as the lowest sufficient allocation for a two-file presentational source/test correction. It edits only owned paths, runs source checks, and may not stage, commit, merge, push, access external systems, or run runtime/device actions.
- Control independently reviews conformance and accepts/integrates only the exact bounded outcome.
- This is a direct incident correction in application presentation, not a governance change; `AGENTS.md` and planning records are excluded. A failed required check within the unchanged criteria creates a new Control repair attempt, not Planning traffic.

## Control Review And Closeout

- Candidate diff is exactly the two authorized source/test paths: `mobile/App.js` adds `flexGrow: 0` to the horizontal navigation shell and `alignItems: 'center'` to its existing non-wrapping content row; `mobile/__tests__/ui-refinement.test.js` asserts both style contracts. No Header, tab order, label, touch-height, state, dependency, config, or identity path changed.
- Static proof retains exactly five `accountMenu()` destinations, horizontal ScrollView tablist, `flexWrap: 'nowrap'`, absence of destination-label truncation, bound Header Settings then Sign out, and unbound Sign-out-only behavior.
- `git diff --check` passed. Focused account-surface/UI-refinement tests passed 10/10. `yarn lint` and `yarn verify` passed.
- Required full `yarn test` did not pass solely because this fresh worktree has no `mobile/node_modules` and `expo-oauth-runtime.test.js` cannot read the locked `expo-crypto/build/Crypto.types.js`. The remaining tests passed (57/58); no product assertion failed. The plan excludes dependency materialization, symlinking, and any lockfile/manifest action, so Control did not materialize or substitute the locked closure.
- Candidate remains unstaged/uncommitted in the isolated worktree with these two source/test modifications; this Control record is the only additional path. Canonical main is unchanged. No runtime/device/external action occurred.

## Terminal Disposition

- Classification: `required_locked_dependency_materialization_not_authorized`.
- Continuation disposition: `director_decision_or_authority`.
- Next owner/action: Planning/Director must authorize one bounded exact locked dependency materialization (or a byte-identical temporary materialization rule) to run the required full suite before the preserved two-path candidate can be accepted or integrated.
