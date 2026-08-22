# TempleMate Phase 3 Tenant And Support UI Readiness Scan Plan

Status: accepted for direct report-only dispatch after commit

Accepted: 2026-08-14

Owner: Wenfu Planning / Director

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main` at plan commit parent
`c9482cd918ad2321cfd5dae98d4bdb998c917c08`

Parent audit:
TEMPLEMATE_PHASE_3_DIRECTOR_HOLISTIC_UI_AUDIT_PLAN.md (deleted 2026-08-22 in
the plans/archive cleanup; recoverable via `git log --grep`)

Accepted findings:
TEMPLEMATE_PHASE_3_UI_AUDIT_FINDINGS.md (deleted 2026-08-22 in the
plans/archive cleanup; recoverable via `git log --grep`)

Parallel runtime packet: Control B owned the (now-completed) dummy
development-client audit session under TEMPLEMATE_PHASE_3_UI_AUDIT_RUNTIME_SESSION_PLAN.md
(deleted 2026-08-22 in the plans/archive cleanup; recoverable via
`git log --grep`). This scan was not to stop, alter, attach to, automate, or
otherwise interfere with that session.

## Objective

Perform one evidence-only readiness scan for Findings 001–003 before any
source implementation. Map the smallest coherent implementation boundaries,
shared-state risks, existing contracts, missing tests, runtime proof, and exact
remaining Director decisions for:

1. moving bound-state temple switching from Home to the lowest-priority part
   of Settings;
2. turning the authenticated-but-unbound state into a QR-first setup gate
   rather than an ordinary empty account shell;
3. distinguishing retained admin-visible assistance from temple email contact;
   and
4. repairing the rendered Expo forms so real-adapter payloads satisfy the
   existing Rails native contracts.

This packet produces a report and implementation recommendation only. It does
not change source, tests, copy, navigation, Rails behavior, or runtime state.

## Required Evidence Inventory

Control must inspect current canonical source and focused history/tests rather
than inferring from the running dummy presentation.

### Tenant binding and navigation

- Trace signed-in initialization, restore/reset/sign-out, `binding` states,
  `activePresentationTenant`, header, Home, Navigation, Settings, camera entry,
  link fixture, request/confirm switch, and tenant-state cleanup.
- Establish which account surfaces require a bound temple and which safe
  global actions must remain available while unbound. At minimum, distinguish
  QR setup, sign-out, camera permission/error/retry, and accessibility needs
  from temple-scoped account content.
- Identify how dummy binding differs from deliberate local/test real binding.
  Preserve real adapter no-fallback behavior, environment/tenant-scoped
  storage, trusted QR rules, confirmation-before-cleanup, and account-only
  authority.
- Determine whether production-facing UI can remove the fixture connection-link
  field without deleting the underlying test seam needed by deterministic
  evidence.
- Map Android Back, navigation fallback, reset, locale/theme, error/notice,
  and app-resume consequences of an unbound blocking gate.

### Assistance and contact

- Trace the rendered Expo form through dummy adapter, real adapter, Rails
  native controller, form/model/service, audit record, and admin/email
  destination for each action.
- Confirm the exact assistance channel/context requirements, duplicate-open
  behavior, registration/profile association, status lifecycle, admin
  dashboard/index visibility, authority, and tenant isolation.
- Confirm the exact Contact Temple subject/message validation, email delivery
  and patron acknowledgement behavior, audit-only persistence, delivery
  failure behavior, and absence of an admin-webapp inbox record.
- Distinguish dummy fixture-only success from real accepted delivery. Identify
  any copy or success-state claim that can presently overstate what happened.
- Identify whether one combined UI can preserve both backend semantics, or
  whether keeping/removing/consolidating an action requires a Director product
  decision. Do not make that decision on the Director's behalf.

### Contract and test coverage

- Prove or reject the recorded payload gaps: Assistance currently submits no
  channel; Contact Temple currently renders/submits no subject and does not
  mirror the Rails message-length contract.
- Explain why existing dummy and real-adapter tests did not catch any confirmed
  rendered-form mismatch.
- Inventory the smallest likely Expo, Rails, copy, and test paths for a later
  implementation, separated into shared navigation/state work and support-form
  contract work. Do not edit them.
- Define deterministic unit/contract/integration checks and a later installed-
  client runtime matrix. State explicitly whether either implementation would
  require a native dependency/configuration change or development-client
  rebuild.

## Required Report

Control writes one immutable report under
`ops/docs/handoffs/2026-08-14-templemate-phase-3-tenant-and-support-ui-readiness-control-a.md`
containing:

- exact repository/worktree/branch/base/final evidence;
- observed current behavior and source-backed mechanism for each finding;
- confirmed defects versus accepted Director direction versus open decisions;
- recommended implementation phase split and ordering;
- likely owned paths, required checks, runtime evidence, rollback, and boundary
  matrix for each later phase;
- explicit native rebuild/version/build conclusion;
- first true blocker, if any; and
- final status/staging and authority-boundary confirmation.

## Acceptance Criteria

The scan is accepted only if:

1. every conclusion is tied to current source/test evidence;
2. bound and unbound UX are analyzed across dummy and real modes without
   weakening tenant/session/QR/switch safety;
3. assistance and contact destinations are distinguished accurately, including
   admin visibility and email-only behavior;
4. the rendered-form/native-contract mismatch is confirmed or disproved with
   exact call shapes;
5. the report identifies all remaining Director decisions without inventing a
   visual/product answer;
6. later work is split into the smallest coherent implementation and runtime-
   validation packets, avoiding one-off screen patches;
7. no source, test, dependency, runtime, device, provider, account, production,
   or external state changes; and
8. canonical main is not merged by this report-only packet until Planning
   reviews the immutable terminal outcome and separately authorizes mechanical
   integration.

## Explicit Exclusions

No Expo/Rails/Vue source or test edit, UI implementation, copy decision,
dependency/lockfile/config/native change, build/prebuild/EAS/install,
version/build increment, Metro/ADB/device action, active Control B session
mutation, real API/OAuth/provider/email delivery, admin/account/data action,
deployment, production inspection, release, push, secret access, or external
mutation.

Current blocker: none for the readiness scan. Any product decision discovered
by the scan returns to Wenfu Planning/Director before implementation.
