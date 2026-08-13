# Platform Billing Qualifying Registration Accounting Plan

Status: accepted for implementation

Accepted: 2026-08-13

Owner: Wenfu Planning

Parent roadmap:
`ops/docs/plans/SHENGFUKUNG_PAYMENT_AND_OFFERING_PHASE_ROADMAP.md`

## Objective

Replace creation-time platform metering with one deterministic qualifying-
registration accounting contract. Preserve immutable monthly statements while
making later full-refund/cancellation corrections reflect the original
statement's aggregate progressive price.

## Observed Defects

- `Billing::PlatformUsage` selects rows by registration `created_at` rather
  than the accepted qualifying event.
- A paid registration can therefore be assigned to the month in which it was
  created instead of the month in which payment completed.
- `Billing::PlatformStatementCloser` stores a fee by row ordinal and later
  credits that stored ordinal. Under progressive pricing, removing any one row
  must instead reprice the source statement's aggregate qualifying count.
- `partial_refunded` currently maps to the same terminal refunded state as a
  full refund even though V1 has no accepted partial-refund billing semantics.

## Immutable Accounting Contract

1. A paid registration qualifies exactly once at the earliest verified
   completed `TemplePayment` event for that registration. ECPay completion and
   admin-attested completed cash use the same rule. Use `processed_at`, with a
   deterministic persisted fallback only for compatible historical rows.
2. A genuinely free registration qualifies when the accepted registration is
   persisted. It does not require a fabricated payment.
3. Pending and failed paid registrations do not qualify.
4. A cancelled registration and a fully refunded registration do not qualify.
   `open` versus `fulfilled` is otherwise irrelevant to platform metering.
5. All month assignment uses the qualifying timestamp in `Asia/Taipei`.
6. One registration can contribute at most one count to one source statement,
   regardless of duplicate callbacks, multiple payment attempts, retries, or
   concurrent close attempts.
7. A full refund or cancellation after statement close creates at most one
   later adjustment for that registration. The adjustment amount is the
   difference between the source statement's progressive quote before and
   after its cumulative corrected count; it is not the removed row's ordinal
   fee. Existing closed source statements and usage evidence remain immutable.
8. V1 supports full refund only. A requested or provider-reported partial
   refund must fail closed before it can be represented as a full refund,
   change registration eligibility, or create a platform-billing credit.
9. A correction cannot make the effective source count or credited amount
   negative. Replays and concurrent correction/close attempts remain
   idempotent.
10. Tenant isolation is mandatory at query, usage-record, statement, and
    adjustment boundaries.

## Implementation Boundary

Control A owns this phase. It may change the smallest Rails model, migration,
billing/payment service, and focused test surfaces needed to implement the
contract. Any migration must be additive, reversible, compatible with existing
closed statements, and exercised through forward/rollback/forward in a
disposable test database.

Control A must not change:

- Stripe Product/Price objects, keys, webhook configuration, customers,
  invoices, subscriptions, test clocks, or any provider state;
- ECPay credentials, merchant settings, callbacks, or real/fake adapter
  selection;
- offering templates/prices, Expo/Vue surfaces, deployment, timers, production
  data, release refs, or external systems; or
- the accepted pricing tiers themselves.

## Required Evidence

- Taipei boundary cases for free acceptance and later paid completion.
- Pending, failed, cancelled, fulfilled, full-refund, and unsupported partial-
  refund behavior.
- Multiple payment attempts and duplicate completion idempotency.
- Progressive boundaries at 500/501, 2,000/2,001, and 10,000/10,001.
- Aggregate repricing when arbitrary early or late usage rows are corrected,
  including multiple corrections from one source statement.
- Close retry/concurrency and adjustment replay/concurrency evidence.
- Cross-tenant denial and historical closed-statement compatibility.
- Existing platform-billing lifecycle, Stripe collection (stubbed), account,
  admin cash, payment sync, refund, and statement regressions.
- Ruby syntax, migration status/rehearsal when applicable, and
  `git diff --check`.

## Acceptance Criteria

The phase is complete only when all ten accounting rules are implemented and
the required evidence passes with no provider/external call. Control A commits
one accepted immutable pre-integration checkpoint on its isolated branch and
sends one terminal packet to Wenfu Planning. It does not merge canonical
`main` during this parallel track.

## Next Step

Planning waits for both this Phase 1 terminal and the parallel Phase 2 terminal
before authoring the shared integration continuation through Control A and the
later Phase 3 plan. Control A does not coordinate directly with Control B.
