# Expo Temple QR camera permission-denial repair — Control B packet

## Identity

- Parent accepted plan and unchanged criteria:
  `ops/docs/plans/EXPO_TEMPLE_QR_CAMERA_FOUNDATION_PLAN.md` at
  `c724517125bfcb961beba8f24b1aee15083e9a35`.
- Control authority: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0`; Planning direct continuation.
- Repository/worktree/branch/base:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`,
  `/private/tmp/shengfukung-wenfu-expo-temple-qr-camera`,
  `codex/expo-temple-qr-camera-foundation`,
  `4f05e2b0353089fe018971578ff774ee531c4c9b`.
- Immutable repair identity/attempt:
  `2026-08-11-expo-temple-qr-camera-permission-denial-repair-control-b`,
  attempt 2.

## Observed failed conformance and direct repair

- Failed attempt/evidence: accepted source commit `4f05e2b` has
  `camera_surface.js` call `requestPermission()` whenever permission is denied
  and can be asked again. A normal user denial therefore triggers a second
  unrequested prompt after permission state changes, contrary to the plan's
  explicit denied/retry behavior.
- Exact owned editable paths: `mobile/app/tenant/camera_surface.js`, focused
  `mobile/app/tenant/camera_session.js` only if needed for deterministic
  request-state control, and focused `mobile/__tests__/camera-session.test.js`
  or a directly related camera test. This repair packet only by Control.
- Direct mechanism: an explicit scanner opening may make at most one initial
  request while permission is undetermined. A user denial must leave the
  visible denied state without another effect-driven request. Retry alone may
  request again exactly once. Blocked state must never request. Close/reopen
  starts a new explicit scanner session but cannot loop.
- Required proof: deterministic component/controller evidence for initial
  request count, denied no-repeat, exactly-one user Retry, blocked no-request,
  and close/reopen reset; focused camera tests plus the parent mobile test,
  lint, verification, offline Doctor, both public config modes, and diff check.
- Exclusions unchanged: no config/dependency/Plan/Rails/Vue edits, no build,
  Metro/device/EAS/provider/secret/deployment/push/external action.

## Allocation and return boundary

- Persistent Handoff: no; the defect is direct and bounded.
- Selected ephemeral Implementer: `gpt-5.6-terra/medium`, the lowest sufficient
  allocation for a deterministic local permission-state correction.
- One fresh Implementer task: `expo_temple_qr_camera_permission_repair`.
- Implementer may not stage, commit, merge, push, edit this packet, or broaden
  scope. Return only to this Control.
- Planning receives no intermediate status. Control accepts only after the
  required proof, then commits/integrates and sends one replacement terminal.

## Closeout

- Conformance review: accepted. The effect now delegates permission requests to
  the controller; it makes one automatic request only after this user-opened
  scanner receives `status: "undetermined"`. Denial remains inert, Retry is
  the sole retry authority, blocked state never requests, and close/reopen
  resets only the explicit scanner session.
- Acceptance evidence: focused deterministic request-count proof and full
  mobile suite 42/42 passing; lint, verification, offline project-local Doctor
  (exit 0 with only the configured offline metadata warning), public config
  proofs, and `git diff --check` passing.
- Integration/direct terminal/paired receipt: pending Control commit,
  canonical-main integration, and direct Planning receipt.
- First residual gate after accepted repair: later separately authorized EAS
  development-client build and physical camera/device validation.
