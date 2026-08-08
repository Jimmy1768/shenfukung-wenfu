# First-Tenant Billing, Entitlement, And Registration Gate Plan

Status: Director accepted — real-client intake deferred; local entitlement/billing implementation authorized

Product authority: Director

Control owner: Wenfu Control B

Date: 2026-08-08

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Observed base: `cb112f6`

## Purpose

Prepare a controlled first-tenant path that makes the following sequence true
in product behavior, rather than only in owner-facing copy:

1. An operator converts the temple's offerings DOCX into the reviewed Wenfu
   offering intake format.
2. The owner configures ECPay.
3. The owner pays the one-time `NT$10,000` Stripe onboarding fee and supplies
   the payment method used for recurring platform charges.
4. Wenfu records a durable active entitlement before registrations become
   available, and an operator creates the approved offerings.
5. Wenfu closes and collects monthly statements automatically, retains the
   documented failed-payment path, and consistently gates registration/payment
   intake when entitlement is no longer active.

This is a new follow-on plan. It does not rewrite the completed
`PLATFORM_BILLING_MONTHLY_AUTOPAY_CORRECTION_PLAN.md`, whose scope was
presentation only.

## Authority And Safety Boundary

Planning owns this committed plan and its frozen criteria. Ordinary work routes
`Planning -> Wenfu Control B -> one ephemeral Implementer`; Planning neither
dispatches nor monitors an Implementer, and Control does not author or reopen
this plan. A committed accepted plan is execution authority for ordinary,
reversible, local, in-scope work. No repeated Director approval is needed
between the authorized local phases below.

This plan authorizes local implementation only. It does not authorize a live
provider call, timer enablement, deployment, production migration or data
change, or an external payment action.

The following remain outside this plan's implementation authority unless a
separate approved first-tenant activation packet names the target, commit,
rollback, verification, and monitoring boundaries:

- accessing or changing Stripe/ECPay credentials, webhook configuration,
  catalog/products/prices, merchant settings, customers, invoices,
  subscriptions, or payment methods;
- moving money, testing against a real Stripe event, or enabling provider
  collection against a live tenant;
- enabling the installed scheduler units, deployment, production migration, or
  production-data changes;
- legal, tax, accounting, invoicing, or settlement assertions.

No raw provider payload, card data, or temple/customer personal data belongs in
fixtures, logs, screenshots, or this plan.

## Execution Authority And Stop Conditions

Phases 1 through 4 and Phase 5 local acceptance are authorized in sequence.
After Planning accepts an immutable Control terminal packet for one phase, it
sends the next committed frozen phase directly to Control B immediately unless
one of these actual stop conditions prevents that next phase:

1. a design or product decision is absent from, or contradicts, this plan;
2. an external/provider/secret/deployment/production-migration/timer/account/
   payment action is required but not explicitly authorized;
3. dirty overlapping user work or an ambiguous canonical checkout exists; or
4. a current, undeferred frozen criterion is unmet and prevents a named next
   action.

A deferred real-client intake, future live activation, later provider event,
or other independent dependency is not a blocker to the authorized generic
local phase. Any claimed blocker must name the exact criterion, current
evidence, first prevented action, and why no authorized independent work can
continue.

## Decisions Captured From The Director

| Topic | Frozen direction |
| --- | --- |
| Onboarding amount | `NT$10,000` is a one-time Stripe onboarding fee, not a legacy or annual charge. |
| Recurring charge | Charge the normal `NT$1,500` first monthly base fee, then continue monthly automatic collection using the configured Stripe monthly Price. |
| Grace behavior | Preserve the current lifecycle: seven days overdue followed by a 30-day grace window; the current implementation freezes on day 37 after a failed collection. Do not describe this as a 30-day total window. |
| Waiver policy | Do not silently waive month one or distort registration tiers. A future promotion requires an explicit, auditable credit/adjustment design and is out of this first-tenant path. |
| Offering activation | Offerings are created only after the DOCX intake is reviewed, ECPay is configured, Stripe onboarding has completed, and the entitlement is active. |

### First-month charge: rationale

Charging the first month's normal base fee keeps the published pricing,
registration counts, statement totals, Stripe invoice amount verification, and
support story aligned. A waiver is possible as a separate product decision,
but the existing `PlatformBillingAdjustment` model is tied to a source
statement and usage record; it is not a safe general promotional-credit model.
Using it to waive the first month would change its accounting semantics and
could make tier reporting misleading.

## Readiness Evidence

### Confirmed locally

| Area | Evidence | Readiness result |
| --- | --- | --- |
| Offering intake | `ops/docs/reference/onboarding.md` defines a deterministic DOCX-to-YAML operator translation path and validation constraints. | Ready for reviewed intake; no direct DOCX importer is assumed. |
| Offering setup draft | `Offerings::SetupDraftApplier` safely applies reviewed **service** drafts as draft offerings and rejects event drafts. | Service-only controlled path; event creation needs a separately supported path. |
| Stripe onboarding | `Billing::StripePaymentMethodSetup` creates a paid setup Checkout, verifies a completed matching session, persists Stripe customer/payment-method identifiers, marks its setup delivery paid, and audits it. | Local service/test coverage exists; no live checkout proof in this scan. |
| Monthly collector | `Billing::StripePlatformBillingCollection` uses the configured monthly Price and Stripe `charge_automatically`, then verifies Stripe's invoice total against Wenfu's statement. | Collection service exists and is locally tested in isolation. |
| Webhook ingress | The signed endpoint and event ingest check a matching temple/delivery metadata pair, record a deduplicated event, change delivery state, and audit it. | Local simulated signed-event, replay, bad-signature, and cross-tenant tests exist. |
| Failed-payment lifecycle | `Billing::PlatformBillingLifecycle` represents `overdue -> grace -> frozen`; tests assert freeze on day 37 after failure. | Lifecycle state transitions are locally tested. |

### Gaps found by the readiness scan

| ID | Gap | Evidence | Consequence |
| --- | --- | --- | --- |
| R1 | No entitlement exists. | There is no entitlement model or activation/revocation policy. Webhook ingest only changes `PlatformBillingDelivery` status. | A successful setup or monthly payment does not grant a durable, auditable right to register. |
| R2 | Registration enforcement reads a different legacy signal. | `Temple#registration_intake_frozen?` delegates to `online_payments_frozen?`, which reads `billing.payment_method_on_file` and legacy `billing_grace_deadline`; setup completion instead persists `stripe_payment_method_id`, and lifecycle status lives on deliveries. | A `frozen` monthly delivery does not reliably block registrations; a completed setup may not satisfy the old gate. |
| R3 | Monthly close does not collect. | `PlatformBillingMonthlyCloseJob` closes a statement and creates a pending delivery, but has no call site for `StripePlatformBillingCollection.collect!`; its test explicitly asserts no Stripe call. | “Automatic monthly collection” is not end-to-end wired. |
| R4 | Scheduled jobs are not activated. | The runtime reference documents close/lifecycle units as installed but disabled pending an explicit first-tenant decision. | No scheduled collection/lifecycle advance occurs in the documented runtime state. |
| R5 | First-tenant webhook proof is absent. | Tests stub signature verification and event objects; runtime documentation identifies a matching controlled first-tenant event as remaining onboarding proof. | Code behavior is covered locally, but live endpoint/secret/event configuration is unverified. |
| R6 | Event offerings cannot use the draft applier. | `Offerings::SetupDraftApplier` rejects `offering_kind == "event"`. | A DOCX containing events needs the existing event YAML/admin workflow or a separately authorized product extension. |
| R7 | No safe first-month waiver mechanism exists. | Existing adjustments require a source statement and usage record. | Do not implement a waiver by reusing a refund/usage correction primitive. |
| R8 | Billing presentation and enforcement do not share one status authority. | `Admin::PaymentMethodsForm` displays `platform_billing_state`, while registration controllers use the legacy temple flag. | Owner status can say frozen while registration remains available, or the inverse. |
| R9 | ECPay setup is stored, not externally verified. | `Admin::PaymentMethodsForm` considers ECPay configured when merchant ID, HashKey, and HashIV are present; its local tests deliberately prove only secret-safe persistence. | A saved configuration is not evidence that the intended merchant account, callback, or real payment path is operational. |

## Scope Contract

### In scope for the implementation program

- an explicit entitlement state machine, ownership, audit trail, and
  idempotent activation/revocation rules;
- central registration/payment-intake enforcement based on that entitlement;
- the exact onboarding completion and monthly webhook transitions which update
  entitlement;
- an idempotent monthly collection dispatch after the local statement closes;
- supporting owner/admin status copy, localized notices, tests, and runbook
  evidence;
- a controlled first-tenant activation procedure after local acceptance.

### Out of scope unless separately planned

- redesigning Stripe catalog products, creating Stripe subscriptions, or
  changing Stripe/ECPay merchant configuration;
- a generic discount/promotion/credit system;
- automatic DOCX parsing or an event-draft creation feature;
- retroactively changing legacy annual records;
- enabling live timers or provider calls as part of local code acceptance.

## Entitlement Contract To Implement

Create one temple-scoped entitlement record (or equivalently durable,
auditable first-class state) whose source of truth is not a mutable settings
flag. The design must make the following transitions explicit and idempotent:

| Trigger | Entitlement outcome | Notes |
| --- | --- | --- |
| No successful onboarding | `pending_setup` / inactive | ECPay configuration alone never grants registration access. |
| Verified matching onboarding Checkout completion | `active` | Activate only after server-side session verification and setup delivery success. Browser return alone is not sufficient. |
| Monthly delivery paid via a verified matching webhook | remain or become `active` | Must be safe on replay and cannot activate another temple. |
| Monthly delivery failure / overdue / grace | retain active access, with visible billing state | Preserve the current seven-day overdue plus 30-day grace behavior. |
| Lifecycle reaches frozen | `suspended` / inactive | Registration creation and online checkout must be consistently blocked. |
| Later verified payment | restore `active` | Must record the recovery transition and preserve prior billing evidence. |

The selected model and migration must state an explicit treatment for existing
temples. It must not default existing active temples to suspension merely
because a new entitlement row is absent. Since this first-tenant work has no
approved production migration, the backfill/adoption rule remains a release
gate, not an implementation shortcut.

## Phased Implementation

Each phase requires an accepted Control packet with exact owned paths and one
ephemeral Implementer. Planning sends Phase 1 directly to Control B after this
plan commits. After each accepted terminal packet and Planning receipt,
Planning sends the next local phase directly to Control B; it does not pause
for routine reauthorization.

### Phase 0 — Freeze the first-tenant operating contract

Goal: remove ambiguity before changing authority or billing code.

- The real-client offerings DOCX remains deferred because no client exists.
  Its later service/event classification, reviewed YAML conversion, and any
  event workflow remain real-client work and must never be simulated.
- Treat ECPay credential entry as later configuration staging, not
  merchant/payment proof. A future activation packet must name the approved
  provider-side verification and rollback evidence without exposing secrets.
- A future first-tenant activation packet will name the ECPay setup operator,
  Stripe onboarding owner, expected runtime endpoint, and rollback/monitoring
  owner. These target-specific facts are deferred, not prerequisites for the
  generic local phases.
- Freeze the entitlement states and the rule that successful server-side
  onboarding verification—not a redirect—activates access.
- Record the first-month base fee as charged and exclude waiver behavior.

Pass condition: a reviewer can identify the deferred real-client work, the
initial access state, the activation and suspension events, and the later
activation packet boundary without reading implementation code. The deferred
DOCX does not block Phase 1.

## Frozen Generic Contract For Phase 1

Phase 1 implements one durable, temple-scoped billing entitlement authority
with a unique record per temple and the states `pending_setup`, `active`, and
`suspended`.

- `pending_setup` is inactive. A browser return, saved ECPay settings, or a
  mutable temple settings flag cannot activate it.
- `active` is the only entitlement state that permits the newly adopted
  registration/payment-intake gate.
- `suspended` is inactive and is reached only by the specified local billing
  lifecycle transition; an overdue or grace delivery remains active.
- A missing entitlement row is the explicit compatibility state for a
  pre-existing, not-yet-adopted temple. It preserves that temple's current
  behavior and must never silently suspend an existing temple. New first-
  tenant adoption creates `pending_setup` before the new gate is applied.
- A local transition service accepts only an owning temple plus durable billing
  delivery/event context, rejects cross-tenant or invalid context, is
  idempotent, and writes structured audit evidence without provider payload,
  card, or personal data. The local entitlement write and audit write are one
  database transaction; no outbox or provider call belongs in Phase 1.
- Existing annual records, historical statements/deliveries/events, ECPay
  patron flow, and the separate Stripe catalog remain unchanged.

### Phase 1 — Durable entitlement and migration design

Goal: establish one auditable access authority.

- Add a temple-scoped entitlement persistence model with constrained states,
  timestamps/references needed for audit, and tenant-scoped uniqueness.
- Add a transition service that accepts a billing delivery/event context,
  rejects mismatched tenant state, is idempotent, and writes structured audit
  evidence without provider payload/card details.
- Replace only the appropriate legacy registration-gate decision with an
  entitlement query. Preserve legacy billing data and compatibility behavior
  until an explicit migration/adoption policy is accepted.
- Specify and test the safe missing-row behavior for both the new first tenant
  and pre-existing temples.

Pass condition: entitlement cannot be granted by a browser return, a
cross-tenant delivery, an invalid/replayed provider event, or a mutable
boolean; all states and transition evidence are testable locally.

### Phase 2 — Onboarding completion and registration enforcement

Goal: make initial payment produce the intended right and ensure every intake
surface uses it.

- Invoke the approved entitlement transition only after
  `StripePaymentMethodSetup.complete` has verified the matching paid Checkout
  Session and persisted its setup delivery.
- Centralize gating for account registration creation, account checkout, admin
  order checkout, and any other identified intake/online-payment path.
- Preserve staff visibility of historical registrations and offline/cash
  accounting; only the specifically frozen intake/online-payment actions are
  blocked.
- Show an owner/operator-safe suspended explanation without revealing payment
  credentials or provider payloads.

Pass condition: completed setup enables a new registration in focused tests;
pending setup and suspended entitlement block every agreed intake surface;
tenant isolation and existing authorization remain intact.

### Phase 3 — Wire monthly collection to delivery creation

Goal: make the existing automatic collector reachable exactly once.

- Define an idempotent collection dispatcher invoked after a monthly statement
  and pending delivery are successfully created.
- Require a verified Stripe customer/payment method and validated monthly Price
  configuration before dispatch; record a retry-safe local failure without
  silently treating it as paid.
- Preserve statement totals as Wenfu's authority and retain the existing
  Stripe invoice-total mismatch rejection.
- Keep the monthly close job's iteration, tenant isolation, and audit behavior
  safe when one temple fails.

Pass condition: a local job/service test proves one pending monthly delivery
causes one collector invocation, re-running does not create another provider
collection attempt, and failure remains visible/retryable without granting or
revoking entitlement prematurely.

### Phase 4 — Webhook-to-entitlement and lifecycle convergence

Goal: make payment outcomes, grace, and registration access one coherent
state machine.

- On verified matching setup/monthly success events, update delivery and
  entitlement atomically or with a clearly recoverable outbox/reconciliation
  rule.
- On failed/action-required events, retain access through overdue and grace;
  advance entitlement to suspended only when the lifecycle freezes the
  delivery.
- On a later paid event, reactivate entitlement idempotently.
- Remove or isolate the legacy `payment_method_on_file`/
  `billing_grace_deadline` path from registration enforcement only after
  compatibility tests demonstrate no ambiguous dual authority remains.

Pass condition: focused tests cover success, failure, overdue, grace, day-37
freeze, recovery, replay, malformed signature, and cross-tenant metadata;
registration outcomes match entitlement in every case.

### Phase 5 — Local acceptance and first-tenant activation packet

Goal: distinguish local proof from live operational proof.

- Run the complete focused Rails model/service/job/request suite, migration
checks, and `git diff --check`; review owner/admin and account states in the
isolated local environment.
- Produce a separate controlled activation packet that names the exact commit,
  first temple/owner, ECPay/Stripe operator, expected webhook event/delivery
  metadata, scheduler enablement order, rollback, success evidence, and
  monitoring window.
- Under the separately approved activation workflow, verify one matching live
  onboarding event and its local audit/entitlement result before enabling
  recurring timers. Do not infer live readiness from stubs.

Pass condition: local acceptance has durable evidence, and no scheduler or
provider action occurs until a separately approved packet produces the first
matching controlled event.

## Readiness Scan By Phase

| Phase | Ready inputs | Gaps that must close before phase passes | External hold |
| --- | --- | --- | --- |
| 0 | Pricing direction and deferred real-client operating contract | Real client, completed DOCX, target-specific operators and ECPay verification remain deferred | No provider access in this phase; deferred work does not block Phases 1–5 local acceptance. |
| 1 | Billing deliveries, audit logger, tenant relations, lifecycle states | Entitlement schema/state/adoption policy and unified authority | No production migration. |
| 2 | Verified setup service and existing controller gates | Gate must stop reading legacy boolean/deadline; all intake surfaces must be inventoried and tested | No real Checkout required. |
| 3 | Statement closer, pending delivery creator, collector service and its unit test | Missing invoker/retry semantics; define safe configuration failure behavior | No real invoice or timer. |
| 4 | Signed webhook handler, event dedupe, lifecycle tests | Atomic/recoverable delivery+entitlement transition and recovery contract | Live event remains unproven. |
| 5 | Local test seams and runtime reference | Exact first-tenant target, approval, release/rollback/monitoring plan | Provider access/timer enablement require separate approval. |

## Required Regression Coverage

- entitlement state/migration constraints, tenant isolation, transition audit,
  and idempotency;
- verified setup success activates only its owning temple;
- monthly webhook paid/failure/action-required/replay/cross-tenant outcomes;
- lifecycle timing: overdue at failure, grace after day seven, suspended only
  at day 37, then recovery after verified payment;
- account registration creation and checkout, admin order checkout, and any
  gathering/offering path selected in the Phase 0 intake-surface inventory;
- monthly close-to-collector dispatch, one-attempt idempotency, Stripe total
  validation, and isolated temple failure behavior;
- owner/admin display is derived from the same entitlement authority as the
  gate and reveals no secrets, provider payload, or card data;
- legacy annual-record rejection and historical billing data preservation.

## Implementation Start Gate

This committed plan freezes the Phase 1 state/adoption/transaction contract
above, so Phase 1 may begin immediately after Planning sends it to Control B.
The exhaustive intake-surface inventory is Phase 2 work. The real-client DOCX,
target-specific activation owner, provider proof, scheduler enablement,
production migration, deployment, and monitoring boundary are deferred to the
separate first-tenant activation packet; none blocks local Phases 1–5.

The Billing page remains presentation-only proof until the later phases create
and apply entitlement enforcement. This does not authorize a real Stripe
webhook, a live scheduler, or any provider action.

## Execution State

### Phase 1 acceptance

Planning accepted Control B's Phase 1 terminal packet at
`9e89b96062ae216592fd417853a6d93f633f8851` (`feat(billing): add temple
entitlement authority`). The local implementation added the unique durable
temple entitlement, transactional audited transitions, active-only adopted
gate, and explicit missing-row legacy compatibility. Focused Rails evidence
passed: 31 runs, 161 assertions, zero failures/errors/skips; the new migration
is up in the local test database. No provider, secret, timer, deployment,
production-data, or external action occurred.

### Phase 2 acceptance

Planning accepted Control B's Phase 2 terminal packet at
`bc8ec73c8e5067cd5953b5ae604093ae09a874d3` (`feat(billing): activate
entitlement after setup`). The local implementation adopts the new temple into
`pending_setup` only after its existing local setup guards and configuration
validation, then activates it only after server-side verification of the paid
matching Checkout Session and its owning persisted setup delivery. The account
registration and checkout, admin order and checkout, gathering entry, and
account payment presentation now converge on the same entitlement authority;
pending and suspended states block while the explicit missing-row legacy
compatibility remains intact. Focused Rails evidence passed: 62 runs, 400
assertions, zero failures/errors/skips. No provider, secret, timer,
deployment, production-data, or external action occurred.

### Phase 3 acceptance

Planning accepted Control B's Phase 3 terminal packet at
`716d1b05431cd36d8dde12ebae4253ff77377d6c` (`feat(billing): dispatch monthly
collections`). The local monthly-close path now creates or reuses a pending
monthly delivery before dispatching it once. Its dispatcher only attempts a
pending monthly TWD delivery, leaves retry-safe failures pending with bounded
audit evidence, preserves the existing invoice-total mismatch guard, requires
the stored customer/payment-method prerequisites, and isolates one temple's
failure from later temple dispatches. Focused Rails evidence passed: 70 runs,
433 assertions, zero failures/errors/skips. No provider, secret, timer,
deployment, production-data, or external action occurred.

Phase 4 is the next authorized local phase. Its real-client/live activation
dependencies remain deferred and are not a blocker.

The Director authorized execution on 2026-08-08. Phase 0 established that no
real tenant intake is available: the supplied DOCX is a blank four-page
template with no completed offering entries, classifications, prices, dates,
or registration requirements. The Director explicitly deferred this
real-client intake because no client exists, while authorizing generic local
entitlement/billing Phases 1–5. Offering conversion/creation and live
activation remain deferred and must never be simulated as real onboarding.

The later live ECPay and Stripe/webhook verification remains intentionally
outside local implementation authority and will require the separate controlled
activation packet described above.
