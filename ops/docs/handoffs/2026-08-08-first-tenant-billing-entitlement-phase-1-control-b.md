# Control B Implementation Packet — First-Tenant Billing Entitlement, Phase 1

## Identity

- Accepted-plan path and frozen criteria:
  `ops/docs/plans/FIRST_TENANT_BILLING_ENTITLEMENT_AND_REGISTRATION_GATE_PLAN.md`,
  **Frozen Generic Contract For Phase 1** and **Phase 1 — Durable entitlement
  and migration design**.
- Control task and authority state: Wenfu Control B; Planning directly sent the
  committed accepted Phase 1 request on 2026-08-08.
- Repository, worktree, branch, and base HEAD:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`, canonical worktree, `main`,
  `405453e445147cf2b858fea2329a2e69853550d6`.
- Packet status and date: frozen for one ephemeral Implementer, 2026-08-08.

## Scope

- Objective: add one durable, audited, temple-scoped entitlement authority and
  make the existing central registration/payment-intake gate use it only where
  a temple has explicitly adopted the new authority. A missing record remains
  legacy compatibility, not suspension.
- Exact owned editable paths:
  - `rails/db/migrate/20260808000023_create_platform_billing_entitlements.rb`
  - `rails/db/schema.rb`
  - `rails/app/models/platform_billing_entitlement.rb`
  - `rails/app/models/temple.rb`
  - `rails/app/services/billing/platform_billing_entitlement_transition.rb`
  - `rails/test/models/platform_billing_entitlement_test.rb`
  - `rails/test/services/billing/platform_billing_entitlement_transition_test.rb`
  - `rails/test/models/temple_test.rb` only if focused legacy/new-gate coverage
    belongs there; otherwise add a dedicated focused test under
    `rails/test/models/`.
  - this packet's closeout sections only after Control acceptance; no other
    documentation path.
- Exact behavior:
  - states are exactly `pending_setup`, `active`, and `suspended`; only active
    permits an adopted temple's existing intake gate;
  - one unique entitlement belongs to one temple; create an explicit local
    adoption operation that creates `pending_setup` and never activates it;
  - missing entitlement preserves the temple's pre-existing legacy
    `registration_intake_frozen?` behavior;
  - an idempotent transition needs the owning temple plus a durable matching
    billing-delivery context, with optional matching durable billing-event
    context where supplied; reject missing, cross-temple, or mismatched
    context;
  - the entitlement mutation and its structured audit evidence occur in one
    database transaction. Repeating an already-applied transition does not
    create duplicate entitlement state/audit evidence;
  - record only safe identifiers/state/timestamp context, never provider raw
    payload, card data, credentials, or personal data.
- Explicitly excluded paths and systems:
  - all controllers, forms, views, routes, jobs, lifecycle/webhook/setup and
    Stripe/ECPay service code;
  - all existing billing delivery/event/statement models and migrations;
  - plan/governance files, provider configuration, secrets, real Checkout or
    webhook calls, timers, deployment, production data/migration, staging,
    push, and external mutation.
- Required checks and expected evidence:
  - focused new model/service tests covering state constraints, unique temple
    authority, adoption, active-only gate, missing-row compatibility,
    idempotency, cross-tenant/mismatched/invalid delivery-event context, and
    safe audit metadata;
  - existing focused billing lifecycle, event-ingest, setup, and registration
    payment-flow tests remain green;
  - local migration/schema validation appropriate to this Rails repository;
  - `git diff --check`.
- Evidence sources and status:
  - configured: Rails models, migrations, `SystemAuditLogger`, and the
    existing `Temple#registration_intake_frozen?` central gate;
  - documented: Planning's committed Phase 1 contract;
  - observed: `main` at the Planning base is clean, staging empty, ahead 47;
  - unknown: any live provider/timer/first-tenant runtime behavior; excluded.
- First blocked surface: none for this local Phase 1 packet.

## Incident-Correction Placement

- Is this an incident correction? No. This is the accepted first generic
  product/runtime implementation phase.
- Selected surface: Rails persistence, model, service, and focused tests.
- `AGENTS.md` is excluded; no Director authorization exists to edit it.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no.
- Eligibility confirmed before selecting a model: yes; no exceptional
  continuity reason exists.
- Luna disqualifiers checked: availability, cost, mechanical simplicity, and
  rejection do not qualify.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra/high`.
- Selection reason and lowest-sufficient configuration: this packet introduces
  a new tenant-scoped persistence authority, transactional audit semantics,
  and compatibility behavior across old and adopted gates. Terra/high is
  justified for the bounded semantic integration; Sol is not authorized or
  needed.
- Ephemeral allocation: justified `gpt-5.6-terra/high`; Luna is never
  ephemeral.
- One ephemeral Implementer task: implement this packet only, run the required
  checks, and return changed paths, results, and any concrete blocker directly
  to Control B.
- Return destination: this Control directly.
- Implementer boundaries: owned paths only; no acceptance, staging, commit,
  merge, push, deploy, approval handling, secret access, external mutation,
  or scope expansion.

## Control Review And Closeout

- Conformance review against the frozen plan: accepted. The implementation
  adds one unique temple entitlement, explicit pending-only adoption,
  active-only adopted-gate behavior, legacy missing-row compatibility, and a
  delivery/event-context transition service. It does not alter excluded
  controllers, provider services/configuration, lifecycle, jobs, or external
  state.
- Acceptance decision and rationale: accept. The Implementer used only owned
  product paths; Control independently reviewed the migration/model/service and
  safe audit metadata. Focused Rails evidence passed with 31 runs and 161
  assertions, the Phase 1 migration is up in `golden_template_test`, Ruby
  syntax checks passed, and `git diff --check` passed.
- Integration, staging, and commit evidence when accepted: Control staged only
  the eight packet-owned paths, verified the cached diff, and integrated this
  closeout with the accepted Phase 1 implementation on canonical `main`.
- Terminal packet to Planning: send the accepted commit, checks, final state,
  and residual external boundary directly after integration.
- Residual risk, production gap, and next owner: live first-tenant activation,
  provider evidence, timers, and later phases remain excluded.
- Authority confirmation: Planning froze the committed plan and Phase 1
  criteria; Control owns this packet, review, and local integration.
