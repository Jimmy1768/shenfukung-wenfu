# OAuth Account Resolution Production Rollout Readiness Plan

Status: accepted for report-only dispatch to Wenfu Control A after commit; no
production, provider, account, deployment, branch-promotion, or external action
is authorized

Created: 2026-08-12

Owner: Wenfu Planning

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted OAuth runtime source commit:
`82b0e52e0005ee705b5ce85964a773bc7e0f7809`

Planning base:
`fab60934cacfb9b94a609f80de59bf123531e636`

Configured live release baseline, observed locally:
`release/current` and `origin/release/current` at
`99a0a6929c5cb0eace21d5fa074cdab3950b269c`

The actual production-host checkout, schema, services, configuration entries,
and runtime state are unknown in this packet. They must not be inferred from
the local branch.

## Decision And Sequence

The smallest safe next packet is production rollout readiness, not historical-
account remediation.

Reason:

- the corrected resolver, pending-resolution table, lookup-only admin branch,
  and safe feature gates do not exist on the configured live release baseline;
- historical consolidation must not run against old application code;
- the accepted consolidator is deliberately non-routed and no protected
  production operator or self-service proof journey has yet been accepted;
- the observed Apple-only record must remain untouched until rollout and real
  provider behavior are verified.

This plan therefore authorizes a local/read-only readiness report only. It does
not authorize SSH, provider login, production database queries, release branch
movement, push, migration, restart, feature-flag mutation, sign-in, session
creation, or account remediation.

## Exact Configured Production Target

The readiness report must use repository evidence to describe, but not contact:

- public origin: `https://shengfukung.com.tw`;
- host: `jimmy1768_user@174.138.18.211`;
- repository: `/home/jimmy1768_user/Projects/shengfukung-wenfu`;
- live branch: `release/current`;
- Rails working directory:
  `/home/jimmy1768_user/Projects/shengfukung-wenfu/rails`;
- environment file: `/etc/default/shengfukung-wenfu-env`;
- services: `shengfukung-wenfu-puma` and
  `shengfukung-wenfu-sidekiq`;
- live application path: Puma port 3000 behind the accepted Nginx/TLS origin;
- tenant-local smoke endpoint:
  `https://shengfukung.com.tw/api/v1/temple`.

These are configured/documented targets. Current reachability, checkout,
service health, database state, and provider state remain unknown until a later
explicit read-only or rollout packet authorizes observation.

## Primary Readiness Risk: Release Delta

Local evidence shows the accepted OAuth runtime commit is 110 commits ahead of
the configured release baseline. The full diff contains 185 paths, including
43 Rails paths, 52 Expo paths, builder-governance changes, and extensive
documentation. Promoting the accepted `main` ancestry directly would therefore
be a broad release, not a narrow OAuth hotfix.

Control A must compare two candidate strategies without promoting either:

### Candidate A — Exact accepted-main promotion

Candidate runtime commit:
`82b0e52e0005ee705b5ce85964a773bc7e0f7809`.

Inventory every Rails/runtime/deployment change from
`99a0a6929c5cb0eace21d5fa074cdab3950b269c` to `82b0e52`. Identify migrations,
route/session/auth changes, dependencies, environment/config requirements,
background-worker impact, Vue/public-asset impact, and unrelated accepted work
that would enter production.

This candidate is ready only if its entire runtime delta can truthfully pass as
one reviewed release. Expo-only and documentation changes do not execute on the
web host, but their presence does not waive review of the Rails and deployment
delta.

### Candidate B — Minimal release candidate

Using a disposable isolated worktree only, determine whether the accepted OAuth
implementation can be applied to the release baseline with a complete,
reviewable dependency closure. The report must name every required commit and
path, any conflict, and every prerequisite introduced by earlier Rails-native
OAuth/account-session work.

Do not assume that cherry-picking only
`dcc258b8e97e3c48803c6eb292a592ee6d990371` is complete or safe. It was built
on the current main ancestry and may depend on shared OAuth/native services and
tests absent from `release/current`.

The disposable comparison leaves no retained candidate branch, commit, staged
file, generated schema, database, or worktree residue. Control does not select
or create the production release commit in this packet. It recommends the
smallest complete candidate for a later Planning/Director decision.

## Local Source And Migration Readiness

For each viable candidate, prove locally:

- complete changed-path and migration inventory;
- Ruby/bundle and environment prerequisites;
- full focused OAuth/account/admin/native suite from the accepted Control
  evidence;
- retained password, privacy, closure, tenant, dual-role, and admin authority
  regressions;
- full Rails suite, or an exact evidence-backed reason and broader substitute
  if the repository cannot run it;
- route inventory for central callback, account resolution, legacy callback,
  and native start/exchange;
- forward migration on a disposable PostgreSQL database;
- migration failure behavior when duplicate `(user_id, provider)` rows exist;
- clean migration on a compatible pre-migration dataset;
- no destructive down-migration as the ordinary rollback;
- `git diff --check`, clean/staging-empty state, and no generated residue.

The migration `20260812000000` is additive except for a unique
`oauth_identities(user_id, provider)` index. The later production preflight
must prove the existing database has no conflicting rows before migration.
This packet may define the sanitized query and expected typed result but may
not run it against production.

## Feature-Gate Readiness

The report must prove from source:

- `oauth_account_resolution` defaults to disabled when no system ConfigEntry
  exists;
- `oauth_account_consolidation` also defaults disabled;
- exact provider-subject sign-in and lookup-only admin behavior do not depend
  on enabling pending resolution;
- an unmatched account sign-in while resolution is disabled fails closed and
  creates no user, identity, pending record, or session;
- enabling `oauth_account_resolution` is a system-wide binary decision for a
  signed-out user because the evaluator has no actor for this flow; percentage
  rollout must not be claimed;
- `oauth_account_consolidation` remains disabled throughout rollout/provider
  validation.

The report defines exact future configuration commands and read-back checks as
reviewable text only. It does not execute them. No raw credentials, provider
subjects, emails, tokens, or secrets may enter the report.

## Future Production Rollout Packet Boundary

The readiness report must produce one proposed exact production packet with
the following immutable boundaries. It is a proposal, not authority.

### Preconditions

- Director approves one exact release candidate commit and its complete diff;
- canonical and `release/current` refs are clean and reconciled;
- production target-fenced read-only preflight confirms exact current checkout,
  services, environment-key presence, schema migration status, PostgreSQL
  readiness, and zero `(user_id, provider)` duplicates using sanitized counts;
- local candidate tests and migration rehearsal pass;
- current `oauth_account_resolution` and `oauth_account_consolidation` values
  are captured without exposing unrelated ConfigEntry values;
- a known-good prior release commit and branch ref are recorded;
- no simultaneous deployment, migration, provider validation, or remediation
  is active.

### Exact rollout order

1. Keep both new feature gates disabled.
2. Promote only the Director-approved release commit to `release/current`.
3. Deploy/fetch that exact commit on the configured host.
4. Run the single forward migration set and stop on any failure or unexpected
   version.
5. Restart only the two named services.
6. Verify exact checkout, migration up, service active state, Rails health, and
   tenant-local smoke endpoint.
7. Verify email/password plus already-linked exact Google and exact Apple
   behavior only under a separately accepted provider-validation authority.
8. Enable `oauth_account_resolution` only under a separately accepted binary
   activation/validation step. Keep consolidation disabled.

Steps involving host mutation, login, provider use, session creation, or flag
mutation are not authorized by this readiness packet.

### Rollback

Ordinary rollback is:

1. disable `oauth_account_resolution` if it was enabled;
2. return `release/current` and the production checkout to the exact recorded
   known-good commit;
3. restart only Puma and Sidekiq;
4. repeat health and tenant smoke verification;
5. leave migration `20260812000000` applied unless a separately approved
   database rollback proves no pending/audit data and no dependency on the
   unique index.

Dropping the pending-resolution table or unique index is not the default
rollback. A failed transactional migration stops before service restart and
must be reconciled before retry. An uncertain migration result is
`reconciliation_required`, never a blind retry.

### Approval

- Planning accepts the readiness report and exact release candidate.
- Director separately authorizes the exact production rollout packet.
- Control A owns the rollout and returns one sanitized terminal receipt.
- Provider validation and feature activation require their named authority;
  historical remediation never rides inside the deployment packet.

### Verification and monitoring

The future packet must define:

- immediate health/schema/service/route checks;
- safe exact-identity Google/Apple and email-login matrix;
- unmatched-resolution validation with no accidental user/session creation;
- sanitized counts of pending resolutions by state/mode, failed OAuth callback
  classification, identity-link conflicts, and new users during the window;
- active monitoring for 30 minutes after deployment and after any gate change;
- a 24-hour follow-up review before historical remediation can be planned;
- stop/rollback thresholds: health or migration failure, exact-identity login
  regression, admin authority leak, unexpected account/session creation,
  duplicate identity constraint error, raw secret/subject leakage, or rising
  unclassified callback failures.

Monitoring records counts and typed states only. It must not retain raw emails,
provider subjects, authorization codes, tokens, credentials, or private relay
addresses.

## Provider Validation Readiness

No provider validation is authorized here. The report must separate:

- existing exact Google sign-in;
- existing exact Apple sign-in;
- unmatched Apple/Google callback while resolution is disabled;
- unmatched callback after binary resolution activation, stopping safely at
  the resolution choice unless a separate account-creation/link test is
  authorized;
- account linking while already signed in;
- admin exact identity and unmatched lookup-only behavior;
- browser account versus native account response behavior.

Each real journey mutates at least session, identity activity metadata, pending
resolution, or audit state and therefore needs explicit target/account/provider
authority. Prior successful provider evidence is historical readiness input,
not permission to repeat it.

## Historical-Account Remediation Gate

The observed Apple-only account remains deferred and untouched.

Historical remediation is not executable merely because the local service
exists. Before any such packet:

1. the accepted source must be deployed and pass the 24-hour rollout review;
2. the exact source and keeper records must receive a separately authorized
   sanitized read-only inventory;
3. the Director must confirm the keeper and source after dual proof;
4. a user-facing or protected operator mechanism must obtain a fresh
   exchange-derived consolidation proof without exposing provider subject,
   token, or keeper password to Planning/Control;
5. the source must pass every empty-placeholder guard at execution time;
6. the packet must define transaction, session revocation, audit, uncertain-
   outcome reconciliation, and post-action verification;
7. consolidation must be enabled only for the exact action window and disabled
   immediately afterward.

The current helper is non-routed. The readiness report must explicitly classify
the missing safe proof-acquisition/execution interface as the first remediation
blocker. Direct database reassignment or an ad hoc Rails runner containing
password/provider material is prohibited.

## Report And Control Boundary

Control A may use one ephemeral Implementer for local repository inventory,
disposable candidate comparison, local tests/migration rehearsals, and immutable
report preparation. Control independently reviews the evidence, commits only
its report/packet records, and may integrate those documentation paths to
canonical main.

Required report path:
`ops/docs/handoffs/2026-08-12-oauth-account-resolution-production-rollout-readiness-control-a.md`.

The report must include:

- exact configured target and observed/unknown-state classification;
- candidate A/B dependency and risk comparison;
- recommended exact release strategy and first blocker;
- local checks and disposable migration evidence;
- proposed preflight, rollout, rollback, verification, approval, monitoring,
  provider-validation, and remediation boundaries;
- explicit no-external-action and clean Git evidence.

## Explicit Exclusions

- SSH, network request, live health/smoke check, production log or database
  access;
- release/current movement, push, deployment, migration, restart, feature-flag
  change, provider validation, OAuth sign-in, account/session mutation;
- historical-account inventory, consolidation, deletion, reassignment, closure,
  or remediation;
- SourceGrid/provider console, credentials, secrets, payment, Expo/mobile,
  EAS, build, release/store, or external action;
- product source changes or another OAuth implementation phase.

## Terminal Classifications

- `oauth_account_resolution_rollout_readiness_complete`;
- `release_candidate_dependency_gap`;
- `migration_or_rollback_readiness_gap`;
- `true_planning_design_gap`;
- `no_evidence_backed_direct_repair_remaining`.

Current classification:
`oauth_account_resolution_rollout_readiness_authorized`.

First blocker to production: an accepted exact release candidate. The current
accepted runtime commit is a broad 110-commit release delta from the configured
live baseline, and a minimal complete dependency closure has not yet been
proved.
