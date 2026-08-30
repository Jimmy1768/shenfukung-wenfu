# Personal And Offering Data — Contract Gap Plan

Status: first draft, Planning-owned. No implementation, production-data,
deployment, or account action is authorized by this document.

Drafted: 2026-08-28. Recorded against `main` at `dcd5493`.

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
| 2. Truncated → pending → admin completes → payment | Partial — gate exists and works; no way to find pending work | W2 |
| 3. Save and prefill next time | Yes | — (W4 refines) |
| 4. Per-registration data changes every time | No — not modeled; treated as durable | W4 |
| 5. Patron creates dependents, admin cannot | Yes, exactly | — (W3 touches the shape) |
| 6. Temple cannot edit foundational patron data | No — violated for `phone` and `notes` | W1 |

Rules 3 and 5 hold as stated and need no corrective work. Rule 5's
*enforcement* is correct; W3 questions whether the dependent **shape** is
sufficient, which is a different question from who may create one.

---

## W1 — Admin registration edits overwrite the patron's own profile

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

### Needs a Director decision

When an admin learns on the phone that a patron's number has genuinely
changed, what should happen?

- (a) Nothing — registration only; the patron updates their own profile.
- (b) Prompt the admin explicitly ("also update this patron's profile?"),
  audited as a distinct action.
- (c) Update silently, as today.
- (d) Write to a separate namespace and reconcile with the patron. The
  registration writes `metadata["registration_contact"]["phone"]` and never
  touches `metadata["phone"]`. On the patron's next profile visit: "a recent
  registration used a different number — keep yours, or update it?"

(a) is the strictest reading of rule 6. (b) and (d) both preserve the
phone-call workflow of rule 2 without silent mutation; they differ in **who
decides**. (b) asks the admin; (d) asks the owner of the data.

(d) is the better fit for this system's own logic: rule 5 already establishes
that dependents are patron-owned and staff may assist but not create. The same
reasoning says patron profile data should be changed by the patron, not by
staff on their behalf. (d) also subsumes the notes-collision fix above.

This plan does not assume which. Recommend putting (b) and (d) in front of the
Director together.

---

## W2 — The completion step has no work queue

**Rule 2. Severity: high — blocks the stated operating model at any real
volume. Effort: small-to-moderate.**

### What already exists

The Director noted uncertainty here ("I'm not sure if we have this level of
detail"). The mechanism does exist and is live in production as of
2026-08-28:

- `TempleRegistration#admin_completion_required?` — true for everything
  except `TempleGathering` (`app/models/temple_registration.rb:121`)
- `#admin_completed?`, `#checkout_ready?`, `#mark_admin_completed!`
- `Admin::OfferingOrdersController#complete` — the explicit staff checkpoint,
  audited as `temple.registration.admin_completed`
- Patron-side: `Account::RegistrationsController#start_checkout` refuses
  checkout unless `checkout_ready?`; the payment page shows a calm
  "the temple is reviewing your registration" state.

So the pipeline the Director described — patron submits truncated → pending →
admin completes → payment opens — is real, not aspirational.

### What is missing

An admin cannot **find** the registrations waiting on them — and the problem
is worse than a missing filter (sharpened by review).

- `admin_completed_at` surfaces only as a status pill on an individual
  registration's show page (`app/views/admin/offering_orders/show.html.erb:77`).
- `TempleRegistration.admin_filtered` (`app/models/temple_registration.rb:58`)
  supports offering type/id, payment method, paid/unpaid status, text query,
  and a date range — **no completion filter**.
- The `status` filter accepts exactly two values: `paid` and `unpaid`.

That last point is the real finding. A registration awaiting admin completion
is not merely *unfiltered* — it is **camouflaged inside the largest bucket on
the page**, sitting in `unpaid` alongside every registration that is fully
complete and simply not yet paid by the patron.

With a handful of demo registrations this is invisible. With a real temple in
lamp-lighting season, a registration nobody completes is a registration the
patron can never pay for, and it is indistinguishable from one that is
correctly waiting on the patron.

### What is needed

Two things, not one:

1. A completion filter in `admin_filtered`.
2. A status vocabulary that can express **"waiting on us" vs "waiting on
   them."** The current two-value paid/unpaid cannot represent that
   distinction at all, so a filter alone would still leave the two states
   visually merged wherever status is displayed.

Surfaced as a default-visible "awaiting completion" grouping with a count.
This is the operational half of a mechanism that is otherwise finished.

### Needs a Director decision

Should "awaiting completion" be its own admin screen, a filter chip on the
existing orders index, or a dashboard card with a count? All three are cheap;
the choice is about where staff will actually look during a busy season.

---

## W3 — Person-level ritual data has no home in the live schema

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

### Needs a Director decision

The per-(offering, field) classification across the four live offerings —
sixteen cells at most, realistically far fewer since only multi-value
reusable fields need one — and whether the empty state is a literal "請選擇"
placeholder or simply no selection.

---

## Cross-cutting open questions

1. W1: which of (a)/(b)/(c)/(d) governs an admin learning a genuinely changed
   phone number. (b) and (d) are the live candidates.
2. W2: where the pending-completion queue lives, and what the expanded status
   vocabulary should be called in patron-neutral terms.
3. W3: whether repeatable person lists gate the first real onboarding.
4. W4: per-(offering, field) reuse classification across the four live
   offerings.

Questions 1, 2 and 4 are small and unblock their workstreams immediately.
Question 3 is a scope decision about the first real client and may reasonably
wait for the Shengfukung onboarding visit.

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
- **W2**: an admin can see, from a default-visible surface, every
  registration awaiting completion, with a count, **distinguishable from
  registrations that are complete and merely awaiting patron payment**;
  covered by tests.
- **W3**: scoped and sequenced as an extension of the offering-spec plans,
  dispatched as schema-then-form packets, with the first-onboarding scope
  decision recorded.
- **W4**: accumulated values render as options rather than as the current
  selection; reuse classification exists in the schema at
  **per-(offering, field)** granularity and is set across the four live
  offerings; covered by tests including the same-field-name/opposite-
  semantics case (`dedication_message` as item-picker vs freeform text).

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
