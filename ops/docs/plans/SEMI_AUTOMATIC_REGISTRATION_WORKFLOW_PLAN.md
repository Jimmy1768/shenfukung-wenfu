# Semi-Automatic Registration Workflow Plan

Status: item 1 (the registration-completion gate) implemented and shipped
2026-08-23, and materially extended 2026-08-28 -- gatherings are no longer
exempt, and the surrounding lifecycle now has queryable states, work queues,
bulk completion, and a recordable fulfilment stage. See
`ops/docs/reference/admin_portal.md` and
`ops/docs/reference/account_portal.md` for the durable description of how it
actually works; those are maintained, this is not.

Item 2 (admin notification email) remains deferred and is now partly
described by W2 of `PERSONAL_AND_OFFERING_DATA_CONTRACT_GAP_PLAN.md` as
pipeline stage 7 -- `Notifications::DispatchEvent` exists with zero callers.
Items 3-4 remain deferred, findings/design only, no phase authorized.

Owner: Wenfu Planning / Director

## Purpose

Director's own words, close to verbatim: patrons start a registration —
that's *intent*. Admin should get notified, then complete the
registration (fill in the details the patron-side form can't capture —
lamp type, dedication message, etc. — and confirm the choice is actually
available). After that, the patron can pay online from the app, or come
in person and pay cash. "Semi-automatic," by design: the admin is a
deliberate checkpoint, not a bottleneck to remove. Director explicitly
does not want a fully automatic patron-picks-everything flow, since there
is no backend concept of per-sub-type availability today (a patron
picking "太歲燈" when none are actually left has nothing to stop them).

This doc exists because the design is coherent and confirmed against the
Director's mental model, but most of it is not built yet — this session's
own testing found that today a patron can self-register *and* pay online
immediately, with zero admin involvement in between. The checkpoint the
whole design depends on doesn't exist as an enforced gate right now.

## Confirmed current state (as of this session)

Verified directly, not assumed:

- Patron self-registration already is deliberately "thin" — only
  quantity/contact info, arrival window, notes. It cannot capture any
  offering-specific field (lamp type, dedication message, table size,
  certificate number, etc.). This already matches "patron intent, not a
  finished registration."
- Admin editing a registration (`Admin::OfferingOrdersController#update`)
  already supports every offering-specific field across all 4 real
  templates, and can add them after patron self-registration. Proven
  end-to-end this session, including the `certificate_number` bug found
  and fixed along the way (see commit history on `main`,
  `real_pilot_temple_all_offerings_admin_test.rb`).
- Cash completion already works end-to-end: admin marks a registration
  paid, a `FinancialLedgerEntry` posts, the `view_financials`-gated
  Payments index reflects it correctly. Proven via
  `real_pilot_temple_sales_demo_script_test.rb`, chaining patron-register
  → admin-complete → admin-cash-accept → accounting screen, exactly the
  sales demo script.
- **The gate does not exist.** `Account::RegistrationsController#start_checkout`
  only checks `current_temple.registration_intake_frozen?` (a
  billing-freeze concept, unrelated to admin review). Nothing currently
  blocks a patron from self-registering and immediately paying online,
  skipping the admin-completion step the whole design assumes. This is
  the single most important gap below.
- There is exactly one `pending` status covering the entire
  pre-payment lifecycle (`TempleRegistration::PAYMENT_STATUSES`). Nothing
  today distinguishes "just patron intent, unreviewed" from "admin
  confirmed, ready to pay."
- A real, working push-notification system already exists
  (`Notifications::Push::Delivery`, Expo/FCM-capable) and a generic
  `Notifications::DispatchEvent` dispatcher (push → email fallback,
  `NotificationRule`/`Notification` tracking records) — but it has **zero
  call sites anywhere in the app**. Built for something, never wired to
  anything, including this.
- No attendance/check-in concept exists anywhere in the backend today —
  not a stub, not a dead column, nothing. `fulfillment_status`
  (open/fulfilled/cancelled) is the closest existing concept, and it's
  not the same thing as tracking who showed up.
- The 4 real offering templates are now live on production
  (`offerings:apply_templates` rake task), so all of the above can
  actually be exercised for real, not just in tests.

## Explicitly ruled out, per the Director

- **Push notifications, for now.** Not a backend limitation — TempleMate's
  Expo app was never given an admin-side surface at all, so there is no
  mobile endpoint a push notification could even target for an admin.
  This is a real, structural blocker, not a "wish" that can be worked
  around cheaply. Email is the realistic near-term channel; the
  infrastructure for it already exists and is unwired (see above).
- **A second app surface for admin**, along the lines of DojoMate's
  `adminRole`-gated second menu. Explicitly rejected as too heavy. Any
  admin-mobile work must be a thin, role-gated addition to the *same*
  single app shell and navigation — a role check, not a mode switch — not
  a parallel admin app-within-the-app.
- **Duplicating the admin console.** Whatever light mobile surface
  eventually gets built is a small, specific slice (e.g. complete a
  registration, check attendance), not a second copy of the existing Rails
  admin views.

## Deferred work items

Not ordered into phases yet — no implementation authorized. Listed by
what each depends on.

### 1. The registration-completion gate (most load-bearing item here) — DONE

Implemented 2026-08-23: `TempleRegistration#admin_completed_at` (set via
`#mark_admin_completed!`, idempotent), gated only the patron's own
`start_checkout` path per the Director's explicit confirmation below, and
originally exempted gatherings (no offering-specific fields to complete, and
at the time no admin UI to ever clear the gate for one). **That exemption
was removed 2026-08-28** -- a gathering is a sub-type, not a separate flow,
so it now follows the same pipeline; the completion path had to be built
first, since removing the exemption alone would have made every gathering
registration permanently unpayable. Admin action lives on the registration's
own show page. Full current-state description now lives in
`ops/docs/reference/admin_portal.md` and
`ops/docs/reference/account_portal.md`; the design reasoning below is kept
for context on items 2-4, which still depend on this.

Without this, nothing else in the design is actually enforced — it's the
one piece that turns "semi-automatic" from a description into an actual
control.

Needs a design decision before any code: does the gate block *only* the
patron's own online-checkout path (`start_checkout`), or does it also
need to block/allow something for the admin's own cash-completion path?
Worth noting: in the sales-demo script itself, the *same admin* both
completes the registration and immediately accepts cash in one sitting —
so the gate as actually needed is specifically "block patron-initiated
online payment until an admin has completed the registration," not a
block on admin action generally. Likely shape:

- A new distinguishing signal on `TempleRegistration` — either a new
  status value, or a `completed_at`/`completed_by_admin_id` pair — set by
  a new, explicit admin action (not just any edit; needs to be a
  deliberate "mark as ready for payment" step, distinct from ongoing
  metadata edits).
- `start_checkout` gains a check against that signal, redirecting/blocking
  with a clear message if the registration hasn't been marked complete
  yet.
- Cash payment (`Admin::PaymentsController#create`) is admin-initiated by
  definition, so it doesn't need the same gate. **Director confirmed
  2026-08-23**: gate patron online checkout only, leave admin cash
  acceptance ungated.

### 2. Email notification to admin on new patron registration

Depends on (1) existing as a real event to hook into (the natural trigger
is "patron registration created, awaiting completion").

- Add a new `event_key` (e.g. `registration.awaiting_completion`) and wire
  a call to `Notifications::DispatchEvent.call(user: ..., event_key: ...,
  delivery_methods: [:email])` from
  `Account::RegistrationsController#create`.
- Needs a `NotificationRule` seed entry for the new event/channel.
- Open question, not yet decided: who is "the admin" that gets notified
  for a given temple? Every admin with `manage_registrations`? Just the
  owner? Configurable per temple? This needs a real answer before writing
  the recipient-resolution code, not an assumption.

### 3. ECPay online payment, tested for real

Not urgent, but the Director considers it near-term. Technically a known
quantity — DojoMate and Combatives-Rails already accept platform payments
via a comparable pattern, so the *mechanism* isn't new ground. What's
actually untested is the ECPay route specifically end-to-end, and that
needs a real temple with real ECPay merchant credentials on file — the
demo temple's fake NT$50 flow can't stand in for this, since ECPay itself
needs to be live on the other end. Deferred until there's a real temple
ready to test against, not blocked on any unsolved technical question.

### 4. Light admin mobile surface (later phase, explicitly deferred)

Candidate scope, per the Director: complete a registration, check an
attendance list — "very light, in case admin is away from computer." Two
real open questions before this becomes buildable work:

- **Native screens vs. mobile web.** A first cut might not need any new
  Expo/React Native code at all — the existing Rails admin views, opened
  in a mobile browser (reached via an emailed link once (2) exists),
  could satisfy "away from computer" without touching the mobile app at
  all. Worth deciding whether that's sufficient before committing to
  native work.
- **Attendance/check-in doesn't exist yet, at any layer.** This isn't a
  UI-only task — there's no backend model, no status, nothing to surface.
  If this stays in scope, it's new backend design work first, not just a
  mobile screen over an existing concept.
- Whatever ships must be role-gated inside the single existing app
  shell, per the "no second surface" ruling above — not a new nav stack,
  not an `adminRole` mode switch.

## Loose end, not part of this plan

`shengfukung-wenfu` has a 5th, pre-existing service offering
(`peace-opera-household`, `status: draft`) that is not one of the 4
templates. Per the Director: it's actually two offerings mixed together
and needs clarification from the temple before it can be split/finalized.
Left untouched — draft status means it's not patron-visible, so it's
inert, not urgent, and out of scope for this plan.

## Next Step

Item (1) is done and extended; see the Status note above. Items (2)-(4) are
still unauthorized. (2) is the most likely next candidate and is tracked
more precisely as stage 7 in
`ops/docs/plans/PERSONAL_AND_OFFERING_DATA_CONTRACT_GAP_PLAN.md`, which
records that the notification infrastructure already exists and needs only a
caller.
