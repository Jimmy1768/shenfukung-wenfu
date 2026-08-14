# TempleMate Phase 3 Tenant Gate Back-Dismissal Runtime Retry Plan

Status: accepted for direct runtime retry after commit

Accepted: 2026-08-14

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`ebf46d7ef72476d63bae5a5b26299885ae533529`

Accepted implementation:
`1e37e3853e9d576f07a01cb6f07cebc83ebd6bc2`

Predecessor reports:

- `ops/docs/handoffs/2026-08-14-templemate-phase3-tenant-gate-assistance-runtime-review-control-b.md`
- `ops/docs/handoffs/2026-08-14-templemate-phase3-tenant-gate-foreground-retry-control-b.md`

## Objective

Complete only the updated authenticated-unbound tenant-gate observation that
the preceding packets could not reach because Android NotificationShade
remained focused. Replace the ineffective status-bar-collapse method with one
ordinary Android Back event, then foreground and verify the exact TempleMate
package. Control performs this preparation; no Director device action is
requested.

## Entry And Target Fence

Reverify the unchanged parent entry fence: accepted implementation ancestry;
clean isolated and canonical worktrees; exact Pixel serial
`39011FDJH00FQ8` in ADB `device` state; Pixel 8 / `shiba`; installed
`com.jimmy1768.komainu.dev` version `1.0.0`, code `1`, target SDK 36 and
expected MainActivity; unowned TCP 8081 and target reverse; byte-identical
temporary dependency access; full mobile tests, lint and verify.

Read current focus before mutation. This retry applies only when
NotificationShade is current and the exact TempleMate package is the
underlying focused app. Stop if the device is credential/PIN/biometric locked,
unauthorized, disconnected, focused on another app, or does not match the
fenced target. Do not bypass a device lock or request a credential.

## Authorized Foreground Preparation

On the exact serial only, Control may:

1. issue exactly one ordinary Android `KEYCODE_BACK` while NotificationShade
   is current;
2. read fresh focus/UI-hierarchy evidence;
3. if NotificationShade is absent, start/foreground exactly
   `com.jimmy1768.komainu.dev/.MainActivity` once; and
4. read fresh evidence proving the exact TempleMate package is current and no
   system shade/launcher/other package covers it.

If the single Back event does not remove NotificationShade, stop without a
second Back or alternate gesture. No swipe choreography, status-bar collapse,
notification interaction, launcher navigation, settings/accessibility/
keyboard change, unlock credential, unrelated package action, app-data clear,
force-stop, uninstall or package mutation is authorized.

## Authorized Runtime Retry

After the foreground fence passes:

- start one explicit dummy/development localhost Metro session on port 8081
  from isolated accepted source;
- wait for the listener before creating the exact serial
  `adb reverse tcp:8081 tcp:8081`;
- deliver the exact local `exp+templemate` URL once to the exact package;
- enter deterministic signed-in dummy state and use visible dummy reset to
  reach authenticated-unbound state; and
- repeat the accepted unbound-gate checkpoint.

Required visible evidence:

- Header sign-out and QR-first finish-setup copy;
- one TempleMate in-app scan action;
- no ordinary navigation, account screens, fixture link field or Contact
  Temple;
- CameraView open/cancel returns to the same unbound gate without binding or
  data change; and
- Android Back cannot expose any hidden account screen.

Return exactly
`director_action_required: phase3_updated_unbound_gate_review`
only after the updated gate is visibly ready. Leave packet Metro and the exact
reverse running, then wait for Director review. Do not perform trusted-QR
binding or advance the parent review matrix without a subsequent Planning
direction.

## Cleanup And Exclusions

On failure or later explicit completion, stop/remove only packet Metro, exact
reverse, temporary dependency access and named package-scoped evidence;
preserve the installed client and unrelated device state.

No source/test/config/dependency/native edit, repair, build/install/version
increment, real QR/API/OAuth/provider/email, payment/admin, production,
deployment, release, push, secret or unrelated external action is authorized.

Current blocker: none before the single target-fenced Back dismissal attempt.
