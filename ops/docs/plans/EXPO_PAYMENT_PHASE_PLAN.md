# Expo Payment Phase Plan

Status: separately deferred payment surface and lifecycle; not part of core V1
and not current implementation authority

Created: 2026-08-11

Owner: Wenfu Planning

Core-track predecessors: `ops/docs/plans/EXPO_ACCOUNT_JSON_API_TRACK_PLAN.md`
and `ops/docs/plans/EXPO_NATIVE_CLIENT_INFRA_TRACK_PLAN.md`

## Objective

Plan and implement the native account payment surface only after core account
registration behavior is stable. Core V1 can create and test registrations
without checkout, and can present already-paid fixtures without performing or
simulating payment.

## Entirely Deferred Surface

- account payment history and payment-detail fields;
- registration payment status polling;
- checkout start and system-browser/native return;
- pending, completed, failed, cancelled, interrupted, duplicate, and retry
  lifecycle handling;
- ECPay callback/correlation behavior used by account registrations;
- any Stripe behavior that is actually part of an account-user payment flow;
- provider-safe diagnostics, receipts, monitoring, rollback, and staged
  validation required by the selected provider path.

Stripe platform billing is an admin/web concern and does not enter the account
app merely because Stripe exists elsewhere in Wenfu. Before this phase is
accepted for implementation, Planning must inventory the exact provider and
account-route mapping rather than assuming both providers belong in every
registration flow.

## Relationship To Core V1

- Core V1 may create registrations that need no payment.
- A payment-required registration may stop at a truthful unpaid/pending state.
- Local/test data may contain an already-paid registration so the registration
  UI can display paid state.
- A paid fixture is not provider, callback, receipt, reconciliation, settlement,
  refund, accounting, or production evidence.
- Core V1 contains no payments menu, checkout button, status poller, provider
  reference, or transition that claims money moved.

## Provider And Release Boundary

No real ECPay/Stripe credential, merchant/customer change, checkout, callback,
refund, money movement, provider-console action, production data, deployment,
or store/release action is authorized by this plan. Local/stubbed evidence must
remain explicitly non-provider and non-accounting evidence.

## Immutable Acceptance Criteria

Before later payment implementation can be accepted:

1. The exact existing Rails account payment and registration state machine is
   mapped without introducing IAP or a new provider behavior.
2. Native checkout/return/status behavior has explicit correlation,
   interruption, cancellation, idempotency, duplicate, and retry rules.
3. Account-safe serializers expose no unnecessary provider or accounting
   reference.
4. Tenant, registration ownership, lifecycle, callback, and replay protections
   remain server-authoritative.
5. Local/stubbed acceptance makes no claim about credentials, callbacks,
   settlement, refunds, accounting, production, or release readiness.
6. Any live provider validation uses a separately authorized provider-safe
   workflow.

## Current Gate

The entire payment surface/lifecycle is deferred. It does not block the dummy
development client, native email session, core account CRUD, or V1 UI
refinement.
