# Admin Billing Panel Findings Plan

Status: findings gathered, organized into 3 phases by dependency/risk.
Phase 1, Phase 2, and Phase 3's code (job split + systemd templates) are
implemented and tested on this branch. The safety gate itself is still
in force and untouched: nothing on this branch installs or enables any
timer on production, and actually wiring the scheduler to fire real
Stripe charges still needs the Director's own direct confirmation of
live/test key status and an explicit decision to start Phase 5A — see
Phase 3 below.

Owner: Wenfu Planning / Director

## Purpose

Director reviewed the live "Platform usage billing" admin screen
(`/admin/platform_billing`) as an owner and found real problems. Rather than
patch each one immediately, this doc collects everything found in that
review pass (and whatever else turns up while continuing to look) before
any fix work starts — per the Director's explicit instruction: gather
problems first, don't just patch as they're found.

No implementation, deployment, or production action is authorized by this
document. It's a findings record.

## Implementation Phases

Ordered by dependency and risk, not by discovery order. Each phase is
independent of the others unless stated — nothing here requires the whole
doc to land in one shot.

### Phase 1 — Localization + tier chart (low risk, purely additive, no dependencies) — DONE

Pure view-layer work: add `t()` calls, add locale keys, render data that
already exists. No behavior change, no schema change, no shared
infrastructure touched. Safe to ship independently of everything else in
this doc.

- Finding 1: localize all 3 admin screens (`platform_billing/show`,
  `payments/new`, `sessions/new`). Done — new `admin.platform_billing.show.*`,
  `admin.payments.new.*`, `admin.sessions.new.*` namespaces in both
  `admin.en.yml` and `admin.zh-TW.yml`.
- Finding 4: localize all patron-side hits, both directions
  (`dependents/new`, `temples/index`, `registrations/edit` need English
  added; `oauth_resolutions/show`, `payments/ecpay_checkouts/show` need
  Chinese added). Done — note `payments/ecpay_checkouts/show.html.erb` is
  actually `Payments::EcpayCheckoutsController` (no `Account::` module), so
  it uses explicit `account.payments.ecpay_checkouts.show.*` keys rather
  than relative lookup.
- Finding 2: render the real 3-band tier chart instead of the one-sentence
  summary. Data already computed by `PlatformPricingPolicy::Quote` — view
  work only. Done — full tier breakdown table (base/band 1/2/3 + total) added
  to `platform_billing/show.html.erb`.
- Fallout fixed: 3 existing integration tests
  (`oauth_account_resolution_test.rb`, `oauth_identity_management_test.rb`,
  `admin/platform_billing_test.rb`) asserted the old hardcoded-English copy
  literally; updated to assert via `I18n.t(...)`, matching the rest of the
  suite's convention. 558/558 green on a fenced disposable test DB.

### Phase 2 — Grace period + dead-constant cleanup (small, contained behavior change) — DONE

A real behavior change (shortens how long a temple keeps service after a
failed charge), but self-contained — touches one service, one dead
constant, and the tests for both. No dependency on Phase 1 or Phase 3.

- Design Decision 4: `Billing::PlatformBillingLifecycle::GRACE_WINDOW`
  30 days → 14 days (7 + 14 = 21 total, down from 37). Done.
- Readiness Scan finding 2: delete the dead
  `Admin::PaymentMethodsForm::DEFAULT_BILLING_GRACE_DAYS` constant in the
  same change — leaving it would go stale as an unreferenced, misleading
  duplicate of the number this phase is changing. Done.
- Readiness Scan finding 4 confirms this is safe to apply uniformly:
  `grace_days` has no per-temple override path today, so there's no stale
  stored value on any temple to conflict with a new code-level default.
- Updated the one test with a hardcoded `37.days` total
  (`test/services/billing/platform_billing_lifecycle_test.rb`) to
  `21.days`, and added a direct constant-value regression test so a future
  accidental change to either window is caught immediately. Confirmed via
  full-repo grep that every other `30.days`/`37.days` hit in the codebase
  (JWT refresh TTL, session-preference seed expiry, report date-range
  fixtures) is unrelated to platform billing. 559/559 green on a fenced
  disposable test DB.

### Phase 3 — Two-phase monthly billing scheduling (highest risk, real infrastructure, explicit safety gate) — CODE DONE, NOT ACTIVATED

The biggest, riskiest piece — real scheduling infrastructure. Sequenced
last deliberately.

- Design Decision 1: split `PlatformBillingMonthlyCloseJob` into a
  capture/review step (1st of month) and a separate collection/charge
  step 2–4 days later (3rd or 5th — never the 4th). Done — the old job
  is gone, replaced by `PlatformBillingMonthlyReviewJob` (closes the
  statement, creates the pending delivery, no dispatch) and
  `PlatformBillingMonthlyCollectionJob` (dispatches every pending monthly
  delivery review left behind).
- **Correction to Readiness Scan finding 1, found while implementing**:
  the original claim ("no scheduling infrastructure exists... a
  cron/systemd timer is the lowest-footprint option") was incomplete. A
  prior commit (`af459d9`, 2026-08-03, "prepare TempleMate billing
  scheduler") had already built systemd timer/service *templates* for the
  old single-job design, and — contrary to what a first read of
  `bin/apply_systemd_units` suggests (it only ever installs
  puma/sidekiq) — those units were, per
  `ops/docs/reference/templemate_platform_billing_runtime.md`, actually
  installed on the production host directly, just left disabled pending
  a first-tenant decision. Verified this directly against the host:
  both `shengfukung-wenfu-platform-billing-monthly-close.timer` and
  `-lifecycle.timer` are loaded from `/etc/systemd/system/` and
  `Active: inactive (dead)` — confirmed non-firing, not just
  assumed. Presented this conflict (single daily-atomic design already
  built vs. the two-phase design decided earlier in this doc) to the
  Director directly rather than guessing; decision was to proceed with
  the two-phase split as planned and treat the old templates as
  superseded. The old `golden-template-platform-billing-monthly-close.*`
  templates are deleted, replaced by
  `golden-template-platform-billing-monthly-{review,collection}.*`;
  `ops/scripts/render_ops_templates.rb` and
  `ops/scripts/verify_templemate_phase4a.rb` updated to match, and the
  reference doc above updated with the new schedule table. Review runs
  daily (idempotent, same self-healing property as the old design);
  collection deliberately runs on a single fixed calendar day (the 5th)
  rather than daily, since running it every day would eventually
  dispatch the *following* month's pending delivery before that month's
  own buffer had elapsed. **The old disabled units already installed on
  the host reference a job class that no longer exists after this
  change** — inert since they were never enabled, but flagged in the
  reference doc for cleanup whenever someone with production access next
  re-runs the systemd staging step; this branch does not touch the host.
- Readiness Scan finding 3: the one existing job test hardcoded "close
  and dispatch happen in the same call" as its core assertion. Done —
  that test is deleted, replaced by two new test files
  (`platform_billing_monthly_review_job_test.rb` and
  `platform_billing_monthly_collection_job_test.rb`), each proving its
  job's actual new behavior including per-temple/per-delivery failure
  isolation.
- Design Decisions 2 and 3 (no minimum-threshold/carry-forward, no
  timezone handling) are already-settled scope reductions for this same
  phase — no code needed for either, since they're both "don't build
  this" decisions.

**Post-merge-review defect, found and fixed**: OperatorKit Strategy
reviewed the branch directly and found `PlatformBillingMonthlyCollectionJob`
collected *every* pending monthly delivery ever created, unbounded by
period — `reference_time` reached only the error-log metadata, never
scoped the query. Verified independently before touching anything: `.monthly.where(status: "pending")`
had no period filter, `PlatformBillingCollectionDispatcher` guards only
kind/status/currency (no period guard either), and all 3 original tests
created their delivery in the current period only — the backlog case was
untested. Consequence: the first real collection run after any gap in
scheduling (including first activation, since the old timers have been
sitting disabled this whole time) would have charged every
never-collected delivery across every past month in one pass, to live
cards. Fixed: added `Billing::PlatformUsage.previous_month`/
`.period_start_at_for` as the single shared computation both jobs use, so
`reference_time` means the identical period in both; collection now
scopes to `status: "pending", period_start_at: <that period>` instead of
an unbounded query. Added the regression test Strategy asked for (a
pending delivery from an earlier period, asserted not collected). 564/564
green.

Strategy then traced the full value chain by reading (review job →
`PlatformStatementCloser` → `PlatformBillingDeliveryCreator` → collection
job) and confirmed the fix holds by construction, not convention — but
flagged that every test still hand-builds its delivery's `period_start_at`
with the same helper the job calls, which proves the job's query is
self-consistent but never proves a delivery born from the *real* path
lands somewhere collection actually finds. Added
`test/jobs/platform_billing_monthly_review_to_collection_test.rb`: runs
the real review job, then the real collection job, and asserts the
delivery review created through the actual closer/creator path is
exactly the delivery collection dispatches — no hand-built
`period_start_at` anywhere. 565/565 green.

**Resolved by the Director — no hold/void status needed**: Strategy had
separately flagged that `PlatformBillingDelivery::STATUSES` has no
hold/void/skip state, so an operator has no affirmative way to pull one
delivery out of the collection pass during the buffer. Director's
decision: keep it simple. The buffer is intentionally passive, not a
gate — it's a chance for the temple admin to notice and flag a problem
during the window, not a self-service hold mechanism. If it's ignored,
the charge goes through as designed; that's the correct default, not a
gap. A notification system prompting admins to check during the window
is a real future improvement, explicitly deferred, not part of this
phase.

This is already supported by what Phase 1 built, not just a policy
statement with nothing behind it: `admin/platform_billing/show.html.erb`
(the same page the tier chart lives on) lists closed statements each
with their delivery's live collection status — once review closes a
period, that statement and its "Pending" delivery appear there
immediately, visible to any owner who checks during the buffer window.
No new status or UI needed for the Director's intended design; the
existing view already surfaces exactly what a checking admin needs to
see.

**Explicit safety gate, not optional — still fully in force**: Finding 3
already established the collection code is real (genuine
`Stripe::Invoice.create` with `collection_method: "charge_automatically"`)
and the Director's stated belief (not yet independently verified against
the Stripe dashboard) is that the configured key is live mode. Building
the two-phase code in this phase does not mean wiring it to actually fire
automatically — nothing in this phase installs, enables, or starts either
new timer on production. Activating real scheduled execution stays gated
on the Director confirming live/test key status directly and deliberately
choosing to start Phase 5A of
`SHENGFUKUNG_PAYMENT_AND_OFFERING_PHASE_ROADMAP.md`, independent of when
the code itself is merged.

## Confirmed Findings

### 1. Three admin screens were never localized at all — not just Platform Billing

Director's original observation was about `/admin/platform_billing`
showing untranslated English despite the locale switcher being set to
繁體中文. Checked how widespread this actually is with a systematic sweep
(every `app/views/admin/**/*.erb`, checked for real `t("...")` calls,
excluding generic reusable partials that take pre-translated text as
params) rather than assuming it was isolated to one page. Three real hits:

- `app/views/admin/platform_billing/show.html.erb` — added 2026-08-02
  ("feat: add temple usage billing meter"). Zero `t()` calls; every string
  (labels, headings, table headers, the pricing-policy sentence) is a
  hardcoded English literal. No `platform_billing` keys exist in either
  locale file at all — this was never wired for i18n, not a broken lookup.
- `app/views/admin/payments/new.html.erb` (**"Record Cash Payment"** — the
  exact screen the sales-demo cash-completion flow depends on, verified
  working end-to-end against a real offering earlier today) — from the
  original 2026-01-05 build. Same shape: zero `t()` calls, all hardcoded.
- `app/views/admin/sessions/new.html.erb` (**the admin login page itself**
  — the single highest-traffic screen in the entire admin panel) — from
  the original 2026-01-02 build. "Temple Management System," "Sign in
  to...," "Continue with OAuth," etc. — all hardcoded English, regardless
  of locale.

Two files the same sweep flagged and ruled out as false positives, confirmed
by reading them: `_segmented_boolean.html.erb` and `_date_picker_script.html.erb`
are a generic reusable form partial (renders whatever label/text its caller
passes in, no text of its own) and pure JS with locale-agnostic placeholder
formatting — neither is a real gap.

The two oldest hits (login page, cash payment form) predate any i18n
convention in the codebase; the newest hit (platform billing, 8 months
later) shows the pattern of "ship a new admin screen without localizing
it" has recurred since, not just a one-time historical artifact from
before i18n existed. Worth treating as a class of gap, not three isolated
one-offs — there may be more not yet found; this sweep covered `admin/`
views specifically, not `account/` or public-facing views.

### 2. Platform billing pricing shown as one vague sentence instead of the real tier structure

Current copy: *"NT$1,500 base includes 500 registrations. Progressive
usage begins at registration 501; payment value and donations are not
used."* The actual policy (`Billing::PlatformPricingPolicy`) is a real
3-band progressive schedule the sentence doesn't convey:

| Band | Range | Rate |
| --- | --- | --- |
| Base | 1–500 | NT$1,500 flat |
| 1 | 501–2,000 | NT$1.00 / registration |
| 2 | 2,001–10,000 | NT$1.25 / registration |
| 3 | 10,001+ | NT$1.50 / registration |

The `Quote` struct returned by `PlatformPricingPolicy.quote` already
computes `band_one_registration_count`/`band_two_fee_cents`/etc. for every
band — the data for a real tier breakdown already exists, the view just
never rendered it as more than one summary sentence.

### 3. The Stripe monthly-collection mechanism is real code but fully inert today

Director asked directly whether the "charge the saved payment method"
mechanism is real or fake. Checked precisely rather than assumed either
way:

- `Billing::StripePlatformBillingCollection#collect!` is genuine, working
  Stripe API integration — real `Stripe::Invoice.create` with
  `collection_method: "charge_automatically"`, not a mock or stub. If it
  ran successfully it would attempt a real charge.
- **Nothing ever triggers it.** Full-codebase search found no cron, no
  scheduled job, nothing that ever enqueues `PlatformBillingMonthlyCloseJob`.
  It is entirely inert unless someone manually invokes it — there is no
  automatic monthly billing today, for any temple.
- Stripe credentials (secret key, publishable key, platform account ID,
  setup/monthly Price IDs, webhook secret) are all configured in
  production via env vars. Whether the configured secret key is live or
  test/sandbox mode was **not checked** — even reading the key's prefix
  was correctly blocked by the session's own safety tooling as credential
  material. Only the Director knows which mode is configured; this doc
  does not guess.
- Checked directly (safe to inspect — internal record IDs, not secrets):
  the `shengfukung-wenfu` demo temple has **no** `stripe_customer_id` or
  `stripe_payment_method_id` saved in `billing_settings`. Even if the job
  were manually triggered today, `collect!` would raise
  `"Verified Stripe customer is required"` before ever reaching Stripe —
  nothing would be charged, regardless of live/test key mode.

Net: the collection code is real and would work for a temple that had a
saved payment method and a running scheduler, matching
`SHENGFUKUNG_PAYMENT_AND_OFFERING_PHASE_ROADMAP.md`'s own status (Phase
5A — Stripe sandbox validation — explicitly not started yet, deferred
until the Director is ready). For the demo temple today, it's genuinely
inert on both counts (no scheduler, no saved payment method), independent
of whatever Stripe mode is configured.

**Director's stated belief (2026-08-21, not independently verified by this
session): the configured `STRIPE_SECRET_KEY` is live mode, not test/sandbox.**
Worth being precise about the actual implication, since Phase 5A's whole
premise was validating against sandbox data first: if that belief is
correct, the two inert-today conditions above (no scheduler, no saved
payment method) are the *only* things currently preventing a real charge
attempt — there is no sandbox layer underneath them. Any future work that
populates a real `stripe_customer_id`/`stripe_payment_method_id` on any
temple's `billing_settings`, or that manually invokes
`PlatformBillingMonthlyCloseJob`/`StripePlatformBillingCollection`
without deliberately checking this first, would be operating against
real money, not test data. Worth the Director confirming this directly
against the actual Stripe dashboard before any Phase 5A work proceeds,
rather than relying on a recalled belief.

### 4. The same class of gap exists on the patron-facing side too — both directions

Director asked to extend the sweep to `account/` (patron-facing) views.
Confirmed first that the account portal genuinely supports both locales
(`account_locale_path`, a real switcher in `layouts/account.html.erb`) —
so a locale mismatch on these screens is a real defect, not moot.

Two different directions of the same underlying problem, not one:

- **Hardcoded Traditional Chinese, no English fallback ever** —
  `account/dependents/new.html.erb`, `account/temples/index.html.erb`,
  `account/registrations/edit.html.erb`. A patron on the English locale
  would see Chinese on these three screens regardless.
- **Hardcoded English, same as every admin-side hit** —
  `account/oauth_resolutions/show.html.erb`. Worth flagging specifically:
  this is the **web equivalent of the exact native OAuth account-resolution
  screen built and tested extensively earlier today** ("I already have an
  account" / "Create a new account") — the feature is real and working,
  it has simply never been localized on the web surface, same as the
  admin login page.
- **`payments/ecpay_checkouts/show.html.erb`** — the actual ECPay checkout
  redirect page real patrons see mid-payment ("Redirecting to ECPay...").
  Hardcoded English, zero `t()` calls. Unlike the Stripe platform-billing
  finding above, ECPay is the live, active provider real patrons pay
  through today — not a deferred phase.

One checked and ruled out: `demo/playground/show.html.erb` looked like a
hit on the same sweep, but all its text comes from controller-passed
instance variables (`@hero`, `@features`, `@cta`), not hardcoded in the
view — any gap there would be a data/controller question, not a template
one, and it's a playground/demo page rather than a real patron surface.

## Open Questions, Not Yet Answered

- ~~Is the configured `STRIPE_SECRET_KEY` live or test/sandbox mode?~~
  **Partially resolved.** Director's stated belief is live mode (see
  Finding 3) — not independently verified against the Stripe dashboard.
  Treat as provisional until confirmed there directly.
- Should `PlatformBillingMonthlyCloseJob` ever run automatically (a real
  cron/scheduler), or is manual triggering the intended model even once
  Phase 5A starts?
- ~~Public marketing pages are Vue-based...~~ **Resolved, not open.**
  Checked the Vue router (`vue/src/layouts/classic/routes.js`) directly:
  it only exposes marketing/informational routes (home, about, events,
  archive, news, services, contact) — no login, registration, account, or
  payment routes anywhere. All real functionality (login, registrations,
  payments, account management) is server-rendered by Rails under
  `/account`, confirmed, not assumed. Out of scope for this findings doc
  for that reason — nothing "functional" there to have a localization or
  billing gap in.

## Design Decisions For Future Monthly Billing Scheduling

Not implementation yet — decisions to build against once this doc moves
past gathering. Reference: `Combatives-Rails`'s
`MonthlyDispatcherJob`/`MonthlyChannelBillingReviewWorker`/
`ChannelBillingCollectionWorker` (a real, running two-phase
capture-then-collect pattern with a deliberate gap between the two, plus
a minimum-collection-threshold/carry-forward mechanism for small amounts).

1. **Two-phase schedule, Wenfu-scaled dates.** Combatives runs review on
   day 5/6 and collection on day 7/8 specifically because it's already
   Sidekiq-heavy across many entities and needs the load spread out.
   Wenfu doesn't have that constraint (far fewer temples, no daily/weekly
   per-temple jobs, only monthly billing) — so the capture/review step
   runs on the **1st of the month**, with collection following 2–4 days
   later. Deliberately **not the 4th** — considered inauspicious in a
   temple context (homophone for death in Mandarin/Taiwanese), a real
   product constraint for this specific customer base, not a technical
   one. **3rd or 5th** are the accepted candidates for the actual collection
   date; exact choice still open.
2. **No minimum-collection-threshold/carry-forward needed.** Confirmed
   the reasoning, not just accepted it: Combatives needs this because
   its charges are usage-only and can land on tiny per-period amounts.
   Wenfu's base fee is a flat NT$1,500/month regardless of usage — there
   is no tiny-amount scenario to guard against, so this piece of the
   reference pattern is deliberately not carried over.
3. **No timezone-handling needed, for a specific and durable reason, not
   just current scope.** This product is Taiwan-only by deliberate
   choice — roughly 12,000 temples in Taiwan is the actual addressable
   market, and the stated priority is converting those before considering
   expansion to other Chinese-diaspora markets. Worth recording precisely:
   even a future mainland China expansion would stay the same timezone
   (China Standard Time = Taiwan time, both UTC+8) — so this isn't a
   "we'll deal with it later" gap, it's a genuinely low-probability-ever
   problem for this product's realistic growth path. The separate concern
   Combatives' timezone-spread machinery actually solves — spreading cron/
   Sidekiq load — is a real future consideration if temple count grows
   large, but Wenfu has far less recurring-job volume than Combatives to
   begin with (monthly billing only, no daily/weekly per-temple jobs), so
   even that concern is smaller in shape. Not a today problem either way.
4. **Grace period: shorten from the current 30 (37 total) days to 7 +
   14 = 21 days.** Current `Billing::PlatformBillingLifecycle` runs
   `OVERDUE_WINDOW = 7.days` then `GRACE_WINDOW = 30.days` — 37 days
   total from a failed charge to freezing the temple's account. Accepted
   direction: keep the 7-day overdue window, shorten the grace window to
   14 days (21 total) — closer to common practice than the current 37,
   while still meaningfully longer than a typical consumer-SaaS dunning
   window, appropriate for a B2B/community-institution relationship.

## Readiness Scan — Inconsistencies And Gaps Before Implementation Starts

Checked for things likely to trip up the actual fix work, ahead of time
rather than mid-implementation.

1. **No scheduler infrastructure exists at all, at the gem level.** Not
   just "nothing currently calls the job" (already known) — checked the
   `Gemfile` itself: Sidekiq is the configured `ActiveJob` adapter, but
   there is no `whenever`, `sidekiq-cron`, or `sidekiq-scheduler`, nothing
   that could run a job on a schedule at all today. Implementing the
   two-phase design (Design Decision 1) requires deciding on and adding
   an actual scheduling mechanism first — a system-level cron/systemd
   timer invoking a rake task (matches how Puma/Sidekiq are already
   managed on the droplet) is the lowest-footprint option, versus adding
   a new gem. This is infrastructure work, not just business logic —
   worth sequencing explicitly, not discovering mid-implementation.
2. **A second, independent, dead `30` constant exists.**
   `Admin::PaymentMethodsForm::DEFAULT_BILLING_GRACE_DAYS = 30` — defined,
   never referenced anywhere else in that file or elsewhere. The actual
   displayed/used grace value comes from `Temple#billing_grace_days`
   (`billing_settings["grace_days"] || 30`), a completely separate code
   path from this constant. Changing the grace period (Design Decision 4)
   without also removing this dead constant would leave a stale "30"
   sitting in the code that could mislead a future reader into thinking
   it's the source of truth, or that there's a real inconsistency to
   chase down. Worth deleting in the same change, not a separate cleanup.
3. **The existing job test hardcodes "close and dispatch happen in the
   same job call" as core behavior**, not incidentally. `test/jobs/platform_billing_monthly_close_job_test.rb`
   asserts `PlatformBillingMonthlyCloseJob.perform_now` closes the
   statement *and* dispatches collection in one call, immediately
   verifiable in the same test. Splitting into two phases 2-4 days apart
   means deliberately rewriting this test's core assertions, not just
   adding new coverage alongside it — the single existing test would
   otherwise keep asserting a behavior the redesign removes.
4. **Good news, checked rather than assumed: `grace_days` is read-only
   everywhere.** No admin UI, form, or controller ever writes
   `billing_settings["grace_days"]` for any temple — it's a pure
   code-level default with no per-temple override capability today.
   Changing the default from 30 to 14 applies uniformly to every temple
   immediately; there's no risk of a stale explicit "30" lingering on any
   temple's stored settings to cause drift.

## Next Step

All 3 phases implemented and tested on `claude/platform-billing-findings`;
nothing merged to `main` yet. No open decisions remain — the
hold/void-status question is resolved (see the "Resolved by the
Director" note under Phase 3): the buffer is intentionally passive, a
chance for the temple admin to notice via the existing platform-billing
view, not a self-service gate; ignoring it means the charge proceeds as
designed. A future notification system to prompt admins to check is a
deliberately deferred improvement, not a blocker.

Remaining before this branch can be merged is only the standard
review/merge step itself — no further phase work or design decisions are
outstanding. The activation safety gate (actually enabling either new
timer on production) is separate from merging this branch's code and
stays with the Director alone, independent of when the merge happens.
