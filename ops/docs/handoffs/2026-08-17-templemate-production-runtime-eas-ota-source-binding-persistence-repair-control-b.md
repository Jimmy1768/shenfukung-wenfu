# Control repair packet — production trusted-QR binding persistence

## Identity

- **Parent packet:** `2026-08-17-templemate-production-runtime-eas-ota-source-control-b`, attempt 1, against accepted plan `TEMPLEMATE_PRODUCTION_RUNTIME_EAS_OTA_SOURCE_IMPLEMENTATION_PLAN.md` at `41a92ee090717650a081da16d201362add9a180a`.
- **Repair attempt:** 2, Control B -> Wenfu Planning; same isolated worktree and branch.

## Observed conformance defect

The candidate's real `scanCameraPayload` validates the exact public temple but `TenantSetupGate` only calls React `setBinding(result)`. No source seam stores or restores a successful real binding under the environment/tenant scoped secure-storage boundary. This prevents acceptance of the plan's explicit persistence criterion; it is a direct bounded source repair, not a Planning design gap.

## Direct mechanism and scope

- Add a narrow nonsecret binding persistence seam within the existing scoped storage and real adapter boundary; persist only server-derived `id`, `name`, state/source needed to restore the trusted binding, never QR text, token, raw payload, response body, or arbitrary API origin.
- Restore only a validated binding for the exact release config; failed/invalid scan preserves prior binding or the unbound gate; logout, OAuth/session revocation, closure, and confirmation-switch tenant cleanup clear it.
- Update `App.js`, real storage/adapter, tenant binding/scanner seams, and focused tenant/real-adapter/source tests only as required. Do not change dependencies, lockfile, EAS/config profiles, versioning, docs except this repair record, or external behavior.
- The candidate's earlier dependency materialization is complete and its `node_modules` cleanup remains required. Run focused dependency-free tests for the repair; reuse the recorded 59/59, lint, verifier, Doctor, and guardrail evidence for unchanged dependency/config surfaces. Do not perform a second materialization.

## Boundaries and acceptance

- New ephemeral Implementer: `gpt-5.6-terra/medium`; fresh normal allocation because this is a small client storage/parser conformance repair.
- No EAS/Apple/provider/device/build/publish action, no source-scope expansion, no secret or QR data handling, and no staging/commit/merge by the Implementer.
- Control will review persistence/clearing semantics, exact path scope, focused tests, prior unchanged suite evidence, diff checks, and cleanliness before a single terminal outcome.
