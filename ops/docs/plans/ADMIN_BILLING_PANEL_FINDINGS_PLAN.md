# Admin Billing Panel Findings Plan

Status: gathering findings, not yet accepted for implementation

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

## Next Step

Continue gathering findings — nothing here is scoped for a fix yet.
