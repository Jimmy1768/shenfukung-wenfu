# Control Repair Packet — Cash Settlement Amount Parsing

## Identity And Observed Defect

- Accepted plan: `ops/docs/plans/SHENGFUKUNG_WEB_DEMO_CASH_ONLY_FLOW_PLAN.md` at `031cc0ad82aac1fdebba6ba85996fe8fa58be034`.
- Prior attempt: `wenfu-control-a-shengfukung-web-demo-cash-only-flow-config-path-repair-attempt-2`; all required focused and full Rails checks passed.
- Control source review observed that `CashPaymentRecorder` normalizes submitted `amount_cents` with `to_i`. A malformed value that begins with the authoritative number can be coerced into that number instead of failing closed, contrary to the immutable wrong/arbitrary amount pre-mutation criterion.
- Immutable repair packet: `wenfu-control-a-shengfukung-web-demo-cash-only-flow-cash-amount-parse-repair-attempt-3`, 2026-08-13 Asia/Taipei.

## Direct Mechanism And Scope

- Change only `rails/app/services/payments/cash_payment_recorder.rb` and its directly affected test path(s), plus this packet. Parse the submitted amount strictly and reject missing, malformed, fractional, or non-authoritative values before retained mutation; preserve valid form string handling and all current settlement/locking behavior.
- The accepted plan, preceding packet ownership, no-migration rule, disposable-database fence, required checks, local-only boundaries, and terminal rule remain unchanged.

## Dispatch

- One fresh ephemeral `gpt-5.6-terra/high` Implementer returns directly to Control; retained transaction/lock/ledger/audit/accounting behavior remains the reason for the deeper bounded allocation.
- No Handoff, staging, commit, merge, push, provider/secret/external action, or Planning traffic before terminal outcome.
