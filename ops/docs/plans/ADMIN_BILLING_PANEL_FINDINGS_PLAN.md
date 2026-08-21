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

- Is the configured `STRIPE_SECRET_KEY` live or test/sandbox mode? Only
  the Director can answer this safely; not something this session
  determines by inspecting the key itself.
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

## Next Step

Continue gathering findings — nothing here is scoped for a fix yet.
