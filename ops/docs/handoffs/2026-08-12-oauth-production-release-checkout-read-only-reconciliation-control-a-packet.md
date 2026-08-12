# Control packet — OAuth production release checkout read-only reconciliation

Accepted plan: `ops/docs/plans/OAUTH_PRODUCTION_RELEASE_CHECKOUT_READ_ONLY_RECONCILIATION_PLAN.md` at `6eab9957f0ad107604cc4836646aea6a634f8b84`.

Isolated source: `codex/oauth-production-release-checkout-reconciliation` at
`/private/tmp/shengfukung-wenfu-oauth-production-release-checkout-reconciliation`.

Control will run exactly the plan's one noninteractive SSH command, once, and
no other remote command. It will retain only the permitted normalized porcelain
aggregates/path schema. Any unsafe/ambiguous output stops all further action.
Persistent edits are limited to this packet and
`ops/docs/handoffs/2026-08-12-oauth-production-release-checkout-read-only-reconciliation-control-a.md`.

One ephemeral `gpt-5.6-terra/medium` Implementer performs local static
sanitization/report review only and has no production, SSH, network, database,
provider, secret, account, runtime, staging, commit, push, or external authority.
