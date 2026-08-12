# OAuth account-resolution production rollout readiness — Control A

Date: 2026-08-12
Classification: `oauth_account_resolution_rollout_readiness_complete`
Authority: report-only execution of
`ops/docs/plans/OAUTH_ACCOUNT_RESOLUTION_PRODUCTION_ROLLOUT_READINESS_PLAN.md`.

## Scope and observed-state boundary

This record assesses local Git/source evidence only. It does **not** establish
the current state of any host, checkout, service, schema, environment entry,
provider, account, session, or historical record.

The configured target for a later, separately authorized packet is documented
as follows, but was not contacted:

- origin: `https://shengfukung.com.tw`;
- SSH target: `jimmy1768_user@174.138.18.211`;
- checkout: `/home/jimmy1768_user/Projects/shengfukung-wenfu` on
  `release/current`;
- Rails directory: `/home/jimmy1768_user/Projects/shengfukung-wenfu/rails`;
- protected environment file: `/etc/default/shengfukung-wenfu-env`;
- services: `shengfukung-wenfu-puma` and
  `shengfukung-wenfu-sidekiq`;
- application path: Puma on port 3000 behind the configured TLS origin; and
- tenant-local smoke endpoint: `https://shengfukung.com.tw/api/v1/temple`.

No SSH, network request, provider interaction, configuration mutation,
release-ref movement, deployment, restart, account/session action, production
data access, or secret access occurred.

## Local inputs and candidate comparison

| Candidate | Local boundary | Inventory | Result |
| --- | --- | --- | --- |
| A — accepted-main promotion | `99a0a6929c5cb0eace21d5fa074cdab3950b269c..82b0e52e0005ee705b5ce85964a773bc7e0f7809` | 185 paths: 43 Rails, 52 mobile, 90 documentation/governance; it also changes `mobile/package.json`, `mobile/yarn.lock`, `rails/config/routes.rb`, and migration `20260812000000`. | A 110-commit broad release. It is not a narrow OAuth promotion and must receive whole-release review if selected. |
| B — minimal complete release candidate | exact release baseline plus the five upstream commits below, applied only in a disposable detached worktree | 43 Rails paths, 3,225 insertions and 297 deletions; no mobile, dependency manifest/lockfile, public-asset, deployment, or environment-template change. | Applied cleanly, with no conflict, and passed the recorded source/migration evidence. |

Candidate A includes the accepted Rails source but also all intervening Expo,
documentation, governance, and unrelated runtime work. Expo files do not run
on the web host, but their presence does not turn A into a hotfix.

The complete Candidate A runtime inventory is the same 43 Rails paths listed
for Candidate B below: account/native session and refresh-token support;
central, legacy, and native OAuth endpoints; exact-identity resolution and the
new pending-resolution/consolidation services; account resolution browser UI;
routes; the additive migration/schema; and the corresponding tests. Its only
Rails configuration path is `rails/config/routes.rb`; there is no changed
Rails Gemfile/lockfile, environment template, worker/scheduler/service unit,
deployment script, Vue source, or `rails/public` asset in the A delta. The
additional executable files in A are the 52 Expo/mobile paths, including the
mobile package manifest and lockfile; all remaining 90 paths are
documentation/governance. That is why A requires whole-release review even
though its web-host Rails subset is complete.

Candidate B's complete dependency closure is, in this exact order:

1. `684c9efcd43127b07281fe0bf67d4932f98e0ef2` — native account JSON API;
2. `740aa39bb38806d2207636bb391167c2fee6a9b1` — native account contract
   evidence that covers the first commit's account/session surface;
3. `7fa60f01a05e009a2722c55b878e013acccd4473` — native OAuth Rails contract;
4. `6eb57c3563d39a24f29e753866c3f030287ab84f` — typed central
   `invalid_grant` preservation; and
5. `dcc258b8e97e3c48803c6eb292a592ee6d990371` — proof-gated account
   resolution.

The existing narrow Google subject repair
`3898b0967581df79223d4a22e4d634eb9e434458` is already an ancestor of the
configured release baseline. The five commits above were each absent from that
baseline. In a disposable detached worktree, they cherry-picked cleanly onto
the exact baseline in that order. The resulting temporary candidate was
`11964f8`; it is evidence only and is not a release branch or a proposed
production commit.

The closure is necessary: `dcc258b` relies on the shared exchange/native
response structures added by `7fa60f0`, which in turn routes through the
native account/session base added by `684c9ef`; `6eb57c3` retains the
distinguishable invalid-grant contract, and `740aa39` supplies the retained
native account contract evidence. The resulting Rails path set contains the
native account controllers/session and refresh-token support, central and
legacy OAuth controllers, OAuth exchange/resolution/consolidation services,
the resolution model/view/routes, migration/schema, and their account,
admin, native, concurrency, and service tests.

### Recommendation and first release blocker

Recommend **Candidate B**, as one newly reviewed release commit made from
`release/current` at `99a0a692` by applying exactly the five original commits
above in that order, preserving their complete Rails test closure. Do not
promote the disposable `11964f8` hash, and do not move `release/current` in
this packet.

The first production blocker is therefore Director/Planning acceptance of this
exact Candidate B release boundary and its review against the then-current,
target-fenced production preflight. Candidate A remains an alternative only as
a separately reviewed broad release; it is not the recommended OAuth rollout
path.

## Routes, migration, and local evidence

The candidate exposes the following relevant routes:

- `POST /api/v1/account/native/oauth/start` and
  `POST /api/v1/account/native/oauth/exchange`;
- `GET /account/oauth/resolution`, plus the explicit existing-account and
  new-account resolution posts;
- `GET /auth/central/:provider/start` and `GET|POST /auth/callback`; and
- the gated legacy OmniAuth callback.

Migration `20260812000000_create_oauth_account_resolutions.rb` creates the
pending-resolution table, digest/expiry indexes and keeper foreign key, then
adds the unique `oauth_identities(user_id, provider)` index. Its reversible
down would remove pending state and the index, so it is not the ordinary
application-rollback path; the migration remains applied by default.

All local database work used only disposable
`oauth_rollout_repair_test_20260812a`. Every Rails database command started
with `RAILS_ENV=test` and `PGDATABASE_TEST=oauth_rollout_repair_test_20260812a`
(with the local socket explicitly selected). Before every schema load,
migration, fixture insertion, and test run, a Rails guard asserted all of:

1. `Rails.env.test?`;
2. the configured Rails database equals the declared name; and
3. `SELECT current_database()` equals the declared name.

The guard printed `guard_pass env=test database=oauth_rollout_repair_test_20260812a`
each time. A first attempt with the default local TCP setting was denied by the
local sandbox before a connection was made; it was not retried against another
database. Re-running with the local Unix socket passed the exact guard.

Evidence from the fenced rehearsal:

- a compatible pre-migration schema loaded at the fourth-commit state;
- after switching the disposable worktree to the full Candidate B state,
  `db:migrate` applied `20260812000000` successfully in 0.0308 seconds;
- after recreating only the declared disposable database, a synthetic
  same-user/same-provider pair with distinct subjects was inserted only there;
  the migration stopped as expected with `ActiveRecord::RecordNotUnique` /
  `PG::UniqueViolation` while creating
  `index_oauth_identities_on_user_id_and_provider`; and
- the database was recreated once more from the full Candidate B schema for
  regression tests.

This proves the production preflight must run a sanitized duplicate count
before migration, and treat a nonzero result as a stop condition. The exact
future query is a target-fenced, read-only aggregate over `(user_id, provider)`
with counts only; it must not emit emails, provider subjects, tokens, or other
identity material.

Focused local regressions passed:

```text
RAILS_ENV=test PGDATABASE_TEST=<declared disposable name> PGHOST=/tmp \\
  bundle exec rails test [OAuth/account/admin/native focused files]
68 runs, 477 assertions, 0 failures, 0 errors, 0 skips
```

The focused set includes resolver/exchange/resolution/concurrency/
consolidation/central-client/native-transaction tests; browser resolution and
identity-management tests; native OAuth contract; password, privacy, and
closure tests; tenant-scoped native resources; and admin session/multi-temple
authority tests.

The complete local Rails suite also passed:

```text
RAILS_ENV=test PGDATABASE_TEST=<declared disposable name> PGHOST=/tmp \\
  bundle exec rails test
452 runs, 2692 assertions, 0 failures, 0 errors, 0 skips
```

The Rails test output retains existing Rack deprecation warnings for
`:unprocessable_entity`; no new source change is authorized by this report.
`git diff --check 99a0a692..11964f8` and
`git diff --check 99a0a692..82b0e52` both passed.

Control independently repeated the retained OAuth/account/admin/password/
privacy/closure regression set in its own exact disposable test database after
the report was returned. The pre-write guard again confirmed `RAILS_ENV=test`
and the declared database before schema load; the result was 79 runs and 539
assertions with 0 failures, 0 errors, and 0 skips. Control dropped that exact
disposable database immediately afterward.

## Feature-gate and fail-closed proof

Source inspection establishes the following:

- `FeatureFlags::Evaluator.enabled?` returns its `default: false` when the
  system ConfigEntry is absent. Thus both `oauth_account_resolution` and
  `oauth_account_consolidation` default disabled.
- Resolver lookup begins with the exact `(provider, provider_uid)` identity;
  the narrowly scoped verified Google-subject compatibility replacement is
  retained. It does not restore generic signed-out email attachment.
- On an unmatched signed-out identity, `OAuthExchangeIdentity` only asks
  `OAuthAccountResolution.create!` after the resolver raises unmatched.
  With the resolution gate disabled that call raises before a user, identity,
  pending record, or session is created. Central browser handling returns to
  its safe fallback; native handling returns its dedicated unavailable result.
- The admin central path passes `lookup_only: true`; an unmatched identity is
  re-raised rather than turned into a pending resolution. Exact identity lookup
  remains available while admin provisioning stays absent.
- The evaluator receives no actor for unmatched resolution. If a rollout
  record exists it returns the base Boolean before percentage bucketing, so
  enabling resolution is a system-wide binary decision, not a percentage
  rollout. The report makes no percentage-rollout claim.
- Consolidation separately checks `oauth_account_consolidation` and is kept
  false throughout deploy and provider validation. Its non-routed helper is
  not an execution interface.

For a later approved packet, the command text may be reviewed as a protected
production Rails operation that writes only the named system flag and reads it
back as a Boolean. It must be run only after the release verification step and
only with a specific Director authorization. This report did not run any such
command.

## Proposed later production rollout packet (not authority)

### Target-fenced preflight

1. Record the Director-approved Candidate B commit, the exact known-good
   previous release commit, and clean/reconciled canonical and
   `release/current` refs.
2. Read-only, target-fenced checks confirm the actual checkout, Rails bundle,
   expected protected environment-key **presence** (not values), PostgreSQL
   readiness, migration status, and named service state.
3. Run the sanitized duplicate `(user_id, provider)` count. A nonzero count,
   unknown result, or anything other than the selected candidate is a stop.
4. Capture only the Boolean values of the two named OAuth flags; both must be
   disabled before rollout.
5. Confirm no concurrent deploy, migration, provider validation, or
   remediation activity is active.

### Rollout order and rollback

1. Keep both OAuth flags disabled.
2. Promote and deploy only the approved Candidate B commit.
3. Apply the forward migration set once; stop and reconcile any failed or
   uncertain result without blind retry.
4. Restart only `shengfukung-wenfu-puma` and `shengfukung-wenfu-sidekiq`.
5. Verify exact checkout, migration up state, both services, Rails health, and
   the tenant-local smoke endpoint.
6. Provider validation and the later binary resolution activation are separate
   named authorities. Consolidation remains disabled.

Ordinary rollback first disables resolution if it was enabled, returns the
release ref and checkout to the recorded known-good commit, restarts only the
two named services, and repeats safe health/smoke checks. It leaves migration
`20260812000000` applied. Dropping the table/index requires a separately
approved database rollback proving no dependent pending or audit data. A
failed transactional migration is `reconciliation_required`, never a retry
signal.

### Approval, verification, and monitoring

Planning accepts this readiness evidence and the exact release candidate;
the Director separately authorizes the rollout packet; Control A returns one
sanitized receipt. Provider validation and flag activation need their own
named authorization.

Immediately after deployment, verify health/schema/services/routes, email and
password login, exact existing Google and Apple identity behavior, lookup-only
admin behavior, and an unmatched callback's no-user/no-session outcome. The
provider matrix must separately cover:

| Journey | Required later authority and safe expected outcome |
| --- | --- |
| existing exact Google | provider/session authority; exact existing account only |
| existing exact Apple | provider/session authority; exact existing account only |
| unmatched Google or Apple while disabled | provider/session authority; no user, identity, pending record, or session |
| unmatched callback after binary activation | provider/session plus activation authority; stop at resolution choice unless a separately authorized proof journey applies |
| signed-in linking | provider/account authority; only explicit fresh proof and unowned subject |
| admin exact/unmatched | provider/admin authority; exact lookup only; unmatched never provisions |
| browser versus native | respective browser/native session authority; same resolution contract, no cross-surface token/session leakage |

Monitor typed aggregate counts only for 30 minutes after deployment and after
any gate change: pending resolutions by state/mode, failed callback
classification, identity-link conflicts, and new-user counts. Complete a
24-hour review before Planning considers historical remediation. Stop and roll
back or reconcile on health/migration failure, exact-identity regression, admin
authority leak, unexpected user/session creation, duplicate-identity constraint
error, raw identity/secret leakage, or rising unclassified callback failures.
No monitoring record may contain raw email, provider subject, code, token,
credential, or private-relay address.

## Historical remediation remains blocked

The observed Apple-only record is untouched. The first historical-remediation
blocker is the absence of an accepted safe fresh-proof acquisition/execution
interface. The existing consolidation helper is deliberately non-routed;
direct SQL, direct record reassignment, or a runner carrying password/provider
material is prohibited.

Before a remediation packet, the approved source must be deployed and pass the
24-hour review; the exact source and keeper need a separately authorized,
sanitized read-only inventory; the Director must confirm both after dual proof;
and a protected user-facing or operator journey must acquire an
exchange-derived proof without exposing credentials or provider material to
Planning/Control. The action then needs its own transaction/session-revocation,
audit, uncertain-outcome, verification, time-window gate enable/disable, and
rollback plan.

## Incident and cleanup record

The prior attempt accidentally selected shared local development database
`golden_template_dev` while loading a migration rehearsal. It was a local,
non-production incident. This repair did not read, reset, recover, or use that
database as evidence. No production or external action occurred.

The repair created only one named disposable PostgreSQL database and one
detached disposable candidate worktree. The database was dropped after the
evidence collection; the candidate worktree was removed after its generated
schema file was restored and it was clean. No disposable candidate branch,
commit, database, staged path, generated schema, or worktree is retained.

Persistent changed path for this attempt:

```text
ops/docs/handoffs/2026-08-12-oauth-account-resolution-production-rollout-readiness-control-a.md
```
