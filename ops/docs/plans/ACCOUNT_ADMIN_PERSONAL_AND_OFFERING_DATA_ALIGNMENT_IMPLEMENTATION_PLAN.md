# Account/Admin Personal And Offering Data Alignment Implementation Plan

Status: accepted implementation authority

Accepted: 2026-08-17

Owner: Wenfu Planning / Director

Target Control: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted base: canonical `main`
`0ed62ec520c97c50429d484b60379144bdb12539`

Parent track:
`ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`

Accepted readiness evidence:
`ops/docs/handoffs/2026-08-16-account-admin-personal-and-offering-data-readiness-control-a.md`

Required Control record:
`ops/docs/handoffs/2026-08-17-account-admin-personal-and-offering-data-alignment-control-a.md`

## Objective

Implement the smallest Rails alignment that makes reusable patron and owned-
dependent data a safe friction-reduction layer for account and authorized
admin registration work.

Registration records remain authoritative historical snapshots. Reusable
defaults may prefill a later registration and may be corrected after an
accepted editable registration write. They are not completeness requirements,
verified identity, family hierarchy, approval state, payment authority, or an
offering-definition system.

This packet must close the readiness-proven same-slug tenant collision, stop
lifecycle and price fields from entering reusable metadata, and make accepted
account/admin self/dependent create and update paths follow one explicit
write-back contract.

## Accepted Product Contract

1. Personal and offering-specific values are optional unless the selected
   offering's configured form schema explicitly requires them.
2. A patron may enter or correct their own and an owned dependent's permitted
   values. An admin with the existing `manage_registrations` authority may do
   the same while assisting that patron. No new authority tier is introduced.
3. Contact/payer, selected owned dependent, and a freeform ritual person/name
   remain distinct. A freeform ritual value never creates or mutates a
   dependent.
4. Each registration stores its own snapshot. Changing a reusable default does
   not rewrite prior registrations. Editing one eligible registration may
   update future defaults only after the registration write succeeds.
5. Blank registration input omits or clears only that registration snapshot as
   the existing form contract allows; it never implicitly erases a reusable
   default. An explicit clear is accepted only through an existing dedicated
   profile/dependent editor or the narrowed reusable-value editor.
6. No profile completion gate, field ownership lattice, family hierarchy,
   approval queue, source precedence engine, or historical reconciliation is
   needed.

## Required Storage Boundary

Introduce one service-owned, versioned JSON namespace under `User#metadata`
for registration defaults. The logical key must include:

- exact tenant identity (`temple.id`);
- exact registrable type (`TempleEvent`, `TempleService`, or
  `TempleGathering`); and
- exact stable offering identity (`registrable.id`).

The service may choose a normal nested JSON representation, but callers must
not construct paths themselves. Slug alone is forbidden. The public service
must provide the only read, nonblank write, configured multi-value add/remove,
and explicit-clear interfaces.

The existing unscoped `metadata["offerings"][slug]` data must remain byte-for-
byte preserved and must no longer receive writes. It must not be used as an
automatic prefill fallback because its tenant origin cannot be proven. No
automatic backfill, deletion, conflict guess, or dual-write to the unsafe path
is authorized. This is the accepted backwards-compatibility rule: retain the
legacy data for later explicit reconciliation while all new behavior uses the
safe namespace.

No schema migration is authorized or required. If implementation proves JSON
storage insufficient, Control must stop with a precise design gap rather than
add a migration.

## Allowed Reusable Values

### Account defaults

Retain only the existing account contact defaults used by registration intake,
such as phone and notes/household notes. Name and email continue to come from
the account identity/profile surfaces and are not copied into the new offering
namespace.

### Owned-dependent defaults

Retain only the selected owned dependent's existing contact defaults: phone,
email, and notes. Selection must continue through the current patron's
dependent association. Registration intake may never mutate an unrelated or
freeform person.

### Tenant/offering defaults

Retain only nonblank logistics or ritual fields that are present in the exact
offering's `Registrations::FormSchema` and are eligible for reusable storage.
Configured `allow_multiple` is the sole authority for array behavior.

The following are always forbidden from reusable storage, even when rendered:

- quantity, unit price, total, currency, certificate number;
- offering/event slug, registrable identity, registration period key;
- registrant scope, dependent ID, derived registrant name;
- payment, refund, cancellation, fulfillment, accounting, reference, expiry,
  identity, authority, privacy, or closure data; and
- transient date/time fields already excluded by the accepted source policy.

The offering schema remains the form vocabulary. This packet does not add,
remove, require, or redesign offering fields.

## Required Read, Prefill, And Write-Back Behavior

1. Account self and dependent new-registration forms and admin-assisted new
   registrations read the safe tenant/type/id defaults and merge them beneath
   explicit submitted values. Existing account/dependent identity/contact
   defaults retain their current role.
2. After a successful eligible registration create, write back only accepted
   nonblank reusable values using the selected self/dependent and exact
   tenant/offering context.
3. After a successful eligible registration update, account/native and admin
   paths use the same write-back boundary. Failed validation, duplicate
   redirect, or rejected lifecycle edit performs no reusable mutation.
4. Registrations with a recorded payment, refund, cancellation, fulfillment,
   or an existing read-only gathering state must not update reusable defaults.
   Preserve existing snapshot/lifecycle behavior; do not widen which
   registration fields may be edited.
5. Repeated annual registrations use last accepted nonblank scalar values and
   configured unique multi-value accumulation. No date/period-specific value
   becomes a reusable default.
6. Native/account controllers inherit the Rails form/service behavior; do not
   add a separate native metadata contract.

## Dedicated Clear And Multi-Value Boundary

Narrow `Admin::PatronMetadataValuesController` (or a small replacement behind
the same authorized surface) so it resolves the offering from
`current_temple`, uses exact type/id, and accepts only fields configured by that
offering's `FormSchema` as reusable and `allow_multiple` where applicable.
Arbitrary field paths, arbitrary offering slugs, cross-tenant records, and
lifecycle/price fields fail closed before mutation.

The editor may explicitly remove one configured multi-value or explicitly
clear one allowed scoped reusable field. It must never infer a clear from blank
registration input. Existing profile/dependent editors remain the explicit
place to clear account/dependent contact values; no new patron-facing settings
screen is required.

## Audit And Privacy

- Add the missing admin registration-update audit event using existing audit
  conventions.
- Audit only actor/source, tenant, registration/offering identifiers, and the
  names of changed reusable fields. Never copy entered values, names, contact
  details, freeform ritual text, or the full metadata document into audit.
- Privacy export must continue to include the user's stored metadata, including
  the new safe namespace, without creating a second duplicate payload.
- Existing closure/anonymization and retained registration/payment history
  remain unchanged. Do not invent deletion or retention finality.

## Likely Owned Paths

Control may refine the exact minimal path list after tracing callers. Expected
owned paths are limited to:

- `rails/app/services/registrations/user_metadata_updater.rb` or one narrow
  service replacement/addition under the same namespace;
- `rails/app/forms/account/registration_intake_form.rb`;
- `rails/app/forms/account/registration_metadata_form.rb`;
- `rails/app/services/payments/temple_registration_builder.rb`;
- `rails/app/controllers/admin/offering_orders_controller.rb`;
- `rails/app/controllers/admin/patron_metadata_values_controller.rb`;
- the smallest existing admin helper/view/serializer changes necessary to pass
  stable offering identity rather than a slug;
- focused Rails tests for the above; and
- the required Control record.

Profile/dependent forms may change only if direct tests prove an existing
explicit-clear defect inside this contract. Routes may change only when the
existing metadata-value endpoint cannot express an exact stable offering
identity without ambiguity. No migration/schema/fixture/seed change is owned.

## Required Evidence

Use one or more exactly named disposable PostgreSQL databases under
`RAILS_ENV=test`. Before every schema/test write, prove the configured and
current database names equal the packet-owned test database. Drop all packet-
created databases and prove absence before terminal delivery.

Required tests must prove:

1. same slug in two temples cannot read, prefill, append, clear, or overwrite
   the other tenant's value;
2. event/service/gathering IDs and types cannot collide;
3. legacy slug data remains unchanged and is not an unsafe fallback;
4. account and admin, self and dependent, create and eligible update have the
   same nonblank write-back result;
5. failed/rejected/duplicate/locked/cancelled/refunded/fulfilled/read-only
   writes leave reusable data unchanged;
6. blank registration values do not clear defaults, while explicit editor
   clear works only in scope;
7. only configured reusable fields and configured multi-value behavior pass;
8. quantity/certificate/price/currency/period/identity/lifecycle/payment fields
   never appear in the new namespace;
9. freeform ritual people do not create or mutate dependents;
10. privacy export includes the single stored safe namespace and audits contain
    field names but no sensitive values; and
11. registration snapshots and historical records remain unchanged when a
    later default changes.

Run the focused form/service/account/native/admin/lifecycle/privacy/audit
matrix, Ruby syntax on every changed Ruby file, then the full Rails suite.
`git diff --check`, exact path review, schema/migration absence, and canonical/
isolated cleanliness are required.

## Acceptance Criteria

- One tenant/type/id-scoped service owns every reusable offering-data path.
- All product rules and forbidden fields above have direct tests.
- Account/admin and self/dependent paths are symmetric where the existing
  lifecycle permits a write.
- Legacy unsafe data is preserved but neither read nor written implicitly.
- No migration, profile-completeness rule, hierarchy, ACL, approval, payment,
  pricing, offering-definition, OAuth, Expo, or Vue behavior is introduced.
- Full Rails regression passes in a fenced disposable database.
- Canonical integration contains only accepted owned paths and leaves both
  worktrees clean with staging empty.

## Rollback

The source change is reversible by reverting the accepted implementation
commit. New JSON keys may remain inert user-owned data after code rollback and
must not be deleted automatically. Any cleanup/backfill of new or legacy keys
requires a separately authorized data-maintenance plan.

## Explicit Exclusions

- production/shared-development data inspection, migration, cleanup, or user
  action;
- Expo/mobile, Vue, offering creation, YAML/catalog, payment, refund,
  accounting, OAuth, provider, or user 22 work;
- schema/migration/seed/fixture changes;
- deployment, release-ref movement, push, or external mutation; and
- any claim of legal/privacy retention finality.

## Control Procedure

Control A owns one bounded implementation packet, one ephemeral Implementer,
review, repair authority within unchanged criteria, local integration, and the
terminal record. Implementer returns directly to Control A. Control A must not
coordinate with Control B.

On terminal delivery, Control A returns `accepted_frozen_outcome` or the first
precise evidence-backed design/authority blocker and becomes
`released_terminal_idle`.
