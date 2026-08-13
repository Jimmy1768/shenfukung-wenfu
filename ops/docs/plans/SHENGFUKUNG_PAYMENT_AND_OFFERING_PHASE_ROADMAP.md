# Shengfukung Payment And Offering Phase Roadmap

Status: accepted Planning roadmap

Accepted: 2026-08-13

Owner: Wenfu Planning

## Objective

Complete the remaining local payment work without pretending that a real
ECPay merchant account or a complete temple offering worksheet exists. Keep
SourceGrid's Stripe platform billing separate from patron registration
payments, and use the Shengfukung production tenant as a low-value controlled
test tenant only under separately authorized provider-safe packets.

## Fixed Boundaries

- Stripe platform billing charges the temple for TempleMate usage. This
  roadmap validates that higher-priced graduated monthly billing in Stripe
  test mode/sandbox, using Stripe test payment data and no real card or money.
- Patron registration payments are cash or ECPay; Stripe is not the patron
  payment provider in this Taiwan flow. The TWD 50 offering transactions in
  local QA are simulated ECPay/fake-adapter transactions and use no card.
- The existing Stripe graduated Price has already been checked. Do not create
  another catalog-verification gate without changed evidence.
- Real ECPay merchant validation is externally blocked because SourceGrid does
  not have a legally usable merchant identity for this purpose. Local work
  must use the fake-provider boundary and must not claim live ECPay evidence.
- No phase may access credentials, provider consoles, production data, move
  money, issue a real refund, deploy, or change a live tenant without its own
  accepted target-specific authority.

## Offering Decision

The source intake had five rows. Four are sufficiently clear for the controlled
Shengfukung payment work:

1. `incense-donation` — 香油捐獻
2. `lamp-service` — 點燈作業
3. `ghost-festival-table` — 普渡供桌
4. `liberation-ritual` — 拔薦／祖先拔薦

All four use the accepted controlled test price **TWD 50**. This is a test-
tenant product decision, not an unresolved business question. Later Controls
must implement the stated value without reopening currency conversion or
temple-pricing discovery.

### Disabled Fifth Source Entry

Planning marker: **DISABLED — awaiting an updated temple DOCX**.

The original fifth row combined two different apparent offerings:

- 平安戲丁口捐, a household-based contribution; and
- 禮斗法會, a ritual-bucket ceremony with position and registrant data.

The current repository later split that ambiguous row into
`peace-opera-household` and `ritual-bucket-ceremony`. That split is useful
working-draft evidence, but it is not temple approval. Until the temple sends
an updated DOCX that distinguishes the offerings, required fields, lifecycle,
and prices:

- do not activate, sync, seed, sell, price, test, or present either inferred
  half as a confirmed Shengfukung offering;
- do not merge the halves back into one operational form;
- do not use the current six-template YAML or prior “temple-confirmed” wording
  as evidence that the ambiguity was resolved; and
- do not ask a later Codex run to guess again.

`DISABLED` is a Planning/Codex shortcut only. It does not require or authorize
an application schema field, loader feature, migration, runtime flag, or YAML
edit. The only unblocker is a new temple-supplied DOCX followed by a separate
reviewed offering-reconciliation plan.

## Phased Work

### Phase 1 — Qualifying Registration Accounting

Define and implement one authoritative billable-registration event:

- a paid registration qualifies when verified ECPay or admin-recorded cash
  completion occurs;
- a genuinely free registration qualifies when it is accepted;
- pending, failed, cancelled, and fully refunded registrations do not qualify;
- fulfillment status is not the billing criterion;
- the reckoning timestamp uses the qualifying event in Asia/Taipei, not record
  creation time; and
- a later full refund corrects the original monthly aggregate rather than
  repricing a row by its historical ordinal position.

Partial-refund billing semantics remain excluded until explicitly decided.

### Phase 2 — Tenant-Scoped Patron Payment Provider Boundary

Remove reliance on one global provider choice where necessary so the
Shengfukung test tenant can remain on the fake adapter while a future real
temple can use ECPay. Preserve signature, callback, replay, ownership, and
tenant isolation boundaries. This phase performs no live provider action.

Phases 1 and 2 are independent enough for the two Control slots to implement
in parallel on isolated branches. Planning coordinates their later integration
if shared payment or registration surfaces overlap.

### Phase 3 — Four-Offering Controlled Configuration

Reconcile the controlled Shengfukung configuration to the four enabled choices
above at exactly TWD 50 each, and ensure the disabled fifth source entry cannot
enter offering creation or registration evidence. This phase must preserve the
original intake and Git history as evidence.

Phase 3 has no remaining semantic or temple-information decision. Template
reconciliation, source checks, offering creation, authoritative-price tests,
and cleanup are routine implementation/evidence work owned by its later
Control packet.

### Phase 4 — Simulated ECPay Registration QA

Exercise patron- and admin-started registration, the fake adapter's simulated
ECPay-style hosted checkout,
callback/webhook correlation, cash completion, failed/cancelled states,
refund behavior, idempotency, monthly qualification, and reset/cleanup using
only local or disposable data.

Phase 4 has no remaining product-design decision once Phases 1–3 are accepted
and integrated. Its test matrix, fixtures, disposable-data setup, and evidence
collection are routine Control implementation choices. Every TWD 50 payment is
fake-provider state-transition evidence: no card, real ECPay request, or money
movement occurs.

### Phase 5 — Stripe Platform-Billing Lifecycle Validation

Use a separately authorized provider-safe Stripe **test-mode/sandbox** packet
to exercise the temple paying SourceGrid: setup payment, saved test payment
method, graduated monthly reckoning, monthly close, signed test webhook
behavior, failed payment, grace, freeze, recovery, and rollback/monitoring.
Use only Stripe test payment data; no real credit card or money movement is
needed. Do not repeat the already completed graduated-Price configuration
verification absent changed evidence—the remaining work is lifecycle and
reckoning behavior against that Price.

### Phase 6 — Live ECPay Validation

Deferred until a real client supplies a legally usable ECPay merchant account
and authorizes a target-specific provider workflow. Local fake-adapter evidence
does not complete this phase.

## Acceptance And Sequencing

- Each phase requires its own committed accepted plan before implementation.
- Phase 1 and Phase 2 may fan out in parallel.
- Phase 3 uses only the four enabled offering choices recorded here.
- Phase 4 follows the accepted local integration of Phases 1–3.
- Phase 5 is separately provider-gated and may proceed independently when its
  external authority and safe validation mechanism exist.
- Phase 6 remains disabled externally; it does not block Phases 1–5.
- Expo payment UI remains a later phase and consumes accepted Rails/payment
  contracts; it does not redefine them.

## Current Next Action

Wenfu Planning may prepare the separate immutable Phase 1 and Phase 2 plans
for parallel Control dispatch. No implementation, provider action, offering
activation, production mutation, deployment, or Expo payment work is
authorized by this roadmap alone.
