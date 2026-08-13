# Control Packet — Platform Billing Qualifying Registration Accounting

## Identity

- Accepted-plan path and immutable criteria: `ops/docs/plans/PLATFORM_BILLING_QUALIFYING_REGISTRATION_ACCOUNTING_PLAN.md` at `75e16f5fa2e53cc8afa56819f7f1a3981246b210`.
- Control task and authority state: Wenfu Control A `019fc08d-676b-7ca2-be32-3efe42fa2fca`; direct Planning Phase 1 parallel-track dispatch.
- Repository, worktree, branch, and base HEAD: `/private/tmp/shengfukung-wenfu-platform-billing-qualifying-registration-accounting`, `codex/platform-billing-qualifying-registration-accounting`, `75e16f5fa2e53cc8afa56819f7f1a3981246b210`.
- Packet status/date: immutable before implementation; 2026-08-13 Asia/Taipei.
- Immutable packet identity/attempt: `wenfu-control-a-platform-billing-qualifying-registration-accounting-attempt-1`.

## Scope

- Objective: replace creation-time usage selection and ordinal-row credits with one Taipei-time qualifying-registration accounting contract, immutable source statements, aggregate progressive repricing corrections, idempotent adjustment/close behavior, and full-refund-only safety.
- Exact editable paths: `rails/app/models/temple_payment.rb`, `rails/app/models/platform_billing_usage_record.rb`, `rails/app/models/platform_billing_adjustment.rb`, `rails/app/services/billing/platform_usage.rb`, `rails/app/services/billing/platform_statement_closer.rb`, `rails/app/services/payments/status_mapper.rb`, `rails/app/services/payments/refund_service.rb`, `rails/app/services/payments/registration_payment_sync.rb`, any minimal new Rails-only billing/accounting service, one new additive reversible Rails migration and `rails/db/schema.rb`, directly supporting Rails tests under `rails/test/services/billing/`, `rails/test/services/payments/`, and existing payment/account/admin integration test paths only, plus this packet record.
- Explicitly excluded: Stripe/ECPay/provider calls or adapter/configuration/credentials; offering/pricing-tier changes; `mobile/`, `vue/`, deploy/release refs, timers/jobs, production/shared data, external actions, canonical-main merge, and Control B coordination.
- Required evidence: all ten accepted accounting rules; Taipei free/payment timestamp edges; pending/failed/cancelled/fulfilled/full-refund/partial-refund behavior; multiple payment/duplicate completion; pricing bands 500/501, 2,000/2,001, 10,000/10,001; arbitrary/multiple aggregate corrections; close/adjustment retry and concurrency; tenant isolation/historical statement compatibility; billing lifecycle/Stripe stubs/account/admin cash/payment sync/refund/statement regressions; Ruby syntax, guarded migration forward/rollback/forward, migration status, diff checks.
- Database safety: use only `RAILS_ENV=test` and a fresh packet-owned `platform_billing_qualifying_*` disposable PostgreSQL database. Before every schema/migration/test fixture write, configured DB and `current_database()` must both equal the declared disposable name; no development, shared/default test, or production DB. Verify cleanup at end.
- Evidence source status: plan/roadmap documented; existing Rails billing behavior observed locally; provider/production state unknown and excluded.
- First blocked surface: none known.

## Incident-Correction Placement

- Incident correction: no; accepted Phase 1 accounting implementation.
- Selected surface: bounded Rails source/migration/tests plus immutable Control record.
- `AGENTS.md` excluded without explicit Director authorization.

## Repair And Terminal Boundary

- Bounded nonterminal repair: yes, `wenfu-control-a-platform-billing-qualifying-registration-accounting-repair-attempt-2`.
- Observed evidence gap: the candidate had retry and database-uniqueness evidence but no direct concurrent close/adjustment execution proof required by the accepted plan.
- Direct mechanism/owned path: add one deterministic two-connection local Rails regression in `rails/test/services/billing/platform_billing_qualification_correction_test.rb` (and only a minimal production repair if the direct test exposes a defect). Re-run the focused accounting/payment suite, migration checks, syntax, and `git diff --check` against the same guarded disposable database rule.
- Planning packet prohibited until one terminal disposition: yes.
- Required terminal shape: accepted immutable pre-integration checkpoint only; do not merge canonical `main`.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no; no exceptional continuity reason.
- Eligibility before model selection: yes; Luna is never ephemeral.

## Implementer Dispatch

- Selected model/reasoning: `gpt-5.6-terra/high`.
- Lowest-sufficient rationale: additive/reversible accounting persistence, immutable retained statements, source/adjustment idempotency/concurrency, aggregate repricing, and migration rollback evidence are deeper bounded work.
- One ephemeral Implementer: edits packet-owned Rails paths only and returns evidence directly to Control.
- Implementer boundaries: no staging, commit, merge, push, deploy, external/provider/secret action, canonical-main manipulation, or scope expansion.

## Control Review And Closeout

- Review: accepted after direct diff/schema review; two bounded repairs closed the refunded-free eligibility ordering/schema-residue defect and the missing direct two-connection close/adjustment concurrency proof. The final independent guarded full Rails suite passed 468 runs / 2792 assertions with zero failures, errors, or skips; the exact Control disposable database was removed and final packet-database inventory was zero.
- Integration: commit accepted checkpoint on this isolated branch only; no canonical-main merge.
- Terminal: direct to Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`, one immutable pre-integration checkpoint with next owner Planning.
- Authority confirmation: no provider, secret, offering, Expo/Vue, production, deployment, release-ref, timer, push, or external action is authorized.
