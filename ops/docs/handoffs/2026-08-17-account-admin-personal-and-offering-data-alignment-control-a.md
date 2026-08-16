# Control A Implementation Packet — Account/Admin Personal And Offering Data Alignment

## Identity

- Accepted plan: `ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_ALIGNMENT_IMPLEMENTATION_PLAN.md` at dispatch commit `41a92ee090717650a081da16d201362add9a180a`.
- Control: Wenfu Control A / `019fc08d-676b-7ca2-be32-3efe42fa2fca`.
- Repository/worktree/branch/base: `/Users/jimmy1768/Projects/shengfukung-wenfu` / `/private/tmp/shengfukung-wenfu-account-admin-personal-offering-data-alignment` / `codex/account-admin-personal-offering-data-alignment` / `41a92ee090717650a081da16d201362add9a180a`.
- Packet: `wenfu-control-a-account-admin-personal-and-offering-data-alignment-attempt-1`, recorded 2026-08-17; immutable criteria are the accepted plan.

## Scope

- Objective: implement one Rails service-owned, versioned `User#metadata` reusable-default namespace keyed by exact temple id, registrable type, and registrable id; preserve legacy slug data untouched and unused; give account/native and authorized admin self/dependent eligible create/update paths the same safe write-back behavior.
- Exact owned paths: `rails/app/services/registrations/reusable_defaults.rb` (new); `rails/app/services/registrations/user_metadata_updater.rb`; `rails/app/forms/account/registration_intake_form.rb`; `rails/app/forms/account/registration_metadata_form.rb`; `rails/app/services/payments/temple_registration_builder.rb`; `rails/app/controllers/admin/offering_orders_controller.rb`; `rails/app/controllers/admin/patron_metadata_values_controller.rb`; only directly necessary existing admin helper/view/serializer files to supply stable registrable identity; focused Rails tests for those paths and their direct account/native/admin/lifecycle/privacy/audit seams; this packet record.
- Explicit exclusions: all migrations/schema/seeds/fixtures; profile completeness, hierarchy/ACL/approval; offering catalog/configuration; payment/pricing/accounting/provider behavior; OAuth; mobile/Expo/Vue; shared/development/production data; external/network/provider/secret activity; deployment/release/push; Control B coordination.
- Mandatory semantics: no caller-created metadata paths; legacy `metadata["offerings"][slug]` retained byte-for-byte with no read fallback or write; only configured offering-schema reusable fields, with `allow_multiple` as the sole array authority; never persist forbidden lifecycle/identity/price/payment/accounting/date-period fields; blank registration input never clears defaults; explicit scoped editor clear only; no reusable mutation on failed/duplicate/locked/cancelled/refunded/fulfilled/read-only writes; audit field names only and no payload values.
- Checks: all accepted focused collision/type-id/legacy/symmetry/lifecycle/clear/privacy/audit/snapshot tests; Ruby syntax for every changed Ruby file; full Rails suite; `git diff --check`; exact changed-path and no-schema/migration review. Every Rails write must use a newly named packet-owned disposable `RAILS_ENV=test` PostgreSQL database after configured and `current_database()` equality proof; remove it and prove absence before return.
- Evidence status: accepted plan and readiness report are documented; canonical base/worktree state observed clean; no known blocker.

## Correction, Handoff, And Dispatch

- Incident correction: no. `AGENTS.md` is excluded.
- Bounded repair: none at dispatch; a concrete conformance defect under unchanged criteria requires a new nonterminal repair packet and no Planning status traffic.
- Persistent Handoff: not requested; no continuity eligibility.
- Ephemeral Implementer: `gpt-5.6-terra/high`, selected as the lowest sufficient allocation because the packet has shared retained JSON state across account/admin/native paths, tenant/type/id isolation, lifecycle no-mutation guarantees, audit redaction, and disposable-database concurrency/idempotency evidence.
- Implementer: one ephemeral task, returns directly to this Control. It may edit only the paths above; it may not stage, commit, merge, push, deploy, access secrets/providers, mutate external systems, change scope, or contact Planning/Control B.

## Review And Closeout

- Control independently reviews immutable-plan conformance, required checks, forbidden-surface absence, disposable-database cleanup, then stages/commits and locally integrates only an accepted result into canonical main.
- Terminal: one immutable direct packet to Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`, naming exact checks, commits, paths, database fences/cleanup, blocker, continuation, and preserved boundaries. Planning receipt is expected to be `released_terminal_idle`.
