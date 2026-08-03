# TempleMate Phase 4 Stage And Production Release Plan

Status: Planned; no staging or provider action is authorized by this document

Owner: Wenfu Planning

Date: 2026-08-03

## Outcome

Move the locally accepted TempleMate platform-billing workflow through a
controlled staging validation, then make a separate production release
decision. The workflow charges a temple for TempleMate setup and monthly
registration usage. ECPay continues to process patron-to-temple payments.

The staging run proves this sequence in a controlled environment:

```text
qualifying registrations -> closed Wenfu statement -> Stripe collection ->
signed platform event -> Wenfu billing state and owner evidence
```

Wenfu remains the authoritative registration/refund meter, Taipei-calendar
period closer, progressive-price calculator, and statement authority. Stripe
collects the finalized statement input; it does not count registrations or
become a usage-reporting authority.

## Accepted Starting Point

The local Phase 3 workflow is integrated at
`330568601b297988da99f1bff21c7d8451648ac5`, with cleanup at
`003f0e840b3292cfbf1a0b51dab5c5520391a0a6`.

Local fixture/stub coverage proves the setup flow, NT$10,000 setup price,
600-registration NT$1,600 monthly calculation, statement delivery
idempotency, signed webhook handling, tenant isolation, legacy annual-record
protection, and persisted `overdue -> grace -> frozen` transitions.

The existing catalog inputs are:

| Use | Product | Price |
| --- | --- | --- |
| Setup | `prod_V0JaalvBLyIxI8` | `price_1U0Ix77ZKypwRK7gI1x3IngL` |
| Monthly registration usage | `prod_V0Ji2ksvSabvoF` | `price_1U0J5S7ZKypwRK7gRvFaJd4D` |

## Current Phase 4 Preparation Gaps

These are repository facts, not permission to change a runtime:

1. `rails/config/initializers/stripe.rb` reads the required TempleMate
   account, setup Price, monthly Price, and platform-webhook secret from
   runtime environment variables. `ops/env/template.temple.env` does not yet
   document those four non-secret key names.
2. `PlatformBillingMonthlyCloseJob` and `PlatformBillingLifecycleJob` exist,
   but `rails/config/sidekiq.yml` explicitly says scheduler configuration has
   not been added. Their intended production cadence is therefore unknown.
3. No current source verifies a deployed callback URL, a configured stage
   Stripe account, or a configured stage provider credential. Those states are
   unknown until an explicitly authorized stage preflight inspects them.

## Phase 4A — Stage-Readiness Preparation

Before a staging run, complete a bounded local/runtime-preparation packet that:

1. Documents the four TempleMate Stripe environment-key names in the approved
   environment template without adding a secret or real value to source
   control.
2. Selects and documents the job scheduler mechanism, exact Taipei-local close
   time, lifecycle cadence, retry behavior, and operational owner. Add only
   the minimum code/configuration necessary to schedule the existing jobs.
3. Defines the secure runtime-installation procedure for the account ID, setup
   Price ID, monthly Price ID, Stripe secret key, publishable key, and webhook
   secret. Values remain outside the repository.
4. Defines one isolated staging validation temple and its owner/admin test
   account, with a fixed 600-registration scenario. This record is staging
   evidence only and must not be confused with a patron or production temple.
5. Records the exact callback URL, logging/alert destination, and rollback
   owner before any provider-facing validation begins.

The scheduler/callback/configuration decisions are the first Phase 4
implementation packet. They require their own focused local checks before a
staging execution is requested.

## Phase 4B — Authorized Staging Validation

An explicit staging authorization must name the exact environment, commit,
runtime configuration owner, rollback owner, test temple, and provider
boundary. Under that authorization, verify in order:

1. The approved runtime contains the expected non-secret configuration keys
   and the configured account/Price IDs match the recorded TempleMate catalog
   inputs.
2. The dedicated endpoint
   `/api/v1/platform_billing/webhooks` is reachable only through the expected
   signed Stripe callback path.
3. A stage temple owner completes the TempleMate setup flow. Its provider
   customer, payment-method, checkout, and delivery references are visible
   only in that temple's platform-billing records.
4. A closed 600-registration stage statement produces one monthly collection
   delivery for NT$1,600. Replaying the close or collection action does not
   create a second delivery or collection request.
5. A valid signed success event changes only the matching temple/delivery to
   paid. A controlled failed collection exercises overdue, grace, and frozen
   transitions and the corresponding owner/operator evidence.
6. The stage operator reconciles the provider references, delivery/event
   records, system-audit transitions, job execution evidence, and owner view.
7. ECPay patron checkout, patron payment records, refunds, receipts, and
   temple accounting remain unaffected throughout the staging run.

## Phase 4C — Monitoring And Rollback Proof

The stage record must include:

- the release commit and database migration status;
- the scheduler/job execution evidence for monthly close and lifecycle advance;
- platform delivery/event/audit identifiers and redacted error evidence;
- the webhook callback result and duplicate-event result;
- a rollback procedure that stops new platform collection, disables the new
  scheduler/callback path, preserves closed Wenfu statements and audit
  evidence, and restores the known-good application release; and
- the operator responsible for follow-up when a collection is overdue or a
  webhook/job fails.

No rollback deletes statements, billing deliveries, events, provider evidence,
or temple payment history.

## Phase 4D — Production Release Decision

Production collection is a separate decision after staging passes. The release
record must identify the exact approved production commit, target, runtime
configuration/secret owner, callback target, monitoring owner, rollback plan,
temple rollout cohort, and confirmation that the first production collection
will be supervised.

Production success means each enabled temple can complete setup, receive a
monthly platform bill based on its immutable Wenfu registration statement, and
view an accurate billing state without affecting ECPay patron payments.

## Acceptance Criteria

Phase 4 planning is complete when this plan is linked from the pricing and
readiness records, the preparation gaps are explicit, and a future Control can
freeze a bounded configuration/scheduler packet without reopening Phase 3.

Stage validation passes only with the full Phase 4B and 4C evidence. Production
activation passes only with a separate explicit release decision.

## Boundaries

This planning document does not authorize a deployment, push, runtime or
provider configuration change, secret access, Stripe API/CLI call, customer,
subscription, invoice, charge, refund, tax action, production-data change, or
external mutation. It does not change ECPay, temple accounting, patron
payments, tenant isolation, owner/admin authority, assisted onboarding, or
legacy annual Stripe records.
