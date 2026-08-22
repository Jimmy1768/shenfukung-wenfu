# TempleMate Phase 3 Header Navigation Dependency Materialization Continuation Plan

Status: accepted for direct continuation dispatch after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Canonical plan/base: `98ee9180ba488870281f96e5f035e89ff0c110a0`

Parent plan:
TEMPLEMATE_PHASE_3_HEADER_UTILITY_AND_SINGLE_LINE_NAVIGATION_PLAN.md (deleted
2026-08-22 in the plans/archive cleanup; recoverable via `git log --grep`)

Stopped attempt evidence:
`ops/docs/handoffs/2026-08-16-templemate-phase3-header-utility-single-line-navigation-control-b.md`

Preserved isolated candidate:

- branch: `codex/templemate-phase3-header-single-line-nav`
- Control record commit: `ba35e1acb5954c0a3257422b53609e4dc851d7eb`
- unstaged candidate paths: `mobile/App.js`,
  `mobile/app/account/screen_model.js`,
  `mobile/__tests__/account-surface.test.js`, and
  `mobile/__tests__/ui-refinement.test.js`

## Continuation Decision

The Director's accepted instruction to proceed with the navigation patch
authorizes one bounded project-local materialization of the exact canonical
locked mobile dependency closure so the mandatory full mobile suite can assess
the preserved candidate. This continuation changes no accepted product
criteria and authorizes no dependency version, manifest, lockfile, or source
substitution.

The prior result is an environment-materialization stop, not an accepted
source defect. Preserve and evaluate the existing candidate before considering
any source repair.

## Objective

Materialize the exact dependency tree required by the unchanged
`mobile/package.json` and `mobile/yarn.lock`, run the parent plan's complete
checks against the preserved candidate, and accept/integrate it only if all
parent criteria pass.

## Authorized Materialization Boundary

- Before materialization, prove `mobile/package.json` and `mobile/yarn.lock`
  are byte-identical to canonical `98ee9180` and that the only candidate source
  paths are the four recorded mobile paths plus Control records.
- Perform at most one normal project-local Yarn install using the unchanged
  frozen lockfile. Normal registry retrieval is authorized only for archives
  missing from the local cache.
- The install must use frozen-lockfile behavior and must not add, update,
  resolve around, or rewrite any dependency, manifest, lockfile, script,
  package-manager setting, or global installation.
- Verify the locked `expo-crypto/build/Crypto.types.js` runtime file and the
  exact package versions needed by the existing suite are present before
  running checks.
- If the install changes `mobile/package.json` or `mobile/yarn.lock`, resolves
  a different closure, needs a second install, or fails ambiguously, stop and
  report without staging or integrating the candidate.
- Remove only the packet-created isolated-worktree `mobile/node_modules` after
  checks and before final staging/commit. Ordinary Yarn cache entries may
  remain; do not clean shared caches.

## Required Checks And Acceptance

Control must rerun and independently review:

1. the focused account-surface and UI-refinement tests;
2. the full mobile test suite, with no module-load or product failure;
3. mobile lint and verify;
4. the parent plan's exact five-business-destination, bound Header Settings +
   Sign out, unbound Sign-out-only, non-wrapping/no-truncation, Settings-flow,
   and unchanged-screen-content evidence;
5. pre/post byte identity for `mobile/package.json` and `mobile/yarn.lock`;
6. exact changed-path review, `git diff --check`, staged diff check, and clean
   final canonical/isolated worktrees with empty staging; and
7. unchanged TempleMate/Komainu identifiers, Expo `1.0.0`, Android code `1`,
   iOS build `1`, SDK/API 36, dependency manifests, lockfile, and native
   configuration.

If a concrete candidate conformance defect appears under the now-complete
dependency tree, it is a Control-owned bounded repair under the unchanged
parent criteria. No Planning-facing intermediate packet is required.

On full acceptance, Control may stage and commit only the four parent-plan
mobile source/test paths plus its immutable Control records, locally integrate
the accepted result over the current clean canonical main while preserving the
continuation plan ancestry, and return one immutable terminal packet directly
to Planning.

## Explicit Exclusions

No product-criteria change, navigation redesign, new dependency, manifest or
lockfile edit, global install, cache cleanup, Metro/ADB/device/runtime action,
native build/rebuild/EAS/install, version/build increment, Rails/Vue,
adapter/repository/tenant/OAuth/camera/QR/registration/payment behavior,
provider/secret, production/deployment/release/push, or external mutation.

Current blocker: none after this exact materialization authority.
