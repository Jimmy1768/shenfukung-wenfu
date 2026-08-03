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

## Delivery Plan

### 1. Bind Configuration To The Existing Catalog

Add explicit environment configuration for the Stripe account and the two
TempleMate Price IDs. Validate presence, mode, currency, and the distinction
between setup and monthly usage before enabling billing. Keep secrets in the
approved runtime configuration only; never store them in the database, source,
fixtures, or client HTML.

### 2. Replace Annual Setup With Payment-Method Collection

For a newly onboarded temple, collect a Stripe payment method using a setup
flow, verify that the returned customer/payment method belongs to that temple,
and store only the allowed provider references. Charge the one-time setup Price
only through the approved platform-billing workflow—not merely because a card
was collected.

### 3. Deliver Each Closed Monthly Statement For Collection

Create a durable platform-billing delivery record for a closed statement. It
must include the statement ID, temple, billing period, policy version, currency,
registration count, adjustment total, final total, provider request reference,
and idempotency key.

Use the monthly graduated Price with the closed statement's qualifying
registration count. Select and document the exact Stripe collection mechanism
(subscription quantity, metered usage, or invoice item) through a provider
contract test before enabling it. The mechanism must bill the progressive
NT$1,500/500-registration schedule once per closed period and never re-close or
recalculate the statement.

### 4. Reconcile Provider Events Into Billing State

Accept only authenticated, temple-matched provider events. Record a clear
platform billing state for setup, current, overdue, grace, and frozen; derive
that state from the matching platform invoice/payment outcome, not from a
payment-method flag. Make duplicate events, retries, cancellations, and late
refund/cancellation adjustments idempotent and auditable.

### 5. Make The Result Visible And Operable

Extend the owner billing view with the linked statement, collection status,
amount, due date, and visible adjustment history. Keep the existing owner/admin
authority boundary. Add operator-safe reconciliation information without
exposing payment credentials, full card details, or one temple's billing data to
another.

### 6. Validate Before Release

Use local Stripe fixtures/stubs to prove the setup flow, statement delivery,
progressive quantity mapping, replay handling, failed payment, grace transition,
tenant isolation, and no change to temple patron-payment/accounting behavior.
Then run a separately authorized stage workflow against the exact account and
credentials. Production activation remains a separate release decision.

## Acceptance Criteria

1. A closed Wenfu statement produces at most one durable billing delivery for a
   period and retries do not duplicate a provider collection request.
2. A 600-registration closed statement maps to NT$1,600, not NT$2,100; late
   corrections remain separate statement adjustments.
3. Provider references and events are bound to the intended temple; no
   cross-temple read, charge, or status change is possible.
4. Setup, invoice/payment, overdue, grace, and frozen state remain distinct and
   auditable. No local statement or catalog object alone grants entitlement.
5. Existing temple patron payments, ECPay behavior, platform accounting
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
