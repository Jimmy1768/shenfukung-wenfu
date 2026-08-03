# TempleMate Platform-Billing Runtime Preparation

## Scope and authority

This is repository-local Phase 4A preparation. It does not install a protected
environment, validate a Stripe account or callback URL, contact a provider, or
enable, start, reload, or otherwise activate a host unit. A later, separately
authorized staging packet must name the target, commit, configuration owner,
rollback, verification, and monitoring boundaries before doing any of those
things.

Wenfu owns the qualifying registration/refund meter, Taipei-calendar monthly
close, progressive price calculation, adjustments, and final statement. Stripe
is only the collection handler for finalized Wenfu input; it is not the usage
meter or statement authority. The timer services enqueue existing Rails jobs
through the normal Rails/Sidekiq queue only. They make no Stripe, ECPay, or
other provider call and do not enter a patron-payment path.

## Protected runtime configuration

The protected runtime environment must later receive values for
`STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`,
`STRIPE_TEMPLEMATE_PLATFORM_ACCOUNT_ID`,
`STRIPE_TEMPLEMATE_SETUP_PRICE_ID`,
`STRIPE_TEMPLEMATE_MONTHLY_PRICE_ID`, and
`STRIPE_TEMPLEMATE_PLATFORM_WEBHOOK_SECRET`. The account and Price identifiers
are non-secret catalog configuration; the API key and webhook secrets are
protected values. The generic `STRIPE_WEBHOOK_SECRET` remains separate from the
TempleMate platform webhook credential.

No identifier or secret value is recorded here. The later staging workflow must
install values only in the protected environment, without reusing a broad
SourceGrid key. It must also establish the actual callback URL and host/account
configuration then; neither is validated by this packet.

## Deterministic enqueue schedule

Rendered units are created by
`ops/scripts/render_ops_templates.rb --slug <slug> --output <directory>`:

| Timer | Service action | Calendar | Delivery behavior |
| --- | --- | --- | --- |
| `<slug>-platform-billing-monthly-close.timer` | `PlatformBillingMonthlyCloseJob.perform_later` | daily at 00:20 Asia/Taipei | idempotently closes the prior month; the next daily run is the deterministic retry for recorded per-temple close failures |
| `<slug>-platform-billing-lifecycle.timer` | `PlatformBillingLifecycleJob.perform_later` | hourly at minute 05 Asia/Taipei | advances persisted overdue/grace deadlines independently of webhook replays |

Both timers are persistent and have `RandomizedDelaySec=0`. Each one-shot
service retries an enqueue failure after five minutes, with a start limit of
three attempts in a one-hour window. An operator later reviews rendered units
and, under an authorized staging workflow, performs any host installation and
activation; this preparation packet does neither.

## Required staging evidence and preserved boundaries

After authorized staging installation, capture rendered-unit review, timer
state, journal evidence, job execution evidence, and related platform billing
audit evidence. Preserve Phase 3 idempotency and signed-webhook behavior; the
persisted `overdue -> grace -> frozen` lifecycle; legacy annual-record
protection; ECPay and patron payment behavior; tenant isolation and
owner/admin authority; billing records; secrets; and user-work protections.
Neither this template nor later scheduler activation changes payment/accounting
authority or permits exposure of protected values.
