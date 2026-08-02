# Temple Platform Usage Pricing Plan

Status: Director pricing direction captured; implementation deferred

Owner: Shengfukung Wenfu

Date: 2026-08-02

## Purpose

Define a predictable platform price that reflects operational system load
without taking a share of a temple's revenue, donations, or payment volume.
This document is a commercial-policy decision, not an authorization to change
production billing, provider configuration, payments, or temple data.

## Pricing Decision

| Component | Amount | Basis |
| --- | ---: | --- |
| Initial setup | NT$10,000 once | Assisted onboarding, configuration, training, and launch setup. |
| Platform base | NT$1,500/month | Includes the first 500 completed registrations in the billing month. |
| Usage band 1 | NT$1.00 each | Registrations 501–2,000 in the billing month. |
| Usage band 2 | NT$1.25 each | Registrations 2,001–10,000 in the billing month. |
| Usage band 3 | NT$1.50 each | Registrations above 10,000; enterprise support/cap may be agreed separately. |

This is not revenue sharing, a percentage of donations, or a percentage of
payment value. The platform fee is based on workload, not the amount a temple
collects.

Rates increase only for the incremental registrations in each band, so there
is no sudden pricing cliff. This deliberately makes the entry point accessible
to smaller temples while asking high-volume operations to contribute more for
the capacity, support, monitoring, and operational load they create.

| Monthly completed registrations | Monthly platform fee |
| ---: | ---: |
| 500 | NT$1,500 |
| 1,000 | NT$2,000 |
| 2,000 | NT$3,000 |
| 10,000 | NT$13,000 |
| 15,000 | NT$20,500 |

## What Counts

A billable usage unit is one completed, active registration/action record in
the billing month, regardless of whether it is paid or free.

- Paid registrations count.
- Free gathering registrations count.
- A registration counts once; do not multiply it by its price, quantity, or
  payment attempts.
- Failed checkout attempts, duplicate records, cancelled registrations, and
  refunded registrations do not count. Any adjustment discovered after a
  monthly close is credited in the next billing cycle.

The eventual implementation must define the authoritative registration states,
cutoff time zone, de-duplication rule, adjustment report, and tenant-scoped
meter query before any invoice or charge is created.

## Existing Billing Direction

The present platform-billing direction remains an NT$3,000 monthly-equivalent
fee with a 30-day grace period before online payment and registration workflows
freeze. This plan replaces its flat-fee-only commercial model with the lower
base plus progressive-usage structure above; it does not itself change the
current code or grace enforcement.

Payment-provider processing fees remain separate pass-through operating costs.
They must not determine the platform usage price or be represented as a
platform revenue share. Provider fee schedules, live credentials, settlement,
tax, and merchant terms require separate verification and authorization.

## Implementation Boundary

No implementation is authorized by this plan. A separate accepted engineering
packet is required before changing any billing model, pricing configuration,
Stripe/ECPay integration, registration behavior, invoices, customer notices,
or workflow freeze rules.

That packet must include tenant-isolated metering, a reproducible monthly
statement, owner-visible usage reporting, adjustment handling, grace-period
interaction, payment-failure behavior, rollback, and focused tests. It must
preserve the assisted-onboarding model, owner/admin authority, secret handling,
payment/accounting semantics, and all provider/deployment/production-data
boundaries.
