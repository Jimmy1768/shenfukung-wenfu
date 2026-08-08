# Control B Implementation Packet — Billing Consistency Cleanup

## Identity

- Accepted-plan path and frozen criteria: `/Users/jimmy1768/Projects/shengfukung-wenfu/ops/docs/plans/FIRST_TENANT_BILLING_ENTITLEMENT_AND_REGISTRATION_GATE_PLAN.md`, Post-Acceptance Local Consistency Cleanup dispatched by Planning.
- Control task and authority state: Wenfu Control B; ordinary reversible local cleanup authorized directly by Planning.
- Repository, worktree, branch, and base HEAD: `/Users/jimmy1768/Projects/shengfukung-wenfu`; same; `main`; `2a63687cc3b7e29ac58a47f93aa203841bb562af`.
- Packet status and date: frozen for one ephemeral Implementer, 2026-08-08.

## Scope

- Objective: Remove inactive legacy price/interval defaults and make the owner/admin billing presentation respect the already-authoritative entitlement state without changing billing collection, provider, or historical-record semantics.
- Exact owned editable paths:
  - `rails/app/models/temple.rb`
  - `rails/app/forms/admin/payment_methods_form.rb`
  - `rails/test/models/platform_billing_entitlement_test.rb`
  - `rails/test/integration/admin/payment_methods_test.rb`
  - `rails/test/services/billing/stripe_payment_method_setup_test.rb`
  - this packet, only for Control closeout after acceptance.
- Required behavior:
  - Remove only unused legacy `300_000` monthly, `12` interval, and annual-fee defaults/constants. Keep `Billing::PlatformPricingPolicy` and current fixed form display amounts (`NT$1,500` monthly; `NT$10,000` onboarding) unchanged.
  - Preserve `StripePaymentMethodSetup` raw persisted-settings annual-record detection exactly, including its rejection behavior.
  - `Temple#platform_billing_state` must use an existing entitlement before legacy delivery/settings presentation: `pending_setup` yields `setup_needed`; `suspended` yields `frozen`; `active` continues to yield the truthful delivery-derived monthly status. A missing entitlement retains its existing legacy result.
  - Existing payment-method form/view state mapping must consume that model state without new presentation concepts or copy changes. Do not alter the entitlement-first intake gate.
- Explicitly excluded paths and systems: Planning/governance docs other than this packet; migrations/schema; controllers/views/locales; price policy; Stripe/ECPay configuration, catalog/binding, credentials, provider calls, webhooks, scheduler, deployment, production data, target/client activation, external mutation, staging/commit/push.
- Required checks and expected evidence:
  - focused model, payment-method integration, setup-service compatibility, lifecycle presentation regressions as necessary;
  - Ruby syntax for changed Ruby paths;
  - `git diff --check`;
  - proof for pending historical identifiers, suspended/active state, missing-row legacy result, and raw-settings annual rejection.
- Evidence sources and status:
  - Observed: `Billing::PlatformPricingPolicy::BASE_FEE_CENTS` and current form display use `150_000`; model/form legacy 300_000/annual defaults have no active call sites. Existing legacy annual protection reads raw `billing_settings` directly.
  - Observed: current `platform_billing_state` ignores entitlement, allowing a pending adopted temple with historical Stripe fields to appear current.
  - Documented: all provider/runtime/live work is excluded by Planning's cleanup dispatch.
- First blocked surface, if known: none.

## Incident-Correction Placement

- Is this an incident correction? No; this is an accepted local product consistency cleanup.
- Selected surface: bounded Rails model/form behavior and tests.
- `AGENTS.md` excluded unless explicit Director authorization is recorded: excluded.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no.
- Eligibility confirmed before selecting a model: yes; one ephemeral Implementer is the required default.
- Luna disqualifiers checked: availability, cost, mechanical simplicity, and rejection do not qualify.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra/medium`.
- Selection reason and lowest-sufficient configuration: a narrow, testable model/form precedence repair with explicit frozen behavior; medium is sufficient.
- Ephemeral allocation: `gpt-5.6-terra/medium`; Luna is never ephemeral.
- One ephemeral Implementer task: implement only the scope above and return evidence.
- Return destination: this Control directly.
- Implementer boundaries: owned paths only; no acceptance, staging, commit, merge, push, deploy, approval handling, secret access, external mutation, or scope expansion.

## Control Review And Closeout

- Conformance review against the frozen plan: verify exact behavior, raw-settings annual compatibility, and no pricing/provider scope expansion.
- Acceptance decision and rationale: accepted. Only unused legacy 300_000/12/annual defaults were removed. Adopted pending and suspended temples now present their durable entitlement state before historical Stripe identifiers or monthly deliveries, active temples retain delivery-derived presentation, and missing-entitlement temples retain legacy presentation. The raw persisted annual-record guard is unchanged and explicitly tested.
- Integration, staging, and commit evidence when accepted: Control independently reran `bin/rails test test/models/platform_billing_entitlement_test.rb test/integration/admin/payment_methods_test.rb test/services/billing/stripe_payment_method_setup_test.rb test/services/billing/platform_billing_lifecycle_test.rb` (27 runs, 163 assertions, zero failures/errors/skips); Ruby syntax for all five edited Ruby paths and `git diff --check` passed. Local commit pending this closeout record.
- Terminal packet to Planning: send one immutable terminal packet after local integration.
- Residual risk, production gap, and next owner: live first-tenant activation remains separately deferred.
- Authority confirmation: Planning froze product criteria; Strategy owns any cross-repository policy and the Director accepts it.
