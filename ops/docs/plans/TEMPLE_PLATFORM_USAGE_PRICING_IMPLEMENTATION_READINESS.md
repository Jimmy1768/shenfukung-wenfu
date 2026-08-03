# Temple Platform Usage Pricing Implementation Readiness

Status: Local usage-billing foundation committed; contract and provider phases deferred

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

## Phased Implementation Plan

Each phase has a narrow acceptance gate. Completing a phase does not authorize
the next one; in particular, no phase below authorizes a provider or production
change unless that authorization is explicitly granted.

### Phase 0 — Policy and Migration Decisions

Freeze the durable local rules before building the meter.

- Define a versioned platform-pricing policy: setup fee, base allowance,
  progressive bands, currency, effective date, and grandfathering/migration
  rule for existing temples.
- Confirm the count rule above, including that a registration record counts
  once rather than using `quantity` as a participant multiplier.
- Specify Asia/Taipei calendar boundaries, statement close timing, adjustment
  timing, initial-onboarding grace, overdue grace, notices, and the narrow
  freeze behavior.
- Define platform-billing roles: owner access by default, explicitly scoped
  staff visibility where needed, and no expansion of temple financial access.

Acceptance gate: the policy can price synthetic examples at 500, 2,000, 10,000,
and 15,000 registrations without a revenue-based variable or a pricing cliff.

### Phase 1 — Local Metering and Historical Statements

Build the local, tenant-isolated evidence model without any provider calls or
customer charges.

- Add a temple-scoped billing period with Asia/Taipei start/end timestamps,
  idempotency key, immutable registration-count snapshot, amount breakdown,
  adjustment links, and statement status.
- Add a composite `(temple_id, created_at)` registration index for the meter.
- Add a separately named platform-billing statement/invoice record. It must
  never be a `TemplePayment`, a temple patron payment, or temple financial
  revenue.
- Implement deterministic, retry-safe monthly close and next-period credits for
  after-close cancellation, failure, or refund adjustments.

Acceptance gate: focused local tests prove tenant isolation, free and paid
eligibility, exclusions, boundary pricing, Asia/Taipei close, retry safety,
and immutable historical statements.

### Phase 2 — Owner Visibility and Synthetic Review

Make the local calculation understandable before attempting collection.

- Provide an owner-visible usage and statement view: included usage, each
  incremental band, credits, current balance, and close date.
- Keep staff visibility within existing owner/admin authority; do not silently
  grant financial access.
- Review low, boundary, and high-volume synthetic temples with the agreed
  count semantics and customer notices.

Acceptance gate: an owner can reconcile every displayed amount to a statement
snapshot and adjustment record without developer intervention.

### Phase 3 — Provider Collection Design and Local Adapter Work

Prepare the one-time setup charge and recurring platform collection path only
after a separate provider-change approval.

Historical beta-catalog evidence (2026-08-02): the confirmed SourceGrid Stripe test
catalog contains inactive `TempleMate Platform Setup` and `TempleMate
Registration Platform` products. Their inactive lookup keys are
`templemate_platform_setup_twd_once_v1` and
`templemate_registration_platform_twd_monthly_v1`. The setup price is
NT$10,000. The graduated monthly price has a NT$1,500 flat first tier through
500 registrations, then NT$1.00 through 2,000, NT$1.25 through 10,000, and
NT$1.50 above 10,000. No customer, subscription, invoice, or charge was
created.

On 2026-08-02, the connected live restricted key rejected a product-create
attempt for insufficient permission; that attempt changed no live catalog
object. The separately approved completed live catalog evidence is recorded
below. Do not substitute the test price IDs for a live environment or work
around the permission boundary.

### SourceGrid Catalog Ownership And Future Binding Gate

SourceGrid Planning recorded the parent-company ownership decision at
SourceGrid commit `74f3f4dd508c291bf81b3bd3ed62250a2a1c70ec` in
`ops/docs/plans/SOURCEGRID_PLATFORM_STRIPE_CATALOG_AND_TAX_POLICY_PLAN.md`.
SourceGrid owns TempleMate's future first-party Stripe Product/Price catalog
governance, provider binding, merchant-of-record posture, tax-classification
review, and authorization of every live-provider mutation. TempleMate/Wenfu
retains product semantics, registration-count meaning, local customer workflow,
and runtime fulfillment; it receives neither SourceGrid Stripe secrets nor
direct catalog-write authority.

The test catalog above is cross-repository evidence only, not a live SourceGrid
binding, customer-offer acceptance, or provider authorization. Any subsequent
live catalog operation requires separate Director authorization, then a
SourceGrid-local TempleMate manifest/binding plan with distinct immutable keys,
metadata, and binding plus preservation proof for AppRelay, DojoMate, credits,
and Enterprise catalogs. The future credential must be SourceGrid-owned and
least-privilege: only Stripe-supported Products/Prices create-and-read access;
never customer, Checkout, Payment Link, subscription, invoice, payment,
refund, payout, webhook, key/account, tax-activation, connected-account, or
unrelated-catalog access. Exact provider permission labels and role availability
are unknown until a separately approved read-only provider-permission
inspection. A broad secret-key substitute or permission-boundary bypass is not
allowed.

### SourceGrid-Verified Live Catalog Evidence (2026-08-03)

SourceGrid Planning reports that a separately approved SourceGrid-owned live
Stripe catalog operation completed for account `acct_1TFRmE7ZKypwRK7g`.
Wenfu did not independently access Stripe or its credentials; the following
facts are SourceGrid Planning's verified evidence, not Wenfu provider authority:

| Entry | Product | Price | Terms |
| --- | --- | --- | --- |
| TempleMate Platform Setup | `prod_V0JaalvBLyIxI8` | `price_1U0Ix77ZKypwRK7gI1x3IngL` | Active, TWD NT$10,000 one-time |
| TempleMate Registration Platform | `prod_V0Ji2ksvSabvoF` | `price_1U0J5S7ZKypwRK7gRvFaJd4D` | Active, monthly graduated TWD; lookup key `templemate_registration_platform_twd_monthly_v1` |

The registration price is progressive, not cumulative flat blocks: NT$1,500
through 500 qualifying registrations, then NT$1.00 for registrations 501–2,000,
NT$1.25 for 2,001–10,000, and NT$1.50 thereafter. For 600 qualifying
registrations the fee is NT$1,600 (`NT$1,500 + 100 × NT$1.00`), not NT$2,100.

SourceGrid continues to own the live Stripe Product/Price catalog and provider
binding. Wenfu alone owns authoritative registration/refund event semantics,
monthly net-count computation, and the closed immutable period statement. The
recurring Stripe Price neither counts registrations nor closes a billing period.
Catalog existence is not a customer subscription, invoice, charge, payment,
entitlement, usage report, or completed Wenfu billing integration.

The next Wenfu-local planning need is frozen in
`ops/docs/plans/TEMPLEMATE_SOURCEGRID_BILLING_CONTRACT_PLAN.md`: Phase 3
Stripe billing integration using the completed catalog as a configuration input.
It requests no SourceGrid action and awaits a separate provider-integration
implementation packet. No new provider action follows from this planning
evidence alone.

- Define the provider adapter contract for setup charge, recurring collection,
  provider-event verification, idempotency, failures, cancellation, and
  rollback/reconciliation.
- Verify that a returned Checkout session belongs to the intended temple and
  that its subscription/invoice is in an acceptable state before recording a
  billing method or payment truth.
- Keep billing setup, current, overdue, grace, and frozen as distinct auditable
  states; do not use a payment-method flag as invoice-payment truth.
- Test provider-event replay and failed-payment behavior using local fixtures
  only.

Acceptance gate: local tests demonstrate no cross-temple association, no
duplicate charge record on replay, and no change to temple patron payments or
accounting semantics.

### Phase 4 — Stage Verification and Production Gate

This phase is not authorized by this document. It is a future separate workflow
for the exact provider account and deployment target.

- Stage-only verification requires the exact credentials boundary, callback
  routes, rollback, monitoring, approval, and reconciliation evidence.
- Production activation requires a separate production/deployment workflow and
  may proceed only after the stage acceptance evidence is reviewed.

Acceptance gate: explicit written authorization; no local plan or test result
is a substitute for it.

## Boundaries

This pricing work must preserve tenant isolation, owner/admin authority,
assisted onboarding, user-work protections, secret handling, payment and
accounting semantics, historical evidence, temple data, Rails/Vue/Expo
boundaries, and all provider, deployment, and production-data protections.
Nothing in this plan authorizes a push, deployment, external mutation, or a
product/runtime implementation.
