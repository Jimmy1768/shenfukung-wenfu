# Control A Packet — Account/Admin Offering-Data Contract, Phase A0

## Identity

- Accepted plan: `ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`
  (accepted 2026-08-16), Phase A0 — Read-Only Contract Inventory.
- Control: Wenfu Control A (session `local_915b44b0-14b1-4b09-bd97-da19a1169d41`).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- Read-only. No branch, no worktree, no code changes.

## Scope

Trace every account/admin prefill and write path, registration
schema/default, dependent path, multi-value mutation, lifecycle guard,
audit event, JSON serializer, and focused test. Produce a field/surface
matrix. Confirm the cross-tenant behavior of slug-keyed offering
metadata without production-data inspection.

Traced: `reusable_defaults.rb`, `registration_intake_form.rb`,
`registration_metadata_form.rb`, `user_metadata_updater.rb`,
`temple_registration_builder.rb`, `offering_orders_controller.rb`,
`patrons_controller.rb`, `patron_metadata_values_controller.rb`,
`lifecycle_policy.rb`, `form_schema.rb`, `profile_form.rb`/
`dependent_form.rb` and their account/native controllers, native
serializers, `_patron_picker.html.erb`, all `SystemAuditLogger` call
sites, existing test coverage.

## Field/Surface Matrix

**Reusable account** (`User` columns/metadata, not offering-scoped):
`english_name`, `native_name` (columns); `phone`, `city`, `notes`
(`User#metadata`). Write: `Account::ProfileForm` (account self-service +
native profile controller). No admin write path exists
(`Admin::PatronsController` has `create` only, no `edit`). Read:
`registration_intake_form#defaults_from_user`,
`admin/patrons_controller#patron_payload`, `NativeAccountSerializer.user`.
`contact_email` is never cached — always sourced live from `user.email`
at read time.

**Reusable dependent** (`Dependent#metadata` + `UserDependent` link):
`english_name`, `native_name`, `relationship_label`, `birthdate`
(`Dependent` columns / `link.relationship_label`); `phone`, `email`,
`notes` (`Dependent#metadata`). Write: `Account::DependentForm` (account
self-service + native dependents controller) — full CRUD. No admin write
path (`patron_payload` only reads `dependent_entries`, read-only). Also
written narrowly (phone/email/notes only) as a side effect of
registration create/edit when a dependent is selected — see duplication
finding below.

**Reusable tenant-offering** (`Registrations::ReusableDefaults`, keyed
`[temple.id][registrable_type][offering.id]`): under the default schema —
`preferred_slot`, `arrival_window`, `ceremony_location`,
`ancestor_placard_name`, `dedication_message`, `incense_option`,
`certificate_notes` (`preferred_date` excluded — `TRANSIENT_KEY_PATTERN`
strips any field ending in date/time). Write: `UserMetadataUpdater`
(both account and admin create/edit paths) +
`Admin::PatronMetadataValuesController` (the standalone admin UI shipped
in the prior packet). Read: `registration_intake_form`,
`offering_orders_controller#apply_registration_defaults`,
`patrons_controller#reusable_defaults_for` (feeds the JS patron-picker
prefill), the admin reusable-defaults panel.

**Registration-snapshot-only** (`TempleEventRegistration`'s own payload
columns, never fed back): `quantity`, `unit_price_cents`/
`total_price_cents`, `currency`, `certificate_number`, `event_slug`,
`registrant_scope`, `dependent_id`, `registrant_name`,
`registration_period_key`, `payment_status`, `fulfillment_status`,
`refund_status`, `cancellation_status`, `reference_code`, `expires_at` —
all explicitly in `ReusableDefaults::FORBIDDEN_FIELDS`, enforced at the
storage boundary itself (defense in depth).

**Never-reusable (identity/payment/authority)**: login email, OAuth
identities, sessions, password, capability/permission grants, audit
records, payment/refund records, privacy/closure state. Never touched by
`ReusableDefaults` or `UserMetadataUpdater`.

## Confirmed Gaps — Verified Against Current Code, Not Assumed

- "Account-side creation refreshes reusable user/dependent defaults" —
  **confirmed**.
- "Admin-side creation refreshes reusable user defaults" — **confirmed**,
  and already refreshes dependent defaults too
  (`TempleRegistrationBuilder#sync_dependent_profile!`) — more symmetric
  than the plan originally stated.
- "Account and admin edits primarily update the snapshot; reusable
  defaults not refreshed consistently" — **refuted**. Both
  `Account::RegistrationMetadataForm#save` and
  `Admin::OfferingOrdersController#update` already refresh reusable
  defaults on edit, gated by matching conditions (core+contact editable,
  payment pending, fulfillment open, no payments recorded). Not open
  work for A1 — predates the prior packet, not incidentally fixed by it.
- "Selected-dependent write-back is more complete on account creation
  than admin creation" — **refuted**. Both write the identical three
  fields (phone/email/notes). What's real instead: this exact logic is
  reimplemented four separate times (`RegistrationIntakeForm`,
  `RegistrationMetadataForm`, `TempleRegistrationBuilder`,
  `OfferingOrdersController`) — functionally symmetric but duplicated,
  not asymmetric. Same duplication pattern for the
  `reusable_write_allowed?` gate condition
  (`RegistrationMetadataForm`/`OfferingOrdersController`). Real A1
  consolidation target, just not the gap as originally described.
- "Lacks one focused end-to-end contract matrix" — **confirmed**; this
  record is that matrix.

## Cross-Tenant Slug Question — Confirmed, Not Just Traced

`Registrations::ReusableDefaults` keys strictly by
`[NAMESPACE][temple.id][registrable_type][offering.id]` (the offering's
real DB id, never slug), plus a hard `offering.temple_id == temple.id`
check in `valid_context?`. Grepped the whole app for other slug-keyed
personal-data storage (`offering_slug`, `metadata["offerings"]`) — the
only hits are unrelated (OAuth post-login intent resolution, an
offering-template config loader), neither touching personal/reusable
data. No live code path stores or reads reusable personal/offering data
by slug. The cross-tenant leak risk the plan flagged as unconfirmed does
not exist in the current implementation — dropped from Phase A1's scope.

## Other Findings, Not Requested But Relevant

- `Admin::PatronsController#create` is still gated by `manage_permissions`
  (`can_manage_admins?`), stricter than `manage_registrations` used
  everywhere else in this domain
  (`patron_metadata_values_controller`, `offering_orders_controller`) —
  consistent with what the withdrawn admin-CRUD packet described,
  unchanged, not addressed by this phase.
- The native (Expo) API already exposes reusable account/dependent data
  via `NativeProfileController`/`NativeDependentsController`/
  `NativeAccountSerializer` — pre-existing, not touched by this phase,
  noted for Phase A4 (native adoption gate) awareness.

## Closeout

Read-only phase, no branch/worktree/code changes to clean up. Findings
folded into `ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`'s
Confirmed Gaps and Phase A1 sections. Control A standing by for Phase A1.
