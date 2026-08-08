# Control B Implementation Packet — First-Tenant Billing Entitlement, Phase 3

## Identity

- Accepted-plan path and frozen criteria:
  `ops/docs/plans/FIRST_TENANT_BILLING_ENTITLEMENT_AND_REGISTRATION_GATE_PLAN.md`,
  **Phase 3 — Wire monthly collection to delivery creation**, and Planning's
  direct 2026-08-08 Phase 3 dispatch.
- Control task and authority state: Wenfu Control B; Planning accepted Phase 2
  and supplied canonical base `7b4ce5111f56a04a502f978041f21297025f6168`.
- Repository, worktree, branch, and base HEAD:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`, canonical worktree, `main`,
  `7b4ce5111f56a04a502f978041f21297025f6168`.
- Packet status and date: frozen for one ephemeral Implementer, 2026-08-08.

## Scope

- Objective: make a newly created pending monthly delivery reach the existing
  local Stripe collection service exactly once on successful close, while
  safely retaining a local pending delivery/audit trail for retry if collection
  prerequisites or the collector fail.
- Exact owned editable paths:
  - `rails/app/jobs/platform_billing_monthly_close_job.rb`
  - `rails/app/services/billing/platform_billing_collection_dispatcher.rb`
    (new)
  - `rails/app/services/billing/stripe_platform_billing_collection.rb`
  - `rails/test/jobs/platform_billing_monthly_close_job_test.rb`
  - `rails/test/services/billing/platform_billing_collection_dispatcher_test.rb`
    (new)
  - `rails/test/services/billing/stripe_platform_billing_collection_test.rb`
  - this packet's closeout sections only after Control acceptance; no other
    documentation path.
- Exact behavior:
  - after `PlatformStatementCloser.close` and
    `PlatformBillingDeliveryCreator.create_monthly!` both succeed, dispatch
    only a `monthly`, `pending`, `TWD` delivery to the existing collector;
  - successful collection changes the existing delivery to `collecting`; a
    second close/dispatch observes that non-pending delivery and never repeats
    a provider collection attempt;
  - the collector must require nonblank persisted Stripe customer and payment
    method references and `TWD`, and continue using the existing validated,
    distinct monthly Price configuration and invoice-total equality check;
  - invalid/missing local prerequisites or collection errors leave the delivery
    pending and emit a safe structured `platform_billing.collection_failed`
    audit record containing only delivery ID, error class, and bounded message.
    This is the visible local retry evidence. Never mark paid, modify an
    entitlement, or create a lifecycle transition from this error;
  - a collection failure for one temple must not prevent the job from closing
    and safely dispatching the next temple. Preserve the existing
    `platform_billing.monthly_close_failed` handling for close/create errors.
- Explicitly excluded paths and systems:
  - all entitlement/adoption/setup/webhook/lifecycle/controller/form/view
    changes; Stripe/ECPay credentials/configuration and real API/CLI actions;
    timers/schedulers, deployment, production migration/data, push, real
    customer/payment/invoice/subscription work, and external mutation.
- Required checks and expected evidence:
  - focused dispatcher/job tests prove one pending delivery invokes collection;
    rerun after successful collecting status invokes none; prerequisite/collector
    failure remains pending with safe audit; and one temple's failure does not
    prevent another safe dispatch;
  - focused collector tests prove customer, payment-method, and TWD checks,
    monthly Price use, automatic collection, and invoice-total mismatch
    rejection;
  - retain Phase 1/2 entitlement/setup, lifecycle, and event-ingest
    regressions; Ruby syntax checks and `git diff --check`.
- Evidence sources and status:
  - configured: statement closer, pending delivery creator, local Stripe
    collector and its idempotency keys;
  - documented: Planning's committed Phase 3 criteria;
  - observed: canonical `main` is clean at the supplied Planning base;
  - unknown: live catalog currency/price content, provider response, timer
    activation, and first-tenant behavior; excluded.
- First blocked surface: none for this local Phase 3 packet.

## Incident-Correction Placement

- Is this an incident correction? No. This is accepted product/runtime Phase 3.
- Selected surface: local dispatcher/job, existing collection preconditions,
  and focused regression tests.
- `AGENTS.md` is excluded; no Director authorization exists to edit it.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no.
- Eligibility confirmed before selecting a model: yes; no exceptional
  continuity reason exists.
- Luna disqualifiers checked: availability, cost, mechanical simplicity, and
  rejection do not qualify.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra/high`.
- Selection reason and lowest-sufficient configuration: bounded collection
  dispatch must preserve statement authority, local retry semantics, and
  isolation while avoiding any provider behavior change. Terra/high is
  justified; Sol is not authorized or needed.
- Ephemeral allocation: justified `gpt-5.6-terra/high`; Luna is never
  ephemeral.
- One ephemeral Implementer task: implement this packet only, run required
  checks, and return changed paths, results, and any concrete blocker directly
  to Control B.
- Return destination: this Control directly.
- Implementer boundaries: owned paths only; no acceptance, staging, commit,
  merge, push, deploy, approval handling, secret access, external mutation, or
  scope expansion.

## Control Review And Closeout

- Conformance review against the frozen plan: accepted. The close job dispatches
  only after close/create success; the dispatcher skips non-pending deliveries,
  preserves pending failures with safe retry evidence, and isolates each
  temple. The collector now requires TWD plus persisted customer/payment-method
  references while retaining the configured Price and invoice-total guards.
- Acceptance decision and rationale: accept. The Implementer changed only the
  six packet-owned product/test paths. Control independently reviewed retry
  behavior, error metadata, cross-temple iteration, TWD/payment prerequisites,
  and statement-total preservation. The combined Phase 1–3 Rails suite passed
  with 70 runs and 433 assertions; Ruby syntax checks and `git diff --check`
  passed.
- Integration, staging, and commit evidence when accepted: Control staged only
  the seven packet-owned paths, verified the cached diff, and integrated this
  closeout with the accepted Phase 3 implementation on canonical `main`.
- Terminal packet to Planning: send the accepted commit, checks, final state,
  and residual external boundary directly after integration.
- Residual risk, production gap, and next owner: Phase 4 webhook/lifecycle
  convergence and all live activation remain excluded.
- Authority confirmation: Planning froze the committed Phase 3 criteria;
  Control owns this packet, review, and local integration.
