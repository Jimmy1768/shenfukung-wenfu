# TempleMate Platform Billing Implementation Readiness

Status: Local foundation committed; Stripe platform-billing phase planned

Owner: Shengfukung Wenfu

Date: 2026-08-03

Related policy:
`ops/docs/plans/TEMPLE_PLATFORM_USAGE_PRICING_PLAN.md`

## Billing Domain Boundary

ECPay remains the temple's patron-payment provider: patrons pay a temple for
offerings, and ECPay-related refunds, receipts, and accounting stay with that
temple. Stripe is the TempleMate platform-billing provider: a temple pays
TempleMate for setup and monthly registration usage. These are separate flows,
records, webhooks, credentials, and authority boundaries.

Platform billing must never create or alter a `TemplePayment`, patron payment,
ECPay receipt, or temple revenue/accounting record. Temple payment status must
never decide whether TempleMate received its platform fee.

## Committed Local Foundation

Commit `7315beb4a7272a17cd4793959ea7536e4c42bfef` provides the versioned
progressive policy, Asia/Taipei meter, immutable platform statements,
post-close adjustments, composite meter index, and owner-only usage/statement
view. Focused local billing tests pass (20 runs, 122 assertions).

The local foundation is evidence only: it neither creates a Stripe customer nor
collects a platform fee.

## Stripe Catalog Evidence

The active TempleMate catalog is an existing configuration input, not a Wenfu
catalog-management task:

| Use | Product | Price | Terms |
| --- | --- | --- | --- |
| Setup | `prod_V0JaalvBLyIxI8` | `price_1U0Ix77ZKypwRK7gI1x3IngL` | NT$10,000 once |
| Monthly platform usage | `prod_V0Ji2ksvSabvoF` | `price_1U0J5S7ZKypwRK7gRvFaJd4D` | Progressive TWD, lookup key `templemate_registration_platform_twd_monthly_v1` |

The monthly Price is NT$1,500 through 500 qualifying registrations, then
NT$1.00 through 2,000, NT$1.25 through 10,000, and NT$1.50 thereafter. It does
not count registrations, close Wenfu periods, create a subscription, or grant
entitlement by itself.

## Phase 1 — Local Metering And Statements (Committed)

Wenfu calculates the qualifying monthly registration count, applies the
progressive policy, closes an immutable statement, and records later credits.
The statement is tenant-scoped and is not a temple patron-payment or accounting
record.

## Phase 2 — Owner Visibility (Committed)

Temple owners can view current usage and closed local statements. The view is
read-only billing evidence; it does not show a Stripe payment result or permit
a billing charge.

## Phase 3 — Stripe Platform Billing (Planned)

The detailed Phase 3 plan is
`ops/docs/plans/TEMPLEMATE_SOURCEGRID_BILLING_CONTRACT_PLAN.md`.

### 3A. Configuration And Period Lifecycle

Configure the expected Stripe account and setup/monthly Price IDs through the
approved runtime boundary. Add an idempotent Asia/Taipei monthly-close job and
a durable delivery record; closing a statement alone makes no provider call.

### 3B. Temple Setup Billing

Replace the legacy fixed annual Stripe subscription setup for new platform
billing with a verified Stripe payment-method setup flow. Bill the NT$10,000
setup Price only through the approved platform-billing workflow. A manual
admin checkbox must not claim that a Stripe payment method exists.

### 3C. Monthly Usage Collection

For each closed statement, create exactly one replay-safe platform billing
delivery. Select and contract-test the Stripe mechanism that applies the
graduated monthly Price to the statement's qualifying-registration quantity.
Keep setup and recurring usage distinct.

### 3D. Stripe Events And Billing State

Create a dedicated authenticated platform-billing Stripe webhook/event log.
Map only the matching temple's setup, invoice/payment, overdue, grace, and
frozen state. Do not reuse the patron ECPay/fake webhook pipeline.

### 3E. Owner And Operator Review

Show the linked statement, collection status, due date, and adjustments to the
temple owner. Provide operators with reconciliation evidence without exposing
credentials, card details, or cross-temple data.

## Phase 4 — Stage And Production Gate

Run local fixture/stub tests first. Stage validation then requires the exact
Stripe configuration, callback target, rollback, monitoring, and approval
boundary. Production collection requires a separate release decision.

## Current Readiness Gaps

- The existing Stripe path creates a fixed annual subscription rather than
  TempleMate setup and monthly usage billing.
- There is no automatic monthly-close trigger or billing-delivery record.
- The existing payment webhook pipeline is for patron payments and supports
  fake/ECPay, not Stripe platform billing.
- The legacy form can manually set `payment_method_on_file`.
- Stripe account and both TempleMate Price IDs are not explicit runtime
  configuration yet.

## Boundaries

No provider access, Stripe/ECPay configuration, customer, subscription,
invoice, charge, refund, tax, deployment, or production-data action is
authorized by this readiness plan. Preserve tenant isolation, owner/admin
authority, assisted onboarding, user-work protections, secret handling,
payment/accounting semantics, and historical evidence.
