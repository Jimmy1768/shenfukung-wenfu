# OAuth Account Resolution Production Read-Only Preflight Retry Plan

Status: accepted for direct dispatch to Control A after commit

Created: 2026-08-12

Owner: Wenfu Planning

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Canonical pre-plan base:
`6e5ecb7702a32ea09a5090281e55b27768bd3305`

Accepted parent plan:
`ops/docs/plans/OAUTH_ACCOUNT_RESOLUTION_PRODUCTION_READ_ONLY_PREFLIGHT_PLAN.md`

Accepted stopped-at-Phase-0 report:
`ops/docs/handoffs/2026-08-12-oauth-account-resolution-production-read-only-preflight-control-a.md`

## Objective And Inherited Contract

Retry the parent plan's exact target-fenced, sanitized, read-only production
preflight after correcting only its local coordination fence. Every target,
command/query shape, output schema, stop condition, execution window,
non-mutation proof, rollback classification, approval boundary, next-owner
rule, and explicit exclusion in the parent plan remains authoritative.

The failed first attempt performed no SSH, curl, network, production,
database, service, provider, account, or external action. Its canonical
clean-state failure was caused only by Planning committing the independently
accepted Expo foreground-retry plan after the OAuth dispatch. Those paths are
now attributable, committed, and preserved; the failure report is canonically
integrated at `6e5ecb7`.

## Corrected Local Fence

Control creates a fresh isolated codex-prefixed branch/worktree from the exact
committed retry-plan tip. Before production contact it must prove:

1. the isolated packet worktree is exactly at the accepted retry-plan commit,
   clean, and staging empty;
2. the accepted Candidate B baseline and five ordered commits match the parent
   plan exactly;
3. canonical `main` is clean and staging empty and contains the accepted
   retry-plan commit as an ancestor;
4. any canonical commit after the retry-plan commit is inspected by path and
   accepted only if it is an already-authorized Expo Control report/packet or
   Planning callback/status documentation with no Rails, deployment, OAuth,
   environment, dependency, release-ref, or production-plan change; and
5. any other post-dispatch canonical change is a stop and returns authority to
   Planning.

The exact isolated retry-plan worktree—not the moving canonical tip—is the
reproducible local source of the production-preflight packet. This does not
relax remote fences: production checkout, `release/current`, and
`origin/release/current` must still all equal exact baseline
`99a0a6929c5cb0eace21d5fa074cdab3950b269c`.

No local fetch, pull, ref movement, checkout, candidate construction, product
edit, or plan rewrite is allowed to reconcile drift.

## Execution

After the corrected local fence passes, execute Phases 1–5 of the parent plan
once, unchanged, within a new maximum 20-minute window on 2026-08-12
Asia/Taipei. Record new start/end timestamps. Do not count the stopped first
attempt as a production call; it made none.

Control may use one fresh ephemeral Implementer only for immutable packet and
sanitized report preparation/static review. The Implementer receives no
production, SSH, network, database, provider, secret, account, or runtime
authority. Control exclusively executes and sanitizes all protected read-only
observations.

## Terminal And Next Owner

Return one replacement immutable preflight report that references and does not
rewrite the first-attempt report. It must clearly distinguish:

- corrected local-fence evidence;
- actual observed production fields or the exact first remote stop condition;
- pre/post non-mutation proof; and
- the smallest next Planning/Director action.

Success classification:
`oauth_account_resolution_production_read_only_preflight_complete`.

Failure classifications remain those in the parent plan, including
`production_preflight_mutation_reconciliation_required` and
`no_evidence_backed_direct_repair_remaining`.

On success, Planning owns any later Candidate B construction/review or rollout
plan. The retry does not authorize release construction, ref movement, push,
deployment, migration, restart, flag change, provider validation,
account/session action, historical remediation, or any external mutation.

Current classification:
`oauth_account_resolution_production_read_only_preflight_retry_authorized`.

First blocker: none at dispatch. Any parent-plan or corrected-local-fence stop
condition returns authority to Planning without repair.
