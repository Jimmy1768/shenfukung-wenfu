# TempleMate Phase 3 Tenant Gate And Assistance Runtime Review Plan

Status: accepted for direct runtime dispatch after commit

Accepted: 2026-08-14

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`36806430ca9ca2ce45493c7d694206ed78d2a269`

Accepted implementation:
`1e37e3853e9d576f07a01cb6f07cebc83ebd6bc2`

Source plan:
`ops/docs/plans/TEMPLEMATE_PHASE_3_TENANT_GATE_AND_ASSISTANCE_UI_IMPLEMENTATION_PLAN.md`

Parent audit:
`ops/docs/plans/TEMPLEMATE_PHASE_3_DIRECTOR_HOLISTIC_UI_AUDIT_PLAN.md`

## Objective

Reuse the compatible installed Android development client and the accepted USB
Metro method to validate the tenant-gate and Assistance patch, then leave the
updated dummy session running for continued Director UI review. No native
rebuild, version/build increment, source repair, or external action is
authorized.

## Entry Fence

Control must verify before runtime action:

- exact source implementation `1e37e385` is an ancestor of the isolated
  runtime worktree;
- canonical and isolated source are clean with empty staging;
- exact Pixel serial `39011FDJH00FQ8` is in ADB `device` state;
- installed package is `com.jimmy1768.komainu.dev`, version `1.0.0`, Android
  code `1`, target SDK 36, with the expected MainActivity launcher;
- port 8081 and the exact serial reverse are unowned at entry;
- temporary dependency access is byte-identical to `mobile/package.json` and
  `mobile/yarn.lock`; and
- full mobile tests, lint, and verify pass before attachment.

If any fence fails, stop without improvising a build, install, alternate
device, alternate port, Expo QR, or source correction.

## Authorized Runtime Method

Use only the accepted method:

1. explicit dummy/development mode;
2. localhost dev-client Metro on port 8081 from an isolated worktree containing
   accepted source `1e37e385`;
3. exact serial `adb reverse tcp:8081 tcp:8081`;
4. the local `exp+templemate` attachment for
   `com.jimmy1768.komainu.dev`; and
5. package-scoped, nonsecret UI/log evidence only.

Do not use a Metro/Expo QR code, Expo launcher scanner, Pixel native scanner,
provider browser, real API, or alternate attachment method.

## Required Runtime Evidence

### Unbound gate checkpoint

- Enter the deterministic authenticated dummy state and use the visible dummy
  reset so the account remains signed in while temple binding becomes unbound.
- Confirm visibly and through fresh package-scoped hierarchy evidence:
  - TempleMate remains foreground and signed in;
  - Header sign-out remains available;
  - the QR-first finish-setup copy and one in-app scan action are visible;
  - the normal six-tab navigation, account/profile/dependent/registration/
    Discover/Settings content, fixture connection-link field, and Contact
    Temple action are absent;
  - Android Back cannot escape into a hidden account screen; and
  - opening/cancelling the in-app CameraView returns to the unbound gate with no
    binding or account-data change.
- Return callback
  `director_action_required: phase3_updated_unbound_gate_review` after the
  updated unbound gate is visibly ready. Leave Metro/reverse running and wait
  for the Director's review. Do not request or simulate a QR scan before that
  callback.

### Bound/settings/assistance checkpoint

Only after the Director confirms the unbound gate and presents an accepted
trusted demo temple QR inside TempleMate's own CameraView:

- confirm the trusted scan enters bound Home;
- confirm Home shows stable active temple context and no link/switch/confirm
  controls;
- confirm Settings places temple connection/switch after ordinary settings as
  the least-prominent action;
- confirm Contact Temple is absent from Settings and safe navigation;
- confirm Assistance copy identifies the admin-visible request destination and
  dummy fixture-only behavior;
- submit one bounded dummy Assistance message and confirm a truthful local-only
  outcome without changing profile/dependent/registration data;
- confirm Back/navigation and locale/theme feedback scoping remain safe; and
- reset once to restore the canonical unbound gate.

No switch confirmation is required in this packet unless Planning separately
authorizes it after Director review. Prior accepted source/test evidence for
confirmation-only cleanup remains retained.

## Session Ownership And Cleanup

- After the required checkpoints, leave the updated session running if the
  Director continues the holistic audit. Control B remains the runtime owner;
  Planning records findings.
- Do not interpret Director comments as source-repair authority.
- On explicit Planning/Director completion, supersession, device disconnect,
  or truthful blocker, stop only the packet Metro process, remove only the
  exact serial reverse and temporary dependency/evidence state, preserve the
  installed client, and return one immutable terminal report.

## Explicit Exclusions

No source/test/config/dependency/lockfile/native edit, repair, build/prebuild/
EAS/install/artifact, version/build increment, Rails/Vue/server action, real
tenant binding, real API/OAuth/provider/email delivery, payment/admin action,
production data, deployment, release, push, secret, or external mutation.

Current blocker: none before entry. Physical trusted-QR evidence waits only on
the explicit Director callback after the unbound gate is ready.
