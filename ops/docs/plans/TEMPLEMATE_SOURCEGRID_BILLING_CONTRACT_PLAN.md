# TempleMate Phase 3 Stripe Billing Integration Plan

Status: Planned; implementation awaits an explicit provider-integration packet

Owner: Wenfu Planning

Date: 2026-08-03

## Outcome

Turn the local monthly platform-billing statement into a real TempleMate
collection workflow using the already-created Stripe catalog—without changing
the catalog itself. A temple should be able to complete setup, have a payment
method recorded, receive a monthly bill based on its closed registration
statement, and see an accurate current/overdue/grace/frozen billing state.

SourceGrid has completed the catalog work. Wenfu uses the recorded active setup
and monthly graduated Price IDs as configuration inputs only; it does not
create, alter, or administer those Products or Prices.

Stripe is only for the TempleMate platform-billing flow: temple to TempleMate.
ECPay remains the separate patron-to-temple flow and is not used for setup or
monthly platform collection.

TempleMate's monthly charge is registration-usage billing, not cloud/API-usage
billing. Wenfu's qualifying registration and refund events are the sole meter;
after Wenfu closes a Taipei-calendar period, its immutable statement provides
the registration quantity and final progressive amount for Stripe collection.
Stripe does not count registrations and Stripe usage-reporting is not
authoritative.

## Starting Point

Wenfu already has a versioned Taipei-calendar meter, immutable monthly
statements, post-close credits, and an owner-only billing view from
`7315beb4a7272a17cd4793959ea7536e4c42bfef`. The active catalog evidence is
recorded in `ops/docs/plans/TEMPLE_PLATFORM_USAGE_PRICING_IMPLEMENTATION_READINESS.md`:

- setup: `price_1U0Ix77ZKypwRK7gI1x3IngL` (NT$10,000 once);
- monthly usage: `price_1U0J5S7ZKypwRK7gRvFaJd4D` (graduated TWD);
- account: `acct_1TFRmE7ZKypwRK7g`.

The current Wenfu Stripe flow instead creates a fixed annual subscription. This
phase replaces that behavior for new platform billing only; it does not alter
existing temple patron payments, accounting records, or historical billing
settings without an explicit migration decision.

Readiness scan at `e13dcbebfa28f74b10ec7751a1c63afdc974a0be` passed the
focused local billing suite (20 runs, 122 assertions). It also found that the
statement closer has no production trigger, the existing webhook path supports
only patron-payment providers, and the legacy admin form can manually mark a
payment method as present. Phase 3 must close all three gaps.

## Delivery Plan

### 3A.1 Bind Configuration To The Existing Catalog

Add explicit environment configuration for the Stripe account and the two
TempleMate Price IDs. Validate presence, mode, currency, and the distinction
between setup and monthly usage before enabling billing. Keep secrets in the
approved runtime configuration only; never store them in the database, source,
fixtures, or client HTML.

### 3A.2 Close Billing Periods Automatically

Add an idempotent scheduled job that closes each eligible temple's prior
Asia/Taipei calendar month after the chosen close time. It must use the existing
statement closer, record failures for operator follow-up, and never issue a
provider request itself. Statement delivery begins only after this local close
succeeds.

### 3B. Replace Annual Setup With Payment-Method Collection

For a newly onboarded temple, collect a Stripe payment method using a setup
flow, verify that the returned customer/payment method belongs to that temple,
and store only the allowed provider references. Charge the one-time setup Price
only through the approved platform-billing workflow—not merely because a card
was collected. Remove the legacy admin checkbox as a way to declare a payment
method present; only a verified setup result may set that state for a new
platform-billing temple.

### 3C. Deliver Each Closed Monthly Statement For Collection

Create a durable platform-billing delivery record for a closed statement. It
must include the statement ID, temple, billing period, policy version, currency,
registration count, adjustment total, final total, provider request reference,
and idempotency key.

Use the monthly graduated Price with the closed statement's qualifying
registration count and final progressive amount. Select and document the exact
Stripe collection mechanism through a provider contract test before enabling
it. It consumes Wenfu's finalized period input; it must not create a separate
cloud/API-usage meter or treat Stripe usage reporting as authoritative. The
mechanism must bill the progressive NT$1,500/500-registration schedule once per
closed period and never re-close or recalculate the statement.

### 3D. Reconcile Provider Events Into Billing State

Accept only authenticated, temple-matched provider events. Record a clear
platform billing state for setup, current, overdue, grace, and frozen; derive
that state from the matching platform invoice/payment outcome, not from a
payment-method flag. Make duplicate events, retries, cancellations, and late
refund/cancellation adjustments idempotent and auditable.

Use a dedicated platform-billing webhook handler and event log. Do not route
platform billing through the existing patron-payment webhook pipeline, which
updates registration payments and currently supports only fake and ECPay
providers.

### 3E. Make The Result Visible And Operable

Extend the owner billing view with the linked statement, collection status,
amount, due date, and visible adjustment history. Keep the existing owner/admin
authority boundary. Add operator-safe reconciliation information without
exposing payment credentials, full card details, or one temple's billing data to
another.

### 4. Validate Before Release

Use local Stripe fixtures/stubs to prove the setup flow, statement delivery,
progressive quantity mapping, replay handling, failed payment, grace transition,
tenant isolation, and no change to temple patron-payment/accounting behavior.
Then run a separately authorized stage workflow against the exact account and
credentials. Production activation remains a separate release decision.

## Acceptance Criteria

1. A closed Wenfu statement produces at most one durable billing delivery for a
   period and retries do not duplicate a provider collection request.
2. The scheduled close processes an eligible prior Taipei month exactly once,
   records failures, and makes no provider call.
3. A 600-registration closed statement maps to NT$1,600, not NT$2,100; late
   corrections remain separate statement adjustments.
4. Provider references and events are bound to the intended temple; no
   cross-temple read, charge, or status change is possible.
5. Setup, invoice/payment, overdue, grace, and frozen state remain distinct and
   auditable. No local statement or catalog object alone grants entitlement.
6. Existing temple patron payments, ECPay behavior, platform accounting
   history, and legacy annual records remain unchanged unless a separate
   migration explicitly covers them.

## First Implementation Blocker

This plan needs an explicit provider-integration implementation packet with the
approved runtime credential/configuration boundary and the chosen Stripe
collection mechanism. The catalog is ready; no further SourceGrid work is
requested.

## Boundaries

This plan does not itself authorize provider calls, credential access, customer
creation, subscriptions, invoices, charges, refunds, catalog mutation, tax
configuration, deployment, production-data changes, or push. Those actions
belong only to a separately accepted implementation and release workflow.
