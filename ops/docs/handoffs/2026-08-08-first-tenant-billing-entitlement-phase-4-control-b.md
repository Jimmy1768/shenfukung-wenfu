# Control B Implementation Packet — First-Tenant Billing Entitlement, Phase 4

## Identity

- Accepted-plan path and frozen criteria: `/Users/jimmy1768/Projects/shengfukung-wenfu/ops/docs/plans/FIRST_TENANT_BILLING_ENTITLEMENT_AND_REGISTRATION_GATE_PLAN.md`, Planning Phase 4 dispatch received 2026-08-08.
- Control task and authority state: Wenfu Control B; ordinary reversible local phase authorized directly by Planning.
- Repository, worktree, branch, and base HEAD: `/Users/jimmy1768/Projects/shengfukung-wenfu`; same; `main`; `1c5bbcc69d34061e49bcd8d9c2879f48793dcf3f`.
- Packet status and date: frozen for one ephemeral Implementer, 2026-08-08.

## Scope

- Objective: Converge verified local Stripe-event delivery transitions with the existing durable temple entitlement. Retain active access through failure, overdue, and grace; suspend only at the existing durable freeze transition; recover active access on a later verified paid event.
- Exact owned editable paths:
  - `rails/app/services/billing/stripe_platform_billing_event_ingest.rb`
  - `rails/app/services/billing/platform_billing_lifecycle.rb`
  - `rails/test/services/billing/stripe_platform_billing_event_ingest_test.rb`
  - `rails/test/services/billing/platform_billing_lifecycle_test.rb`
  - `rails/test/jobs/platform_billing_lifecycle_job_test.rb`
  - `rails/test/integration/api/v1/platform_billing_webhooks_test.rb`
  - `rails/test/integration/account/registration_payment_flow_test.rb`
  - this packet, only for Control closeout after acceptance.
- Required behavior:
  - A verified matching setup or monthly success event that is persisted for the delivery invokes the existing entitlement transition in the same database transaction, for that delivery's temple only. The transition is idempotent; event replay must not create another transition or affect another temple.
  - Failure and action-required events retain an existing active entitlement through overdue and grace. When the lifecycle transition freezes a delivery, suspend that delivery temple's existing entitlement transactionally. A later verified paid event restores it to active using the existing auditable transition service.
  - Preserve explicit missing-entitlement legacy compatibility. The existing central `Temple#registration_intake_frozen?` must remain the registration authority: entitlement controls adopted temples; legacy payment-method/grace settings apply only when no entitlement exists.
  - Preserve signature verification, metadata/delivery/temple matching, provider-event deduplication, event audit protection, delivery lifecycle, and Phase 1–3 behavior. Do not alter provider calls or configuration.
- Explicitly excluded paths and systems: Planning/governance docs other than this packet; models, migrations, controllers, provider adapters/configuration, credentials, ECPay/patron flows, runtime timer/scheduler activation, deployment, production data, real webhooks/API/CLI/payment/customer/invoice/subscription activity, DOCX/client work, staging/commit/push.
- Required checks and expected evidence:
  - focused service, lifecycle-job, webhook integration, and registration-gate tests covering verified success, failure/action-required, overdue, grace, day-37 freeze, later-paid recovery, replay, invalid/missing signature, cross-tenant metadata, and missing-entitlement compatibility;
  - Ruby syntax for edited Ruby paths;
  - `git diff --check`;
  - no network/provider call or secret inspection.
- Evidence sources and status:
  - Observed: `StripePlatformBillingEventIngest` verifies/matches/deduplicates before `PlatformBillingLifecycle` transitions; lifecycle has `overdue -> grace -> frozen`; signed webhook controller delegates to the ingest service.
  - Observed: Phase 1 `PlatformBillingEntitlementTransition` validates temple/delivery/event context and writes entitlement audit inside a transaction; `Temple#registration_intake_frozen?` already uses entitlement first and legacy flags only if the row is missing.
  - Configured/documented: real provider, webhook, scheduler, and deployment work are excluded by the accepted plan.
- First blocked surface, if known: none.

## Incident-Correction Placement

- Is this an incident correction? No; it is the accepted product-local Phase 4 implementation.
- Selected surface: bounded Rails service and test paths only.
- `AGENTS.md` excluded unless explicit Director authorization is recorded: excluded.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no.
- Eligibility confirmed before selecting a model: yes; one ephemeral Implementer is required.
- Luna disqualifiers checked: availability, cost, mechanical simplicity, and rejection do not qualify.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra/high`.
- Selection reason and lowest-sufficient configuration: this bounded task changes transaction boundaries across signed-event deduplication, lifecycle timing, idempotent entitlement recovery, and cross-tenant protections. Terra/high is justified; it is not a Handoff.
- Ephemeral allocation: justified `gpt-5.6-terra/high`; Luna is never ephemeral.
- One ephemeral Implementer task: implement only the scope above and return evidence.
- Return destination: this Control directly.
- Implementer boundaries: owned paths only; no acceptance, staging, commit, merge, push, deploy, approval handling, secret access, external mutation, or scope expansion.

## Control Review And Closeout

- Conformance review against the frozen plan: verify all frozen Phase 4 criteria against the diff and required local tests.
- Acceptance decision and rationale: accepted. The verified-event transaction now records the matched event, delivery outcome, entitlement activation, and audit together; lifecycle freeze writes delivery and entitlement suspension transactionally. Failure/action-required keeps entitlement unchanged, and the existing central entitlement-first gate retains explicit missing-row legacy compatibility. The review found no scope expansion or external action.
- Integration, staging, and commit evidence when accepted: Control reran the focused Rails suite (26 runs, 183 assertions, 0 failures/errors/skips), Ruby syntax for all seven edited Ruby paths, and `git diff --check`; local commit pending this closeout record.
- Terminal packet to Planning: send one immutable result after local commit.
- Residual risk, production gap, and next owner: live provider/webhook/scheduler/first-tenant activation remain Phase 5 or separately authorized external work, owned by Planning/Director workflow.
- Authority confirmation: Planning reported and froze product criteria; Strategy owns any cross-repository policy and the Director accepts it.
