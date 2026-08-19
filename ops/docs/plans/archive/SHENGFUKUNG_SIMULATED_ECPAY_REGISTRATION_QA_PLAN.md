# Shengfukung Simulated ECPay Registration QA Plan

Status: accepted for implementation

Accepted: 2026-08-13

Owner: Wenfu Planning

## Exact Base

- Canonical repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`
- Branch: `main`
- Accepted Phase 3 canonical base:
  `e10d05945fb2570b5293c937a81e28880e51647c`
- Governing roadmap:
  `ops/docs/plans/SHENGFUKUNG_PAYMENT_AND_OFFERING_PHASE_ROADMAP.md`

The accepted qualifying-registration accounting, tenant-scoped provider
selection, and four-offering NT$50 configuration are ancestors of this base.

## Objective

Close Phase 4 with one network-free, disposable-data proof of the complete
patron-payment lifecycle that can be exercised without a real ECPay merchant:

- patron- and admin-started registrations;
- fake hosted-checkout start/return and webhook state transitions;
- cash completion;
- failed, cancelled, recovered, and fully refunded outcomes;
- idempotency and tenant isolation;
- monthly qualifying-registration inclusion and later correction; and
- exact internal-to-ECPay TWD amount serialization/callback correlation.

Every offering/payment scenario uses the four accepted Shengfukung templates
at exactly TWD 50 (`price_cents: 5000`). No card, real ECPay request, money
movement, provider account, or credential is involved.

## Readiness Finding: Local ECPay Amount Contract

The accepted source stores monetary values in minor units and formats `5000`
TWD as `NT$50`. ECPay's `TotalAmount`/`TradeAmt` wire fields are whole TWD
integers. The current adapter passes `amount_cents` directly into
`TotalAmount`, so an internal `5000` would be serialized as `5000` rather than
`50`. The current callback normalization also does not expose and correlate
signed `TradeAmt` with the recorded payment amount.

This is a repository-local protocol defect, not a live-provider blocker. This
packet explicitly authorizes the smallest payment-boundary correction and
tests needed to:

1. accept only TWD for ECPay checkout;
2. require a positive amount exactly representable as whole TWD;
3. serialize internal `5000` as wire `TotalAmount=50`;
4. normalize signed callback/browser-return `TradeAmt=50` back to internal
   `amount_cents=5000`; and
5. fail closed before payment, registration, audit, or billing qualification
   mutation when a provider-reported amount or currency conflicts with the
   recorded payment.

Do not generalize this into exchange-rate, settlement, tax, invoice, or
multi-currency infrastructure. Do not infer live ECPay behavior beyond the
documented local contract.

## Required Scenario Matrix

Use a fresh, explicitly guarded Shengfukung-shaped test tenant. Apply the four
templates locally, publish them only inside disposable test data, and prove
all retain authoritative `TWD` / `5000` pricing.

### A. Patron Fake Hosted Checkout

- Create a patron registration through the existing account path for one
  approved service.
- Prove forged client price/currency/title fields cannot change the persisted
  offering authority.
- Start fake checkout; prove one pending payment records provider `fake`,
  amount `5000`, TWD, tenant, intent, and idempotency.
- Follow the existing fake return/query path to completed/paid.
- Prove replay cannot create a second completed charge or qualifying usage.

### B. Admin-Started Online And Cash

- Create one registration through the existing admin offering-order path and
  complete it through the tenant-selected fake checkout.
- Create another admin-started registration and record exact TWD 50 cash using
  existing admin authority.
- Prove both use the intended temple/offering/registrant, become paid only on
  their accepted completion event, and qualify once.
- Do not redesign the existing admin ability to operate an offering/order;
  this phase verifies the approved default price and payment lifecycle.

### C. Failure, Recovery, Cancellation, And Refund

- Drive a pending fake payment to failed through a unique simulated webhook;
  prove the registration is failed and excluded from monthly usage.
- Retry through the existing recorded-provider behavior, create one new
  attempt, complete it, and prove exactly one registration qualification.
- Cancel a separate pending attempt through the fake adapter; prove failed or
  cancelled business state is excluded.
- Fully refund a completed TWD 50 fake payment; prove payment/registration
  refund state, full-refund-only enforcement, and exclusion/correction.
- A partial-refund request and provider-reported partial refund must fail
  closed before mutation.

### D. Webhook, Isolation, And Accounting

- Prove a completed fake webhook is idempotent by provider event ID.
- Prove the same provider reference under another temple cannot mutate the
  Shengfukung payment or registration.
- Close the qualifying Taipei month and prove only completed online/cash
  registrations appear once; pending, failed, cancelled, and refunded rows do
  not.
- Apply a full refund after the source month closes, close the next month, and
  prove one aggregate-repricing correction while the source statement remains
  immutable. Retry must not duplicate the statement, usage, or adjustment.

### E. Local ECPay Wire Contract

Using only local nonsecret fixture values and no network:

- prove TWD `5000` produces `TotalAmount=50` and the checksum covers that exact
  field;
- prove a valid signed `TradeAmt=50` normalizes to internal `5000` and can
  complete only the matching tenant/provider/payment;
- prove signed `TradeAmt=49`, missing/invalid/zero/non-integer amount, non-TWD
  checkout, bad checksum, duplicate event, and cross-tenant reference fail
  closed as appropriate;
- prove no secret or raw sensitive provider field enters audit/report output.

Fake runtime journeys and local ECPay serialization checks are distinct
evidence. Neither is described as an ECPay stage/live transaction.

## Authorized Paths And Repairs

Control owns one bounded packet and one ephemeral Implementer. It may add the
combined Phase 4 acceptance test and make only the smallest corrections in:

- `rails/app/services/payment_gateway/fake_adapter.rb`;
- `rails/app/services/payment_gateway/ecpay_adapter.rb`;
- `rails/app/services/payments/checkout_return_service.rb`;
- `rails/app/services/payments/webhook_ingest_service.rb`;
- one narrowly scoped payment amount-normalization helper under
  `rails/app/lib/payments/taiwan/` or `rails/app/services/payments/` if needed;
- directly affected payment/account/admin/billing tests; and
- the Control handoff record.

Do not change the four offering definitions unless the exact accepted Phase 3
values are proven missing or corrupted, which is a Planning stop. Any need for
a schema migration, provider credential, external callback, UI redesign,
partial-refund product semantics, payment settlement, or broad currency
framework is also a stop.

## Required Checks

1. Focused combined Phase 4 test matrix covering every scenario above.
2. Existing fake/ECPay adapter, checkout, return, webhook, cash, refund,
   registration, offering-authority, provider-resolver, and platform-accounting
   suites.
3. Full Rails suite because the packet couples provider serialization,
   registration state, and platform accounting.
4. Ruby syntax for every changed source file and `git diff --check`.
5. Any migration/schema command is prohibited; if unexpectedly required, stop.
6. All database writes use `RAILS_ENV=test` and an exact packet-owned
   disposable database with configured/current-database fencing. Prove final
   database and temporary-artifact absence.
7. Source/network scan proves no real ECPay/Stripe request, credential access,
   external hostname call, or card/payment artifact occurred.

## Exclusions

No real ECPay or Stripe account, key, console, API, hosted checkout, callback,
refund, card, or money movement. No shared-development or production data. No
deployment, timer, release ref, push, Expo/Vue payment UI, admin product
creation redesign, offering ambiguity work, Phase 5 preflight, legal,
accounting, tax, invoice, or settlement claim.

## Acceptance And Integration

Control must create an isolated `codex/` branch/worktree from the exact clean
plan commit, freeze its implementation packet, and use one ephemeral
Implementer. Control independently verifies every criterion. On full
acceptance it may locally integrate the result into clean canonical `main` and
return one immutable terminal packet. No intermediate Planning traffic is
needed unless unchanged criteria produce a true stop.

## Completion Meaning

Acceptance closes the repository-local payment program through Phase 4. It
does not authorize or complete:

- Phase 5A Stripe sandbox validation; or
- Phase 5B real-client ECPay merchant validation.

Those external tracks remain deferred. Expo payment UI/lifecycle remains a
separate later product phase.
