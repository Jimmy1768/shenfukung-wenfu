# Account/Admin Personal And Offering Data Contract Plan

Status: accepted track roadmap; no implementation, production-data, deployment,
provider, or account action is authorized by this document

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target control for later separately committed phase packets: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted planning baseline: canonical `main`
`8e5840e4cb737cd6cba773e955d12d9dd24ab098`

Parallel track: TempleMate iOS/TestFlight/OTA/native-OAuth work is owned by
Control B under
`ops/docs/plans/TEMPLEMATE_IOS_TESTFLIGHT_OTA_AND_NATIVE_OAUTH_PLAN.md`.
Neither track waits for the other before its own local readiness and source
work. This Rails contract must be accepted before additional reusable-personal-
data behavior is added to TempleMate.

## Director Product Decision

The account, dependent, and offering-specific personal-data surface is a
friction-reduction tool, not a completeness, hierarchy, or eligibility system.

- A temple may need different personal or ritual information for different
  offerings. The stored field inventory is the maximum supported vocabulary,
  not a requirement that every patron complete every field.
- Patrons may enter and correct the information they choose to provide.
- An authorized registration administrator may ask for missing information and
  enter or correct it while assisting with a registration.
- Reusable values exist so recurring or annual registrations can be prefilled.
  They do not make the cached value authoritative over an explicit value in a
  new registration.
- A registration remains a historical snapshot of what was submitted for that
  offering. Later profile/default changes do not rewrite completed historical
  registrations.
- Do not build a family hierarchy, field-by-field permission graph, approval
  chain, profile-completion score, or global completeness gate.
- Preserve only the existing essential boundaries: account ownership,
  tenant isolation, the `manage_registrations` admin capability, registration
  lifecycle/payment locks, audit evidence, and privacy/export/closure behavior.

## Objective

Turn the existing vibe-coded prefill and write-back paths into one small,
explicit, symmetric Rails contract:

```text
optional reusable defaults
        -> prefilled registration form
        -> patron or authorized admin correction
        -> registration-owned snapshot
        -> safe reusable-default refresh for the next registration
```

The contract must work on the Rails account and admin surfaces first. The
native JSON API may expose the already accepted Rails behavior only after the
Rails contract is complete; this track performs no Expo UI expansion.

## Current Source Evidence

The plan records current behavior rather than treating the feature as new:

- `rails/app/forms/account/registration_intake_form.rb` prefills self contact
  data from the user, prefills selected-dependent contact data, creates the
  registration snapshot, updates reusable user metadata, and updates selected-
  dependent metadata on account-side creation.
- `rails/app/services/registrations/user_metadata_updater.rb` stores reusable
  contact defaults and offering-scoped defaults under the current offering
  slug.
- `rails/app/services/payments/temple_registration_builder.rb` invokes that
  updater after an admin creates a registration.
- `rails/app/controllers/admin/patrons_controller.rb` returns patron,
  dependent, and offering-specific cached data to the admin patron picker.
- `rails/app/views/admin/offering_orders/_patron_picker.html.erb` prefills
  contact, selected-dependent, and offering-specific fields from that payload.
- `rails/app/forms/account/registration_metadata_form.rb` and
  `rails/app/controllers/admin/offering_orders_controller.rb` edit the
  registration snapshot subject to lifecycle policy, but do not consistently
  refresh the reusable cache after edits.
- `rails/app/services/registrations/lifecycle_policy.rb` prevents broad core
  and contact edits after payment and prevents gathering edits after creation.
- `rails/app/controllers/admin/patron_metadata_values_controller.rb` provides
  a narrow administrator mutation path for multi-value reusable metadata.

## Confirmed Gaps

**Phase A0 (2026-08-18, Control A) verified this section against current
code rather than assuming it — two items below were refuted with
evidence, not just re-stated. Full field/surface matrix and findings:
`ops/docs/handoffs/2026-08-18-account-admin-offering-data-contract-phase-a0-control-a.md`.**

### Creation and edit symmetry

- Account-side creation refreshes reusable user or dependent defaults —
  confirmed.
- Admin-side creation refreshes reusable user defaults — confirmed, and
  Phase A0 found it already refreshes dependent defaults too
  (`TempleRegistrationBuilder#sync_dependent_profile!`) — more symmetric
  than originally assumed here.
- ~~Account and admin edits primarily update the registration snapshot;
  reusable defaults are not refreshed consistently.~~ **Refuted by Phase
  A0.** Both `Account::RegistrationMetadataForm#save` and
  `Admin::OfferingOrdersController#update` already refresh reusable
  defaults on edit, gated by matching lifecycle conditions. Not open work.
- ~~Selected-dependent write-back is more complete on account creation than
  on admin creation.~~ **Refuted by Phase A0.** Both write the identical
  three fields (phone/email/notes). The real issue: this exact logic is
  reimplemented four separate times (`RegistrationIntakeForm`,
  `RegistrationMetadataForm`, `TempleRegistrationBuilder`,
  `OfferingOrdersController`) — functionally symmetric but duplicated,
  not asymmetric. This is Phase A1's actual consolidation target, in
  place of the assumed asymmetry.
- The complete patron/admin create/edit/prefill cycle lacked one focused
  end-to-end contract matrix — Phase A0's field/surface matrix (handoff
  above) now is that matrix.
- No admin write path exists for account-level profile fields
  (`english_name`/`native_name`/`phone`/`city`/`notes`) or dependent
  fields outside the registration/offering-schema flow — confirmed real
  by Phase A0, but out of scope for A1/A2 as designed: any admin
  extension here must stay gated by the selected offering's registration
  schema (Phase A2's own rule), not become a standalone patron-profile
  editor. A previously proposed packet built the latter; it was withdrawn
  before implementation for exactly this reason.

### Scope and identity

- ~~Offering-specific defaults are currently keyed by offering slug alone.
  Readiness must prove that the key cannot expose one temple's offering
  data in another temple with the same slug. If it can, the smallest
  tenant-scoped key or storage correction is required.~~ **Resolved by
  Phase A0, not just traced.** `Registrations::ReusableDefaults` keys
  strictly by `[temple.id][registrable_type][offering.id]` (the
  offering's real DB id, never slug) plus a hard `offering.temple_id ==
  temple.id` check in `valid_context?`. A full-app grep for other
  slug-keyed personal-data storage found no live path. The cross-tenant
  leak this section flagged as unconfirmed does not exist in the current
  implementation — dropped from A1's scope.
- Reusable contact data, dependent data, offering-specific data, and a
  registration snapshot currently share loosely structured metadata. Their
  ownership and overwrite rules are implicit.
- A registration field may describe the payer/contact, the selected dependent,
  or a person named in a ritual/offering. Those roles must not be collapsed
  into one universal `person` hierarchy.

### Clearing and overwrite behavior

- Current write-back generally ignores blank values. This avoids accidental
  deletion but means clearing a registration field does not necessarily clear
  a reusable default.
- The contract must distinguish explicit profile/dependent deletion from an
  omitted or blank per-registration answer. Do not infer destructive cache
  clearing from a partially completed registration form.

## Minimal Data Model

### Reusable account defaults

Examples: native/English display name, phone, city, contact notes, and other
already accepted profile fields. These are user-owned convenience values.
Login email, OAuth identities, sessions, account closure, and authority are
identity/lifecycle data and are not registration-prefill metadata.

### Reusable dependent defaults

Examples: names, relationship label, birthdate, phone, email, and notes for a
dependent already owned by the patron. A dependent is selected explicitly; a
freeform ritual name does not automatically create a dependent.

### Reusable offering-specific defaults

Examples: placard name, dedication, incense choice, certificate notes, or other
fields explicitly present in that temple offering's registration schema.
These values must be scoped to the owning patron, exact temple, and exact
offering identity. Multi-value behavior is retained only for fields explicitly
configured as multi-value.

### Registration snapshot

The registration owns the submitted registrant choice, contact payload,
logistics payload, ritual metadata, quantity, and the server-authoritative
offering/price/currency/lifecycle state. A later cache correction does not
rewrite an existing snapshot. Offering identity, title, price, currency,
payment, refund, and accounting fields never come from patron defaults.

## Accepted Write Rules

1. **Prefill is a suggestion.** Explicit submitted values take precedence over
   cached values for the new registration.
2. **No new global completeness gate.** Preserve existing minimal registration
   validation; do not make every supported field mandatory. An offering may
   require a field only through its explicit reviewed registration schema.
3. **Creation refreshes reusable defaults.** Successful account or authorized
   admin creation may refresh nonblank reusable values through one shared
   service after the registration snapshot is valid. The snapshot may remain
   editable only while the existing lifecycle policy permits it.
4. **Editable registration corrections refresh consistently.** A successful
   pre-payment account or admin edit refreshes the same allowed reusable values
   through that service. It does not bypass lifecycle policy.
5. **Dependent selection controls dependent write-back.** Only an explicitly
   selected, patron-owned dependent may receive dependent defaults.
6. **Freeform offering names remain offering data.** A name written on a lamp,
   placard, dedication, or ritual remains offering-scoped metadata unless the
   patron separately creates/selects a dependent.
7. **Blank registration fields do not erase defaults.** Explicit clearing of
   reusable profile/dependent data occurs through the owned profile/dependent
   editor or another clearly identified reusable-data control, not implicitly
   through omission on a registration.
8. **Last accepted nonblank correction wins for future prefill.** This is a
   convenience cache rule, not authority over historical registrations.
9. **Audit the actor and changed categories.** Retain redacted field names and
   source surface; do not duplicate sensitive values in audit metadata.
10. **Preserve tenant isolation.** Offering-specific values from one temple
    must never prefill another temple merely because slugs or field names match.

## Phase Map

### Phase A0 — Read-Only Contract Inventory — complete, 2026-08-18

Trace every account/admin prefill and write path, registration schema/default,
dependent path, multi-value mutation, lifecycle guard, audit event, JSON
serializer, and focused test. Produce a field/surface matrix with classifications:

- reusable account;
- reusable dependent;
- reusable tenant/offering;
- registration snapshot only; or
- identity/payment/authority data that is never reusable metadata.

The scan must confirm the actual cross-tenant behavior of slug-keyed offering
metadata without production-data inspection.

Evidence: `ops/docs/handoffs/2026-08-18-account-admin-offering-data-contract-phase-a0-control-a.md`.
Findings folded into the Confirmed Gaps section above.

### Phase A1 — Contract And Storage Alignment — complete, 2026-08-18

Evidence: `ops/docs/handoffs/2026-08-18-account-admin-offering-data-contract-phase-a1-control-a.md`.
Shipped as a behavior-preserving consolidation only, per the narrowed
scope below.

Implement the smallest shared Rails service boundary for prefill and reusable-
default refresh. Align account/admin create and editable-update paths, selected
dependent behavior, tenant/offering scoping, blank handling, and audit metadata.

Per Phase A0: the actual target is **consolidating the four separate
reimplementations** of dependent/contact write-back logic
(`RegistrationIntakeForm`, `RegistrationMetadataForm`,
`TempleRegistrationBuilder`, `Admin::OfferingOrdersController`) into one
shared service call — not fixing an asymmetry, since none was found. The
tenant/offering-scoping correction originally anticipated here is dropped;
Phase A0 confirmed the existing key scheme is already tenant-safe. This
must be a behavior-preserving refactor — Phase A0 found current behavior
correct and symmetric; A1 does not change what gets written, only where
the logic lives.

Prefer existing columns and JSON structures when they can satisfy the accepted
contract safely. A schema migration is not presumed. If tenant-safe identity,
atomicity, or backwards compatibility genuinely requires a migration, Control
must return a Planning design gap for a separately accepted migration packet.

### Phase A2 — Rails Surface Alignment — complete, 2026-08-18

Pure verification, no code changes — all stated invariants confirmed
already holding on current (post-A1) code. Two UI-consistency
observations noted but correctly left out of scope (new work, not part
of "keep the existing simple UX"). Evidence:
`ops/docs/handoffs/2026-08-18-account-admin-offering-data-contract-phase-a2-control-a.md`.

Keep the existing simple UX:

- account and admin forms prefill only fields present in the selected offering
  schema;
- patrons and authorized registration admins can overwrite editable values;
- missing optional fields do not block registration;
- paid/read-only/lifecycle-locked registration snapshots remain protected;
- profile/dependent editors remain the explicit way to clear reusable data;
- no new admin hierarchy or approval flow appears.

The existing native JSON controllers may inherit service behavior, but no
TempleMate screen or mobile payload expansion is permitted in this phase.

### Phase A3 — Contract Verification — 10/12 proven, 2/12 failed, 2026-08-18

Evidence: `ops/docs/handoffs/2026-08-18-account-admin-offering-data-contract-phase-a3-control-a.md`.
Two real, confirmed findings — a small audit-metadata leak
(`Admin::PatronsController#log_patron_creation` logs a real email
value, the one outlier in this domain) and a genuine privacy-deletion
gap (`Privacy::UserDataDeletionFulfillment` doesn't clear
reusable-defaults data on account deletion, so free-text fields that
can name people survive a fulfilled deletion request).

**Deletion gap fixed 2026-08-19**, evidence:
`ops/docs/handoffs/2026-08-19-privacy-deletion-fulfillment-reusable-defaults-control-a.md`.
Item 11 is now resolved. Broader grep for the same shape found one more
instance (`User#close_account!` on `oauth_identity.metadata`), judged a
different bug and not fixed — status change, not anonymization, flagged
for a future look.

**Audit-metadata leak (Finding 1) resolved 2026-08-19 — by deletion, not
patch.** Investigation found `Admin::PatronsController#create` (the
action containing the leak) was dead code since the controller's first
commit (2026-01-06) — never reachable through any real view, JS, or
route; only `#index` (search/patron-picker) is live. Director's call:
delete rather than fix a log line in an action that shouldn't exist.
Evidence: `ops/docs/handoffs/2026-08-19-remove-dead-admin-patron-create-control-a.md`.

**Both Phase A3 findings closed. All 12 verification items now hold.
Track Acceptance Criteria (below) is fully met.**

Prove at minimum:

- self and dependent prefill on account and admin surfaces;
- account/admin creation refresh symmetry;
- account/admin editable-update refresh symmetry;
- explicit registration value overrides cached value;
- omitted/blank registration value does not erase reusable data;
- explicit reusable profile/dependent clearing behaves as documented;
- tenant/offering separation when two temples reuse the same offering slug;
- freeform ritual/person names do not create or mutate dependents;
- payment/lifecycle locks protect historical snapshots and prevent hidden
  reusable-data mutation on rejected updates;
- audit records contain actor/source/changed-field names without copied
  sensitive values;
- privacy export/deletion/closure behavior remains compatible; and
- full Rails regression evidence passes in an exactly fenced disposable test
  database when database writes are required.

### Phase A4 — Native Adoption Gate

After Rails acceptance, Planning decides which settled fields TempleMate
actually needs. Absence from Expo is not a Rails defect and does not block the
TestFlight demo. Any native expansion requires its own later Control B plan
against the accepted Rails contract.

## Likely Rails Paths

Later Control packets may narrow these paths and must not treat this roadmap as
blanket edit authority:

- `rails/app/forms/account/registration_intake_form.rb`
- `rails/app/forms/account/registration_metadata_form.rb`
- `rails/app/services/registrations/user_metadata_updater.rb`
- `rails/app/services/payments/temple_registration_builder.rb`
- `rails/app/controllers/account/registrations_controller.rb`
- `rails/app/controllers/admin/offering_orders_controller.rb`
- `rails/app/controllers/admin/patrons_controller.rb`
- `rails/app/controllers/admin/patron_metadata_values_controller.rb`
- focused account/admin form, service, integration, tenant-isolation, audit,
  and privacy tests
- one Control record per separately accepted phase

## Acceptance Criteria

The track is complete only when:

- the reusable/snapshot/identity classifications are explicit and implemented;
- account and admin creation and editable-update paths share the accepted
  prefill/write-back rules;
- selected-dependent and offering-specific values cannot cross account or
  tenant boundaries;
- optional data remains optional unless an offering explicitly requires it;
- no new profile-completion, hierarchy, or approval mechanism exists;
- historical and paid registration snapshots retain lifecycle protection;
- focused and full required Rails evidence passes; and
- the accepted source is integrated cleanly with no Expo, Vue, provider,
  deployment, or production-data change.

## Explicit Exclusions

- Expo/mobile UI or adapter expansion;
- offering creation, relabeling, pricing, payment, refund, accounting, or
  provider behavior;
- OAuth resolver rollout, user 22 recovery, identity merge/link policy,
  production account action, or provider-console action;
- real patron or production-data inspection/migration;
- a universal person graph, household hierarchy, field ACL system, completion
  score, consent workflow, or staff approval queue;
- deployment, release-ref movement, push, or external mutation.

## Track Boundary And Next Owner

This plan does not block Control B's TestFlight work or the existing cash-only
demo. It blocks only adding or claiming broader personal/offering-data parity
in TempleMate before Rails semantics are accepted.

Next owner/action: Phases A0–A3 are complete, both A3 findings resolved,
Acceptance Criteria fully met (evidence above). Only Phase A4 (Native
Adoption Gate) remains — Planning decides which settled fields
TempleMate actually needs, if any, as a separate later decision. No
Control A packet is active from this roadmap alone right now.
