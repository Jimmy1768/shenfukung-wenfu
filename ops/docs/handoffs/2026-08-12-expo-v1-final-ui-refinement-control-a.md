# Expo V1 Final UI Refinement — Control A Packet

Status: immutable before Implementer dispatch

Date: 2026-08-12

## Identity

- Accepted plan: `ops/docs/plans/EXPO_V1_FINAL_UI_REFINEMENT_IMPLEMENTATION_PLAN.md`
  at `0d099a7e8de532b114f66575326b65979ec850f0`.
- Control: Wenfu Control A `019fc08d-676b-7ca2-be32-3efe42fa2fca`,
  `gpt-5.6-terra/high`.
- Repository/worktree/branch: `/Users/jimmy1768/Projects/shengfukung-wenfu` /
  `/private/tmp/shengfukung-wenfu-expo-v1-final-ui-refinement` /
  `codex/expo-v1-final-ui-refinement`.
- Accepted readiness report:
  `ops/docs/handoffs/2026-08-12-expo-v1-final-ui-refinement-readiness-control-b.md`
  at `74ffad700af204d6c839db6fa5e6227099d41fcf`.
- Packet identity and attempt:
  `wenfu-control-a-expo-v1-final-ui-refinement-attempt-1`.

## Scope

- Objective: repair only transient-feedback ownership/localization and Android
  Back while TempleMate's in-app CameraView is active.
- Direct mechanisms: signed-in `error` and rendered-string `notice` are global
  above every account screen, with no owner or navigation boundary; `reset()`
  stores `t.saved` before the preference state resets the locale. The App Back
  handler consumes only `screen !== 'home'`, even when `cameraOpen` is true.
- Implementer-owned paths only: `mobile/App.js`; at most one small pure helper
  in `mobile/app/ui/`; at most one small pure helper in `mobile/app/tenant/`;
  `mobile/__tests__/ui-refinement.test.js`; `mobile/__tests__/camera-session.test.js`;
  and at most one new focused JavaScript state test under `mobile/__tests__/`.
  No `camera_surface.js` edit is authorized unless direct evidence proves one
  essential; existing Cancel and session behavior are read-only by default.
- Control-owned paths: this immutable packet and final safe receipt under
  `ops/docs/handoffs/` only.
- Required behavior/proof: feedback has an explicit screen/action or intended
  destination lifetime; unrelated navigation, reset, locale transitions, and
  sign-out do not show stale feedback; forwarded success may appear only at its
  destination. Active CameraView consumes Back and closes to home without
  touching binding/account/locale/theme/permission/form state; closed camera
  preserves existing home/non-home Back behavior. Focused state tests must
  exercise the selected feedback and Back authorities directly rather than
  source regex alone.
- Required checks: focused feedback/UI and camera/back tests, full `yarn test`,
  `yarn lint`, `yarn verify`, diff/staged-diff checks, exact owned-path review,
  and scans excluding adapter/OAuth/QR-trust/dummy-repository/config/dependency/
  native/version/Rails/Vue changes. A byte-identical temporary local
  `node_modules` symlink may be used only when needed and is removed before
  return.
- Explicit exclusions: dependent/registration change; CameraView child-warning
  repair; copy/design/navigation-framework or new feature work; adapter, OAuth,
  QR trust, dummy repository, dependencies/lockfile/config/native/Rails/Vue/
  version/build; Expo Doctor, Metro, ADB/device, EAS/build, provider,
  deployment/release/push, secrets, and external action.
- First blocker: none; both confirmed mechanisms are direct local JavaScript
  state/presentation defects within the plan-owned scope.

## Incident-Correction Placement

- Incident correction: yes; small testable feedback/back state authorities and
  App wiring, not a product, adapter, native, or governance redesign.
- `AGENTS.md` is excluded; no persistent governance change is introduced.

## Repair And Terminal Boundary

- Bounded nonterminal repair within unchanged criteria: no; attempt 1.
- Any observed in-scope conformance defect requires a fresh Control repair
  packet; Planning receives no intermediate status.
- One immutable terminal goes directly to Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6` only after accepted local integration
  or another truthful terminal disposition.

## Handoff Eligibility And Implementer Dispatch

- Persistent Handoff requested: no. This is one bounded pure JavaScript/test
  packet with no continuity requirement; Luna eligibility is absent.
- Selected Implementer: `gpt-5.6-terra/medium`. The mechanisms are already
  diagnosed and the work has no persistence, migration, concurrency, or
  destructive cleanup; medium is the lowest sufficient configuration.
- The Implementer edits only packet-owned paths, does not stage, commit,
  merge, push, deploy, access secrets/providers, perform external action, or
  broaden scope, and returns evidence directly to this Control.

## Control Review And Closeout

- Control independently verifies state-authority behavior, feedback owner and
  localization boundaries, camera-active/closed Back decisions, unchanged
  Cancel/permission/session and adapter/OAuth/QR-trust behavior, exact diff,
  required checks, staging, and clean states before commit and local main
  integration.
- Next owner after accepted integration: Planning may separately dispatch the
  sequenced Control B installed-client validation. No runtime/device action
  follows here.
- Authority confirmation: only local packet-owned Expo JavaScript/test work is
  authorized; no external, provider, secret, deployment, release, or product
  runtime action is used.
