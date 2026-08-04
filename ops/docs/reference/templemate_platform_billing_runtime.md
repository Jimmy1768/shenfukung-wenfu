# TempleMate Platform-Billing Runtime Reference

## Product and authority boundary

TempleMate has two separate money flows:

- **ECPay** processes patron-to-temple offerings, registrations, refunds,
  receipts, and temple accounting.
- **Stripe** collects TempleMate platform setup and monthly
  registration-usage fees from a temple.

Wenfu owns qualifying-registration/refund semantics, the Taipei-calendar
monthly close, progressive-price calculation, adjustments, and the immutable
statement. Stripe receives only Wenfu's finalized collection input; it is not
the registration meter, a cloud/API-usage meter, or statement authority.

SourceGrid owns the Stripe catalog and provider binding. Wenfu uses the
catalog as configuration and retains neither catalog-write authority nor a
broad SourceGrid secret key. One shared billing backend serves every tenant;
each tenant may use its own public frontend domain and owner/admin console.

## Catalog configuration

The active SourceGrid account is `acct_1TFRmE7ZKypwRK7g`. These are non-secret
runtime inputs:

| Purpose | Product | Price | Meaning |
| --- | --- | --- | --- |
| TempleMate Platform Setup | `prod_V0JaalvBLyIxI8` | `price_1U0Ix77ZKypwRK7gI1x3IngL` | NT$10,000 one-time |
| TempleMate Registration Platform | `prod_V0Ji2ksvSabvoF` | `price_1U0J5S7ZKypwRK7gRvFaJd4D` | Progressive monthly TWD registration usage |

The monthly schedule is progressive: NT$1,500 through 500 qualifying
registrations, then NT$1.00 through 2,000, NT$1.25 through 10,000, and NT$1.50
thereafter. At 600 qualifying registrations, Wenfu's closed statement total is
NT$1,600.

## Protected runtime configuration

`/etc/default/shengfukung-wenfu-env` holds the protected values:

```dotenv
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_TEMPLEMATE_PLATFORM_ACCOUNT_ID=acct_1TFRmE7ZKypwRK7g
STRIPE_TEMPLEMATE_SETUP_PRICE_ID=price_1U0Ix77ZKypwRK7gI1x3IngL
STRIPE_TEMPLEMATE_MONTHLY_PRICE_ID=price_1U0J5S7ZKypwRK7gRvFaJd4D
STRIPE_TEMPLEMATE_PLATFORM_WEBHOOK_SECRET=
```

The API key and webhook secret never belong in source control, chat, logs, or
fixtures. The API key is a TempleMate-specific restricted key, not a reused
SourceGrid broad key. `STRIPE_WEBHOOK_SECRET` remains separate and blank until
the later patron-to-temple Stripe Connect flow; it must never be substituted
for the TempleMate platform-billing endpoint secret.

## Deployed shared backend

As observed on 2026-08-04, `release/current` deployed
`af459d904af547222d1bd45ff3e40340aca9b894` to the Wenfu host. Additive
platform-billing migrations `20260802000021` and `20260803000022` are up, and
Puma plus Sidekiq are running and enabled at boot.

The shared Stripe platform-billing endpoint is:

```text
https://shengfukung.com.tw/api/v1/platform_billing/webhooks
```

`shengfukung.com.tw` is a temporary backend hostname, not the TempleMate
brand domain or a requirement for future temple domains. An unsigned probe
returns `401`; a locally generated valid-signature probe without tenant or
delivery metadata returns `422`. Together those results prove the deployed
environment, public route, and signature verification, while safely refusing
an event that cannot belong to a tenant.

The endpoint accepts only these platform events:

```text
checkout.session.completed
invoice.paid
invoice.payment_succeeded
invoice.payment_failed
invoice.payment_action_required
```

An event can return `200` only after it matches an existing TempleMate tenant
and platform-billing delivery. That first matching event is the remaining
controlled onboarding proof; catalog existence or route readiness does not
create a customer, subscription, invoice, charge, payment, or entitlement.

## Deterministic enqueue schedule

Rendered units are created by
`ops/scripts/render_ops_templates.rb --slug <slug> --output <directory>`:

| Timer | Service action | Calendar | Delivery behavior |
| --- | --- | --- | --- |
| `<slug>-platform-billing-monthly-close.timer` | `PlatformBillingMonthlyCloseJob.perform_later` | daily at 00:20 Asia/Taipei | idempotently closes the prior month; the next daily run is the deterministic retry for recorded per-temple close failures |
| `<slug>-platform-billing-lifecycle.timer` | `PlatformBillingLifecycleJob.perform_later` | hourly at minute 05 Asia/Taipei | advances persisted overdue/grace deadlines independently of webhook replays |

Both timers are persistent and have `RandomizedDelaySec=0`. Each one-shot
service retries an enqueue failure after five minutes, with a start limit of
three attempts in a one-hour window. The units are installed but disabled: no
automatic close, collection, or lifecycle advancement runs until an explicit
first-tenant onboarding decision enables them.

## First-tenant gate and preserved boundaries

Before enabling either timer or initiating the first setup collection, name the
first tenant and owner, confirm its expected statement and payment-method
setup path, and supervise the matching Stripe event and Wenfu audit record.
Preserve platform-delivery idempotency, signed-webhook behavior, the persisted
`overdue -> grace -> frozen` lifecycle, legacy annual-record protection,
ECPay/patron payment behavior, tenant isolation, owner/admin authority,
accounting records, secrets, and assisted onboarding. No rollback deletes
closed statements, billing deliveries, provider-event evidence, or temple
payment history.
