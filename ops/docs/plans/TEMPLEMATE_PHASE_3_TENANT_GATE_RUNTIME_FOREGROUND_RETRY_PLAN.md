# TempleMate Phase 3 Tenant Gate Runtime Foreground Retry Plan

Status: accepted for direct runtime retry after commit

Accepted: 2026-08-14

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`70c92d9fb165b177240a41005e7190e9e402c0fe`

Accepted implementation:
`1e37e3853e9d576f07a01cb6f07cebc83ebd6bc2`

Parent runtime plan:
`ops/docs/plans/TEMPLEMATE_PHASE_3_TENANT_GATE_AND_ASSISTANCE_RUNTIME_REVIEW_PLAN.md`

Failed observation:
`ops/docs/handoffs/2026-08-14-templemate-phase3-tenant-gate-assistance-runtime-review-control-b.md`

## Objective

Repeat only the previously blocked updated-unbound-gate checkpoint, adding a
narrow target-fenced Android foreground preparation so Control—not the
Director—collapses NotificationShade and foregrounds the exact TempleMate
development package. Then leave the updated review session running at the
verified unbound gate.

## Entry And Target Fence

Reverify the unchanged parent entry fence: accepted source ancestry and clean
worktrees; exact Pixel serial `39011FDJH00FQ8` in ADB `device` state; Pixel 8 /
`shiba`; installed `com.jimmy1768.komainu.dev` version `1.0.0`, code `1`,
target SDK 36, expected MainActivity; unowned port/reverse; byte-identical
temporary dependency access; full mobile tests, lint, and verify.

Stop if the exact device is locked behind credential/PIN/biometric input,
disconnected, unauthorized, or not the fenced package. Do not bypass a device
lock or request a credential.

## Authorized Foreground Preparation

Control may perform only these additional target-fenced system-UI actions on
the exact serial:

1. issue the ordinary Android status-bar collapse command once;
2. start/foreground exactly
   `com.jimmy1768.komainu.dev/.MainActivity` once; and
3. read fresh focused-package/UI hierarchy evidence proving NotificationShade
   is absent and the exact TempleMate package is foreground.

No swipe choreography, launcher navigation, notification interaction,
settings change, accessibility/keyboard change, unlock credential, unrelated
package action, app-data clear, force-stop, uninstall, or package mutation is
authorized.

## Authorized Runtime Retry

After the foreground fence passes:

- start one explicit dummy/development localhost Metro session on port 8081
  from an isolated worktree containing accepted source;
- wait for the listener before creating exact serial
  `adb reverse tcp:8081 tcp:8081`;
- deliver the exact local `exp+templemate` URL once to the exact package;
- enter the deterministic signed-in dummy state and use visible dummy reset to
  reach authenticated-unbound state; and
- repeat the parent plan's Unbound gate checkpoint exactly.

Required visible evidence remains:

- Header sign-out and QR-first finish-setup copy;
- one TempleMate in-app scan action;
- no normal navigation, account screens, fixture link field, or Contact Temple;
- CameraView open/cancel returns to the same gate without binding/data change;
  and
- Android Back cannot reveal a hidden account screen.

Return exactly
`director_action_required: phase3_updated_unbound_gate_review`
only after the updated gate is visibly ready. Leave packet Metro and the exact
reverse running, then wait for Director review and the later trusted-QR
callback sequence from the parent plan.

## Cleanup And Exclusions

On failure or later explicit completion, stop/remove only packet Metro, exact
reverse, temporary dependency access, and named package-scoped evidence;
preserve the installed client and unrelated device state.

All parent exclusions remain: no source/test/config/dependency/native edit,
repair, build/install/version increment, real QR/API/OAuth/provider/email,
payment/admin, production, deployment, release, push, secret, or external
action.

Current blocker: none before the fenced foreground attempt.
