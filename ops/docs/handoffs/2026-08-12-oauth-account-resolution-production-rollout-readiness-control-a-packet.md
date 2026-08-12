# Control implementation packet — OAuth account-resolution production rollout readiness

## Authority and exact inputs

- Planning: Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Accepted plan:
  `ops/docs/plans/OAUTH_ACCOUNT_RESOLUTION_PRODUCTION_ROLLOUT_READINESS_PLAN.md`.
- Exact plan base: `45f50da360ce1af8262b7708f293a56f5aec7798`.
- Accepted local OAuth runtime source:
  `82b0e52e0005ee705b5ce85964a773bc7e0f7809`.
- Configured release references observed locally:
  `release/current` and `origin/release/current` at
  `99a0a6929c5cb0eace21d5fa074cdab3950b269c`.
- Execution branch/worktree:
  `codex/oauth-account-resolution-production-rollout-readiness` at
  `/private/tmp/shengfukung-wenfu-oauth-account-resolution-production-rollout-readiness`.

## Bounded outcome

Prepare the required immutable, report-only readiness record at
`ops/docs/handoffs/2026-08-12-oauth-account-resolution-production-rollout-readiness-control-a.md`.
It must compare the exact accepted-main candidate with a minimal complete,
disposable release-baseline candidate, recommend only an exact future release
strategy/commit boundary, and define the later protected rollout packet. It
must not promote, deploy, inspect, or mutate any external target.

## Owned paths and disposable scope

The sole persistent implementation path is the required readiness report above.
The Implementer may create and remove disposable local worktrees, branches,
test databases, migration rehearsal databases, and generated files strictly
for the source/rehearsal checks. It must remove all of that residue before
returning. It may not modify product source, config, dependency manifests,
release refs, or any path outside the report.

## Required report evidence

1. State the exact configured target as documented only; distinguish all live
   host/schema/service/config/provider state as unknown because it is not
   observed under this packet.
2. Inventory Candidate A from `99a0a692` through `82b0e52`: Rails/runtime,
   migrations, routes/session/auth, dependencies, environment/config,
   worker/deployment, Vue/public asset, and unrelated release scope.
3. In a disposable candidate only, test Candidate B's complete dependency
   closure from the release baseline. Name every required commit/path/conflict
   and never assume `dcc258b` alone is sufficient. Recommend the smallest
   complete future release boundary, or classify a factual dependency gap.
4. Run the accepted local OAuth/account/admin/native regressions, retained
   password/privacy/closure/tenant/dual-role evidence, and full Rails suite or
   exact documented limitation/substitute. Rehearse the additive migration
   against a disposable PostgreSQL target, covering a compatible pre-migration
   state and duplicate `(user_id, provider)` constraint failure. No durable
   database, schema, generated, worktree, or branch residue may remain.
5. Prove source feature-gate defaults/behavior: resolution and consolidation
   disabled absent ConfigEntry; exact identity/lookup-only admin unchanged;
   disabled unmatched sign-in fails closed; resolution is binary/system-wide;
   consolidation stays disabled. Define future commands as sanitized text
   only—do not run ConfigEntry mutation.
6. Specify a proposed future preflight, rollout order, rollback (migration
   retained by default), approval, verification, 30-minute monitoring,
   24-hour follow-up, provider-validation matrix, and typed stop conditions.
7. Explicitly classify the first historical-remediation blocker: the missing,
   accepted safe fresh-proof acquisition/execution interface. Do not create or
   route it here.

## Allocation and constraints

Dispatch one ephemeral `gpt-5.6-terra/high` Implementer. Terra/high is the
lowest sufficient allocation because this report requires a multi-commit
dependency closure, disposable migration/rollback and duplicate-constraint
rehearsal, full retained-boundary regression analysis, and an exact future
production safety envelope. The Implementer must not stage, commit, merge,
push, deploy, use SSH/network/provider/secrets, access production, mutate
ConfigEntry/accounts/sessions, or make external changes. It returns directly
to Control.

## Required final checks

- report completeness against every frozen criterion;
- disposable-residue proof, isolated and canonical status/staging checks;
- local candidate path/migration/dependency inventory and tests;
- `git diff --check`, report redaction scan, and changed-path review;
- local canonical integration only of the Control packet/report records.

## Terminal boundary

Control commits and locally integrates only accepted documentation records,
then sends one immutable terminal packet to Planning. The outcome must include
the recommended exact future release strategy or the first evidence-backed
blocker, all checks, clean states, and explicit confirmation that no external,
production, provider, release-ref, deployment, account, payment, or secret
action occurred.
