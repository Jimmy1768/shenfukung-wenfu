# Wenfu Control Header Navigation Dependency Materialization Packet

## Identity

- Accepted continuation plan: `ops/docs/plans/TEMPLEMATE_PHASE_3_HEADER_NAVIGATION_DEPENDENCY_MATERIALIZATION_CONTINUATION_PLAN.md` at `00b09feaf1f06ad20ba310bbd510c2802bc64dc4`; parent plan at `98ee9180ba488870281f96e5f035e89ff0c110a0`.
- Preserved candidate record/base: `ba35e1acb5954c0a3257422b53609e4dc851d7eb` on `codex/templemate-phase3-header-single-line-nav`.
- Control authority: Wenfu Control B / `019fe020-e92e-7770-984f-b59acd547ab0`; target Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Worktree: `/private/tmp/shengfukung-wenfu-templemate-phase3-header-single-line-nav`; continuation attempt 11.

## Scope

- Objective: materialize exactly the canonical locked dependency closure once and complete the mandatory parent checks against the preserved four-path candidate.
- Candidate paths: `mobile/App.js`, `mobile/app/account/screen_model.js`, `mobile/__tests__/account-surface.test.js`, and `mobile/__tests__/ui-refinement.test.js` only.
- Exact permitted local mutation: one project-local `mobile/yarn install --frozen-lockfile` plus packet-local `mobile/node_modules`; public locked Yarn cache entries may remain. Node modules must be removed after checks.
- Excluded: source repair unless a concrete unchanged-parent conformance defect is observed; all dependency/manifest/lockfile/script/global configuration changes; runtime/device, Metro, Rails/Vue, build, provider, production/deployment/release/push/external action.
- No Implementer: this continuation contains one authorized environment materialization and Control-owned verification only; the already-preserved source candidate is not reopened absent a concrete check failure.

## Acceptance And Terminal Boundary

- Before/after: prove candidate paths and byte-identical `mobile/package.json`/`mobile/yarn.lock`; locked `expo-crypto` runtime must exist.
- Required checks: focused tests; full `yarn test`; lint; verify; parent menu/header/non-wrap/unbound/settings-flow static evidence; diff/path/staging review.
- On full acceptance: stage/commit only the four candidate paths and Control records, then integrate over clean current canonical main while retaining continuation-plan ancestry.
- On any failed/ambiguous single install or required check: stop without candidate staging/integration and report the exact evidence.

## Control Review

- Pre/post package and lock SHA-256 values exactly matched canonical. Before the one authorized install, the only candidate diff was the recorded four mobile paths; locked `expo-crypto/build/Crypto.types.js` was present after materialization.
- Required checks passed: focused account-surface/UI-refinement tests 10/10; full `yarn test` 58/58; `yarn lint`; `yarn verify`; and `git diff --check`.
- Parent conformance evidence: `accountMenu()` is exactly `home`, `profile`, `dependents`, `registrations`, `discover`; Settings remains a valid account screen; the bound Header uses the existing `navigate('settings')` feedback path before adjacent Sign out; the unbound gate Header passes no Settings action; Navigation is a horizontal non-wrapping tablist with no `numberOfLines` truncation on destination labels. No copy, adapter, tenant, OAuth, camera/QR, payment, configuration, dependency, lockfile, or native path changed.
- Cleanup: the packet-created isolated `mobile/node_modules` is absent. The ordinary public locked Yarn cache is retained as authorized.
- Acceptance decision: accepted for local integration, subject to clean canonical preflight and exact four-source-path plus Control-record staging review.
