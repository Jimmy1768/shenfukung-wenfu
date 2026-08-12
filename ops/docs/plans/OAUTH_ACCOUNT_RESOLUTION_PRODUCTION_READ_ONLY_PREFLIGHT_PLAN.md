# OAuth Account Resolution Production Read-Only Preflight Plan

Status: accepted for direct dispatch to Control A after commit

Created: 2026-08-12

Owner: Wenfu Planning

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Canonical Planning base:
`44d3b250c37f615b5356bbded7b3d8ce0408cd64`

Accepted readiness report:
`ops/docs/handoffs/2026-08-12-oauth-account-resolution-production-rollout-readiness-control-a.md`

## Director Decision And Exact Future Release Boundary

The Director accepts Candidate B as the future OAuth rollout release boundary:

1. exact `release/current` baseline
   `99a0a6929c5cb0eace21d5fa074cdab3950b269c`;
2. `684c9efcd43127b07281fe0bf67d4932f98e0ef2`;
3. `740aa39bb38806d2207636bb391167c2fee6a9b1`;
4. `7fa60f01a05e009a2722c55b878e013acccd4473`;
5. `6eb57c3563d39a24f29e753866c3f030287ab84f`; and
6. `dcc258b8e97e3c48803c6eb292a592ee6d990371`.

The five commits are ordered and indivisible for later release construction.
The disposable rehearsal hash is not a release commit. This preflight must not
construct or move any release ref, create a production candidate, push, deploy,
migrate, restart, or change any external state.

## Objective

Perform one target-fenced, read-only production preflight that establishes the
actual current production baseline and the blockers for a separately planned
Candidate B rollout. The packet may observe only:

- exact remote checkout/ref/clean state;
- Rails bundle and protected environment-key presence, never values;
- database connection identity as a Boolean comparison, migration/table state,
  and the aggregate duplicate `(user_id, provider)` group count;
- Boolean state of only `oauth_account_resolution` and
  `oauth_account_consolidation`;
- named Puma/Sidekiq service state and concurrent-operation count; and
- the existing tenant-local HTTPS smoke endpoint's status metadata, with its
  body discarded.

No provider, account, session, historical user, or identity row may be
inspected. No email, provider subject, token, code, credential, private-relay
address, ConfigEntry value, database name, environment value, or response body
may enter chat or the durable report.

## Exact Target Fence

- SSH target: `jimmy1768_user@174.138.18.211`
- checkout:
  `/home/jimmy1768_user/Projects/shengfukung-wenfu`
- expected branch/ref: `release/current`
- expected checkout/ref/remote baseline:
  `99a0a6929c5cb0eace21d5fa074cdab3950b269c`
- Rails directory:
  `/home/jimmy1768_user/Projects/shengfukung-wenfu/rails`
- environment loader: `bin/load_temple_env shengfukung-wenfu`
- protected environment file path:
  `/etc/default/shengfukung-wenfu-env`
- services: `shengfukung-wenfu-puma` and
  `shengfukung-wenfu-sidekiq`
- public origin: `https://shengfukung.com.tw`
- tenant-local smoke URL:
  `https://shengfukung.com.tw/api/v1/temple`

Before every remote command, Control verifies that the command names only the
exact SSH target and checkout above. Any host-key mismatch, unexpected
hostname/user/path, symlinked checkout root, missing Git repository, or command
that would require a different target is an immediate stop.

## Execution Window And Control Ownership

Run once on 2026-08-12 Asia/Taipei, only when Control can complete the bounded
read-only sequence within 20 minutes. Record start and end timestamps in both
UTC and Asia/Taipei. If the SSH session drops or any result is uncertain, stop
and reconcile read-only state; do not blindly retry or extend the window.

Control A owns all SSH/network execution and sanitization. It may use one
ephemeral Implementer only for packet/report preparation and local static
review. The Implementer receives no production, SSH, provider, secret,
database, or runtime authority.

## Phase 0 — Local Immutable Input Proof

Before contacting production, Control verifies locally and reports only
Booleans plus the accepted hashes:

- canonical worktree and isolated packet worktree are clean/staging empty;
- `release/current` and `origin/release/current` both resolve exactly to
  `99a0a6929c5cb0eace21d5fa074cdab3950b269c`;
- each of the five ordered commits exists and is absent from that baseline;
- the five-commit order is the accepted dependency order; and
- no release ref is created, checked out, moved, fetched, or pushed.

Any ref drift is a stop. This packet does not fetch to resolve drift.

## Phase 1 — Remote Checkout And Bundle Proof

Use separate noninteractive SSH calls. The exact read-only command shapes are:

```text
ssh jimmy1768_user@174.138.18.211 \
  'hostname; id -un; readlink -f /home/jimmy1768_user/Projects/shengfukung-wenfu'

ssh jimmy1768_user@174.138.18.211 \
  'cd /home/jimmy1768_user/Projects/shengfukung-wenfu && git status --porcelain=v1 && git branch --show-current && git rev-parse HEAD && git rev-parse release/current && git rev-parse origin/release/current'

ssh jimmy1768_user@174.138.18.211 \
  'cd /home/jimmy1768_user/Projects/shengfukung-wenfu/rails && bundle check'
```

The first command's raw hostname is used only inside Control's target fence;
the durable receipt records `target_match: true|false`, not the hostname.
Success requires the expected user, exact resolved checkout path, empty status,
branch `release/current`, and all three Git hashes equal to the accepted
baseline. Any mismatch stops the packet before Rails/database observation.

## Phase 2 — Environment Presence Without Values

Confirm the protected file exists and is not world-readable using metadata
only. Do not print its owner/group names, contents, line count, size, or hash.
Then load the accepted environment through the repository helper and emit only
presence Booleans for these exact keys:

```text
PROJECT_SLUG
DATABASE_URL
SECRET_KEY_BASE
AUTH_BASE_URL
AUTH_CLIENT_ID
AUTH_CLIENT_SECRET
AUTH_NATIVE_RETURN_URL
```

Exact command shapes:

```text
ssh jimmy1768_user@174.138.18.211 \
  'mode=$(stat -c %a /etc/default/shengfukung-wenfu-env) && test $((8#$mode & 4)) -eq 0 && printf "env_file_present=true env_file_not_world_readable=true\n"'

ssh jimmy1768_user@174.138.18.211 \
  'cd /home/jimmy1768_user/Projects/shengfukung-wenfu && RAILS_ENV=production APP_ENV=production bin/load_temple_env shengfukung-wenfu -- ruby -e '\''keys=%w[PROJECT_SLUG DATABASE_URL SECRET_KEY_BASE AUTH_BASE_URL AUTH_CLIENT_ID AUTH_CLIENT_SECRET AUTH_NATIVE_RETURN_URL]; keys.each { |key| puts "#{key}=#{!ENV[key].to_s.empty?}" }'\'''
```

Control sanitizes away the loader's path chatter and retains only the seven
`key=true|false` lines. Missing `PROJECT_SLUG`, `DATABASE_URL`,
`SECRET_KEY_BASE`, or any of the three central-auth keys is a rollout stop.
Missing `AUTH_NATIVE_RETURN_URL` is recorded as a native-OAuth validation
blocker and must be resolved before real native OAuth validation; it does not
authorize an environment edit in this packet.

## Phase 3 — One Read-Only Rails/Database Observation

Run one production Rails runner through the same environment loader. The
runner must open an explicit transaction, execute
`SET TRANSACTION READ ONLY`, perform only the query shapes below, emit one
sanitized JSON object, and roll back the transaction deliberately.

Exact invocation and runner shape (sent over stdin; no remote file):

```bash
ssh jimmy1768_user@174.138.18.211 \
  'cd /home/jimmy1768_user/Projects/shengfukung-wenfu && RAILS_ENV=production APP_ENV=production bin/load_temple_env shengfukung-wenfu -- bash -lc "cd rails && bin/rails runner -"' <<'RUBY'
require "json"

connection = ActiveRecord::Base.connection
result = nil

ActiveRecord::Base.transaction(requires_new: true) do
  connection.execute("SET TRANSACTION READ ONLY")
  keys = %w[oauth_account_resolution oauth_account_consolidation]
  entries = ConfigEntry.where(
    scope_type: "system",
    scope_id: nil,
    key: keys
  ).index_by(&:key)
  boolean = ActiveModel::Type::Boolean.new

  result = {
    rails_env: Rails.env,
    adapter: connection.adapter_name,
    database_matches_config:
      connection.select_value("SELECT current_database()") ==
        ActiveRecord::Base.connection_db_config.database,
    transaction_read_only:
      connection.select_value("SHOW transaction_read_only") == "on",
    migration_20260812000000_applied: ActiveModel::Type::Boolean.new.cast(
      connection.select_value(<<~SQL.squish)
        SELECT EXISTS (
          SELECT 1 FROM schema_migrations
          WHERE version = '20260812000000'
        )
      SQL
    ),
    oauth_account_resolutions_table_present:
      connection.data_source_exists?("oauth_account_resolutions"),
    duplicate_user_provider_groups: connection.select_value(<<~SQL.squish).to_i,
      SELECT COUNT(*)
      FROM (
        SELECT user_id, provider
        FROM oauth_identities
        GROUP BY user_id, provider
        HAVING COUNT(*) > 1
      ) duplicate_groups
    SQL
    flags: keys.to_h do |key|
      entry = entries[key]
      [key, { present: !entry.nil?, enabled: boolean.cast(entry&.value) }]
    end
  }

  raise ActiveRecord::Rollback
end

puts JSON.generate(result)
RUBY
```

Permitted query shapes only:

```sql
SELECT current_database();
SHOW transaction_read_only;
SELECT EXISTS (
  SELECT 1 FROM schema_migrations
  WHERE version = '20260812000000'
);
SELECT COUNT(*)
FROM (
  SELECT user_id, provider
  FROM oauth_identities
  GROUP BY user_id, provider
  HAVING COUNT(*) > 1
) duplicate_groups;
SELECT key, value
FROM config_entries
WHERE scope_type = 'system'
  AND scope_id IS NULL
  AND key IN ('oauth_account_resolution', 'oauth_account_consolidation');
```

The ConfigEntry result is converted inside the runner to `present` and
Boolean `enabled`; raw values are never emitted. The database name is compared
inside the runner to Rails' configured database and is never emitted. Schema
introspection may additionally call only
`data_source_exists?('oauth_account_resolutions')`.

Sanitized JSON output schema:

```json
{
  "rails_env": "production",
  "adapter": "PostgreSQL",
  "database_matches_config": true,
  "transaction_read_only": true,
  "migration_20260812000000_applied": false,
  "oauth_account_resolutions_table_present": false,
  "duplicate_user_provider_groups": 0,
  "flags": {
    "oauth_account_resolution": { "present": false, "enabled": false },
    "oauth_account_consolidation": { "present": false, "enabled": false }
  }
}
```

`present` may truthfully be true, but both `enabled` values must be false.
Before rollout the migration/table are expected absent; an already-applied
migration/table is unexpected drift and a stop for reconciliation. A duplicate
group count other than exactly zero, a non-production Rails environment,
adapter mismatch, database comparison failure, or failure to prove a read-only
transaction is an immediate stop.

No row details, totals other than the duplicate-group aggregate, identities,
users, pending resolutions, sessions, or audits may be queried.

## Phase 4 — Services, Concurrency, And Public Smoke

Use these exact read-only shapes:

```text
ssh jimmy1768_user@174.138.18.211 \
  'systemctl is-active shengfukung-wenfu-puma shengfukung-wenfu-sidekiq && systemctl show shengfukung-wenfu-puma shengfukung-wenfu-sidekiq --property=Id,ActiveState,SubState,ExecMainStartTimestamp --no-pager'

ssh jimmy1768_user@174.138.18.211 \
  'printf "conflicting_processes="; pgrep -fc "[r]ails db:migrate|[b]in/deploy|[o]auth.*consolidat|[p]rovider.*validat" || true'

curl -sS -o /dev/null -w \
  'status=%{http_code} content_type=%{content_type}\n' \
  https://shengfukung.com.tw/api/v1/temple
```

Success requires both named services active, zero conflicting processes, and
HTTP 200 with a JSON content type. Do not run `systemctl status`, journal/log
queries, a provider URL, an OAuth start/callback, an authenticated endpoint, or
retain any response body.

## Phase 5 — Non-Mutation Postcondition

Repeat only:

- remote Git status/branch/HEAD/ref resolution from Phase 1;
- the sanitized migration/table/duplicate/flag read-only runner from Phase 3;
- named service state/start timestamps from Phase 4; and
- local canonical/isolated clean and staging-empty checks.

All values must match the preflight entry observation. The packet creates no
remote/local file, ref, branch, database record, ConfigEntry, session, cache,
or service action, so ordinary rollback is `none_required_read_only`. Close the
SSH session and remove only packet-local sanitized scratch evidence after the
immutable report is committed.

If any mutation or uncertain outcome is observed, classify
`production_preflight_mutation_reconciliation_required`, stop, preserve only
sanitized evidence, and request a new Planning decision. Do not revert, delete,
restart, rewrite, or compensate under this packet.

## Stop Conditions

Stop immediately on any of:

- target/user/path/ref/checkout mismatch or dirty checkout;
- local or remote baseline drift;
- missing bundle or required-now environment-key presence;
- secret/value/body leakage into output;
- Rails environment/database/adapter/read-only-transaction mismatch;
- migration/table unexpectedly present;
- duplicate group count nonzero or unknown;
- either OAuth flag enabled or unreadable;
- named service inactive, conflicting-process count nonzero, or smoke not 200
  JSON;
- authentication/permission prompt requiring new authority;
- network ambiguity, timeout, or any evidence of mutation.

No stop condition authorizes a retry, fix, deploy, or broader inspection.

## Immutable Report And Acceptance

The Control terminal records:

- exact plan/base and accepted Candidate B tuple;
- execution start/end timestamps and elapsed time;
- target/checkout/ref/clean-state Booleans;
- bundle and environment-presence Booleans;
- the exact sanitized Rails/database JSON schema above;
- named service states, conflicting-process count, and smoke status metadata;
- pre/post equality and non-mutation confirmation;
- first stop condition, if any; and
- the smallest next owner/action.

Success classification:
`oauth_account_resolution_production_read_only_preflight_complete`.

On success, the next owner is Wenfu Planning. Planning may author a separate
Candidate B construction/review or rollout plan; neither is implied. Provider
validation, flag activation, historical remediation, and account/session work
remain separate later authorities.

## Explicit Exclusions

- no `release/current` or other ref movement, fetch, pull, checkout, merge,
  cherry-pick, commit, push, or release-candidate construction;
- no deploy, migration, schema write, restart/reload, ConfigEntry write, cache
  clear, file write, permission change, package install, or process signal;
- no provider login/start/callback/validation or central-auth mutation;
- no user/account/session/identity/pending-resolution/audit row inspection or
  mutation, and no historical remediation/consolidation;
- no secret/environment value, database name, email, provider subject, token,
  code, credential, relay address, log body, or HTTP response body output;
- no payment, Expo/mobile, EAS/device, DNS/TLS/proxy, production data repair,
  deployment, release, or push action.

Current classification:
`oauth_account_resolution_production_read_only_preflight_authorized`.

First blocker: none at dispatch. Any observed stop condition returns authority
to Planning without direct repair.
