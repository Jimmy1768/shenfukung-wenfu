# Tenant-scoped patron payment provider — Control packet

## Immutable identity

- Accepted plan/base: `ops/docs/plans/TENANT_SCOPED_PATRON_PAYMENT_PROVIDER_PLAN.md` at `75e16f5fa2e53cc8afa56819f7f1a3981246b210`.
- Parent roadmap: `ops/docs/plans/SHENGFUKUNG_PAYMENT_AND_OFFERING_PHASE_ROADMAP.md`.
- Control B `019fe020-e92e-7770-984f-b59acd547ab0` to Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Worktree/branch: `/private/tmp/shengfukung-wenfu-tenant-scoped-patron-payment-provider`; `codex/tenant-scoped-patron-payment-provider`.
- Packet/attempt: `2026-08-13-tenant-scoped-patron-payment-provider-control-b`, attempt 20.

## Bounded implementation authority

- Control: `gpt-5.6-terra/high`. One Implementer: `gpt-5.6-terra/high`, warranted by tenant-isolated retained payment state across resolver precedence, checkout creation/returns, refunds/cancels, and webhook correlation; the frozen semantics require careful cross-tenant/idempotency review.
- Expected owned source paths: `rails/app/services/payments/provider_resolver.rb`, `rails/app/services/payments/refund_service.rb`, `rails/app/controllers/account/registrations_controller.rb`, `rails/app/controllers/admin/payments_controller.rb`, `rails/db/seeds/temples.rb`, and `rails/db/temples/shengfukung-wenfu.yml`.
- Expected owned focused tests: `rails/test/services/payments/provider_resolver_test.rb`, `rails/test/services/payments/refund_service_test.rb`, `rails/test/services/temples_bootstrap_test.rb`, `rails/test/integration/account/registration_payment_flow_test.rb`, `rails/test/integration/admin/payments_flow_test.rb`, `rails/test/integration/api/v1/payment_webhooks_test.rb`, plus exact test counterparts required by an owned controller/service change.
- Implement tenant stored nonsecret `fake|ecpay` through existing `payment_provider_settings`; precedence is recorded provider, tenant choice, existing process compatibility, then environment default. Reject invalid tenant/environment selection; historical payment provider/temple stays authoritative across returns/retry/refund/cancel/webhook.
- Shengfukung profile bootstrap must set fake idempotently while preserving existing credentials, billing settings, profile/admin work. Fake stays network-free and Stripe platform billing untouched.
- No schema/migration, offering/accounting/statement/template/price, ECPay protocol/credential/provider action, Stripe, Expo/Vue, deployment/production/release/timer/push/external change, or canonical-main merge.

## Required checks/evidence

- Two tenant resolution and credential isolation; precedence/invalid fail-closed; bootstrap preservation/idempotency; account/admin start/display/return/retry; refund/cancel and webhook context; fake no-network; existing relevant payment, ECPay, cash/reporting/provider regression suites; Ruby syntax and diff check.
- Pre-integration terminal only: accepted isolated commit/clean branch, canonical main unchanged/clean, exact path/check evidence, first blocker if any, and direct packet to Planning.

## Result matrix

| Evidence | Status | Safe result |
| --- | --- | --- |
| Resolver, tenant settings, precedence, invalid fail-closed | passed | `patron_checkout_provider` accepts only resolver-recognized fake/ecpay values. Explicit recorded provider resolves before tenant selection, then existing process compatibility/default. Two concurrent temples resolve FakeAdapter and EcpayAdapter without environment switching; invalid tenant selection, invalid process fallback, and invalid temple context raise instead of selecting another provider. |
| Bootstrap source profile and retained provider context | passed | Shengfukung profile records nonsecret fake selection. Bootstrap merges that key idempotently into existing provider settings and preserves ECPay credential values, Stripe billing data, unrelated admin work, profile metadata, and existing record state. Historical payment provider remains the controller source for return/retry even after tenant selection changes. |
| Account/admin/refund/cancel/webhook tenant context | passed | Account/admin display/start use the current temple choice for new checkout and recorded provider for existing payment paths. Refund/cancel pass `payment.temple` to adapter resolution. Existing webhook path remains explicitly temple/provider scoped; focused cross-tenant callback proof leaves the other temple's payment untouched. |
| Focused regressions, syntax, diff, isolated checkpoint | passed | Local Rails payment/provider/ECPay/account/admin/webhook/cash/reporting regression command passed 78 runs/450 assertions. Five changed Ruby sources passed syntax checks; diff check passed. Fake-provider tests remained local/network-free and ECPay behavior stayed stubbed. |

## Terminal closeout

- Classification: `tenant_scoped_patron_payment_provider_complete`.
- Continuation disposition: `accepted_frozen_outcome`.
- Accepted isolated checkpoint: pending Control commit at packet creation; recorded in the terminal delivery.
- Canonical-main state: intentionally unchanged; this is the required pre-integration parallel-track checkpoint.
- Boundary confirmation: no schema/migration, qualifying-accounting/statement, offering/price/template, ECPay/Stripe credential or provider action, Expo/Vue, deployment, production data, release/timer/push, or external action occurred.
