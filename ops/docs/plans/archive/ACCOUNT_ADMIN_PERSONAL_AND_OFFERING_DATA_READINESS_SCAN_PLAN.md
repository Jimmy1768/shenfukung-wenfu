# Account/Admin Personal And Offering Data Readiness Scan Plan

Status: accepted read-only readiness authority; report only

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target Control: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted base: canonical `main`
`38a73acb3e0d9ab0fcfd0460d8ca7fcd4c855526`

Parent track:
`ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`

Required report:
`ops/docs/handoffs/2026-08-16-account-admin-personal-and-offering-data-readiness-control-a.md`

## Objective

Perform the complete Phase A0 inventory needed to turn the existing Rails
account/admin prefill and write-back behavior into the small symmetric contract
accepted by the parent plan. Establish what exists, what is asymmetric, what is
unsafe or ambiguous, and the smallest later implementation boundary.

This is not a request to redesign the feature. The accepted product rule is
that reusable personal and offering data reduces friction. It is optional
unless an offering explicitly requires a field. Patrons and authorized admins
may correct entered values. The system must not become a profile-completion,
family-hierarchy, field-ACL, or approval framework.

## Read-Only Meaning

The packet may read source, tests, schema, routes, local Git history, and
documentation. It may run existing Rails tests and non-mutating source checks.
When database evidence is needed, it may create and destroy only one or more
exactly named disposable PostgreSQL test databases under `RAILS_ENV=test`,
after proving the configured and current database names before every write
stage. It must remove all packet-created databases before closeout.

It may not edit product source, tests, schema, migrations, configuration,
fixtures, seeds, plans, or reference documentation. The only committed path is
the required sanitized Control report and Control-owned packet record.

No shared development database, production database, account, user,
registration, dependent, offering, payment, provider, server, or external
system may be inspected or changed.

## Required Inventory

### Field and ownership map

Inventory every currently supported field and classify it as exactly one of:

- reusable account default;
- reusable owned-dependent default;
- reusable tenant-and-offering-specific default;
- registration snapshot only; or
- identity, authority, lifecycle, price, payment, accounting, privacy, or
  closure data that must never be treated as registration-prefill metadata.

For each field, record its storage location, normalization, blank behavior,
public shape, serializer, form input, rendering surface, updater, audit
behavior, and deletion/export/closure treatment. Distinguish a configured
field vocabulary from fields actually rendered by each offering.

### Surface and data-flow map

Trace the complete path for:

- account self registration create and editable update;
- account owned-dependent registration create and editable update;
- admin-assisted self registration create and editable update;
- admin-assisted owned-dependent registration create and editable update;
- account profile and dependent CRUD;
- admin patron lookup/prefill and reusable multi-value metadata operations;
- native/account JSON controllers and serializers that already inherit or
  diverge from the Rails contract; and
- privacy export, closure, audit, registration lifecycle, and payment locks.

For every path, show:

```text
source of prefill
  -> rendered or serialized field
  -> submitted parameter and strong-parameter boundary
  -> registration-owned snapshot
  -> reusable-default write-back, omission, or rejection
```

### Symmetry matrix

Produce a factual account/admin matrix for:

- self versus dependent;
- create versus editable update;
- prefill versus explicit override;
- nonblank correction versus blank omission;
- explicit reusable-data clearing;
- single-value versus configured multi-value fields; and
- accepted update versus lifecycle/payment-rejected update.

Mark every cell `implemented_and_covered`, `implemented_uncovered`,
`asymmetric`, `unsafe`, `absent_by_design`, or `unknown`, with exact source and
test evidence. Do not turn an uncovered behavior into a claimed defect without
direct evidence.

### Tenant and offering identity

Establish the exact current key used for offering-specific reusable data and
prove whether two temples using the same offering slug can read, prefill, or
overwrite each other's values. The proof must use local source and disposable
test state only.

Record whether a safe correction can use existing JSON storage and stable
tenant/offering identifiers. Do not presume a migration. If atomicity,
backwards compatibility, or tenant-safe identity truly requires schema work,
return that as a separately planned design gap with the exact reason.

### Person-role separation

Verify that payer/contact data, an explicitly selected owned dependent, and a
freeform person named in a ritual or offering are not silently collapsed. In
particular, confirm whether a freeform name creates or mutates a dependent, and
whether admin-assisted entry can target only the selected patron/dependent.

### Clearing, overwrite, audit, and privacy

Establish current behavior for:

- omitted and blank registration values;
- explicit profile/dependent clearing;
- repeated annual registrations and last accepted nonblank corrections;
- redacted audit metadata and accidental sensitive-value duplication;
- privacy export and account closure; and
- rejected, paid, refunded, cancelled, or otherwise locked registrations.

The scan must evaluate the parent rule that blank per-registration fields do
not implicitly erase reusable defaults while an explicit reusable-data editor
may clear them.

## Required Existing Evidence

Control must identify and run the smallest existing focused Rails matrix that
covers the observed paths, plus the full Rails suite when the disposable test
database can be fenced safely. If existing tests cannot establish a required
fact without adding code, report the fact as unproven and name the smallest
later test seam; do not edit tests during this scan.

At minimum, review these source families and their callers/tests:

- `rails/app/forms/account/registration_intake_form.rb`
- `rails/app/forms/account/registration_metadata_form.rb`
- `rails/app/services/registrations/user_metadata_updater.rb`
- `rails/app/services/payments/temple_registration_builder.rb`
- account profile, dependent, registration, privacy, and closure controllers;
- admin offering-order, patron, dependent, registration, and reusable-metadata
  controllers, services, views, and serializers;
- native/account JSON controllers and serializers;
- registration lifecycle, payment, authority, audit, and tenant boundaries;
- schema, models, routes, fixtures, seeds, and focused tests.

This inventory is illustrative, not a path-edit grant. Control must follow
actual callers and may read any repository-local evidence needed for a complete
report.

## Required Report

The durable report must contain:

1. exact repository, base, worktree, branch, status, staging, and evidence
   environment;
2. the field/ownership inventory;
3. the account/admin/native surface matrix;
4. the create/edit/prefill/write-back/clear symmetry matrix;
5. tenant/offering collision proof and classification;
6. person-role, lifecycle, audit, privacy, and closure findings;
7. existing focused/full test results and every unproven row;
8. the smallest coherent Phase A1 implementation boundary, likely paths,
   rollback shape, focused/full checks, and whether a migration is actually
   required;
9. exact exclusions and preserved behavior; and
10. first blocker, next owner/action, and one terminal classification:
    `account_admin_data_contract_ready_for_implementation` or a precise
    evidence-backed Planning/authority gap.

The report must distinguish `configured`, `documented`, `observed`, and
`unknown`. It must contain no real personal data, fixture secrets, credentials,
database URLs, session material, or copied sensitive field values.

## Acceptance Criteria

Planning may accept the scan only if:

- every required field and surface has an evidence-backed classification;
- account/admin create/edit and self/dependent asymmetries are explicit;
- tenant/offering scoping is proven or precisely blocked;
- clearing, lifecycle, audit, privacy, and closure behavior is not inferred;
- existing tests and gaps are reported truthfully;
- the proposed next packet is minimal and does not add hierarchy or
  completeness machinery;
- no product/source/test/schema/configuration change occurred;
- all disposable test state is removed;
- `git diff --check` passes; and
- canonical `main` remains unchanged and clean.

## Explicit Exclusions

- Expo/mobile source, UI, adapter, distribution, or native work;
- offering creation, pricing, payment, refund, or accounting changes;
- OAuth resolver rollout, user 22 recovery, identity linking/merging, provider
  work, or account mutation;
- production/shared-development data inspection or migration;
- deployment, release-ref movement, push, or external mutation; and
- implementation of any readiness recommendation.

## Next Owner

On terminal delivery, Planning sends the paired `released_terminal_idle`
receipt and decides whether to commit the narrow Phase A1 implementation plan.
No implementation continuation is implied by this scan.
