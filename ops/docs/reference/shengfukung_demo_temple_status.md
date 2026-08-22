# shengfukung.com.tw / shengfukung-wenfu: Demo Status, Not a Real Client

## The one fact this doc exists to prevent getting wrong

**`shengfukung-wenfu` (public domain `shengfukung.com.tw`) is not a real,
paying platform-billing client.** It is the temple used to demo TempleMate
to prospective clients, and it is allowed to create registrations freely for
that purpose — but it must never be treated as a real client by anything
that bills, charges, or reports on real platform-billing usage.

This distinction exists because of a real, discovered situation, not a
hypothetical: this temple's `platform_billing_entitlement` was created
(state `pending_setup`) during earlier admin-panel testing/demoing, which by
itself would freeze registration intake (see
`Temple#registration_intake_frozen?`) without ever indicating a real,
paying relationship. Both problems needed solving together, not by
completing a fake Stripe setup checkout to "fix" the freeze.

## How each half is handled

### 1. It is excluded from real-client billing

`Temple.platform_billing_adopted` (used by `PlatformBillingMonthlyReviewJob`
and transitively by `PlatformBillingMonthlyCollectionJob`) requires a
`platform_billing_entitlement` whose state is **not** `pending_setup` --
i.e. `active` or `suspended`, meaning the temple actually completed the
Stripe setup checkout at some point. A `pending_setup`-only entitlement
(this temple's current state) does not count as adopted, so the monthly
billing jobs skip it entirely -- no statement, no delivery, no charge, ever,
for as long as it stays in `pending_setup`.

This is a general rule (any temple with only a `pending_setup` entitlement
is excluded, not a special case keyed to this one temple's slug), but this
temple is the concrete reason it was written this way.

### 2. It is allowed to create registrations anyway

`Temple#registration_intake_frozen?` normally freezes registration creation
for any temple whose entitlement isn't `active` (see
`app/models/temple.rb`). This temple's `demo_registration_unlocked` billing
setting overrides that check and forces it to return `false`, regardless of
entitlement state. This is also a general, reusable mechanism -- any demo
temple can use it -- not something hardcoded to this one slug.

Toggle it via rake, matching the `admin_controls:seed_qa_dummy_admin`
convention:

```bash
bin/rails "admin_controls:unlock_demo_registrations[shengfukung-wenfu]"
bin/rails "admin_controls:lock_demo_registrations[shengfukung-wenfu]"   # to undo
```

Or directly: `Temple#unlock_demo_registrations!` / `#lock_demo_registrations!`
(each logs a `SystemAuditLog` entry, so toggling it is auditable).

## What NOT to do

- Do **not** complete a real Stripe setup checkout for this temple just to
  unfreeze it -- that would make it a genuine paying client and defeat the
  whole point.
- Do **not** delete or otherwise mutate its `platform_billing_entitlement`
  row to "fix" the freeze -- the period-scoping exclusion above already
  handles it correctly without touching that row.
- Do **not** assume `demo_registration_unlocked` implies real-client status,
  or vice versa -- they are two independent flags answering two independent
  questions ("can it register?" and "is it billed?"), and this temple is a
  live example of a temple that is genuinely yes/no on each.

## Source

- `app/models/temple.rb` -- `registration_intake_frozen?`,
  `demo_registration_unlocked?`, `unlock_demo_registrations!`,
  `lock_demo_registrations!`, `Temple.platform_billing_adopted`.
- `lib/tasks/admin_controls.rake` -- `unlock_demo_registrations`,
  `lock_demo_registrations`.
- `app/jobs/platform_billing_monthly_review_job.rb`,
  `platform_billing_monthly_collection_job.rb` -- the jobs that rely on
  `Temple.platform_billing_adopted` to skip non-real clients.
- `ops/docs/plans/ADMIN_BILLING_PANEL_FINDINGS_PLAN.md` -- Phase 3, where
  the two-phase monthly billing design this all supports was built.
