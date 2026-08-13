# Control Packet — Payment Foundation Parallel-Track Integration

## Identity

- Accepted-plan path and immutable criteria: `ops/docs/plans/PAYMENT_FOUNDATION_PARALLEL_TRACK_INTEGRATION_PLAN.md` at canonical base `ad21758807185913f68201e27d17059afde1df96`.
- Control task and authority state: Wenfu Control A `019fc08d-676b-7ca2-be32-3efe42fa2fca`; direct Planning integration dispatch.
- Repository, worktree, branch, base: `/private/tmp/shengfukung-wenfu-payment-foundation-parallel-track-integration`, `codex/payment-foundation-parallel-track-integration`, `ad21758807185913f68201e27d17059afde1df96`.
- Immutable packet identity/attempt: `wenfu-control-a-payment-foundation-parallel-track-integration-attempt-1`; 2026-08-13 Asia/Taipei.

## Scope

- Objective: preserve Phase 1 `ab05e844067b6c6c5c8e74e45d9b1d2536fef2a1` and Phase 2 `f1049789079c93ebfe31a579ed68d6d27453f1fc` as merge ancestors, retaining qualifying-registration accounting and tenant-scoped patron provider selection together.
- Exact editable path: only `rails/app/services/payments/refund_service.rb` and `rails/test/services/payments/refund_service_test.rb` if the known overlap requires a minimal resolution; this packet record. All other checkpoint content is incorporated unchanged by Control merge.
- Known overlap rule: retain full-refund-only rejection before payment/registration/billing eligibility mutation **and** call provider resolution with the recorded payment temple for both refund and cancel.
- Explicitly excluded: any other conflict, offering/template/price, provider/Stripe/ECPay interaction or credentials/configuration, `mobile/`, `vue/`, production data, deployment, timer, release ref, push, and external action.
- Required evidence: both checkpoint ancestry; both full checkpoint matrices together; guarded disposable migration forward/rollback/forward; full Rails; changed-source syntax; partial-refund + temple propagation; qualifying timestamp, pricing, aggregate correction, tenant/provider, fake Shengfukung selection, historical binding, webhook tenant boundaries; diff checks and clean canonical/integration states.
- Database fence: every local write must use `RAILS_ENV=test` and one declared `payment_foundation_integration_*` disposable database with configured/current database equality; no development, shared test, or production DB; cleanup verified.
- First blocked surface: none known; the two specified overlaps merged automatically and require semantic review only.

## Handoff And Implementer

- Persistent Handoff: no; no exceptional continuity rationale.
- Selected ephemeral model/reasoning: `gpt-5.6-terra/high`, lowest sufficient for preserved multi-branch migration/accounting/provider-precedence semantics, concurrency, rollback, and full integration review.
- One Implementer: reviews the automatic two-path overlap resolution, edits only those paths if required by direct test evidence, runs checks, and returns to Control; no staging, commit, merge, push, deploy, secret/provider/external access, or scope expansion.

## Closeout

- Acceptance requires immutable-plan conformance and all combined checks. Control alone commits the completed Phase 2 merge and any packet record, then locally merges the accepted integration to canonical `main`.
- Terminal goes directly to Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6` with integration/ancestry/status and next owner.
- Authority confirmation: no provider, offering, Expo/Vue, production, deployment, release, timer, push, or external authority is granted.
