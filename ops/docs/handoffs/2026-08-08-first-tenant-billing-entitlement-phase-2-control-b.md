# Control B Implementation Packet — First-Tenant Billing Entitlement, Phase 2

## Identity

- Accepted-plan path and frozen criteria:
  `ops/docs/plans/FIRST_TENANT_BILLING_ENTITLEMENT_AND_REGISTRATION_GATE_PLAN.md`,
  **Phase 2 — Onboarding completion and registration enforcement**, and
  Planning's 2026-08-08 accepted Phase 2 request.
- Control task and authority state: Wenfu Control B; Planning accepted Phase 1
  at `9e89b96062ae216592fd417853a6d93f633f8851` and directly sent this packet.
- Repository, worktree, branch, and base HEAD:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`, canonical worktree, `main`,
  `1645988b0961928a7e39c0be5213d3d691223aa3`.
- Packet status and date: frozen for one ephemeral Implementer, 2026-08-08.

## Scope

- Objective: adopt `pending_setup` as the local Stripe platform setup begins,
  activate only after `StripePaymentMethodSetup.complete` server-verifies and
  persists the owning paid setup delivery, and make all agreed intake/payment
  surfaces reflect the existing central entitlement gate.
- Inventory of agreed surfaces:
  - account registration `new`/`create` through
    `Account::RegistrationsController#ensure_registration_intake_open!`;
  - account registration `start_checkout`;
  - admin offering-order `new`/`create` through
    `Admin::OfferingOrdersController#ensure_registration_intake_open!`;
  - admin payment `start_checkout`;
  - admin gathering registration-entry affordance through
    `Admin::BaseController#admin_registration_entry_enabled_for?`.
  These already use `Temple#registration_intake_frozen?`; do not duplicate a
  second gate or broaden to history, edit, cash, or accounting actions.
- Exact owned editable paths:
  - `rails/app/services/billing/stripe_payment_method_setup.rb`
  - `rails/app/controllers/account/registrations_controller.rb`
  - `rails/app/views/account/registrations/payment.html.erb`
  - `rails/test/services/billing/stripe_payment_method_setup_test.rb`
  - `rails/test/integration/account/registration_payment_flow_test.rb`
  - `rails/test/integration/admin/payments_flow_test.rb`
  - `rails/test/integration/admin/offering_orders_registrant_flow_test.rb`
  - `rails/test/integration/admin/payment_methods_test.rb`
  - this packet's closeout sections only after Control acceptance; no other
    documentation path.
- Exact behavior:
  - `start` first passes the existing legacy/configuration protections, then
    explicitly adopts the owning temple into `pending_setup` before a setup
    Checkout is created. An existing adopted record remains idempotent.
  - `complete` keeps server-side paid-session, temple, and delivery checks;
    after its setup delivery is persisted `paid`, it invokes the Phase 1
    transition service with the owning delivery and state `active` in the same
    local transaction.
  - no redirect, missing checkout-session parameter, settings flag, ECPay
    configuration, or unverified/unpaid/cross-tenant setup can activate access.
  - existing missing-row temples retain legacy behavior. Once adopted,
    `pending_setup` and `suspended` block all inventory surfaces and `active`
    allows them. Account payment presentation must use that central decision so
    it does not present a checkout CTA for an inactive adopted temple.
  - retain safe localized/existing notices; never render provider credentials,
    payment method details, raw provider payload, or personal data.
- Explicitly excluded paths and systems:
  - entitlement migration/model/transition-service changes; controller routes
    and admin order/payment implementation changes; provider configuration,
    webhooks, lifecycle/jobs/timers, collection, ECPay/Stripe catalog binding,
    real Checkout, secrets, deployment, production migration/data, push,
    real-client DOCX, and external mutation.
- Required checks and expected evidence:
  - focused service tests prove start adopts pending, verified matching complete
    activates only the owning temple, and failed/unpaid/mismatched completion
    does not activate;
  - focused request tests prove pending/suspended block, active allows, and
    missing-row legacy behavior remains for account creation/checkout, admin
    order creation, and admin checkout; test the account payment page has no
    checkout CTA while inactive;
  - retain Phase 1 entitlement/model/transition, lifecycle, event-ingest, and
    prior payment-method regressions;
  - Ruby syntax checks and `git diff --check`.
- Evidence sources and status:
  - configured: Phase 1 entitlement/gate at `9e89b96`, setup service, and
    listed controller surface inventory;
  - documented: Planning's committed Phase 2 criteria;
  - observed: Planning base `1645988` is clean and staging empty;
  - unknown: live Stripe/ECPay/timer/first-tenant behavior; excluded.
- First blocked surface: none for this local Phase 2 packet.

## Incident-Correction Placement

- Is this an incident correction? No. This is accepted product/runtime Phase 2.
- Selected surface: existing verified setup service, account presentation, and
  focused local regression tests.
- `AGENTS.md` is excluded; no Director authorization exists to edit it.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no.
- Eligibility confirmed before selecting a model: yes; no exceptional
  continuity reason exists.
- Luna disqualifiers checked: availability, cost, mechanical simplicity, and
  rejection do not qualify.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra/high`.
- Selection reason and lowest-sufficient configuration: this is a bounded but
  cross-surface authorization change linking verified onboarding to existing
  account/admin gates and preserving compatibility. Terra/high is justified;
  Sol is not authorized or needed.
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

- Conformance review against the frozen plan: accepted. Setup adopts only after
  existing guards/configuration validation and before Checkout creation;
  completion activates only after the matching paid setup session and delivery
  persistence. The existing central gate covers every inventoried surface, and
  the account payment page now reflects that same authority.
- Acceptance decision and rationale: accept. The Implementer changed only six
  packet-owned product/test paths. Control independently reviewed activation
  order, cross-tenant/non-paid rejection, inactive presentation, and legacy
  compatibility. The focused Rails suite passed with 62 runs and 400
  assertions; Ruby syntax checks and `git diff --check` passed.
- Integration, staging, and commit evidence when accepted: Control staged only
  the seven packet-owned paths, verified the cached diff, and integrated this
  closeout with the accepted Phase 2 implementation on canonical `main`.
- Terminal packet to Planning: send the accepted commit, checks, final state,
  and residual external boundary directly after integration.
- Residual risk, production gap, and next owner: Phase 3 collection wiring,
  Phase 4 webhook/lifecycle convergence, and live first-tenant activation
  remain excluded.
- Authority confirmation: Planning froze the committed Phase 2 criteria;
  Control owns this packet, review, and local integration.
