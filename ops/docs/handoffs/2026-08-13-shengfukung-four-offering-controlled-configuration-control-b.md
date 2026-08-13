# Wenfu Control Implementation Packet

## Identity

- Accepted-plan path and immutable criteria: `ops/docs/plans/SHENGFUKUNG_FOUR_OFFERING_CONTROLLED_CONFIGURATION_PLAN.md`; exactly four loader-ready Shengfukung services (`incense-donation`, `lamp-service`, `ghost-festival-table`, `liberation-ritual`), each TWD / `price_cents: 5000`; inferred fifth-row halves absent from loader-ready source and existing records untouched.
- Control task and authority state: Wenfu Control B / `019fe020-e92e-7770-984f-b59acd547ab0`, direct Planning dispatch; active bounded local Phase 3 implementation.
- Repository, worktree, branch, and base HEAD: `/Users/jimmy1768/Projects/shengfukung-wenfu`; `/private/tmp/shengfukung-wenfu-four-offering-controlled-configuration`; `codex/shengfukung-four-offering-controlled-configuration`; `d375763275f09056a5ae539706a0814aaab371a6`.
- Packet status and date: recorded immutable before implementation, 2026-08-13.
- Immutable packet identity and implementation attempt: `2026-08-13-shengfukung-four-offering-controlled-configuration-control-b`, attempt 1.

## Scope

- Objective: reconcile only the loader-ready Shengfukung offering catalog to the Planning-approved four TWD 50 draft services, with local deterministic proof that historical inferred rows are orphaned and unchanged.
- Exact owned editable paths: `rails/db/temples/offerings/shengfukung-wenfu.yml`; focused tests and a narrow helper only under `rails/test/services/offerings/`; this Control record.
- Explicitly excluded paths and systems: all application services/models/schema/migrations, seeds/bootstrap source, intake/working-draft/historical plans, provider and credential surfaces, payment lifecycle, Expo/Vue, shared-development or production databases, deployment, push, and external systems.
- Required checks and expected evidence: YAML parser/catalog-set proof; exact TWD / `price_cents: 5000` / formatter evidence; guarded `RAILS_ENV=test` template-parity proof against a fresh tenant; orphaned inferred-row no-update/no-delete proof; focused offering/template/bootstrap tests and any affected tests; Ruby/YAML parsing; `git diff --check`; clean disposable-test-artifact cleanup.
- Evidence sources and status: accepted plan and roadmap documented; canonical base/worktree/clean main observed; current YAML and TemplateParity behavior observed; test database behavior pending Implementer/Control validation.
- First blocked surface, if known: none.

## Incident-Correction Placement

- Is this an incident correction? no; this is the accepted Phase 3 controlled configuration implementation.
- Selected surface: the loader-ready tenant YAML and focused offering parity/config tests, as authorized by the plan.
- `AGENTS.md` excluded unless explicit Director authorization is recorded: excluded.

## Repair And Terminal Boundary

- Is this a bounded nonterminal repair within unchanged immutable criteria? no.
- Failed attempt identity and evidence: none.
- Immutable repair packet direct mechanism, owned paths, and checks: not applicable unless a concrete conformance defect is observed.
- True Planning design gap, Director authority decision, or no evidence-backed direct repair remaining: not known.
- Planning packet prohibited until a terminal disposition: confirmed.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no.
- If yes, exceptional recorded continuity reason and one-packet boundary: not applicable.
- Eligibility confirmed before selecting a model: yes; no Handoff qualifies.
- Luna disqualifiers checked: availability, cost, mechanical simplicity, and rejection do not qualify: confirmed.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra` / high.
- Selection reason and lowest-sufficient configuration: this packet has retained relational test-state behavior: it must prove that template application creates four exact records while a pre-existing inferred record is classified orphaned and is neither updated nor deleted. That requires careful test isolation and preservation proof, so Terra/high is the lowest sufficient deeper bounded allocation.
- Ephemeral allocation: `gpt-5.6-terra/high` with the retained-state/orphan-preservation rationale above; Luna is never ephemeral.
- Persistent-Handoff allocation, only after eligibility: not applicable.
- One ephemeral Implementer task: `shengfukung_four_offering_configuration_implementer`.
- Return destination: this Control directly.
- Implementer boundaries: owned paths only; no acceptance, staging, commit, merge, push, deploy, approval handling, secret access, external mutation, or scope expansion.

## Control Review And Closeout

- Conformance review against immutable criteria: accepted. The final loader has exactly the approved four service slugs, no event entries or duplicate slugs, and every persisted template authority is `TWD` / `price_cents: 5000`. The two inferred entries are absent from loader-ready source only. Their historical working-draft/intake/Git surfaces are unchanged.
- Acceptance decision and rationale: accepted after an independent guarded disposable-database rerun. `TemplateParity.ensure_missing!` creates four exact draft services for a fresh test tenant. A pre-existing `peace-opera-household` row is orphaned, remains reloadable, retains its recorded price/status/metadata, and is not deleted while the approved rows are created.
- Integration, staging, and commit evidence when accepted: accepted configuration/test/packet commit `c8750b5` on the isolated branch; canonical-main integration remains a Control action after this record closeout.
- Immutable terminal packet direct delivery, source Control, target Planning, implementation attempt, and continuation disposition: pending direct delivery to Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`; intended disposition `accepted_frozen_outcome`.
- Paired Planning receipt: `released_terminal_idle`: pending.
- Parent classification, continuation disposition, and next owner/action: Planning owns Phase 4 only after this canonical Phase 3 acceptance.
- `active_packet: none` only with the exact missing decision and owner: not applicable while this packet is active.
- Residual risk, production gap, and next owner: no real temple database/provider action is attempted. Control created `wenfu_phase3_offerings_20260813` only after proving it absent, migrated and used it under `RAILS_ENV=test` / `PGDATABASE_TEST`, then dropped it and verified it absent before acceptance. Planning owns later Phase 4 authorization.
- Authority confirmation: Planning reported evidence only; Strategy owns any cross-repository policy and the Director accepts it.

## Local Evidence

- Guarded disposable database lifecycle: `psql -d postgres -Atqc` proved `wenfu_phase3_offerings_20260813` absent; `env RAILS_ENV=test PGDATABASE_TEST=wenfu_phase3_offerings_20260813 bin/rails db:create db:migrate` created and migrated it; the focused suite passed; `env RAILS_ENV=test PGDATABASE_TEST=wenfu_phase3_offerings_20260813 bin/rails db:drop` removed it; the same `psql` query then returned no database row.
- Focused matrix in that exact disposable database: `bin/rails test test/services/offerings/template_parity_test.rb test/services/offerings/readiness_synthetic_proof_test.rb test/services/offerings/setup_draft_applier_test.rb test/services/offerings/setup_field_catalog_test.rb test/services/temples_bootstrap_test.rb test/integration/account/api/payment_statuses_test.rb test/integration/admin/offering_orders_registrant_flow_test.rb` — 33 runs, 272 assertions, 0 failures, 0 errors, 0 skips.
- Static checks: YAML catalog parser proved the exact four-item no-event/no-duplicate list and exact TWD/5000 values; `ruby -c rails/test/services/offerings/template_parity_test.rb` passed; `git diff --check` passed. The focused matrix exposed no shared-fixture or catalog coupling, so the plan does not require a full Rails-suite run.
