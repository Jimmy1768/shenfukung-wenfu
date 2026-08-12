# Control packet — OAuth account-resolution production read-only preflight

## Authority and target

- Planning: Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Accepted plan:
  `ops/docs/plans/OAUTH_ACCOUNT_RESOLUTION_PRODUCTION_READ_ONLY_PREFLIGHT_PLAN.md`.
- Base: `988283842f145387633646c6c2856ef66ce04a61`.
- Candidate boundary: `99a0a692` plus, in order, `684c9ef`, `740aa39`,
  `7fa60f0`, `6eb57c3`, `dcc258b`; this packet does not construct it.
- Isolated branch/worktree: `codex/oauth-account-resolution-production-preflight`
  at `/private/tmp/shengfukung-wenfu-oauth-account-resolution-production-preflight`.
- Exact production target: `jimmy1768_user@174.138.18.211`, checkout
  `/home/jimmy1768_user/Projects/shengfukung-wenfu`, expected baseline
  `99a0a6929c5cb0eace21d5fa074cdab3950b269c`.

## Immutable execution boundary

Control alone performs the single bounded SSH/network observation within the
accepted 20-minute Asia/Taipei window. Before each call it checks that the
command names only the exact target/path and has no write capability. It
executes only the plan's Phase 1–5 command shapes: target/checkout/ref/bundle,
environment presence Booleans, transaction-read-only sanitized Rails aggregate,
named service/concurrency status, body-discarding tenant smoke, and prescribed
postcondition repeats. Any stop condition, output leak, timeout, drift,
permission prompt, or uncertainty stops the sequence with no retry or repair.

## Persistent scope and Implementer

The only editable paths are this packet and the required sanitized report:
`ops/docs/handoffs/2026-08-12-oauth-account-resolution-production-read-only-preflight-control-a.md`.
One ephemeral `gpt-5.6-terra/medium` Implementer performs only a local static
review of the plan/report redaction and report completeness. Medium is the
lowest sufficient allocation because it has no production authority, executes
no SSH/network/database/runtime command, and edits only the report if asked by
Control. It must not stage, commit, merge, push, deploy, access secrets or
external systems, or mutate state; it returns directly to Control.

## Required evidence and closeout

Report only safe Booleans, accepted hashes, timestamps, elapsed time, the
sanitized Rails JSON fields, service/concurrency/smoke metadata, pre/post
equality, stop condition if any, and the smallest next owner/action. Never
retain secret/environment values, database names, response bodies, logs,
emails, subjects, tokens, codes, credentials, or identities. On acceptance,
Control commits/integrates only the packet/report records locally and sends one
terminal to Planning. No release construction, ref movement, deployment,
migration, restart, flag/config change, provider/session/account action, or
historical remediation is owned.
