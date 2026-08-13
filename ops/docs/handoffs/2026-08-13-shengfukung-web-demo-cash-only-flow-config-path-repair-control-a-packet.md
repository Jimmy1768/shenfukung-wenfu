# Control Repair Packet — Shengfukung Cash-Only Configuration Path

## Identity And Observed Defect

- Accepted plan: `ops/docs/plans/SHENGFUKUNG_WEB_DEMO_CASH_ONLY_FLOW_PLAN.md` at `031cc0ad82aac1fdebba6ba85996fe8fa58be034`.
- Superseded packet/attempt: `wenfu-control-a-shengfukung-web-demo-cash-only-flow-attempt-1`.
- Observed before any implementation edit, staging, database write, or external action: `rails/db/temples/shengfukung-wenfu.yml` is the loader-ready tenant source that sets `patron_checkout_provider: fake`; `rails/db/seeds/temples.rb` only reads that configuration. The first packet omitted this necessary source path.
- Immutable repair packet: `wenfu-control-a-shengfukung-web-demo-cash-only-flow-config-path-repair-attempt-2`, 2026-08-13 Asia/Taipei.

## Direct Mechanism And Scope

- Replace only Shengfukung's loader-ready client-facing `fake` selection in `rails/db/temples/shengfukung-wenfu.yml` with the explicit accepted no-online/cash-only tenant capability, using the existing loader path. Do not alter the four offerings or disabled fifth-offering decision.
- All source/test paths of attempt 1 remain owned. This repair adds precisely `rails/db/temples/shengfukung-wenfu.yml` and its directly affected bootstrap/config tests.
- The required Rails/web behavior, local-only boundaries, disposable-DB fence, no-migration rule, checks, integration, and Planning-terminal rule remain unchanged from the accepted plan and attempt 1 packet.

## Dispatch

- One fresh ephemeral `gpt-5.6-terra/high` Implementer is required because retained financial settlement, concurrency, and accounting proofs remain the unchanged complexity rationale.
- No Handoff. Implementer returns directly to Control and may not stage, commit, merge, push, access providers/secrets, or make external changes.
- Planning receives no packet until this bounded repair reaches a terminal accepted outcome or a genuine design gap.
