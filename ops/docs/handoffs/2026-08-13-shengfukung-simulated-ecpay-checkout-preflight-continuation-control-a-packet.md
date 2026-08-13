# Control Continuation Packet — Simulated ECPay Checkout Preflight

## Identity

- Accepted continuation: `ops/docs/plans/SHENGFUKUNG_SIMULATED_ECPAY_CHECKOUT_PREFLIGHT_CONTINUATION_PLAN.md` at canonical `bcb4e1aa8f0a8bc41f8f231875e204ef58bc7784`; parent base `1e69a28302394102b49e616088f0e681e00950ba`.
- Prior terminal: `wenfu-control-a-shengfukung-simulated-ecpay-registration-qa-checkout-scope-gap` accepted as a true planning design gap.
- Control/worktree: Wenfu Control A `019fc08d-676b-7ca2-be32-3efe42fa2fca`; `/private/tmp/shengfukung-wenfu-simulated-ecpay-registration-qa`; `codex/shengfukung-simulated-ecpay-registration-qa`; candidate provenance verified at exact parent base, staging empty, and only parent-owned paths changed/untracked.
- Immutable packet/attempt: `wenfu-control-a-shengfukung-simulated-ecpay-checkout-preflight-continuation-attempt-2`; 2026-08-13 Asia/Taipei.

## Scope

- Objective: retain the exact stopped candidate, add only CheckoutService pre-persistence ECPay validation via the existing narrow amount helper, then complete all parent Phase 4 local-only criteria.
- Exact new authority: `rails/app/services/payments/checkout_service.rb` and its directly affected test only, in addition to the preserved parent candidate paths.
- Required behavior: before `create_pending!`, ECPay accepts only positive whole-TWD-representable internal amounts; `5000` maps to provider amount `50`; invalid currency, missing/malformed/zero/negative/fractional-TWD inputs raise with no payment/registration/audit/webhook/statement/usage/adjustment mutation. Reuse the one existing normalization helper; valid fake checkout/reuse semantics remain unchanged.
- Excluded: all other product paths, migrations/schema, offering definition edits, real providers/credentials/network/card/money, shared/development/production DB, Expo/Vue, deployment/release/timer/push, Phase 5, and external action.
- Required evidence: the complete parent A–E matrix plus direct pre-persistence negative-state counts and valid ECPay serialization/pending-payment proof; focused/full Rails, syntax, source/path scan, diff checks, and disposal cleanup.
- Database fence: all writes require `RAILS_ENV=test` and one exact packet-owned `shengfukung_simulated_ecpay_*` disposable DB with Rails configured/current-database equality before every write; final absence required.

## Implementer

- Persistent Handoff: no.
- Selected ephemeral allocation: `gpt-5.6-terra/high`, the lowest sufficient for payment mutation sequencing, callback/replay/tenant safety, accounting correction, and full local matrix.
- One fresh Implementer returns directly to Control; no staging, commit, merge, push, deployment, provider/secret/external action, or scope expansion.

## Closeout

- Control accepts only all parent and continuation criteria. On acceptance, commits the complete candidate, locally integrates it into clean canonical main preserving the continuation-plan ancestor, and sends one replacement terminal to Planning.
- No partial/failed candidate integration.
