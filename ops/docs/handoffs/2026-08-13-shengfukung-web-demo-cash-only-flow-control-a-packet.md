# Control Implementation Packet — Shengfukung Web Demo Cash-Only Flow

## Identity

- Accepted plan and immutable criteria: `ops/docs/plans/SHENGFUKUNG_WEB_DEMO_CASH_ONLY_FLOW_PLAN.md` at `031cc0ad82aac1fdebba6ba85996fe8fa58be034`.
- Control: Wenfu Control A `019fc08d-676b-7ca2-be32-3efe42fa2fca`; active ordinary Planning-to-Control dispatch.
- Repository/worktree/branch/base: `/Users/jimmy1768/Projects/shengfukung-wenfu`; `/private/tmp/shengfukung-wenfu-web-demo-cash-only-flow`; `codex/shengfukung-web-demo-cash-only-flow`; `031cc0ad82aac1fdebba6ba85996fe8fa58be034`, clean with empty staging at packet creation.
- Immutable packet: `wenfu-control-a-shengfukung-web-demo-cash-only-flow-attempt-1`, 2026-08-13 Asia/Taipei.

## Scope

- Objective: implement the local Rails/web contract for Shengfukung's explicit no-online-provider/cash-only demo state, authoritative one-time admin cash settlement, and exactly-once qualifying accounting.
- Owned paths: `rails/db/seeds/temples.rb`; `rails/app/services/payments/{provider_resolver,checkout_service,cash_payment_recorder}.rb`; directly required account/admin payment controller or helper paths; `rails/app/views/account/registrations/payment.html.erb`; directly required account locale files; and directly affected Rails tests under `rails/test/services/payments/`, `rails/test/services/`, and `rails/test/integration/{account,admin,api}/`, plus this packet.
- Excluded: migrations/schema, offering YAML/definitions or fifth-offering decisions, Stripe/ECPay/provider configuration or credentials, any network/provider/card/money action, Expo/Vue/device/EAS, deployment/SSH/production/shared-development data, release refs, push, Phase 2, Apple OAuth, and all unrelated UI or product changes.
- Required evidence: two-locale cash-only account presentation with no checkout/retry/provider claim; direct account/admin checkout no-side-effect failure; server-authoritative full cash settlement; duplicate and two-connection concurrency single-result proof; one qualifying `completed_cash` usage contribution at the persisted completion timestamp; retained provider/free/failed/refunded/frozen/tenant/authority/audit behavior; focused and full Rails evidence, syntax/YAML, diff/path/network scans, and exact disposable-test-DB cleanup.
- Database fence: every database write is `RAILS_ENV=test` against an exact fresh packet-owned disposable `shengfukung_web_demo_cash_*` database whose configured and `current_database()` names are proved equal before writes; final absence is mandatory.

## Execution

- Incident correction: no; this implements an accepted Phase 1 source contract. `AGENTS.md` is excluded.
- Persistent Handoff: no; one normal ephemeral Implementer returns directly to this Control.
- Implementer allocation: `gpt-5.6-terra/high`, the lowest sufficient selection because this packet changes retained cash-payment/ledger/audit/registration state and requires duplicate/concurrent settlement and accounting idempotency proof.
- Implementer boundaries: owned paths only; no staging, commit, merge, push, deploy, approval handling, secret/provider access, external mutation, scope expansion, or Planning traffic.

## Review And Closeout

- Control accepts only all immutable criteria, independently reviews the diff and evidence, locally integrates accepted work into clean canonical `main`, and sends one immutable terminal to Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- First known blocker: none.
