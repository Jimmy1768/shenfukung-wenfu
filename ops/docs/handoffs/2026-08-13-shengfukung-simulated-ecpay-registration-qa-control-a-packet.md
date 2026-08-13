# Control Packet — Shengfukung Simulated ECPay Registration QA

## Identity

- Accepted plan: `ops/docs/plans/SHENGFUKUNG_SIMULATED_ECPAY_REGISTRATION_QA_PLAN.md`, canonical base `1e69a28302394102b49e616088f0e681e00950ba`.
- Control: Wenfu Control A `019fc08d-676b-7ca2-be32-3efe42fa2fca`, direct Planning dispatch.
- Worktree/branch: `/private/tmp/shengfukung-wenfu-simulated-ecpay-registration-qa` / `codex/shengfukung-simulated-ecpay-registration-qa` at the exact accepted base.
- Immutable packet/attempt: `wenfu-control-a-shengfukung-simulated-ecpay-registration-qa-attempt-1`; 2026-08-13 Asia/Taipei.

## Scope

- Objective: establish only local/disposable Phase 4 proof for the four accepted Shengfukung offerings at `TWD` / `price_cents: 5000`, fake hosted lifecycle, cash/refund/cancellation/accounting outcomes, and the bounded internal-TWD-to-ECPay wire contract.
- Exact editable paths: `rails/app/services/payment_gateway/fake_adapter.rb`, `rails/app/services/payment_gateway/ecpay_adapter.rb`, `rails/app/services/payments/checkout_return_service.rb`, `rails/app/services/payments/webhook_ingest_service.rb`, one minimal payment amount helper under `rails/app/lib/payments/taiwan/` or `rails/app/services/payments/`, directly affected Rails payment/account/admin/billing tests, and this packet record.
- Immutable expected repair: ECPay accepts only positive, whole-TWD-representable internal amounts; internal `5000` serializes as `TotalAmount=50`; signed callback/return `TradeAmt=50` normalizes to internal `5000`; currency/amount/checksum/tenant/reference/event mismatches fail before payment, registration, audit, or billing mutation.
- Required evidence: every accepted A–E scenario, all four authoritative disposable offering templates/prices, forged client authority resistance, patron/admin/fake/cash/failure/recovery/cancellation/full-refund/partial rejection/idempotency/isolation/Taipei close/correction; local ECPay wire fields/checksum/amount safety without network.
- Explicit exclusions: migration/schema; offering definition changes unless a true Planning stop; real provider/API/key/card/money/hosted checkout; network, credential/config inspection, shared/development/production DB, `mobile/`, `vue/`, deployment, release, timer, push, Phase 5, product redesign, and external action.
- Database fence: every write uses `RAILS_ENV=test` plus one exact disposable `shengfukung_simulated_ecpay_*` DB; Rails-configured database and `current_database()` must both equal it before each write; cleanup/final absence required.
- Required checks: focused complete Phase 4 matrix; fake/ECPay/checkout/return/webhook/cash/refund/registration/offering/provider/accounting regression suites; full Rails; source syntax/diff; no migration/schema command; network/provider/source scan; clean final state.

## Handoff And Implementer

- Persistent Handoff: no, no continuity exception.
- Ephemeral model: `gpt-5.6-terra/high`; lowest sufficient for payment protocol amount integrity, callback/replay/tenant enforcement, retained accounting correction, and disposable lifecycle matrix.
- One Implementer: edit only the stated Rails paths, run guarded checks, return directly; no staging, commit, merge, push, deploy, provider/credential/external action, or scope expansion.

## Closeout

- Control accepts only after all frozen criteria pass, commits accepted local work, then locally integrates into canonical main as this plan authorizes.
- One terminal packet goes directly to Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Authority confirmation: this packet does not authorize real ECPay/Stripe activity, money, credentials, production/deployment, Expo/Vue, or Phase 5.
