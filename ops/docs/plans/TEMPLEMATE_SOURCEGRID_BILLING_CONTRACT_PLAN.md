# TempleMate SourceGrid Billing Contract Plan

Status: Wenfu planning criteria frozen; cross-repository contract decision pending

Owner: Wenfu Planning

Affected planning owner: SourceGrid Planning

Date: 2026-08-03

## Purpose And Current State

Define Wenfu's planning requirements for the later contract that connects a
closed TempleMate platform-billing statement to SourceGrid's provider-owned
billing path. This is a cross-repository contract and authority question; its
route is `Wenfu Planning -> OperatorKit Strategy -> SourceGrid Planning`.
It is not a Control packet and authorizes no application, database, Stripe,
account, customer, subscription, invoice, payment, refund, tax, deployment, or
external-system action.

Committed Wenfu source at `7315beb4a7272a17cd4793959ea7536e4c42bfef`
contains the local pricing policy, Asia/Taipei monthly meter, immutable
statement and adjustment records, and owner-only statement view. Those local
surfaces establish Wenfu's registration/refund and closed-statement semantics;
this plan neither re-accepts that implementation nor changes it.

SourceGrid Planning's reported live catalog evidence is recorded in
`ops/docs/plans/TEMPLE_PLATFORM_USAGE_PRICING_IMPLEMENTATION_READINESS.md`.
SourceGrid owns the active Product/Price catalog and provider binding. Wenfu
does not hold SourceGrid credentials or direct catalog-write authority.

## Frozen Wenfu Contract Criteria

1. Wenfu is authoritative for tenant-scoped registration/refund event meaning,
   Asia/Taipei billing-period boundaries, progressive pricing calculation,
   post-close adjustment calculation, and the closed immutable platform
   statement. The Stripe Price does not count registrations or close periods.
2. A billable handoff candidate exists only after a Wenfu statement is closed.
   It must carry a durable statement identity, temple-scoped opaque external
   reference, pricing-policy version, currency, period start/end, registration
   count, component amounts, adjustments, final total, and idempotency/replay
   identity. It must not expose credentials, payment-method data, or unrelated
   customer or tenant data.
3. SourceGrid is authoritative for mapping an accepted contract record to its
   customer/billing identity, active Stripe Product/Price, merchant-of-record
   posture, tax review, provider event handling, and every provider mutation.
   Wenfu must not infer payment, entitlement, invoice, or subscription state
   from catalog existence or a local statement alone.
4. The joint contract must define acknowledgement, idempotent delivery/replay,
   duplicate suppression, failure visibility, correction timing, and the
   relationship between a later Wenfu adjustment and an already delivered
   statement. Historical Wenfu statements remain immutable; corrections are
   separate durable adjustments.
5. The joint contract must distinguish the one-time setup fee from recurring
   period usage and specify whether, when, and under which separately approved
   event either may become a SourceGrid billing request. It may not create a
   customer or provider action merely because a temple record, catalog object,
   or local statement exists.
6. Tenant isolation, owner/admin authority, assisted onboarding, user-work
   protection, payment/accounting separation, secret handling, and historical
   evidence remain mandatory. A platform statement is never a temple patron
   payment, temple revenue record, or substitute for provider settlement.

## Decisions Requested Through Strategy

SourceGrid Planning and Strategy must resolve, in their respective sources of
truth, before any implementation packet:

- the versioned contract owner and canonical record/transport boundary;
- the opaque stable identity mapping between a Wenfu statement and
  SourceGrid's customer/billing path;
- the exact acknowledgement, retry, reconciliation, and late-adjustment
  protocol;
- the SourceGrid binding from the contract to the active setup and graduated
  monthly catalog entries, including when a provider mutation is separately
  authorized; and
- the customer notice, due, overdue, grace, and freeze authority boundary.

Exact transport, provider API shape, SourceGrid credential/role details, tax
treatment, customer creation, and live billing behavior are unknown here and
must not be inferred from the catalog evidence.

## Acceptance Gates And Blocker

Planning may mark this contract phase ready only when SourceGrid Planning has
an accepted matching contract record and Strategy confirms the cross-repository
authority/sequencing boundary. The agreed contract must prove that a closed
Wenfu statement cannot cross tenant boundaries, be delivered twice as a charge
request, or silently alter historical usage; it must also preserve all existing
SourceGrid catalogs.

After that acceptance, any Wenfu-local implementation requires a separate
accepted plan and ordinary `Planning -> authoritative Control -> ephemeral
Implementer` packet. Any provider operation needs its own explicit authority.

Current first blocker: no accepted cross-repository billing contract defining
how Wenfu's finalized immutable period total reaches the SourceGrid-owned
billing path.

## Boundaries

Do not push, deploy, publish, access provider credentials or secrets, mutate a
provider, create customers, activate billing, change payment/accounting data,
or alter production data under this plan. No product/runtime phase is opened by
this planning record.
