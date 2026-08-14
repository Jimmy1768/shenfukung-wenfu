# Wenfu Control A — Tenant Gate And Assistance UI Repair Packet

## Identity And Observed Failure

- Parent packet: `wenfu-control-a-templemate-phase-3-tenant-gate-and-assistance-ui-attempt-1`.
- Repair packet: `wenfu-control-a-templemate-phase-3-tenant-gate-and-assistance-ui-repair-attempt-2`.
- Accepted plan/base/worktree/branch remain `ops/docs/plans/TEMPLEMATE_PHASE_3_TENANT_GATE_AND_ASSISTANCE_UI_IMPLEMENTATION_PLAN.md` | `4a0b78bdde1e7c07b4380b5a4f4ba575b9e4af44` | `/private/tmp/shengfukung-wenfu-templemate-phase-3-tenant-gate-assistance-ui` | `codex/templemate-phase-3-tenant-gate-assistance-ui`.
- Attempt 1 made no source change because it incorrectly classified the plan-required real local/test Assistance adapter path as an external action.

## Direct Repair Mechanism

- Implement the unchanged plan only through injected/local-test transport and fixtures. `mobile/app/real/config.js` already rejects every real-mode origin except explicit localhost, loopback, or `.test`; `createRealAdapter` requires injected transport. No live endpoint, provider, or network operation is authorized or needed for tests.
- Deliver the accepted unbound QR gate, bound Settings-only switch presentation, and Assistance-only UI/adapter/test contract. Preserve Rails/web Contact Temple unchanged.

## Scope And Boundaries

- Owned product paths and checks are exactly those of the parent packet; packet-owned documentation is this repair record plus the parent packet.
- No Rails/Vue/config/dependency/native/version/build, device/Metro/ADB, Control B runtime interaction, provider/secret, external, staging, commit, merge, push, or deployment action.
- Model: one fresh ephemeral `gpt-5.6-terra/medium`; normal bounded Expo JavaScript/state/adapter/test work remains the lowest sufficient allocation. Persistent Handoff is ineligible.
- Required evidence remains every accepted-plan check, including real local/test request assertions with no actual network invocation, and all final clean/diff/path/fence evidence.

## Nonterminal Boundary

- This is a Control-owned in-scope conformance repair under unchanged criteria. No Planning message is permitted before an accepted terminal outcome or a true authority gap.
