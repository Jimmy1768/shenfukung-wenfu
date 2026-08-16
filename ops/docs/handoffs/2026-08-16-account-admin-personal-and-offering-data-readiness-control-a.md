# Account/Admin Personal And Offering Data Readiness — Phase A0

Date: 2026-08-16

Terminal classification: `account_admin_data_contract_ready_for_implementation`

## Evidence boundary

- Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`.
- Isolated worktree/branch/base: `/private/tmp/shengfukung-wenfu-account-admin-personal-offering-readiness` / `codex/account-admin-personal-offering-readiness` / `4620012c2ba53913297a4354ea1785537f4217f8`.
- Initial status had only the Control-owned untracked packet. No staging was present. This attempt writes only this report; no product, test, schema, configuration, fixture, seed, or plan was changed.
- Source and schema findings below are **observed**. The offering vocabulary is **configured** by `Registrations::FormSchema`; rendering is conditional on each offering's `metadata.registration_form.sections`, rather than every catalogued field always being rendered.
- Test evidence used `RAILS_ENV=test` and one exact disposable local PostgreSQL database, `account_admin_readiness_20260816`. Before schema load, focused tests, and the full suite, Rails proved both configured and current database names equal that exact name. The first `db:prepare` attempt failed in existing seed code with an invalid admin-role enum before test execution; that database was dropped, recreated, schema-loaded without seeds, and used for the passing runs below. No URL, credential, session, fixture value, or personal data was recorded.

## Field and ownership inventory

| Field family (supported vocabulary) | Classification | Storage / normalization / rendered-public shape | Write and privacy treatment |
| --- | --- | --- | --- |
| Account identity: email, English/native name | identity/authority/privacy data; never prefill metadata | `users` columns; profile form and native serializer expose account-owned profile; native registration defaults use email/name only for contact display | Account profile writes names; email is not a registration-form write. Export includes user record; closure/anonymization redacts it. |
| Account reusable contact: phone, city, notes | reusable account default, except city is not consumed by registration | `users.metadata`; profile/native profile strong parameters. Intake reads phone; account UI/native profile serialize all three. | Profile update merges only nonblank values; intake create updater writes nonblank phone/notes. Export includes metadata; deletion retains metadata with anonymization markers rather than a full metadata scrub. |
| Intake contact: primary contact, phone, email, household/dependent notes | registration snapshot, with name/email identity-adjacent; phone/notes additionally reusable account defaults on create | `temple_registrations.contact_payload`; account serializers expose contact-name/phone/email/household-notes. Account intake defaults from user identity/metadata; dependent defaults come from selected owned dependent. | Account create snapshots compact-blank values and writes nonblank phone/notes only for self. Admin create snapshots and writes nonblank mapped values. Account/admin update changes snapshots only. Export includes payload. |
| Owned dependent: names, birthdate, relationship, phone, email, notes | reusable owned-dependent default; relationship/birthdate are personal data, not registration prefill metadata | `dependents` plus `user_dependents`; contact-like values in dependent metadata. Account/native dependent forms serialize CRUD records. | Explicit selected dependent is found through the current user link. Intake create may write only nonblank phone/email/notes to that dependent. Export includes link and dependent. Closure deletes the user link for shared dependents, otherwise anonymizes dependent values. |
| Registrant selection: scope, dependent id, derived registrant name | registration snapshot and authority linkage; never freeform profile metadata | `temple_registrations.metadata`; account/native serializer exposes scope and dependent id. | Strong parameters accept selection in metadata updates/native intake/admin order; lookup is restricted to owner’s dependents. No freeform ritual field reaches a dependent writer. |
| Logistics: preferred date, preferred slot, arrival window, ceremony location | reusable tenant-and-offering-specific default in current admin-create updater; registration snapshot in every registration | registration `logistics_payload`; offering schema conditionally renders admin controls. Account only renders/serializes arrival window. | `UserMetadataUpdater` excludes keys ending in date/time, so only non-transient logistics can be retained. Current account create submits arrival window but updater stores it under an offering slug. Account/admin updates do not write reusable defaults. Export includes snapshot. |
| Ritual/offering fields: placard/freeform name, dedication message, incense option, certificate notes, ceremony notes | registration snapshot; current implementation also retains nonblank values under offering slug on create, so this is an unsafe mixed classification pending A1 | registration `metadata`; offering schema conditionally renders admin fields; account only exposes ceremony notes. | Account and admin create call updater (excluding period key); updater retains nonblank values. Freeform ritual values do not create/update dependents. Account/admin edit writes registration only. Export includes snapshot. |
| Quantity, certificate number, currency, unit/total price, registration-period key, event/offering slug | lifecycle, price, payment, accounting, or offering identity; never prefill metadata | registration columns and metadata. Admin schema may render quantity/certificate/currency; account exposes quantity. | Builder/updater currently retains quantity/certificate and selected metadata under offering slug, which is incompatible with the target classification and must be stopped in A1. Period key is deliberately excluded from account builder payload. Export includes registration/payment facts. |
| Payment state, fulfillment state, payment records, reference code, expiry/cancellation/refund facts | payment/accounting/lifecycle data; never prefill metadata | registration columns/associated payments; serializers expose status. | Lifecycle policy locks core/contact after any payment record and prevents edits to persisted gathering registrations; it does not turn all snapshot metadata/logistics edits off. Export includes payments and registrations; closure does not delete registration/payment history. |
| Admin account, memberships, permissions, OAuth identities, privacy requests/settings, lifecycle events, audit metadata | identity, authority, privacy, or closure data; never prefill metadata | dedicated tables and metadata; only controlled serializers expose selected account fields. | Patron/admin authorization gates manage-registration access. Export includes these surfaces. Audit logs record actor/target/changed field names and selected identifiers, not registration payload values in the inspected paths. |

`FormSchema::DEFAULT_SECTIONS` is the configured vocabulary: order (`quantity`, price/currency/certificate), contact (`primary_contact`, phone/email/notes), logistics (date/slot/arrival/location), and ritual metadata (freeform ritual fields). A missing/true section uses defaults; false suppresses it. Thus a configured field is not proof it was rendered for a particular offering.

## Surface and data-flow map

| Surface | Observed flow | Classification |
| --- | --- | --- |
| Account self create | profile/user metadata -> `RegistrationIntakeForm` defaults -> account new form -> `registration_intake_params` -> contact/logistics/metadata snapshot -> `UserMetadataUpdater` (self contact plus offering slug) | implemented; focused coverage is partial. |
| Account dependent create | selected `current_user.dependents` -> dependent contact defaults only when no contact input key -> intake strong params plus controller-selected scope/id -> snapshot -> updater gets no contact payload; `sync_dependent_profile!` writes nonblank dependent contact fields | implemented; update semantics are asymmetric from self. |
| Account editable update | existing snapshot -> `RegistrationMetadataForm` -> `metadata_params` -> merged snapshot -> no updater | implemented and covered for basic account update; no reusable write-back by design/current omission. |
| Account profile/dependent CRUD | user/dependent records -> profile/dependent forms -> strong params -> merged record metadata -> audit changed-field names | implemented; native uses the same forms. Blank values are compacted, not explicit clears. |
| Admin-assisted create | patron picker/user id plus owned-dependent validation -> conditional offering-schema form -> `registration_params` -> builder snapshot -> `UserMetadataUpdater` under `event_slug`/offering slug -> audit create | implemented; basic builder test covered, registrant-flow coverage exists; no collision test. |
| Admin-assisted update | registration snapshot -> same schema form -> `policy_filtered_update_attributes` -> merge payload -> registration save -> no updater and no explicit update audit | implemented; asymmetric with admin create and uncovered for reusable defaults. |
| Admin patron lookup/multi-value | global `User` lookup filtered by role gate -> JSON payload includes account/dependent contact metadata and `offerings`; metadata-values endpoint receives arbitrary field and optional offering slug -> JSON metadata array add/remove | implemented but unsafe: no selected-temple component in stored offering path and no field allowlist. Explicit array-value removal exists; scalar clear does not. |
| Native profile/dependents | bearer-auth native controllers -> same profile/dependent forms -> native serializer -> audit source marker | implemented and covered by native account contract for basic CRUD. |
| Native registrations | native controller -> same intake/metadata forms -> registration serializer -> audit source marker | create accepts registrant scope/id directly and the form verifies dependent ownership; update shares account snapshot-only behavior. Contract coverage covers new/edit shape, not all write-back/clear cells. |
| Privacy/closure/audit | privacy controller/native privacy requests -> fulfillment services -> export/anonymization/lifecycle/audit records | implemented and covered by privacy/closure tests; export intentionally contains stored payloads, so A1 must not duplicate sensitive values into audit metadata. |

## Symmetry matrix

| Cell | Status | Evidence / factual outcome |
| --- | --- | --- |
| Self create, prefill, nonblank correction | implemented_uncovered | Intake defaults from user; create writes snapshot and updater’s nonblank phone/notes/offering data. No exact form-unit test for every mapped field. |
| Dependent create, prefill, nonblank correction | asymmetric | Defaults only if no contact key is submitted; snapshot plus nonblank dependent contact sync. It never writes account contact defaults. |
| Self editable update | implemented_and_covered | Registration metadata form merges snapshot; account portal flow covers update. No reusable write-back occurs. |
| Dependent editable update | asymmetric | It can change registration scope/dependent snapshot while core editable, but does not sync dependent profile. Account portal flow covers self-to-dependent registration switch, not dependent write-back. |
| Admin self/dependent create | implemented_uncovered | Builder invokes updater for a selected user; dependent is constrained through selected user. Existing builder/registrant-flow tests do not prove every default field or clear behavior. |
| Admin self/dependent editable update | asymmetric | Controller merges registration only; it never invokes updater or audit logger for update. |
| Native create/update | asymmetric | Create/update reuse forms, but native accepts scope/id in intake where web controller fixes them from selection. Native basic contract covered; metadata persistence symmetry unproven. |
| Nonblank explicit override | implemented_uncovered | Updater overwrites scalar values and appends unique configured multi-values on create only. |
| Blank omission | implemented_uncovered | Updater skips blank values; intake/admin sanitize compact blank snapshots. Account registration update can remove blank snapshot keys but never reusable data. |
| Explicit reusable scalar clearing | absent_by_design | Profile/dependent forms compact blank fields; updater skips blanks; no explicit scalar-default clear endpoint. |
| Explicit configured multi-value clearing | implemented_uncovered | Admin metadata-values destroy removes a nonblank exact array entry. It is not field-scoped/tenant-safe and has no focused test in the selected matrix. |
| Single vs configured multi-value | asymmetric | `multi_value_fields` is admin-supplied and updater appends arrays; account has no corresponding control/parameter. |
| Paid/refunded/recorded-payment update | asymmetric | Core/contact rejected by policy after any payment record, while ordinary event metadata/logistics remains saveable; no payment-status-specific update test proves every branch. |
| Cancelled registration update | unsafe | Cancellation alone is not checked by lifecycle policy; absent payment record permits core/contact edit. No direct test. |
| Persisted gathering update | absent_by_design | Both account and admin redirect/refuse gathering edits through `gathering_editable?`; covered in registration payment/lifecycle-related suites, exact all-field matrix unproven. |

## Tenant/offering identity and role separation

The current reusable-offering key is exactly `users.metadata["offerings"][offering_slug]`. `UserMetadataUpdater` receives `offering.slug`/registration event slug; `PatronMetadataValuesController` uses the same optional `offering_slug` path. Neither includes `temple_id`, tenant slug, registrable type, or stable offering id. Therefore two temples with the same offering slug can read, prefill, and overwrite the same user metadata slot: **unsafe, source-proven collision**. Existing tests do not exercise it. A1 needs a tenant-safe stable identity before retaining any offering-specific default; current JSON can hold a composite stable key, so a schema migration is not proven necessary. It requires a focused collision test and explicit migration decision only if backward-compatible JSON-key migration cannot be made atomic/reversible.

Payer/contact is the registration’s `user_id` plus contact snapshot. An owned dependent is only selected through that user’s `dependents`; admin resolution uses `user.dependents.find_by`. Ritual freeform fields are stored solely in registration metadata and have no `Dependent` write path. Admin entry is therefore constrained to the selected patron/dependent for dependent selection, but admin patron lookup itself is global and must not be interpreted as tenant-owned profile authority.

## Clearing, audit, privacy, lifecycle, and evidence gaps

- Repeated accepted nonblank creates use last-write-wins scalars and append/deduplicate configured arrays. No exact annual-repeat test establishes intended retention.
- Audit records inspected for account/native/profile/dependent creation/updates contain action, actor/source, reference or target, and changed **field names**; they do not copy payload values. Admin registration create audits offering/reference identifiers; admin update has no corresponding audit call. This is a material A1 audit gap, not a claim that all historical audit metadata is redacted.
- Privacy export intentionally returns user metadata, dependents, registration payloads/metadata, payments, requests, and lifecycle events to the subject. Closure/anonymization redacts identity and dependent records while retaining registration/payment history; user metadata is augmented with anonymization markers rather than scrubbed. Exact export treatment of each future reusable key is therefore unproven until A1 names it.
- No direct existing test proves: cross-tenant same-slug isolation, self/dependent/admin update write-back parity, blank/default-clear behavior, configured multi-value authorization/isolation, annual correction behavior, cancelled/refunded matrix, or audit non-duplication for every new field.

## Test results

Focused existing Rails matrix (schema-only fenced DB): `55 runs, 402 assertions, 0 failures, 0 errors, 0 skips`. It included builder, native registrations/account contract, account registration/payment, admin offering registrant/patron, privacy/closure, refund, and payment-sync tests.

Full Rails suite (same fence): `495 runs, 3095 assertions, 0 failures, 0 errors, 0 skips`.

The passing suite is evidence for existing behavior only; it does not cover the unproven rows above. The earlier seed failure is an existing seed enum mismatch and was not repaired under this report-only packet.

## Smallest Phase A1 boundary

Implement one symmetric, tenant-safe reusable-default boundary for account and authorized admin create/update, leaving registration snapshots authoritative per registration. Likely paths: the two registration forms, updater (or a narrow replacement), admin offering orders, patron metadata endpoint, form/serializer seams, and focused tests. Do not add profile completeness, family hierarchy, field ACL, approval, payment, pricing, OAuth, or mobile work.

The packet should: (1) define a tenant + stable offering identity JSON key and backwards-compatible read/write policy; (2) accept explicit reusable-data clear only in a dedicated authorized editor, while blank registration fields never erase defaults; (3) remove lifecycle/price/payment/accounting/identity fields from reusable persistence; (4) give account/admin self/dependent create/update the same explicit write-back contract; (5) constrain multi-value fields to configured vocabulary and tenant/offering scope; (6) retain audit field names/redaction and add admin-update audit; and (7) add collision, clear, lifecycle-lock, privacy-export, and symmetry tests.

Rollback shape: additive JSON-key write/read behind a single service boundary; preserve old JSON untouched until focused migration/backfill decision. A schema migration is **not currently required**. If A1 later needs a backfill, it must be an independently approved reversible migration/maintenance packet with dual-read, deterministic conflict handling, and rollback proof.

Required checks: focused form/service/integration collision and symmetry matrix, privacy/closure/audit/lifecycle tests, then full Rails suite in a newly named disposable fenced test database. Preserve account-owned dependent selection, snapshot history, payment/lifecycle locks, tenant isolation, and current optionality of offering fields.

## Exclusions, blocker, next action

No external system, shared/development/production database, user account, provider, payment operation, deployment, device, Metro, staging, commit, merge, or push was accessed. The first blocker is **none** for planning the narrow A1 implementation; test-seed failure is recorded as an unrelated evidence note because schema-only test execution passed. Next owner/action: Wenfu Planning should issue the paired `released_terminal_idle` receipt and decide whether to write the narrow Phase A1 implementation plan.
