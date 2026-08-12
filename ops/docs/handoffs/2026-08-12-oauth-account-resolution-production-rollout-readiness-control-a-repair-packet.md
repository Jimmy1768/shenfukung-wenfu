# Control repair packet — explicitly fenced local migration rehearsal

## Authority

This is a bounded repair under the unchanged accepted plan
`ops/docs/plans/OAUTH_ACCOUNT_RESOLUTION_PRODUCTION_ROLLOUT_READINESS_PLAN.md`
and the original Control packet
`ops/docs/handoffs/2026-08-12-oauth-account-resolution-production-rollout-readiness-control-a-packet.md`.

## Observed conformance failure

The first ephemeral Implementer ran a migration-rehearsal schema load without
`RAILS_ENV=test`. Rails therefore selected local development database
`golden_template_dev`, where read-only follow-up established that the candidate
schema version and `oauth_account_resolutions` table are present. No production,
network, SSH, provider, secret, release-ref, account, or repository source
action occurred. The shared local development database is not a disposable
target and must not be reset, dropped, repaired, or used as evidence in this
packet.

The exact disposable worktrees
`/private/tmp/shengfukung-wenfu-oauth-rollout-candidate-b` and
`/private/tmp/shengfukung-wenfu-oauth-rollout-baseline`, and exact disposable
databases `oauth_rollout_clean_migration_test` and
`oauth_rollout_duplicate_migration_test`, were removed by Control before this
repair attempt. No unaccepted report or source change exists.

## Fresh bounded outcome

Create the one required readiness report at
`ops/docs/handoffs/2026-08-12-oauth-account-resolution-production-rollout-readiness-control-a.md`
and perform the plan's remaining local/disposable comparison and rehearsal.
Only that report is a persistent edited path.

## Database safety fence

Before any Rails or PostgreSQL database write, declare one exact disposable
database name prefixed `oauth_rollout_repair_test_`. Every Rails database command
must begin with both `RAILS_ENV=test` and `PGDATABASE_TEST=<that exact name>`.
Do not use `PGDATABASE`.

Before `db:schema:load`, `db:migrate`, test setup, or any other write, run a
database-free/connection-only guard that aborts unless:

1. `Rails.env.test?` is true;
2. Rails resolves the exact declared `PGDATABASE_TEST` name; and
3. `current_database()` is that exact disposable name.

Record only the environment classification and database name in the report;
never emit credentials. On any guard mismatch, stop without retrying against
another target. Never touch `golden_template_dev`, `golden_template_test`, or
any database without the declared disposable prefix. The Implementer must
drop only its exact declared disposable database after evidence is collected
and prove it is absent. It must remove its exact disposable worktrees before
returning.

## Remaining requirements

Retain every original report requirement: exact Candidate A/B inventory and
minimal complete dependency closure; local source/tests and duplicate-index
migration evidence; feature-gate/rollback proof; exact future preflight,
rollout, monitoring, provider matrix and stop conditions; and the missing safe
fresh-proof acquisition/execution interface as the first historical-remediation
blocker. Report the local development-database incident as non-production
environment evidence, excluded from readiness proof.

## Implementer and boundaries

Dispatch one fresh ephemeral `gpt-5.6-terra/high` Implementer because this is
a migration/rollback/disposable-state repair. It may not edit product source,
config, dependencies, or release refs; may not stage, commit, merge, push,
deploy, SSH, use network, access production/provider/secrets, mutate ConfigEntry
or accounts, or attempt shared local-development database recovery. It returns
directly to Control. Control accepts only a report with all disposable residue
removed and the exact safety guard evidence.
