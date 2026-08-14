# Wenfu Control A — Tenant Gate And Assistance UI Contract Repair

## Identity And Observed Failure

- Parent attempts: `wenfu-control-a-templemate-phase-3-tenant-gate-and-assistance-ui-attempt-1` and repair attempt 2.
- Repair identity: `wenfu-control-a-templemate-phase-3-tenant-gate-and-assistance-ui-contract-repair-attempt-3`.
- Same accepted plan/base/worktree/branch: `ops/docs/plans/TEMPLEMATE_PHASE_3_TENANT_GATE_AND_ASSISTANCE_UI_IMPLEMENTATION_PLAN.md` | `4a0b78bdde1e7c07b4380b5a4f4ba575b9e4af44` | `/private/tmp/shengfukung-wenfu-templemate-phase-3-tenant-gate-assistance-ui` | `codex/templemate-phase-3-tenant-gate-assistance-ui`.
- Control source review observed `Api::V1::Account::NativeResourcesController#assistance` returns `{ assistance_request: {...}, duplicate: true }` for a reused open request and `{ assistance_request: {...} }` for a new request. Candidate `mobile/app/real/adapter.js` instead reads `payload.assistance` and only checks nested duplicate markers, so it would classify the actual reused response as `created`.

## Direct Repair Mechanism

- In `mobile/app/real/adapter.js`, map the actual `assistance_request` response envelope and its top-level Boolean `duplicate` to the accepted scoped `created` / `duplicate` outcome while retaining account snapshot preservation and the exact profile-channel request body.
- In `mobile/__tests__/real-adapter.test.js`, replace synthetic non-contract assistance fixtures with exact Rails response shapes and prove both outcomes. No Rails edit is allowed.

## Boundaries And Evidence

- Owned paths: the two paths above and this packet record only. All parent packet exclusions remain in force.
- One fresh normal ephemeral `gpt-5.6-terra/medium` Implementer; no Handoff.
- Rerun focused real-adapter plus full mobile test/lint/verify/offline Doctor, the existing fenced Rails assistance/admin regressions without edits, exact path/rejected-surface scans, and diff checks. Use no real network/device/provider/external action.
- This is a nonterminal Control repair under unchanged immutable criteria. No Planning message is permitted until terminal disposition.
