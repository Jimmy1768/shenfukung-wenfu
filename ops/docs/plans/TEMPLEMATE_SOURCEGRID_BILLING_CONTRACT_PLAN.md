# TempleMate Phase 3 Billing Handoff Readiness Plan

Status: Wenfu-local Phase 3 criteria frozen; implementation deferred

Owner: Wenfu Planning

Date: 2026-08-03

## Purpose And Current State

Define the next TempleMate planning phase after the local usage-billing
foundation. This is Wenfu-only planning. SourceGrid's completed Stripe catalog
creation is recorded here only as catalog evidence; this plan requests no
SourceGrid decision, reply, task, credential, provider action, or implementation.

Committed Wenfu source at `7315beb4a7272a17cd4793959ea7536e4c42bfef`
contains a local pricing policy, Asia/Taipei monthly meter, immutable
statement/adjustment records, and owner-only statement view. The existing
direct Stripe setup path remains a separate legacy annual-subscription flow and
must not be changed or treated as monthly usage collection under this plan.

The SourceGrid-owned active catalog entries recorded in
`ops/docs/plans/TEMPLE_PLATFORM_USAGE_PRICING_IMPLEMENTATION_READINESS.md`
are not a Wenfu billing integration. Their existence does not create a
customer, subscription, invoice, charge, entitlement, payment truth, or right
to use a provider.

## Frozen Local Criteria

1. Wenfu remains authoritative for tenant-scoped registration/refund event
   semantics, Asia/Taipei billing periods, progressive pricing, post-close
   adjustments, and closed immutable platform statements. A catalog Price does
   not count registrations or close a Wenfu period.
2. Any future billing-ready local record may be derived only from a closed
   statement. It must retain a durable statement identity, opaque temple
   reference, pricing-policy version, currency, period boundaries, registration
   count, component amounts, adjustments, final total, and replay identity. It
   must not include credentials, payment-method data, or unrelated customer or
   tenant data.
3. The one-time setup fee and recurring usage total remain separate concepts.
   Neither becomes a customer, provider, or collection request merely because a
   temple, catalog object, or local statement exists.
4. The existing Stripe annual-subscription setup, payment-method flag, and
   grace behavior remain unchanged. A local statement alone is not invoice,
   payment, overdue, grace, frozen, settlement, or entitlement truth.
5. Historical statements remain immutable. Any later cancellation, failure, or
   refund correction stays a separately visible local adjustment; it must not
   rewrite a prior statement or broaden temple financial access.
6. Tenant isolation, owner/admin authority, assisted onboarding, user-work
   protection, payment/accounting separation, secret handling, and historical
   evidence remain mandatory.

## Deferred Implementation Shape

If the user later explicitly authorizes a bounded Wenfu implementation, the
first candidate is a local-only billing-handoff representation and deterministic
fixtures derived from closed statements. It must have no provider client, no
environment credential, no SourceGrid request, no customer creation, no
catalog mutation, and no change to temple patron payments or accounting.

Any later provider binding, billing delivery, customer identity mapping,
acknowledgement/retry protocol, tax treatment, payment status, notice, due,
overdue, grace, or freeze behavior requires a separate explicit decision and
plan. Nothing here selects those mechanisms.

## Acceptance Gate And Blocker

This planning phase is complete when the local criteria above are recorded and
the catalog evidence remains clearly separated from billing behavior. A future
ordinary implementation requires a separate accepted Wenfu plan and
`Planning -> authoritative Control -> ephemeral Implementer` packet.

Current blocker: no user authorization for a bounded local Phase 3
implementation. No external or SourceGrid action is needed to maintain this
planning state.

## Boundaries

Do not push, deploy, publish, access provider credentials or secrets, mutate a
provider, create customers, activate billing, change payment/accounting data,
or alter production data under this plan. No product/runtime phase is opened by
this planning record.
