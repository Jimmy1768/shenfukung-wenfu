# Shengfukung Web Demo Cash-Only Flow Plan

Status: accepted for direct implementation dispatch to Control A after commit

Accepted: 2026-08-13

Owner: Wenfu Planning

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`3a61cd05ebcc614427150fa723dd962101d157c6`

Parent roadmap:
`ops/docs/plans/TEMPLEMATE_DEMO_READINESS_AND_BETA_DISTRIBUTION_ROADMAP.md`

## Objective

Implement the local Rails/web source contract for the Phase 1 Shengfukung demo
flow. The test tenant must accept patron registrations without Stripe platform
billing or live ECPay, present a truthful online-payment-unavailable/cash-only
state, permit an authorized web admin to record one complete cash settlement,
and include that settled registration in the accepted qualifying-registration
accounting flow.

This is ordinary implementation with no unresolved product decision. It does
not deploy to `shengfukung.com.tw`; exact-target deployment and browser runtime
validation require their own later accepted workflow.

## Accepted Product Contract

1. Shengfukung remains a demo/test tenant with exactly the four already
   accepted `TWD 50` offerings. The ambiguous fifth source row remains disabled
   Planning evidence and is not reopened.
2. “No online provider configured” is an explicit, fail-closed tenant state.
   It is not represented to a patron as fake checkout, ECPay, a failed ECPay
   merchant, platform-billing suspension, or an error condition.
3. A patron may create and view a registration normally. A payment-required
   registration remains `pending` and shows localized Traditional Chinese and
   English guidance that online payment is not available and cash payment can
   be arranged with the temple.
4. The pending/failed presentation exposes no checkout or retry control when
   online checkout is unavailable. Direct account or admin checkout invocation
   also fails before provider resolution, pending-payment creation, audit,
   registration mutation, webhook state, or billing/accounting mutation.
5. Payment-status polling may remain so a patron page can observe a later
   admin-recorded cash completion. It must not manufacture a provider attempt.
6. An admin with `record_cash_payments` authority may record one full cash
   settlement using the registration's authoritative total and currency.
   Partial cash payment and arbitrary-price settlement are outside this demo
   contract.
7. A completed cash settlement creates one completed `manual_cash` payment,
   marks the registration paid, records the existing audit/ledger evidence,
   and qualifies once for platform usage at the accepted persisted completion
   timestamp in Asia/Taipei.
8. Duplicate or concurrent submission for the same already-settled
   registration does not create another cash payment, ledger entry, audit
   event, usage contribution, or adjustment and does not change the
   authoritative amount/currency.
9. The existing fake adapter and its tests remain available for local payment
   engineering. Other tenants' explicit `fake` or `ecpay` selection and
   historical recorded-provider behavior remain unchanged.
10. Absence of Stripe setup does not turn the Shengfukung cash-only demo into a
    provider checkout. This phase does not redesign platform-entitlement
    lifecycle; it only preserves an open demo registration path under the
    accepted tenant state.

## Required Source Result

- Replace Shengfukung's loader-ready patron checkout selection of `fake` with a
  truthful no-online-checkout/cash-only selection or equivalent explicit
  tenant capability.
- Give the provider/checkout boundary a typed availability result so views and
  controllers do not infer availability merely from a provider label.
- Render the unavailable-online-payment state in the account payment view for
  pending and failed registrations, with no provider CTA and no fake/ECPay
  claim.
- Fail closed at every web checkout entry point before retained mutation when
  the current tenant has no online provider.
- Keep the existing admin cash-entry route and permission boundary while
  enforcing authoritative full settlement and single-settlement behavior.
- Preserve paid, refunded, genuinely free, platform-billing-frozen, and
  provider-configured presentation/lifecycle behavior outside the accepted
  cash-only state.
- Preserve the four-offering YAML and disabled-fifth decision unchanged.

Control owns the narrow implementation mechanism and exact packet-owned paths.
Planning does not require a new schema or migration. If Control finds that the
accepted invariants require one, that is a true Planning design/ownership gap
rather than implied authority.

## Required Evidence

### Account web flow

- A Shengfukung/cash-only registration can be created and reaches the payment
  page as pending.
- Both locales show the truthful cash-only/online-unavailable copy.
- The page contains no checkout/retry control or fake/ECPay provider claim.
- A direct checkout POST fails closed with no retained payment, registration,
  audit, webhook, statement, usage, or adjustment mutation.
- The pending page can observe a later legitimate paid transition without
  starting checkout.

### Admin cash settlement

- Correct permission is required.
- Registration amount and currency remain server-authoritative.
- One full cash settlement creates exactly one completed cash payment and
  associated accepted ledger/audit result, marks the registration paid, and is
  visible in account/admin presentation.
- Repeated and direct two-connection concurrent settlement evidence proves one
  durable result with no duplicate financial/accounting side effects.
- Wrong amount, wrong currency, already-refunded/cancelled/ineligible state,
  or foreign-tenant registration fails before mutation.

### Accounting and regression

- The completed cash registration contributes once to the accepted monthly
  qualifying-registration calculation with `completed_cash` evidence.
- Pending, failed, cancelled, and refunded states remain excluded.
- Existing fake and ECPay local/stubbed tests remain green, including tenant
  isolation and historical-provider binding.
- Existing account registration, admin order/payment, reporting, platform
  usage, statement, webhook, and offering configuration tests remain green.
- A guarded full Rails suite runs if the accepted implementation changes a
  shared payment, registration, audit, ledger, or tenant-selection service.
- Ruby/YAML syntax and `git diff --check` pass; final canonical and isolated
  states are clean with staging empty.

## Explicit Exclusions

- No deployment, SSH, production data, shared-development database mutation,
  live tenant mutation, or browser action against `shengfukung.com.tw`.
- No Stripe sandbox/live setup, customer/payment method, price, invoice,
  webhook, grace/recovery, credential, console, or network action.
- No real ECPay merchant configuration, checkout, callback, refund, credential,
  provider console, or money movement.
- No Expo/mobile/Vue visual refinement, native payment surface, provider
  browser, version/build change, EAS, artifact, device, or store work.
- No offering creation, inferred fifth offering, pricing change, platform-
  entitlement redesign, tax/invoice/legal claim, release promotion, push, or
  external mutation.
- No Apple OAuth rollout or user-22 remediation work. That remains an
  independent critical web track.

## Immutable Acceptance Criteria

1. Shengfukung source configuration no longer exposes fake checkout as its
   client-facing payment path.
2. Account registration remains available and payment-required registrations
   stop at a truthful pending/cash-only state.
3. No online checkout/retry action is visible or executable for the cash-only
   tenant, and direct invocation has zero retained side effects.
4. An authorized admin can record exactly one authoritative full cash
   settlement; duplicate/concurrent action remains single-result.
5. The paid transition is visible to the patron/admin and contributes exactly
   once to accepted accounting.
6. Other tenant/provider, free, paid, failed, refunded, frozen, authorization,
   tenant-isolation, audit, reporting, and registration behavior remains
   intact.
7. All required checks pass and no excluded path or external action occurs.

## Sequencing And Terminal Boundary

- Planning commits this plan and sends it directly to Control A.
- Control A records one immutable implementation packet, dispatches one
  ephemeral Implementer, owns bounded conformance repairs and local
  integration, and sends one terminal packet to Planning.
- Acceptance closes the local Phase 1 source contract. It does not claim live
  deployment or meeting-target validation.
- The already approved next phase is development-client demo parity through
  Control B. Planning authors that exact plan only after accepting Phase 1.
- There is no known Planning gap in Phase 2. The first genuine open gap is the
  Director's holistic Phase 3 UI assessment after Phase 2 acceptance.

## Current Gate

Accepted for Control A implementation after commit. First blocker: none.
