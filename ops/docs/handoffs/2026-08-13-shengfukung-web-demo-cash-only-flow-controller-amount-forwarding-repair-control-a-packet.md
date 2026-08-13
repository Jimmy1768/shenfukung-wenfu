# Control Repair Packet — Cash Settlement Controller Amount Forwarding

## Identity And Observed Defect

- Accepted plan: `ops/docs/plans/SHENGFUKUNG_WEB_DEMO_CASH_ONLY_FLOW_PLAN.md` at `031cc0ad82aac1fdebba6ba85996fe8fa58be034`.
- Prior repair: `wenfu-control-a-shengfukung-web-demo-cash-only-flow-cash-amount-parse-repair-attempt-3` strictly parses values at `CashPaymentRecorder` and its focused/full local suite passed.
- Its review established one remaining direct bypass: `rails/app/controllers/admin/payments_controller.rb` sends `payment_params[:amount_cents].to_i` to the recorder, coercing raw malformed request input before strict parsing. This prevents the accepted pre-mutation arbitrary/malformed amount condition from being proved through the public admin entry point.
- Immutable repair packet: `wenfu-control-a-shengfukung-web-demo-cash-only-flow-controller-amount-forwarding-repair-attempt-4`, 2026-08-13 Asia/Taipei.

## Direct Mechanism And Scope

- Change only `rails/app/controllers/admin/payments_controller.rb`, its directly affected integration test path(s), and this packet. Forward raw permitted `amount_cents` to the strict recorder without lossy coercion, then prove malformed direct HTTP input fails before ledger/payment/audit/registration/accounting mutation.
- Preserve all preceding candidate changes and all current authorization, settlement, permission, tenancy, transaction/locking, no-migration, local-only, test-DB, check, integration, and terminal constraints.

## Dispatch

- One fresh ephemeral `gpt-5.6-terra/high` Implementer returns directly to Control. The retained atomic cash settlement/concurrency/accounting context continues to justify the deeper allocation.
- No Handoff, staging, commit, merge, push, provider/secret/external action, or Planning traffic before terminal outcome.
