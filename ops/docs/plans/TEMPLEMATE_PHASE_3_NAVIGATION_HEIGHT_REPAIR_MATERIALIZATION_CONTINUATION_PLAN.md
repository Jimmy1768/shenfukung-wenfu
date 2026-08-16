# TempleMate Phase 3 Navigation Height Repair Materialization Continuation Plan

Status: accepted for direct continuation dispatch after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Canonical plan/base: `ab08b4b2b71ff63df784c3849ba7df37fece925f`

Parent plan:
`ops/docs/plans/TEMPLEMATE_PHASE_3_SINGLE_LINE_NAVIGATION_HEIGHT_REPAIR_PLAN.md`

Preserved candidate:

- branch/worktree: `codex/templemate-phase3-single-line-navigation-height-repair` /
  `/private/tmp/shengfukung-wenfu-templemate-phase3-single-line-navigation-height-repair`
- Control record commit: `68a8f0ec4710b5ac1a69533385bcc8b4eaa6cc5b`
- unstaged source paths: `mobile/App.js` and
  `mobile/__tests__/ui-refinement.test.js`

## Decision And Objective

The Director's active request to repair the screenshot-confirmed navigation
height regression authorizes one exact project-local materialization of the
unchanged canonical mobile lock closure. Preserve the existing candidate,
complete the mandatory full checks, and integrate only if every parent
criterion passes.

The prior stop is an environment-materialization gap: focused tests 10/10,
lint, verify, source review, and diff check passed; the full suite failed only
because the fresh worktree lacked the locked Expo Crypto runtime file.

## Exact Materialization Boundary

- Prove `mobile/package.json` and `mobile/yarn.lock` byte-identical to
  canonical `ab08b4b` before and after materialization.
- Run at most one project-local `yarn install --frozen-lockfile`. Normal
  registry retrieval is authorized only for missing locked archives.
- Do not add, update, substitute, or rewrite a dependency, manifest, lockfile,
  script, package-manager configuration, or global installation.
- Verify `mobile/node_modules/expo-crypto/build/Crypto.types.js` exists before
  running checks.
- If materialization changes either tracked dependency file, needs a second
  install, or resolves a different closure, stop without staging/integration.
- Remove only packet-created isolated `mobile/node_modules` after checks;
  shared Yarn cache may remain.

## Required Acceptance Evidence

Control must rerun and review:

1. focused account-surface/UI-refinement tests;
2. full mobile tests with no module-load or product failure;
3. mobile lint and verify;
4. the exact `flexGrow: 0` navigation-shell and cross-axis centered row proof;
5. retained Header, five-item one-line menu, no-truncation, minimum touch
   height/padding, and unchanged screen behavior;
6. package/lock byte identity, exact two-path source scope, diff and staged
   diff checks; and
7. clean/staging-empty final canonical and isolated states with all identity,
   version, SDK/API, dependency, config, and native values unchanged.

If a concrete candidate conformance failure appears under the complete tree,
Control owns one bounded repair under unchanged parent criteria. Otherwise,
stage/commit only the two source/test paths plus Control records, locally
integrate over current clean canonical main while preserving continuation-plan
ancestry, and return one immutable terminal packet directly to Planning.

## Explicit Exclusions

No new UI decision, source-path expansion, dependency/manifest/lockfile/config/
native/version/build change, global install, cache cleanup, Metro/ADB/device,
rebuild/EAS/install, Rails/Vue, provider/secret, production/deployment/release/
push, or external mutation.

Current blocker: none after this exact materialization authority.
