# OAuth Account Resolution Candidate B Construction Plan

Status: accepted local-only construction/review plan for direct dispatch to
Wenfu Control A. This plan authorizes no production, provider, account,
deployment, release-ref, push, or historical-record action.

Planning source base:
`1bcbf81d6b1427237bb62bb228d3a43f76c55446`.

Readiness source:
`ops/docs/plans/OAUTH_APPLE_USER_22_RECOVERY_READINESS_SCAN.md`.

## Objective

Construct and independently review the exact Director-accepted narrow Rails
Candidate B from the configured release baseline. Retain one immutable local
candidate branch/tip for a later separately authorized production preflight and
release decision.

This phase does not move or merge `release/current`, does not deploy, and does
not remediate user 22.

## Exact Candidate Boundary

The candidate must start from exact local baseline:

`99a0a6929c5cb0eace21d5fa074cdab3950b269c`

Apply these exact source commits in this exact order:

1. `684c9efcd43127b07281fe0bf67d4932f98e0ef2`
2. `740aa39bb38806d2207636bb391167c2fee6a9b1`
3. `7fa60f01a05e009a2722c55b878e013acccd4473`
4. `6eb57c3563d39a24f29e753866c3f030287ab84f`
5. `dcc258b8e97e3c48803c6eb292a592ee6d990371`

The retained candidate must contain exactly five candidate commits above the
baseline, with durable source-commit attribution. It may not include current
`main`, later Expo work, later documentation/governance commits, or any sixth
source correction.

## Authority And Execution Route

Use ordinary Codex Work Mode:

`Planning -> Wenfu Control A -> one ephemeral Implementer`.

Control chooses and freezes the exact codex-prefixed branch/worktree names,
commands, implementer model/reasoning, disposable database names, and check
order. The implementation packet must state why its database and migration
work cannot target any shared local development or ordinary test database.

Control may retain one local candidate branch based on the release baseline and
one Control evidence/report path based on canonical Planning ancestry. It must
not merge the release-derived candidate branch into canonical `main`; current
`main` already contains broader source history. If accepted, only the immutable
Control report/packet documentation may be integrated into canonical `main`.

## Construction Criteria

Before construction, Control must prove:

- canonical `/Users/jimmy1768/Projects/shengfukung-wenfu` is clean with empty
  staging and contains the accepted plan commit;
- local `release/current` is exactly the accepted baseline;
- all five source commits exist and are readable locally;
- no existing candidate worktree/branch will be overwritten or reused without
  exact clean-state proof;
- no dependency installation, fetch, pull, or network action is needed.

The candidate must then satisfy:

- exact baseline ancestry;
- exact five-commit ordered source mapping;
- no conflict resolution or manual product-source edit;
- no additional commit, path, generated native tree, dependency artifact, or
  local secret/configuration residue;
- clean worktree and empty staging at the final candidate tip.

If any accepted source commit does not apply cleanly, Control stops and returns
the first conflict. It must not redesign, squash around, omit, reorder, or
repair Candidate B under this plan.

## Expected Source Boundary

The accepted candidate is Rails-only. Its cumulative delta from the baseline
must match the prior immutable Candidate B inventory:

- account/native authentication, refresh-token, resource, and contract paths;
- central/browser/native OAuth controllers and services;
- exact identity resolution, pending account resolution, and empty-placeholder
  consolidation services;
- account OAuth resolution routes/view;
- OAuth identity and pending-resolution database migration/schema changes;
- focused Rails tests for the accepted behavior.

Allowed top-level changed path: `rails/` only.

Explicitly prohibited candidate paths:

- `mobile/` or `vue/`;
- dependency manifests or lockfiles;
- deployment, environment-template, systemd, proxy, DNS, TLS, cron, queue, or
  release scripts;
- public/media assets;
- provider credentials, secrets, local environment files, or generated
  credential material;
- Planning/Control documentation inside the retained release candidate.

`rails/config/routes.rb`, migration `20260812000000`, and the corresponding
schema delta are expected Rails paths and are not exclusions.

## Database Safety Fence

All migration/schema/test writes must target fresh, explicitly named disposable
PostgreSQL **test** databases. Reuse of `golden_template_dev`,
`golden_template_test`, or any shared/default database is prohibited.

Before every schema load, migration, rollback, fixture load, or test command,
the packet must fail closed unless all are true:

- `RAILS_ENV=test`;
- the configured database name equals the exact packet-declared disposable
  name;
- `current_database()` equals that same name;
- the name has the packet-owned `oauth_candidate_b_` prefix;
- the database is not production, development, shared test, or any other
  existing project database.

Control may create, recreate, and drop only its exact named disposable test
databases. Cleanup must verify those exact databases are absent. A failed guard
ends the packet; it does not retry against another database.

## Required Review Evidence

### Git and source equivalence

- baseline is an ancestor of final candidate tip;
- candidate range contains exactly five commits;
- each candidate commit maps in order to the accepted source commit and has an
  equivalent patch/content result;
- cumulative changed-path inventory is Rails-only and matches the accepted
  boundary;
- no merge commit, extra source correction, or unrelated current-main content;
- `git diff --check` for every accepted range;
- candidate and canonical worktrees clean, staging empty.

### Migration and integrity rehearsal

In fresh guarded disposable test databases:

- load the pre-migration compatible schema;
- apply migration `20260812000000` successfully;
- prove the resulting pending-resolution table and unique
  `(user_id, provider)` index;
- rehearse rollback/forward compatibility where supported by the exact
  migration;
- in a separate disposable state, prove a synthetic duplicate
  `(user_id, provider)` pair stops the migration with the expected uniqueness
  failure;
- emit only schema names, booleans, counts, error classes, and timing—never
  emails, provider subjects, tokens, or credential values.

### Automated suites

Run at minimum:

- the complete Rails test suite in the guarded candidate database;
- the focused OAuth resolver/exchange/pending-resolution/concurrency/
  consolidator suite;
- browser account resolution, OAuth identity management, sessions, password,
  privacy, closure, admin, tenant, native account, and native OAuth regressions;
- Ruby syntax for all changed Ruby source;
- route proof for central browser callback, account resolution, and native OAuth
  start/exchange;
- scans proving both recovery feature flags default disabled and the
  consolidation helper remains non-routed;
- scans proving no generic signed-out email/name/relay merge behavior is
  reintroduced.

Existing deprecation warnings may be recorded accurately but do not authorize
unrelated cleanup.

## Acceptance And Terminal Classifications

Accept only if all construction, database, source-boundary, and test criteria
pass.

Accepted classification:
`oauth_account_resolution_candidate_b_constructed_and_reviewed`.

The terminal packet must provide:

- exact baseline, five source commits, retained candidate branch/worktree, and
  final candidate tip;
- exact source-to-candidate commit mapping;
- cumulative changed paths and exclusions proof;
- migration/duplicate/rollback evidence;
- focused and complete test counts;
- disposable database/worktree cleanup evidence;
- canonical report-only integration commit, if accepted;
- clean/staging-empty evidence;
- confirmation that no remote or external action occurred.

Failure classifications include:

- `candidate_b_baseline_or_source_mismatch`;
- `candidate_b_construction_conflict`;
- `candidate_b_database_fence_failed`;
- `candidate_b_migration_or_integrity_failed`;
- `candidate_b_regression_failed`;
- `candidate_b_source_boundary_failed`.

A failed candidate is not integrated, promoted, pushed, or repaired beyond the
unchanged exact criteria. Control returns the first evidence-backed blocker.

## Strict Exclusions

This plan does not authorize:

- SSH, curl, provider, Central Auth, production, or other network access;
- production or shared local database access;
- user 22 or keeper inspection/mutation;
- feature-flag read/write;
- `release/current` or remote-ref movement;
- push, pull, fetch, deploy, migration, restart, service action, or smoke test;
- secret/environment-value access;
- mobile, Expo, Vue, payment, admin-product, or UI work;
- cleanup or inspection of the 86 production public paths.

## Next Owner After Acceptance

Planning receives one immutable terminal and paired receipt. The retained
candidate remains local and inactive. The next production-facing phase remains
the separately authorized read-only classification and disposition of the 86
untracked public paths, followed by a new exact Candidate B production
preflight. Candidate construction does not bypass that blocker.
