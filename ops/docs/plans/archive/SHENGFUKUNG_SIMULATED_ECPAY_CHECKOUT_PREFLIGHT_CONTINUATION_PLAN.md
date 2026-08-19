# Shengfukung Simulated ECPay Checkout Preflight Continuation Plan

Status: accepted for implementation

Accepted: 2026-08-13

Owner: Wenfu Planning

## Exact Authority

- Canonical repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`
- Canonical base: `1e69a28302394102b49e616088f0e681e00950ba`
- Parent Phase 4 plan:
  `ops/docs/plans/SHENGFUKUNG_SIMULATED_ECPAY_REGISTRATION_QA_PLAN.md`
- Accepted stopped terminal:
  `wenfu-control-a-shengfukung-simulated-ecpay-registration-qa-checkout-scope-gap`
- Existing isolated branch/worktree:
  `codex/shengfukung-simulated-ecpay-registration-qa` /
  `/private/tmp/shengfukung-wenfu-simulated-ecpay-registration-qa`

The parent criteria remain unchanged. This continuation resolves only the
identified source-path and sequencing authority gap.

## Accepted Diagnosis

`Payments::CheckoutService` currently creates a pending payment before it
invokes `EcpayAdapter#checkout`. Adapter-only validation therefore cannot make
invalid ECPay currency or non-whole-TWD amounts fail before payment mutation,
as the parent plan requires.

## Bounded Correction

This continuation adds `rails/app/services/payments/checkout_service.rb` and
its directly affected test to the parent packet's authorized paths.

The correction must validate an ECPay checkout's internal amount and currency
before `PaymentRepository#create_pending!`:

- provider `ecpay` accepts only currency `TWD`;
- the internal amount must be positive and exactly representable as a whole
  TWD amount;
- internal `5000` must map to provider amount `50`;
- invalid currency, zero/negative, fractional-TWD, missing, or malformed
  amount must raise before any payment, registration, audit, webhook,
  statement, or billing-usage mutation; and
- valid fake-provider behavior remains unchanged.

Use the same narrowly scoped ECPay amount-normalization authority from the
parent plan. Avoid a second divergent conversion implementation. No generic
multi-currency framework or adapter lifecycle redesign is authorized.

## Candidate Handling

Control may retain the existing unstaged candidate only as implementation
input after verifying:

1. its HEAD is the exact canonical base;
2. every changed/untracked path is parent-packet-owned;
3. staging is empty; and
4. its diff matches the stopped terminal's described local work.

Control must freeze a fresh continuation packet and dispatch one fresh
ephemeral Implementer to review the retained candidate, add the authorized
pre-persistence correction, complete the full parent matrix, and return
evidence. If provenance or path scope differs, stop rather than overwrite or
infer ownership.

## Required Evidence

In addition to every unmet parent-plan criterion:

1. Directly prove invalid ECPay currency and each invalid amount class leave
   payment, registration, audit, webhook log, statement, usage, and adjustment
   counts/state unchanged.
2. Prove valid ECPay TWD 5000 reaches adapter serialization exactly once and
   records one pending payment at internal amount 5000.
3. Prove fake checkout creation/reuse semantics are unchanged.
4. Rerun the parent focused matrix, full Rails suite, Ruby syntax, source/path
   scans, and `git diff --check` in the exact guarded disposable test database.
5. Remove the disposable database and temporary artifacts, and prove both
   isolated and canonical worktrees end clean with empty staging.

## Integration And Boundaries

On full acceptance, Control A may commit the complete accepted candidate and
locally integrate it into clean canonical `main`, then return one replacement
immutable Phase 4 terminal packet. No partial candidate or failed report is
integrated.

All parent exclusions remain: no real provider, account, credential, network,
card, money, refund, shared/production data, migration/schema, Expo/Vue,
deployment, release, push, or Phase 5 action.

## Completion

Acceptance of the replacement terminal completes Phase 4 and the repository-
local payment program. Planning then records Phases 1–4 complete and leaves
Phase 5A Stripe sandbox, Phase 5B live ECPay, and Expo payment UI deferred.
