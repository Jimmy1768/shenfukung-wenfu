# Personal And Offering Data — Contract Gap Plan

Status: **W1, W2 and W4 are implemented and shipped** (2026-08-28, commits
`f4a85f5`, `f76bffe`, `e96773c`, `4138cb1`, plus `9e9cbe3` for a FormSchema
defect found during W4). **W3 remains open and unauthorized**, pending the
Shengfukung onboarding visit, which is its input rather than its blocker.

This doc is retained ONLY for W3 and for the decision record. The durable
description of what W1/W2/W4 actually built is maintained in
`ops/docs/reference/admin_portal.md` and
`ops/docs/reference/account_portal.md` — read those, not this. Per
`ops/protocol/claude_work_mode.md`, plan docs drift and are not maintained;
the shipped sections below are kept because their *decision reasoning* is
still worth recovering, not because they describe current behavior.

Reviewed by OperatorKit Strategy across three rounds. No implementation,
production-data, deployment, or account action is authorized by this
document; the implementation that happened was separately authorized by the
Director directly.

Drafted 2026-08-28, recorded against `main` at `dcd5493`.

## Purpose

The Director restated the account/admin personal-and-offering-data model from
first principles on 2026-08-28. This document records that model, checks it
against what the code actually does today, and scopes the gaps.

It is a **gap plan, not a redesign**. Where a gap overlaps existing accepted
work it points there instead of re-specifying:

- `ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`
  — the accepted contract (Phases A0–A4 complete). This document does not
  reopen it; it records where the *stated model* and the *implemented
  contract* diverge.
- `ops/docs/plans/TEMPLE_OFFERING_SYSTEM_SPEC.md` — canonical offering
  vocabulary, including derived `zodiac`/`heavenly_stem_earthly_branch` and
  lunar-calendar defaults.
- `ops/docs/plans/SHENGFUKUNG_OFFERINGS_CONFIG_PLAN.md` — replacing the
  simplified live config with real temple definitions.

## Reading order note

The four workstreams are ordered by **irreversibility first, then blast
radius** — revised from "blast radius" alone after review (see Review Record).
Those are different axes and the distinction matters here:

- **W1 is damage already accruing.** Every completed registration overwrites a
  patron's phone with no recoverable prior value. Waiting destroys information
  nobody can reconstruct.
- **W3 is a capability gap.** Nothing is being destroyed; work simply cannot
  be onboarded. Its cost is bounded by "cannot onboard yet," which later work
  fully recovers.

W3 is very likely the larger *business* blocker, and this ordering does not
dispute that. It says only that W1's cost is the one no later work can undo.

Ordering is deliberately not by the order these surfaced in conversation. W4
was discussed longest and in most detail; that is not evidence it matters
most, and it is placed last on purpose. Effort is called out separately per
workstream, because it does not track severity — W3 is the largest body of
work and sits third.

Each workstream stands on its own and can be dispatched independently.

## The Director's stated model

1. **Personal data** — patron-entered, not mandatory. Phone matters most
   (it is how the temple reaches them). Address and birthday are less
   obviously important.
2. **Offering data** — admin-side. Patrons do not know or understand every
   item, so it is not surfaced to them; each temple's config differs and
   there is no unified template. A patron-initiated registration submits a
   **truncated** form and arrives **pending**; an admin completes the rest,
   phoning the patron for anything missing (e.g. a deceased infant's name).
   Only then does it move to payment-pending.
3. **Reuse** — once #2 is done, the information is saved and prefilled next
   time. Years change (annual ceremonies); the underlying facts do not. Do
   not make an admin ask the same question again.
4. **Per-registration offering data** — some offering data legitimately
   changes every time (an offering table's food items and amounts). This is
   still offering data, not personal data.
5. **Dependents** — patrons create them. A temple admin may assist, but may
   not create them.
6. **Off limits** — a temple must not edit foundational patron data (name,
   phone). A temple may edit data directly relevant to offering templates.

## Verdict against current code

| Rule | Holds today? | Workstream |
| --- | --- | --- |
| 1. Personal data, optional | Partial — optionality holds; the field set does not cover real ritual needs | W3 |
| 2. Truncated → pending → admin completes → payment | Partial — 6 of 9 pipeline stages exist; no stage model, no queues | W2 |
| 3. Save and prefill next time | Yes | — (W4 refines) |
| 4. Per-registration data changes every time | No — not modeled; treated as durable | W4 |
| 5. Patron creates dependents, admin cannot | Yes, exactly | — (W3 touches the shape) |
| 6. Temple cannot edit foundational patron data | No — violated for `phone` and `notes` | W1 |

Rules 3 and 5 hold as stated and need no corrective work. Rule 5's
*enforcement* is correct; W3 questions whether the dependent **shape** is
sufficient, which is a different question from who may create one.

---

## W1 — Admin registration edits overwrite the patron's own profile

**SHIPPED 2026-08-28 (`f4a85f5`).** Current behavior lives in
`ops/docs/reference/account_portal.md`.

**Rule 6. Severity: highest — active, silent, affects real data now. Effort:
small.**

### What happens today

`Registrations::UserMetadataUpdater::CONTACT_MAPPINGS`
(`app/services/registrations/user_metadata_updater.rb:5-9`) maps a
registration's contact payload into the patron's `user.metadata`:

```ruby
"phone"            => "phone",
"dependents_notes" => "notes",
"notes"            => "notes",
```

`Account::ProfileForm` reads and writes those *same keys* as the patron's own
profile fields (`app/forms/account/profile_form.rb:45,53`). They are not
parallel stores; they are one store.

The updater runs on both admin paths:

- admin create — `Payments::TempleRegistrationBuilder#persist_user_defaults`
  (`app/services/payments/temple_registration_builder.rb:90`)
- admin edit — `Admin::OfferingOrdersController#sync_reusable_defaults_after_update`

So when an admin types a phone number while completing a registration, the
patron's **profile** phone number is rewritten. The patron is not told, and
the previous value is not recoverable from the audit record: the audit logs
changed field *names* (`changed_reusable_fields`), never before/after values —
which is correct for privacy, but means this particular overwrite leaves no
recovery path.

### What is already safe

- `english_name` / `native_name` are **not** in the mapping.
- `Admin::PatronsController` has no `update` action; its dead `create` action
  was deleted 2026-08-19.
- When a dependent is selected, admin create passes `contact_payload: {}`, so
  dependent-scoped registrations do not touch the patron's profile. Only
  self-scoped ones do.

So the violation is precisely two fields on one path — not a general leak.

### What is needed

Separate "contact details for this registration" from "the patron's stored
profile." The registration snapshot should keep whatever the admin typed
(that is legitimately registration data), while the patron's profile fields
stay patron-owned.

### Second defect in the same method — fold into the same fix

`CONTACT_MAPPINGS` maps **two** sources to the same destination:
`"dependents_notes" => "notes"` and `"notes" => "notes"`. `update_contact_metadata`
iterates and calls `assign_value`, which is a plain overwrite, so when a
registration carries both, hash insertion order decides and `notes` silently
wins.

Precisely scoped: the **registration snapshot keeps both** — they are separate
keys in `contact_payload`. What collapses is only the write into the patron's
profile `notes`. So this is a cache-fidelity bug, not registration data loss.
It compounds W1 rather than standing alone: notes *about a dependent* are
being written into the *patron's own* profile notes field in the first place.
A fix that gives registration-scoped contact data its own home resolves the
collision as a side effect.

### DECIDED 2026-08-28 — option (d)

When an admin learns on the phone that a patron's number has genuinely
changed, the registration writes to its **own namespace** and the patron
reconciles later. The registration writes
`metadata["registration_contact"]["phone"]` and never touches
`metadata["phone"]`. On the patron's next profile visit: "a recent
registration used a different number — keep yours, or update it?"

Options considered and rejected:

- **(a) registration only, never write anywhere reusable** — looks strictest
  but breaks rule 3. Contact prefill reads `user.metadata`, so never writing
  means the stale number returns next year and staff re-ask, which is the
  exact friction rule 3 exists to remove.
- **(b) prompt the admin ("also update this patron's profile?")** — honest,
  but the admin is deciding about data they do not own, and under season
  pressure a always-click-yes prompt degrades to (c) with an audit trail.
- **(c) silent, as today** — the defect being fixed.

Why (d): the clean split is that the temple **is** authoritative over "what
number did we reach them at for this registration" and is **not**
authoritative over "what is this person's phone number." That is the same
ownership logic as rule 5 — staff assist, the owner decides.

**Required with it:** a read-precedence rule (registration contact first,
profile as fallback), because staff need a single answer when the two differ.
Many of these patrons may never sign in, so the reconciliation prompt may
rarely fire; precedence is what makes (d) satisfy rule 3 regardless.

**Subsumes** the `dependents_notes`/`notes` collision above — both stop
writing to the patron's profile `notes`.

### Related: the gate method is now misnamed

Not part of W1's fix, but discovered alongside it and belonging to whichever
packet touches this code. `Temple#registration_intake_frozen?` no longer
freezes registration intake — that was removed on 2026-08-28 when intake was
separated from payment. Every remaining call site is a **payment** site:

- `account/registrations_controller.rb:84` — patron online checkout (ECPay)
- `admin/payments_controller.rb:75` — admin-initiated ECPay
- `payments/cash_payment_recorder.rb:54` — admin recording patron cash

The name actively misleads and has already caused one round of ambiguity in
discussion. Rename to something payment-accurate (e.g.
`platform_billing_delinquent?` or `payment_settlement_frozen?`).

## W2 — The registration lifecycle has no stage model or work queues

**SHIPPED 2026-08-28 (`f76bffe`, `e96773c`).** Stage 7 (push notification)
remains deliberately deferred. Current behavior lives in
`ops/docs/reference/admin_portal.md`.

**Rule 2. Severity: high — blocks the stated operating model at any real
volume. Effort: moderate; two stages are unbuilt.**

Expanded 2026-08-28: the Director restated rule 2 as a **nine-stage
pipeline**, not a single pending-completion checkpoint. W2's scope grew
accordingly.

### The Director's nine stages, mapped to code

| Stage | Exists | Evidence |
| --- | --- | --- |
| 1. Patron starts a registration | yes | `Account::RegistrationsController#create` |
| 2. Payment not allowed immediately | yes | `checkout_ready?`, built 2026-08-28 |
| 3. Admin starts one; both paths converge | yes | both create the same `TempleRegistration` |
| 4. Delinquency gate | yes, but sited at stages 7–8 | see resolution below |
| 5. Admin completes the form | yes | edit/update path |
| 6. Admin publishes; unlocks patron payment | yes | `mark_admin_completed!` |
| 7. Patron notified (push) | **no** | `Notifications::DispatchEvent` has zero callers |
| 8. Payment done, registration finalized | yes | `mark_paid!` |
| 9. Admin fulfilment action | **no** | `"fulfilled"` is never assigned anywhere |

Six of nine exist. Stages 7 and 9 are unbuilt, and stage 4 sits elsewhere.

The Director has explicitly deferred stage 7 (push) as a later phase — the
underlying pipeline lands first. It is recorded here as a known absence, not
as in-scope work.

### Three findings behind those gaps

1. **Stage 9 has a column and no workflow.** `FULFILLMENT_STATUSES` defines
   `open`/`fulfilled`/`cancelled`, but nothing in `app/` ever assigns
   `fulfilled`. A registration is `open` at creation and only ever becomes
   `cancelled` via expiry. Lighting the lantern, arranging the ritual,
   printing certificates — none of it is recordable today.
2. **Stage 7's plumbing is complete and entirely unused.**
   `Notifications::DispatchEvent` supports push, email, and in-app delivery
   with per-channel rules and notification records; nothing calls it. When
   this phase arrives it is a caller, not a build.
3. **The dashboard already reports a misleading "pending" count.**
   `admin/dashboard_controller.rb:16` computes it as
   `fulfillment_status: open` — every non-cancelled registration, at any
   stage. It should be **replaced**, not supplemented.

### The state model the nine stages imply

The stages mix actor-actions with system-gates. The underlying **states**
collapse to six, and only two are admin work queues:

| State | Blocked on | Surface |
| --- | --- | --- |
| Created, not completed | **us** | queue: "needs completion" |
| Completed, temple delinquent | **the owner** | alert, not a queue |
| Completed, awaiting patron payment | them | informational |
| Paid, not fulfilled | **us** | queue: "needs fulfilment" |
| Fulfilled | — | — |
| Cancelled / expired | — | — |

### What is needed

- **Derive for display; persist what must be queried or timestamped.**
  Revised after review — pure derivation was the original recommendation and
  it is self-defeating here. Four objections, the first fatal:

  1. **A derived state cannot be a database filter.** W2 exists *because*
     pending work is unfindable at volume. Computing six states in Ruby from
     four inputs means you cannot filter, sort, index or paginate on them
     without replicating the derivation in SQL — including a join for temple
     delinquency. That solves "cannot find pending work" with a mechanism
     that cannot be queried.
  2. **Derivation cannot record when a state was entered.**
     `admin_completed_at` is a timestamp; `payment_status` and
     `fulfillment_status` are not; delinquency is temple-level and
     time-varying. "How long has this been blocked on billing?" becomes
     unanswerable — an operational question W2 is meant to serve.
  3. **Delinquency is an input outside the registration.** A registration
     that derived as ready yesterday derives as blocked today, with no record
     that it moved. Historical reporting is non-reproducible by construction.
  4. **The six-state mapping is a function every consumer must agree on.**
     Derivation puts it wherever it is called; drift between call sites is
     silent.

  Likely shape: one state column plus an `entered_at`, maintained by the code
  that already owns the transitions — not a full parallel state model.

  **Gate on this before acceptance criteria are written:** if pure derivation
  is kept anyway, first verify all six states are expressible as a single SQL
  scope *including the delinquency join*. If they are not, W2 does not
  deliver its own goal.
- **Add stage 9's transition** — `mark_fulfilled!`, an admin action, and an
  audit event. This is the only genuinely new persistence, because nothing
  sets `fulfilled` today.
- **Replace the dashboard's "pending" count** with per-stage counts that
  distinguish "waiting on us" from "waiting on them."
- **Expanded status vocabulary** — the existing paid/unpaid pair cannot
  express the distinction, so any surface built on it merges the two.

Recommended surfaces, in order: expanded vocabulary (substrate) → dashboard
counts (the arrive-in-the-morning view) → filter chips on the existing orders
index (where staff work through it). **Not** a separate screen: registrations
already live in orders, and a second location fragments the work.

### RESOLVED — stage 4 is a visibility state, not a block

The Director's numbering places the delinquency gate before admin completion.
In code it sits at payment, which was a deliberate decision earlier the same
day: intake and admin work always flow; only money is blocked, so unpayable
registrations accumulate as pressure on the owner.

Keep the gate at payment. Rationale: work that *can* be done should be done.
With the gate at payment, a temple that clears its bill drains the queue
instantly. With the gate at completion, they clear the bill and then face a
backlog of unstarted forms — the delinquency cost would land on staff and
patrons instead of the owner.

Stage 4 is therefore modelled as a **distinct visible state**
("blocked on billing"), not as a barrier.

### Which payment the gate blocks — the two money flows are not symmetric

Recorded because this was ambiguous in discussion and the method name makes
it worse (see W1's rename note):

- **Trigger** — the *temple's* delinquency to SourceGrid (Stripe platform
  billing; 21 days = 7 overdue + 14 grace, per
  `Billing::PlatformBillingLifecycle`).
- **Blocked** — the *patron's* payment to the temple, on **both** rails.

One relationship's delinquency blocks a different relationship's money flow.
That is the intended leverage.

### DECIDED — both settlement rails stay blocked

There are exactly two settlement actions, and both are things the system
performs: processing an ECPay webhook, and an admin pressing "cash received."
Both converge on the same state. Both remain blocked while delinquent.

Considered and rejected: blocking only the automated rail. Three reasons the
symmetric version is correct:

1. **Blocking only ECPay leaves a free bypass.** A delinquent temple would
   simply mark everything "cash received" and operate indefinitely. The gate
   would not hold.
2. **Unrecorded physical cash is not a harm the system creates.** The
   transaction happens outside the system; a temple could always take cash
   without recording it. The button records an external event, it does not
   control it.
3. **The patron-facing cost is avoidable by the temple.** Staff may accept
   the cash and settle the record once billing clears. Whether they accept
   cash is a temple operating decision, not a platform concern — TempleMate
   is a productivity tool, not the temple's manager.

An earlier concern was raised and **partly** withdrawn. It contained two
claims, and only one was refuted:

- **(a) The system causes harm by blocking cash recording.** Refuted
  correctly. The transaction was never under system control, and attributing
  the harm to the system was wrong. Withdrawn.
- **(b) Blocking cash recording predictably produces an out-of-band
  workaround, and paper is where reconciliation errors live.** *Not* addressed
  by the counterargument. It does not depend on the system causing anything —
  only on the workaround being predictable.

(b) was dropped along with (a) on the first pass; review restored it. It is
an operational forecast, not a harm attribution, and its useful form is a
scoping question rather than an objection:

> **Open scoping item.** Paper records will exist during a freeze. Does the
> system later ingest them (a back-dated cash entry once billing clears), or
> is that explicitly out of scope? Either answer is fine. Deciding now is
> cheaper than discovering it during lamp season.

### DECIDED — patron-facing copy is deliberately vague

The patron is not owed a status report on the temple's internal state.
Current copy narrates machinery the patron has no stake in, and in one case
can be flatly wrong (a patron who paid cash during a freeze still reads
"unpaid").

The rule: **be vague wherever the patron has nothing to do; be specific and
actionable wherever they do.**

| Patron's situation | Can they act? | Copy |
| --- | --- | --- |
| Admin has not completed it | no | vague |
| Temple delinquent, payment blocked | no | vague |
| Paid cash, record not yet updated | no | vague |
| Ready to pay online | yes | specific, with CTA |
| Temple is cash-only (no ECPay configured) | yes — visit the temple | specific |
| Paid / refunded / free | — | terminal fact, unchanged |

The first three collapse into one message. Both current messages leak:

- `online_payments_frozen_notice` — 「您的報名資料已收到，**付款開放後**我們會通知您。」
  hints at a payment problem.
- `awaiting_admin_completion_notice` — 「**廟方正在確認**您的報名資料，確認完成後即可**開放線上付款**。」
  narrates the admin's internal step.

Proposed replacement for all three states:
**「已收到您的報名，廟方正在處理中。」** — true in every one of them, promises
nothing, reveals nothing. The existing helper line
「您這邊暫時不需要做任何事，請放心等候。」 fits and stays.

Deliberate asymmetry, not an oversight: this vagueness is **patron-facing
only**. The admin side needs the opposite — the whole point of the stage
model above is that staff see exactly which state a registration is in.

Do not mention payment methods in the vague message. Admin cash recording is
blocked by delinquency but **not** by the completion gate, so "you may pay in
person" is true while awaiting completion and false while delinquent.

### DECIDED — the gathering carve-out is removed

A gathering is a **sub-type, not a separate registration flow**. It follows
the same nine-stage pipeline; the only difference is that it carries no
offering data to fill in. Payment remains blocked while delinquent, exactly
as for every other type.

So `admin_completion_required?` becomes universal. Today it returns **false**
for `TempleGathering`, letting 社群活動 skip stages 5–6 and become payable
immediately.

The existing code already agrees with this framing more than the carve-out
did: `Registrations::LifecyclePolicy#gathering_editable?` returns false for
any persisted gathering registration, so gathering fields are **already
read-only after creation**. Stage 5 therefore has nothing to edit and the
admin's action is purely stage 6 — review and publish. That is consistent,
not a conflict. The delinquency gate is likewise already uniform:
`registration_intake_frozen?` never inspects registrable type.

What removing the carve-out touches:

| Element | Today | Required |
| --- | --- | --- |
| `TempleRegistration#admin_completion_required?` | `registrable_type != TempleGathering.name` | always true |
| Routes | `member { post :complete }` on events/services only (`config/routes.rb:109,118`) | add for gatherings |
| `complete_admin_offering_order_path_for` | no gathering case; falls through to the **event** path | add gathering case |
| `redirect_gathering_edits!` | `only: %i[edit update]` | unchanged — `complete` is not in it |

The third row is a latent defect independent of this decision: a gathering
currently generates an *event* completion URL via the `else` branch.

### CRITICAL — this must not be implemented as "delete the branch"

Review caught a customer-facing regression in the obvious implementation, and
the code's own comment predicts it. `app/models/temple_registration.rb:117-120`
already states: *"Without this exclusion, `admin_completed_at` would default
to nil for every gathering registration with no way to ever set it,
permanently blocking checkout."*

The chain:

```
admin_completion_required?  ->  registrable_type != TempleGathering.name
checkout_ready?             ->  !admin_completion_required? || admin_completed?
consumers                   ->  account/registrations_controller.rb:88 gates
                                patron checkout
                                account/registrations/payment.html.erb renders
                                the blocked state
routes                      ->  exactly two `member { post :complete }` entries
                                (events, services). No gathering route exists.
```

Delete the branch alone and every gathering registration becomes
**permanently unpayable by the patron** — `checkout_ready?` starts demanding
`admin_completed_at`, and nothing can set it. The table above lists the route
and helper additions, but listing them as supporting rows invites a partial
implementation whose failure mode is silent and customer-facing.

**The Director's reasoning supports gatherings being *completable*; it does
not by itself support deleting the exclusion.** Those are different changes.
Either of these satisfies the reasoning safely:

- add a reachable completion action for gatherings (route + helper + UI), or
- auto-complete gatherings at creation, since there is nothing to fill in.

**Write the acceptance criterion as an outcome, not a mechanism:** *a
gathering registration reaches `checkout_ready? == true` through the same
path every other registration does.* Not "remove the gathering branch from
`admin_completion_required?`."

Ordering constraint for whoever implements: the completion path must exist
and be reachable **before** the exclusion is removed, never after.

**Simplification that falls out.** If completion is universal,
`admin_completion_required?` no longer earns its existence and
`checkout_ready?` collapses to `admin_completed?`. Prefer removing the
concept over making it return a constant.

**Operational consequence — decide with the queue, not after it.** Free
gatherings have no payment step, so completion for them unlocks nothing; it
is purely an attendance confirmation. They will still enter the "needs
completion" queue, and a 200-signup free community event becomes 200 clicks.
This does not argue for restoring the carve-out — the confirmation is real
work, not ceremony — but it does make **bulk-complete** a first-class
requirement of the W2 queue rather than a later addition. Cheap alongside the
queue, painful to retrofit.

---

## W3 — Person-level ritual data has no home in the live schema

**OPEN — the only remaining workstream, and not authorized.**

**Rules 1 and 5. Severity: high — gates onboarding the temple's most
important offerings. Effort: largest of the four; likely multi-phase.**

### The gap

`Registrations::FormSchema::DEFAULT_SECTIONS` provides four sections:
`order`, `contact`, `logistics`, `ritual_metadata`. A registration therefore
carries **one** contact and optionally **one** selected dependent
(`dependent_id`).

`db/temples/offerings/working-draft.yml` — the structure derived from
Shengfukung's own worksheets — needs materially more than that:

- `lamp-service` (點燈作業): a list of **persons**, each with `name`,
  `birthdate`, `gender`, `phone`, `mobile_phone`, `address`,
  `lunar_calendar` (boolean, default true), `leap_month` (boolean),
  `mail_certificate` (boolean); plus derived `age`, `zodiac`,
  `heavenly_stem_earthly_branch`.
- `peace-opera-household` (平安戲丁口捐): a household representative plus a
  `repeatable_person_list` of household members.

None of that is expressible today. The live `shengfukung-wenfu.yml` is a
simplification: its `lamp-service` collects `contact` +
`preferred_date`/`preferred_slot` + `ancestor_placard_name` /
`dedication_message` / `certificate_notes`. The concepts of a per-person
record, a repeatable person list, lunar-vs-solar dates, leap month, and
derived ritual values are absent from the schema entirely.

### Why this connects rules 1 and 5

The Director's rule 1 lists "address, birthday — less obvious that it's
important." Against the real worksheets they are **not** optional extras:
birthdate plus a lunar-calendar flag is what 點燈 rituals are computed from.
The current patron profile carries `english_name`, `native_name`, `phone`,
`city`, `notes` — no birthdate, and `city` rather than a full address.
Dependents *do* carry `birthdate`, but not `gender`, `address`,
`lunar_calendar`, or `leap_month`.

That is why this is one workstream rather than two: the natural home for
per-person ritual data is the dependent record (rule 5's object), and the
question of whether dependents are the right shape cannot be separated from
what rule 1 needs to store.

Note this does **not** challenge rule 5's authority boundary — patrons create
dependents, admins do not, and that holds today with no admin dependent route
existing at all. The open question is whether a registration should reference
*one* dependent or *many*, and whether ritual attributes live on the
dependent or on the registration snapshot.

### Relationship to existing plans

`TEMPLE_OFFERING_SYSTEM_SPEC.md` already establishes the canonical vocabulary
(offering families, templates, variants; derived zodiac/stem-branch as
non-stored values; lunar default true where ritual logic requires it), and
`SHENGFUKUNG_OFFERINGS_CONFIG_PLAN.md` owns replacing the simplified config.
**W3 should be scoped as an extension of those two documents, not as new
parallel design.** This plan's contribution is only to record that the gap is
load-bearing for rules 1 and 5, and that the live schema — not just the
config — is what blocks it.

### Split the dispatch, keep the analysis merged

The analytical merge above is correct, but the resulting workstream contains
two kinds of work with very different rollback profiles: a **schema
migration** (person records, repeatable lists, lunar/leap flags, gender,
address) and **form capability** built on top of it. A bad schema migration
against live registration data is not comparable to a bad form.

Dispatch as two packets — schema first and independently landable, form
second — so the irreversible half can land and settle on its own. This
preserves the merge (one design decision, one owner) while not forcing the
recoverable half to share the irreversible half's risk profile.

### Needs a Director decision

Whether repeatable person lists are in scope for the first real onboarding,
or whether the first temple goes live on the simplified single-contact shape
with per-person data captured as free text. That trades onboarding speed
against re-entering the data later.

---

## W4 — Durable facts and per-registration choices are stored identically

**SHIPPED 2026-08-28 (`4138cb1`).** Current behavior lives in
`ops/docs/reference/account_portal.md`. The `offerings:annotate_reuse`
generator has NOT yet been run with `write` against the sandbox config, so
every field still falls back to the `offer_as_options` constant default.

**Rules 3 and 4. Severity: moderate — wrong data prepared, wrong list shown.
Effort: small-to-moderate, but gated on per-field classification.**

### What already exists — more than first assumed

An initial read of this suggested reusable values accumulate silently and
forever. That was wrong on the write side, and the correction matters for
scoping:

- Accumulation is **opt-in per save**: `registration_multi_value_toggle`
  renders a "save additional" checkbox that defaults to **unchecked**
  (`app/helpers/admin/offering_orders_helper.rb:22`). Nothing enters the
  cache unless an admin deliberately ticks it.
- Accumulated values are **already curatable**:
  `app/views/admin/offering_orders/_reusable_defaults.html.erb` lists each
  stored value with its own delete control, backed by
  `Admin::PatronMetadataValuesController`.
- Storage is correctly tenant-scoped: `Registrations::ReusableDefaults` keys
  by `[temple.id][registrable_type][offering.id]` with an explicit
  `offering.temple_id == temple.id` guard.

So rule 3 genuinely holds, and the curation surface rule 4 would need already
exists.

### What is actually wrong

The **render** side. `app/views/admin/offering_orders/new.html.erb:306`
passes the cached value straight into the field control:

```erb
value: ritual_metadata[:dedication_message]
```

For a multi-value field that value is an **array**, and
`registration_field_control` renders it into a **single-value control** —
a `select` when the field has options, a text input otherwise. The
accumulated set is dumped into one input instead of becoming the menu.

Consequence, in the Director's own terms: a set of past choices is presented
as this year's answer. For an offering table's items that means the temple
prepares goods nobody asked for this year. Because an admin is typically
filling this in over the phone on the patron's behalf, a prefilled value that
goes unread is a realistic error mode, not a hypothetical one.

### The Director's proposed model

Accumulate past values as **selectable options**, not as the current
selection:

> Year 1: choose A. Year 2: A available, choose B. Year 3: A and B both
> selectable, prefill the first or an empty "please select"; choose A.
> Year 4: still A and B — only novel values are added.

This is the right separation, and it is a smaller change than it appears
precisely because storage, opt-in, and curation already exist. The missing
piece is the render side plus one classification decision.

### The classification the system cannot infer

"Prefill the first" and "prefill nothing" are each correct for different
fields, and the split is exactly the Director's rule 3 vs rule 4:

| Field | Semantic | Correct default |
| --- | --- | --- |
| `ancestor_placard_name` | Durable fact (rule 3) — the same ancestors recur | Prefill past values; allow deselect |
| Offering-table items (福宴 / 白米10斤 / 金牌) | Fresh choice (rule 4) | Prefill nothing; force explicit selection |

The obvious proxy — "does the field have a temple-authored `options` list?" —
is refuted by the live config, and the refutation is broader than first
written. `dedication_message` appears in **all four** live offerings:

| Offering | Shape | What it actually holds |
| --- | --- | --- |
| `incense-donation` (`:47`) | 14-item options list, `allow_multiple` | Ritual/donation **items**: 福宴, 祝壽, 壽塔, 頂燈, 金牌壹面1份/3分/5分/1錢, 白米10斤, 貨車油資… |
| `lamp-service` (`:131`) | `allow_multiple`, no options | Freeform blessing text |
| `ghost-festival-table` (`:193`) | `allow_multiple`, no options | Freeform blessing text |
| `liberation-ritual` (`:260`) | `allow_multiple`, no options | Freeform blessing text |

One field name, **one global label** — `admin.zh-TW.yml:109` renders
`dedication_message` as 祈福語 ("blessing message") everywhere — and four live
uses, one of which is a purchase/donation item picker.

So the field is not merely *formatted* differently across offerings; it is
**semantically overloaded**. A classification keyed on field name would still
be wrong, because the name does not determine the meaning. The classification
must be **per-(offering, field)**.

That granularity turns out to be free, and there is **no plumbing step at
all**. `field_settings` already lives inside each offering's own
`registration_form` block, and `FormSchema` has exactly three callers — all
per-offering:

- `admin/offering_orders_controller.rb:331`
- `admin/patron_metadata_values_controller.rb:84`
- `registrations/reusable_defaults.rb:21`

The third is the point: **the class that actually performs reuse already holds
a per-offering `FormSchema` at the moment it decides.** `ReusableDefaults`
consults it today for `eligible_fields` and `multi_value?`. A `reuse:` key
sitting beside `options:` and `allow_multiple:` is readable right there, with
nothing to thread through. This is a one-key schema addition
(shape to be decided — e.g. `reuse: prefill | offer_as_options | never`), not
a new artifact and not a wiring exercise.

**Implementation caution.** `FormSchema#normalize_field_settings`
(`form_schema.rb:96-105`) coerces a bare Array into `{ options: settings }`,
so a field written in that shorthand cannot carry a sibling `reuse:` key until
it is rewritten in Hash form. Checked the live config: all four offerings
already use the Hash form for every entry under `field_settings`, so nothing
currently needs migrating — but the hazard is live in the code path for any
future config that uses the shorthand.

### Separate observation: the overload is itself a config smell

A product picker living under a label that says 祈福語 is a naming problem
independent of reuse classification. Whether `incense-donation` should instead
carry its own properly-named field (e.g. donation items) belongs to
`SHENGFUKUNG_OFFERINGS_CONFIG_PLAN.md`, not here. Noting it because renaming
would *not* remove the need for per-(offering, field) classification —
different temples will legitimately treat the same canonical field as durable
in one offering and per-registration in another.

### DECIDED 2026-08-28 — mechanism now, values provisional

**Build the mechanism; do not treat the classification values as settled.**

Two Director caveats govern this:

1. **All reuse policy lives in the yml, per temple.** There is no
   one-template for 點燈作業 or any other offering — every temple's config
   differs. Ruby must hold only the *default* applied when the yml is silent,
   never a field-name-to-policy table.
2. **The live `shengfukung-wenfu` config is mid-confidence and is sandbox
   data.** The temple admin never completed the offering intake form; a sales
   rep is hand-holding that in person. Critically, this config is **not**
   destined for production: `shengfukung.com.tw` is the permanent sales
   sandbox, and the real Shengfukung temple will be onboarded as a separate
   `shengfukung.org.tw` tenant with a freshly authored config (see
   `ops/docs/reference/templemate_product_positioning.md`).

So the classification table below is a **worked example against sandbox
data**, not an accepted configuration. It exists to prove the mechanism and
to size the work.

### The default rule — derived from config shape, not field names

The default matters more than any individual classification, because a
sparse or in-progress config is the normal case during onboarding.

Failure modes are **not symmetric**:

| Wrong policy | Consequence |
| --- | --- |
| Wrong `prefill` | stale values auto-filled; the temple prepares goods nobody ordered. Silent and costly. |
| Wrong `offer_as_options` | past values appear in a menu, nothing preselected. Harmless. |
| Wrong `never` | an admin retypes last year's answer. Mild friction. |

Only `prefill` causes real harm, so the default must never guess it where
risk is high. Proposed default, keyed on config *shape*:

| Shape | Default | Rationale |
| --- | --- | --- |
| multi-value **with** temple `options` | `never` | the menu is already complete; the cache adds nothing, and these are selections rather than durable facts |
| multi-value **without** `options` | `offer_as_options` | the cache *is* the menu |
| single-value | `prefill` | short, visible value; low risk; preserves rule 3 |

### REVISED after review — the heuristic moves out of the runtime

The shape rule above is right, but running it **at read time** violates
caveat 1 in a way I initially defended incorrectly. I argued "a default is
not policy, it is what happens absent policy." That holds for a *constant*
default. It fails for a *shape-derived* one, and the test is concrete:

> If a temple flips `allow_multiple` from true to false for an unrelated
> reason, does reuse behavior change without anyone deciding it should?

Under runtime shape-derivation, yes — policy moves as a side effect of
editing a different field. That is exactly what caveat 1 exists to prevent.
The problem is not that Ruby holds a default; it is that the default is
**coupled to another field's value**.

There is a third path that costs nothing:

- **Runtime default: a constant.** Shape-independent, one value in Ruby.
- **Onboarding generator: writes explicit `reuse:` keys into the new
  temple's yml**, using the shape heuristic above.

The temple's config arrives pre-filled, so onboarding cost is unchanged. The
yml stays the single source of truth, so caveat 1 holds literally. The
heuristic becomes a one-time authoring suggestion someone can override,
rather than a standing inference re-performed on every read.

It also fixes a property not previously raised: under runtime derivation,
**nobody can read a temple's yml and know what the reuse behavior is.**
Under generation, they can.

Justification for the heuristic itself, corrected: this is **not** about
protecting production from a bad config — the sandbox config never reaches production. It is about
(a) **onboarding economy**, so a rep elicits two answers rather than eleven,
and (b) **demo quality**, since the sandbox is the sales instrument and is
expected to accumulate registrations across many visits. Under the current
broken render, a demo patron reused across six sales visits accumulates
every past value into one field in front of a prospect.

The harm-prevention argument is not discarded — it applies at
`shengfukung.org.tw` and every later real tenant, where goods are physically
prepared and money moves.

### Worked example against the sandbox config

Eleven reusable-eligible cells exist across the four sandbox offerings.
Verified by evaluating `ReusableDefaults#eligible_fields` and
`FormSchema#allow_multiple?`/`#field_options` per offering.

| Offering · field | multi | options | Default gives | Example intent | Declaration |
| --- | :-: | :-: | --- | --- | --- |
| 香油捐獻 · `dedication_message` | yes | 14 | `never` | donation items — a fresh purchase decision | — |
| 點燈作業 · `preferred_slot` | no | 2 | `prefill` | standing preference | — |
| 點燈作業 · `ancestor_placard_name` | yes | 0 | `offer_as_options` | ancestors recur | **`reuse: prefill`** |
| 點燈作業 · `dedication_message` | yes | 0 | `offer_as_options` | freeform blessing | — |
| 點燈作業 · `certificate_notes` | no | 0 | `prefill` | standing instruction | — |
| 普渡供桌 · `ceremony_location` | no | 3 | `prefill` | standing preference | — |
| 普渡供桌 · `dedication_message` | yes | 0 | `offer_as_options` | freeform blessing | — |
| 拔薦 · `ceremony_location` | no | 3 | `prefill` | standing preference | — |
| 拔薦 · `ancestor_placard_name` | yes | 0 | `offer_as_options` | ancestors recur | **`reuse: prefill`** |
| 拔薦 · `dedication_message` | yes | 0 | `offer_as_options` | freeform blessing | — |
| 拔薦 · `certificate_notes` | yes | 0 | `offer_as_options` | per-occasion notes | — |

The default rule lands **nine of eleven** with no declarations at all, and
both misses are in the safe direction — more friction, no harm. The two
explicit declarations are exactly what a temple would knowingly assert:
*"the ancestors are the same every year, remember them."*

`dedication_message` appearing as `never` on 香油捐獻 and `offer_as_options`
on the other three is the case that requires per-(offering, field)
granularity; no field-name-keyed table can express it.

`certificate_notes` is `allow_multiple: true` on 拔薦 but single-value on
點燈作業. Possibly deliberate, possibly drift — worth confirming when the
real config is authored, since it changes which policies are available.

### Input for the onboarding visit

The offering intake form should ask, per multi-value field:

> **"Does this stay the same every year, or change each time?"**

That one question populates `reuse:`, it is answerable by a temple admin
with no system vocabulary, and it is the only new question the mechanism
requires.

### Follow-on config idea, not code

Because `shengfukung.com.tw` is a permanent sandbox rather than a draft of a
real tenant, its config does not need to mirror Shengfukung's actual
operations — it needs to **demonstrate capability**. It could deliberately
carry one field of each reuse behavior so a rep can show the difference
(ancestors persisting year to year; donation items asked fresh every time)
rather than describe it. Cheap to revisit once the mechanism exists;
belongs to whoever owns the sandbox config, not to this workstream.

## Cross-cutting open questions

1. ~~W1: which option governs an admin learning a changed phone number.~~
   **Decided: (d)**, separate namespace plus patron reconciliation.
2. ~~W2: where the queue lives; how the delinquency gate is sited; whether
   both settlement rails stay blocked; patron-facing disclosure; whether the
   gathering carve-out survives.~~ **Decided**, five ways — see W2. No W2
   questions remain open.
3. W3: whether repeatable person lists gate the first real onboarding.
4. ~~W4: per-(offering, field) reuse classification.~~ **Decided**: build
   the mechanism now with a shape-derived default; classification values are
   provisional against sandbox data and are confirmed per temple in yml at
   onboarding.

Question 3 is a
scope decision about the first real client; the Shengfukung onboarding visit
is an **input** to it rather than blocked by it — the visit is where the
offerings spec finally gets filled in, and that spec is what W3's schema
design needs.

## Explicit non-goals

- Reopening the accepted `ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`
  contract. Its phases are complete; this records divergence between the
  stated model and the implemented contract, and does not retract acceptance.
- A universal person graph, household hierarchy, field-level ACL system,
  profile-completion score, or approval workflow — all previously and
  explicitly excluded, and still excluded.
- Expo/mobile surface expansion. Any native adoption follows the same gate as
  Phase A4: Rails semantics accepted first.
- Payment, pricing, refund, accounting, or provider behavior.
- Production data inspection or migration.

## Acceptance criteria

Per workstream, not for the document as a whole — these are independently
dispatchable:

- **W1**: an admin registration edit cannot mutate patron-owned profile
  fields except through an explicit, audited, Director-approved path;
  registration-scoped contact data is unaffected; the
  `dependents_notes`/`notes` destination collision is resolved; covered by
  tests.
- **W2**: the six states are queryable as SQL scopes and the states that
  need a duration carry an `entered_at` (see the derive-vs-persist objections
  above); `mark_fulfilled!` plus an audited admin action exists for stage 9; the misleading dashboard "pending" count is replaced by
  per-stage counts; an admin can see, from a default-visible surface, both
  work queues ("needs completion", "needs fulfilment") with counts,
  distinguishable from registrations merely awaiting patron payment and from
  those blocked on billing; the queue supports **bulk-complete**; **a
  gathering registration reaches `checkout_ready? == true` through the same
  path every other registration does** (outcome-framed deliberately — see the
  CRITICAL note; the completion path must exist and be reachable before the
  exclusion is removed); patron-facing copy collapses the three non-actionable states
  into one vague message while leaving actionable states specific; covered by
  tests.
- **W3**: scoped and sequenced as an extension of the offering-spec plans,
  dispatched as schema-then-form packets, with the first-onboarding scope
  decision recorded.
- **W4**: accumulated values render as options rather than as the current
  selection; a `reuse:` key exists in the offering schema at
  **per-(offering, field)** granularity, read from yml with no field-name
  table in Ruby; the runtime default is a **constant**, not shape-derived,
  and the shape heuristic lives in the onboarding generator that writes
  explicit `reuse:` keys into a new temple's yml; covered by tests including the
  same-field-name/opposite-semantics case (`dedication_message` as
  item-picker vs freeform text). Classification *values* for any given temple
  are config, not part of this workstream's acceptance.

## Review record

Reviewed by OperatorKit Strategy, 2026-08-28, against source at `d8966f6`
rather than against the writeup. All four claims verified independently in
code. Four changes folded in, each strengthening rather than retracting a
finding:

1. **Ordering axis** — "blast radius" conflated damage-already-accruing with
   capability-gap. Re-cut as irreversibility first. W1 stays first, on firmer
   reasoning.
2. **W2 sharpened** — pending-completion is not merely unfiltered but
   camouflaged inside `unpaid`; the fix needs a status vocabulary change, not
   only a filter.
3. **W1 option (d)** — separate namespace plus patron-side reconciliation,
   which fits rule 5's own patron-ownership logic better than prompting the
   admin. Plus the `dependents_notes`/`notes` collision.
4. **W4 granularity** — per-field is insufficient; must be per-(offering,
   field), because the field is semantically overloaded rather than merely
   formatted differently.

Strategy's process note, recorded because it generalizes: W4's *claim* was
correctly shrunk after finding the opt-in checkbox and existing curation
panel — but the same evidence then supported a *larger* remedy than the one
first proposed. Shrinking a claim and shrinking its remedy are separate
decisions, and conflating them is the failure mode to watch when correcting
for recency bias.

**Second review, 2026-08-28 (main `b755f3f`), generalizing that note.** The
same error appeared twice more in mirrored forms:

- W4's default rule: a **correct claim kept alive on wrong reasoning**
  (justified as protecting production; the sandbox config never reaches
  production).
- W2's cash concern: a **possibly-correct observation discarded along with
  its wrong framing** — (b) above was dropped because (a) was refuted.

Both come from treating a claim and its justification as one object. The
generalized rule: *refuting a justification is not refuting the claim it was
offered for.* When a justification falls, re-ask whether anything else
supports the claim before dropping it; when a claim survives, re-ask what
actually supports it.

Second review also caught a **customer-facing regression** in W2's gathering
decision that the first pass missed — see "CRITICAL" under W2. The code's own
comment predicted it, written the same day, and was not re-read when the
decision was recorded. Lesson recorded because it is mechanical, not
conceptual: when a decision removes a guard, re-read the guard's own comment
before writing the change up.

Verification added on this side during fold-in, both since confirmed by
Strategy in a second pass:

- `dedication_message` appears in four live offerings, not two, and carries
  one global label (祈福語) across all of them — strengthening the overload
  finding. (Strategy's original "two" came from a truncated grep whose output
  cap was read as the result.)
- The required per-(offering, field) granularity needs no new mechanism, and
  on Strategy's second pass, no plumbing either: `ReusableDefaults` — the
  class that performs reuse — already holds a per-offering `FormSchema` at
  decision time. Plus the `normalize_field_settings` Array-shorthand caution
  recorded in W4.

Both sides independently verified the other's claims against source rather
than against the writeup. Every exchange strengthened a finding; none
retracted one.
