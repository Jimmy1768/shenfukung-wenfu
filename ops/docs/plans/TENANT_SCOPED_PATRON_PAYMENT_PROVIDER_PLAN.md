# Tenant-Scoped Patron Payment Provider Plan

Status: accepted for implementation

Accepted: 2026-08-13

Owner: Wenfu Planning

Parent roadmap:
`ops/docs/plans/SHENGFUKUNG_PAYMENT_AND_OFFERING_PHASE_ROADMAP.md`

## Objective

Replace global patron-checkout selection with a tenant-scoped provider
contract so Shengfukung can deterministically use the fake adapter while a
future real temple can independently use ECPay.

## Observed Defects

- `Payments::ProviderResolver.current_provider` reads only the process-wide
  `PAYMENTS_PROVIDER` value/default.
- Account and admin checkout entry points therefore cannot select different
  providers for different tenants in the shared backend.
- `Payments::RefundService` resolves an adapter without passing the payment's
  temple, which loses tenant-owned ECPay configuration.
- The Shengfukung source profile does not state its intended fake patron-
  checkout provider.

## Immutable Provider Contract

1. Each temple has one nonsecret patron-checkout provider selection, limited
   to `fake` or `ecpay`, stored through the existing
   `payment_provider_settings` boundary without a schema migration.
2. Resolver precedence is: explicit historical/payment provider argument;
   tenant-scoped configured selection; existing process-level
   `PAYMENTS_PROVIDER` compatibility fallback; environment default.
3. The environment default remains `fake` in Rails test and `ecpay` otherwise.
   An invalid tenant or environment value fails closed and never silently
   selects another provider.
4. `shengfukung-wenfu` source configuration selects `fake`. Temple bootstrap
   applies that nonsecret selection idempotently while preserving existing
   provider credentials, billing settings, profile fields, and admin work.
5. Account and admin checkout display/start/fallback paths resolve from the
   current temple. A created payment persists the resolved provider, and later
   return, retry, refund/cancel, and webhook processing remain bound to that
   recorded provider and temple even if the tenant default later changes.
6. Every adapter construction that may need tenant-owned configuration receives
   the exact payment/registration temple, including refund/cancel.
7. Webhook provider and tenant correlation stays explicit and fail closed.
   Provider switching cannot make a historical callback cross tenants or use
   another tenant's credentials.
8. The fake provider remains visibly test-only and network-free. Selecting it
   for Shengfukung creates no ECPay request and no production/provider claim.
9. ECPay credential storage, redaction, signature verification, callback
   behavior, and the global compatibility fallback remain intact.
10. Stripe platform billing is outside this selector and must remain
    unaffected.

## Implementation Boundary

Control B owns this phase. It may change the smallest Rails tenant profile,
bootstrap, provider resolver, checkout/refund/controller, and focused test
surfaces required by the contract. No schema migration is authorized.

Control B must not change:

- qualifying-registration accounting, statement pricing, adjustments, or
  platform-billing lifecycle;
- offering templates/prices, Expo/Vue surfaces, ECPay adapter protocol,
  credentials, provider consoles, external callbacks, or real payment state;
- Stripe configuration or behavior; or
- deployment, production data, release refs, timers, secrets, or external
  systems.

## Required Evidence

- Two tenants simultaneously resolve `fake` and `ecpay` without process-env
  switching or cross-tenant credential use.
- Explicit recorded provider beats a later tenant-default change.
- Invalid tenant/environment selections fail closed.
- Shengfukung bootstrap selects fake and repeated bootstrap preserves secrets,
  billing data, profile/admin work, and the selection.
- Account and admin display/start/return/retry paths use the tenant provider.
- Refund/cancel and webhook paths retain exact tenant/provider context.
- Fake mode performs no network request; ECPay tests remain stubbed/local.
- Existing account/admin checkout, payment-method form, ECPay adapter,
  webhook/idempotency, cash, reporting, and provider-resolver regressions.
- Ruby syntax and `git diff --check`.

## Acceptance Criteria

The phase is complete only when all ten provider rules are implemented and the
required evidence passes with no provider/external call. Control B commits one
accepted immutable pre-integration checkpoint on its isolated branch and sends
one terminal packet to Wenfu Planning. It does not merge canonical `main`
during this parallel track.

## Next Step

Planning waits for both this Phase 2 terminal and the parallel Phase 1 terminal
before authoring the shared integration continuation through Control A and the
later Phase 3 plan. Control B does not coordinate directly with Control A.
