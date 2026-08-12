# OAuth Production Release Checkout Read-Only Reconciliation Plan

Status: accepted for direct dispatch to Control A after commit

Created: 2026-08-12

Owner: Wenfu Planning

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Canonical Planning base:
`920bcce`

Accepted preflight retry report:
`ops/docs/handoffs/2026-08-12-oauth-account-resolution-production-read-only-preflight-retry-control-a.md`

## Objective

Perform one target-fenced, read-only Git inventory of the dirty production
release checkout that stopped the accepted OAuth preflight. Determine only the
kind and bounded path inventory of checkout drift so Planning/Director can
decide whether the checkout may be cleaned, preserved, or replaced under a
later separately authorized packet.

This packet is diagnosis only. It must not clean, stage, restore, reset,
checkout, stash, delete, move, fetch, pull, merge, commit, push, deploy,
migrate, restart, or otherwise change the checkout or any external state. It
must not resume the OAuth preflight after observing the inventory.

## Exact Target And Known State

- SSH target: `jimmy1768_user@174.138.18.211`
- checkout:
  `/home/jimmy1768_user/Projects/shengfukung-wenfu`
- expected branch: `release/current`
- expected checkout/ref/remote baseline:
  `99a0a6929c5cb0eace21d5fa074cdab3950b269c`
- accepted observation: target/user/path and branch/HEAD/release/current/
  origin/release/current fences passed, but checkout clean state was false;
  no individual path was inspected.

Run once within 10 minutes on 2026-08-12 Asia/Taipei. Control A owns the one
SSH observation and sanitization. At most one ephemeral Implementer may
prepare/static-review the local report only and receives no SSH/production
authority.

## Corrected Local Fence

Use a fresh isolated codex-prefixed packet from the exact committed plan tip.
Require that isolated worktree clean/staging empty and canonical `main` clean/
staging empty with the plan tip as ancestor. Later canonical commits are
acceptable only when they are already-authorized Expo runtime callback/report
documentation and contain no Rails/OAuth/deployment/release/environment/
product source change. Any other drift stops before SSH.

## Exact Remote Read-Only Command Shape

Execute one noninteractive SSH command only:

```text
ssh jimmy1768_user@174.138.18.211 \
  'cd /home/jimmy1768_user/Projects/shengfukung-wenfu && test "$(id -un)" = jimmy1768_user && test "$(readlink -f .)" = /home/jimmy1768_user/Projects/shengfukung-wenfu && test "$(git branch --show-current)" = release/current && test "$(git rev-parse HEAD)" = 99a0a6929c5cb0eace21d5fa074cdab3950b269c && test "$(git rev-parse release/current)" = 99a0a6929c5cb0eace21d5fa074cdab3950b269c && test "$(git rev-parse origin/release/current)" = 99a0a6929c5cb0eace21d5fa074cdab3950b269c && git status --porcelain=v1 --untracked-files=all'
```

No shell wildcard, file read, diff, log, content hash, size, timestamp, owner,
permission, symlink-target inspection below the checkout, or second remote
command is authorized.

## Sanitization And Safe Output Schema

Control parses porcelain output locally and retains only:

- target/branch/ref fence Booleans;
- total changed-path count;
- counts by two-character Git status code;
- normalized repository-relative path strings, only when each path passes all
  safe-path rules below; and
- top-level directory counts.

A safe path must be valid UTF-8, repository-relative, contain no control
character/newline, not begin with `/` or `../`, and not equal or lie under any
of:

```text
.env
.env.*
config/credentials*
rails/config/credentials*
rails/config/master.key
log/
rails/log/
tmp/
rails/tmp/
storage/
rails/storage/
vendor/
node_modules/
mobile/node_modules/
```

If any path is unsafe, sensitive-looking, ambiguous, quoted/escaped by Git,
renamed with two path components, or fails normalization, do not retain any
path list. Emit only `unsafe_or_ambiguous_path_present: true`, status/count
aggregates, and stop. Do not decode or inspect it.

Sanitized report schema:

```json
{
  "target_match": true,
  "branch_match": true,
  "head_match": true,
  "release_ref_match": true,
  "origin_release_ref_match": true,
  "checkout_clean": false,
  "changed_path_count": 0,
  "status_counts": {},
  "top_level_counts": {},
  "safe_paths": [],
  "unsafe_or_ambiguous_path_present": false
}
```

Do not retain path contents, diff hunks, file metadata, Git config, remote URL,
logs, environment/config values, secrets, database information, user/account/
identity/session data, provider data, or application response bodies.

## Stop Conditions And Interpretation

Stop on target/user/path/branch/ref mismatch, SSH ambiguity, output parse
failure, unsafe/ambiguous path, or any evidence of mutation.

If every dirty path is safe and the inventory is complete, classification is
`oauth_production_release_checkout_read_only_reconciliation_complete`.
Planning then owns the cleanup/preservation decision. A known path is not
permission to remove or overwrite it.

If unsafe/ambiguous, classification is
`oauth_production_release_checkout_reconciliation_blocked`; next action is a
new Director decision on a narrower privileged inspection method.

Ordinary rollback is `none_required_read_only`. If any mutation or uncertain
outcome is observed, classify
`production_checkout_mutation_reconciliation_required` and do not compensate.

## Postcondition

The single `git status --porcelain` observation itself is the only checkout
state read. Do not issue a second remote command for postcondition proof. The
durable report states no mutation-capable command was run and that the SSH
session closed. Verify only local canonical/isolated clean and staging-empty
state and `git diff --check` after committing the sanitized report.

## Explicit Exclusions

- no remote file/content/diff/log/config/environment/database/service/process
  inspection beyond the exact one-command Git porcelain inventory;
- no clean/stage/restore/reset/checkout/stash/delete/move/fetch/pull/merge/
  cherry-pick/commit/push/ref/candidate action;
- no bundle, Rails runner, database query, systemctl, pgrep, curl, smoke,
  provider, account/session/identity/remediation observation or action;
- no deploy/migration/restart/flag/config/permission/package/DNS/TLS/payment/
  Expo/build/release action;
- no secrets, credentials, values, bodies, or private data in chat/report.

Current classification:
`oauth_production_release_checkout_read_only_reconciliation_authorized`.

First blocker: none at dispatch. Any stop condition returns authority to
Planning without repair or preflight continuation.
