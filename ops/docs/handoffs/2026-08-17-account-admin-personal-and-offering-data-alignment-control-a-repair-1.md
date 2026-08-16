# Control A Nonterminal Repair Packet — Direct Phase A1 Contract Evidence

## Identity and observed failure

- Parent packet: `wenfu-control-a-account-admin-personal-and-offering-data-alignment-attempt-1`.
- Repair packet: `wenfu-control-a-account-admin-personal-and-offering-data-alignment-repair-1`.
- Observed conformance failure: the parent candidate adds only `ReusableDefaults` unit coverage. It does not directly prove the accepted account/native/admin self/dependent create/update symmetry, rejected-write no-mutation, scoped editor behavior, audit redaction, or privacy/snapshot boundary. Existing unrelated regressions cannot supply the new contract evidence.
- Criteria and plan are unchanged: `ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_ALIGNMENT_IMPLEMENTATION_PLAN.md`.

## Direct mechanism and scope

- Add direct tests in the smallest existing account/native/admin/privacy/audit/lifecycle test seams, and repair only parent-owned Rails source if those tests show a concrete failure of the unchanged contract.
- Editable paths: all parent packet-owned implementation paths, `rails/test/services/registrations/reusable_defaults_test.rb`, `rails/test/integration/account/registration_payment_flow_test.rb`, `rails/test/integration/account/api/native_account_resources_test.rb`, `rails/test/integration/admin/offering_orders_registrant_flow_test.rb`, `rails/test/integration/admin/offerings_audit_test.rb`, `rails/test/integration/account/privacy_flow_test.rb`, and this repair record. No other surface is authorized.
- Required direct proof: account/native/admin, self/dependent, eligible create/update write-back equivalence; duplicate/failed/locked/cancelled/refunded/fulfilled/read-only no mutation; blank registration omission vs exact scoped explicit clear; configured-only and multi-value behavior; audit field-name-only/no sensitive values; privacy export single safe namespace; later-default changes preserve historical registration snapshots; exact legacy/cross-tenant/type-id separation.
- Checks: the augmented focused matrix, full Rails suite, Ruby syntax for every changed Ruby file, `git diff --check`, exact changed-path/no-migration review, and a newly named disposable `RAILS_ENV=test` PostgreSQL database with configured/current equality proof before every write and final absence proof.

## Boundaries and return

- One fresh `gpt-5.6-terra/high` ephemeral Implementer is justified by cross-surface lifecycle/authorization/evidence behavior. It returns directly to Control, may not stage/commit/merge/push/deploy/access external systems, and may not contact Planning or Control B.
- No Planning terminal is permitted until the repaired candidate conforms or a true unchanged-criteria authority/design gap exists.
