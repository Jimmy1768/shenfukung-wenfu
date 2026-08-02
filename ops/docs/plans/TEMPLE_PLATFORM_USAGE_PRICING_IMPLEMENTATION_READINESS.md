# Temple Platform Usage Pricing Implementation Readiness

Status: Readiness scan complete; implementation deferred

Owner: Shengfukung Wenfu

Date: 2026-08-02

Related commercial decision:
`ops/docs/plans/TEMPLE_PLATFORM_USAGE_PRICING_PLAN.md`

## Purpose

Record the issues that must be resolved before the approved platform-pricing
model can be implemented. This is not an authorization to change billing,
Stripe, ECPay, payment-provider configuration, production data, customer
charges, or grace-period enforcement.

## Approved Commercial Model

The platform price is not a share of a temple's revenue, donations, ticket
value, or payment volume. It is based on completed active registrations.

| Component | Amount |
| --- | ---: |
| Initial setup | NT$10,000 once |
| Platform base | NT$1,500/month, including the first 500 registrations |
| Registrations 501–2,000 | NT$1.00 each |
| Registrations 2,001–10,000 | NT$1.25 each |
| Registrations above 10,000 | NT$1.50 each |

The rate for a band applies only to registrations inside that band. It does not
create a pricing cliff. Paid and free registrations are treated consistently as
system workload; payment-provider processing fees remain separate.

## Readiness Findings

### 1. The existing platform subscription is fixed and annual

The current local Stripe path creates a fixed NT$3,000 monthly-equivalent,
yearly subscription. The local billing settings also store a 12-month interval.
It does not calculate monthly registration usage or collect a setup fee.

Implication: do not modify the existing fixed annual subscription in place.
The new model needs its own versioned platform-billing records and migration
path, so existing temples remain understandable and recoverable.

### 2. There is no temple-scoped meter or statement

`TempleRegistration` contains the source records, but there is no platform
usage period, immutable usage snapshot, adjustment, statement, or
platform-invoice record. The existing `UsageBillingSnapshot` is historical,
user-scoped archival data and must not be reused for temple billing.

Implication: create new temple-scoped billing records. Do not place platform
charges in temple patron-payment or temple accounting tables.

### 3. Count eligibility needs an executable rule

Current registrations have independent payment and fulfillment statuses.
Free registrations are payment-pending but require no payment; cancelled,
failed, and refunded cases do not share one single "completed" flag.

The implementation must count exactly one registration record when all of the
following are true for the billing period:

- the record was created in the period, using Asia/Taipei calendar boundaries;
- its fulfillment status is not `cancelled`;
- it is free (`total_price_cents = 0`) or its payment status is `paid`; and
- it has not become failed or refunded before the statement closes.

`quantity` is not multiplied into the meter: a single registration record
counts once. If a future product feature needs participant- or seat-based
pricing, that requires a separate commercial decision and schema/test change.

If a qualifying registration is cancelled, failed, or refunded after close,
the next period receives a separately visible credit adjustment. Statements
must retain both the original count and all adjustments; they must not rewrite
historical usage.

### 4. Monthly cutoff and performance are not yet prepared

The app does not explicitly configure Asia/Taipei as its Rails time zone. The
registration table has tenant and status indexes but no composite
`(temple_id, created_at)` index for a monthly meter range query.

Implication: use an explicit Asia/Taipei billing-calendar service and add the
composite index with the metering migration. The monthly close must be
idempotent and safe to retry.

### 5. Grace and payment truth need separate states

Today the grace gate is based on whether a payment method is marked on file;
it is not based on a monthly platform invoice being paid. The current settings
can also receive that boolean through the administrative form, so it is not an
adequate source of truth for a chargeable subscription.

The new design must keep these independently auditable states:

- billing setup: no valid platform payment method or billing agreement;
- billing current: latest platform statement/invoice is paid or not due;
- billing overdue: a platform invoice passed its due date;
- grace: the defined grace window following an overdue invoice; and
- frozen: the grace window expired under the separately approved freeze rule.

The initial 30-day onboarding grace policy must be retained or deliberately
changed in a separately accepted product decision. It must not be silently
repurposed as recurring-invoice grace.

### 6. Provider integration needs a separate gate

The existing Stripe Checkout return stores a subscription and payment-method
reference but does not provide a platform-invoice ledger or verified recurring
invoice lifecycle. Before any provider collection is enabled, the code must
verify that a returned Checkout session belongs to the intended temple and that
the subscription/invoice is in an acceptable state. It must then reconcile
provider events idempotently.

No real Stripe/ECPay credentials, merchant settings, subscriptions, invoices,
refunds, or customer records may be accessed or changed under this plan.
Stage validation and production activation require separate, explicit
authorization.

## Required Local Design

The implementation packet must specify and test the following before provider
collection is considered:

1. A versioned platform-pricing policy, including the setup fee, base allowance,
   progressive bands, currency, effective date, and grandfathering/migration
   rule for existing temples.
2. A temple-scoped billing period with Asia/Taipei start/end timestamps,
   idempotency key, immutable registration-count snapshot, amount breakdown,
   adjustment links, and statement status.
3. A separately named platform-billing invoice/charge record; it must never be
   a `TemplePayment`, a temple patron payment, or temple financial revenue.
4. An owner-visible monthly usage and statement view showing included usage,
   each incremental band, credits, current balance, and close date. Staff
   visibility must follow existing owner/admin authority rather than silently
   expanding financial access.
5. A monthly close and adjustment workflow that is deterministic, retry-safe,
   tenant-isolated, and preserves the historical evidence of the original
   statement.
6. Provider adapters for a one-time setup charge and recurring platform
   collection, including provider-event verification, idempotency, failures,
   cancellation, and rollback/reconciliation behavior.
7. Explicit initial-grace, overdue-grace, payment-failure, notice, and freeze
   rules. The freeze must remain narrow: it must not delete, alter, or hide
   historical temple, registration, account, payment, or accounting records.
8. Focused tests for free and paid registrations; cancellations, failures, and
   refunds before and after close; tenant isolation; boundaries at 500, 2,000,
   and 10,000; Asia/Taipei month close; duplicate/retried close; authorization;
   and provider-event replay.

## Recommended Delivery Sequence

1. Build and locally test metering, period close, adjustments, and owner-visible
   statements without provider calls or customer charges.
2. Review statements against synthetic temples at low, boundary, and high
   volumes; confirm count semantics and notices.
3. Add the provider collection adapter and verified event reconciliation behind
   a separate provider-change approval.
4. Perform stage-only verification with the exact provider account, callbacks,
   rollback, monitoring, and approval boundaries.
5. Consider production activation only through a separate deployment and
   production-data workflow.

## Boundaries

This pricing work must preserve tenant isolation, owner/admin authority,
assisted onboarding, user-work protections, secret handling, payment and
accounting semantics, historical evidence, temple data, Rails/Vue/Expo
boundaries, and all provider, deployment, and production-data protections.
Nothing in this plan authorizes a push, deployment, external mutation, or a
product/runtime implementation.
