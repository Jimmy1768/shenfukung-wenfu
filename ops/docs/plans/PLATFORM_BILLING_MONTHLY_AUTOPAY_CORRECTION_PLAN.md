# Platform Billing Monthly Autopay Correction Plan

Status: implemented and Control B accepted; local integration in progress

Product authority: Director

Control owner: Wenfu Control B

Date: 2026-08-08

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Observed base: `99cbdb74060484d4f15693d5cc4075c5c6e8c392`

## Authority And Safety Boundary

The Director reported the Billing page's annual `NT$10,000` presentation as
wrong and directed monthly Stripe autopay while preserving the current 30-day
grace period. This records a direct-Control B correction under the existing
thread instruction not to route this bounded work through Control A or
Planning. It does not change ordinary governance.

No Stripe, ECPay, secrets, catalog, merchant configuration, customer, invoice,
subscription, payment method, deployment, or production data may be accessed
or mutated. This work changes only local source, tests, generated local assets
if required, and durable local records.

## Evidence And Diagnosis

- The owner Billing page labels the current `NT$10,000` one-time onboarding
  charge as a yearly charge beside a `NT$1,500` monthly amount.
- `Admin::PaymentMethodsForm` hard-codes the annual presentation instead of
  identifying the one-time onboarding charge and the separately metered
  monthly collection.
- `Billing::StripePaymentMethodSetup` correctly opens a paid Checkout Session
  using the configured onboarding Price. That charge is current product
  behavior and must remain in place.
- `Billing::StripePlatformBillingCollection` already creates Stripe monthly
  invoices using `collection_method: "charge_automatically"` and the configured
  monthly Price. Wenfu's monthly statement remains the amount authority.
- `Billing::PlatformBillingLifecycle` retains the persisted
  `overdue -> grace -> frozen` path with a 30-day grace window. That behavior
  is in scope to preserve, not redesign.

## Frozen Product Direction

Keep the current one-time Stripe onboarding charge. After the owner completes
that onboarding flow, Wenfu's existing monthly statement collection can
automatically charge the saved method using the configured monthly Price. The
owner-facing Billing page must distinguish the one-time onboarding fee from
monthly autopay and must not present an annual charge.

Do not create a Stripe subscription, alter the current onboarding Checkout
flow, enable jobs/timers, alter statement pricing, alter existing legacy annual
records, remove legacy-record protection, or update any external Stripe
product. Existing historical/legacy annual records remain safely rejected by
the onboarding flow.

## Phases

### Phase 1 — Monthly autopay presentation

- Replace the annual presentation in the payment-method form and Billing page
  with a localized one-time onboarding-fee label.
- Add clear localized monthly-autopay and 30-day grace-period guidance in
  English and Traditional Chinese.

Pass condition: no owner-facing Billing HTML claims annual billing; `NT$10,000`
is accurately presented only as the one-time onboarding fee, and monthly
automatic collection is clear.

### Phase 2 — Preserve onboarding and monthly collection boundaries

- Retain the paid onboarding Checkout flow, its configured onboarding Price,
  and customer/payment-method persistence.
- Prove monthly Stripe invoice collection still uses the configured monthly
  Price with automatic collection.
- Retain legacy annual-record rejection and all tenant/audit boundaries.

Pass condition: local request tests prove the current one-time onboarding flow
and independent automatic monthly collection remain intact.

### Phase 3 — Regression and local acceptance

- Prove the 30-day grace/freeze lifecycle is unchanged.
- Run focused Billing integration/service/job tests and static checks.
- Review the local Billing page in the isolated review environment without
  entering provider credentials or initiating Checkout.

Pass condition: all focused tests pass and browser evidence confirms clear
monthly-only owner copy with no annual amount.

## Frozen Acceptance Criteria

1. Billing UI contains no annual-charge copy and presents `NT$10,000` only as
   a one-time onboarding fee.
2. Billing UI communicates automatic monthly collection and the existing
   30-day grace behavior in both supported locales.
3. The configured onboarding Price remains used by the current paid onboarding
   Checkout flow.
4. The configured monthly Price remains required and is used by the existing
   automatic monthly invoice collector.
5. Payment method/customer persistence, tenant isolation, audit logging,
   legacy annual-record rejection, and owner-only access remain intact.
6. No external Stripe/ECPay request, catalog change, money movement, secret
   access, deployment, production-data action, or push occurs.

## Implementation Closeout

All three phases and six frozen criteria were completed on 2026-08-08.

- `NT$10,000` is retained and rendered only as the current one-time Stripe
  onboarding fee; all annual-billing copy and annual fact labels are removed.
- The Billing page now separates one-time onboarding from automatic monthly
  platform collection and preserves the 30-day grace/freeze guidance in English
  and Traditional Chinese.
- The paid onboarding Checkout, configured onboarding Price, Stripe customer
  and payment-method persistence, legacy-annual protection, monthly invoice
  collector, and 30-day lifecycle are unchanged.
- The required Billing suite passed with 19 runs, 121 assertions, 0 failures,
  0 errors, and 0 skips. `git diff --check` passed.
- Isolated local browser review of the owner Billing tab confirmed the revised
  Traditional Chinese copy, `NT$10,000` onboarding label, monthly automatic
  collection statement, and 30-day grace rule without opening provider links or
  initiating Checkout.

No external Stripe/ECPay request, catalog or credential access, payment-method
change, invoice, money movement, deployment, production-data action, or push
occurred.
