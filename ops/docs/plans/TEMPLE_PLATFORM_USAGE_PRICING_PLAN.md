# TempleMate Platform Usage Pricing Plan

Status: Phase 3 locally integrated; Phase 4 stage-and-release planning ready

Owner: Shengfukung Wenfu

Date: 2026-08-03

## Two Separate Money Flows

| Flow | Payer → recipient | Provider | What it covers |
| --- | --- | --- | --- |
| Temple transactions | Patron → temple | ECPay | A temple's offerings, registrations, refunds, receipts, and temple accounting. |
| Platform billing | Temple → TempleMate | Stripe | TempleMate setup and the monthly platform fee based on qualifying registrations. |

ECPay is never used to collect TempleMate's platform fee. Stripe is never the
source of truth for a temple registration, patron refund, or temple accounting
entry. Payment-provider processing fees remain separate from the platform price.

## Registration Usage Meter

TempleMate's monthly fee is **usage billing**: the usage unit is a qualifying
registration. It is not cloud/API-usage billing. Wenfu's authoritative
registration and refund events form the meter; Wenfu closes the Taipei-calendar
period and calculates the final progressive amount. Stripe receives that
finalized billing input only to collect the platform fee. Stripe does not
receive or author a registration meter, and no Stripe usage-reporting API is
the source of truth for this plan.

## Pricing Decision

| Component | Amount | Basis |
| --- | ---: | --- |
| Initial setup | NT$10,000 once | Assisted onboarding, configuration, training, and launch setup. |
| Platform base | NT$1,500/month | Includes the first 500 qualifying registrations. |
| Usage band 1 | NT$1.00 each | Registrations 501–2,000. |
| Usage band 2 | NT$1.25 each | Registrations 2,001–10,000. |
| Usage band 3 | NT$1.50 each | Registrations above 10,000. |

The price is based on operating workload, never temple revenue, donations,
ticket value, payment volume, price, quantity, or payment-provider fees. Tiers
are progressive: 600 registrations cost NT$1,600, not NT$2,100.

## Qualifying Registration Rule

One registration record counts once when it falls in the Asia/Taipei billing
period, is not cancelled, and is either free or paid. Failed, duplicate,
cancelled, and refunded registrations do not count. A post-close cancellation,
failure, or refund produces a visible credit in a later period; it never
rewrites the closed statement.

## Delivery Phases

1. **Policy and local foundation — committed.** Versioned pricing, the
   Asia/Taipei meter, immutable statements/credits, and owner-only billing view
   are local Wenfu behavior.
2. **Stripe platform billing — locally integrated.** The existing TempleMate
   Prices are bound through fixture-only configuration, with platform payment
   method setup, closed registration-usage statement delivery, collection,
   event reconciliation, and owner status. See
   `ops/docs/plans/TEMPLEMATE_SOURCEGRID_BILLING_CONTRACT_PLAN.md`.
3. **Stage and production release — planned.** Complete the configuration and
   scheduler preparation, validate the exact stage account/configuration and
   callback, then make a separate production release decision. See
   `ops/docs/plans/TEMPLEMATE_PHASE_4_STAGE_AND_PRODUCTION_RELEASE_PLAN.md`.

## Boundaries

No plan or local test authorizes provider credentials, customer creation,
subscriptions, invoices, charges, refunds, catalog changes, deployment, or
production-data changes. Preserve tenant isolation, owner/admin authority,
assisted onboarding, secret handling, user-work protections, temple accounting,
and historical records throughout every phase.
