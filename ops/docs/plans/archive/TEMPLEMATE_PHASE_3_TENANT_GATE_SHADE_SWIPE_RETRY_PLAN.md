# TempleMate Phase 3 Tenant Gate Notification-Shade Swipe Retry Plan

Status: accepted for direct runtime retry after commit

Accepted: 2026-08-14

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`88738658f16db41c6559542687862d956a3af671`

Accepted implementation:
`1e37e3853e9d576f07a01cb6f07cebc83ebd6bc2`

## Objective

Complete only the updated authenticated-unbound tenant-gate observation. The
ordinary status-bar-collapse command and one Back event were independently
observed to leave Android 17 NotificationShade current. This final foreground
retry authorizes one target-sized upward dismissal gesture while the shade is
proven current, followed by exact-package foreground verification. Control
performs the preparation; no Director device action is requested.

## Entry And Target Fence

Reverify accepted implementation ancestry, clean isolated/canonical state,
exact Pixel serial `39011FDJH00FQ8` in ADB `device` state, Pixel 8 / `shiba`,
installed `com.jimmy1768.komainu.dev` version `1.0.0`, code `1`, target SDK 36
and expected MainActivity, unowned TCP 8081/reverse, byte-identical temporary
dependency access, full mobile tests, lint and verify.

Read current focus and physical display size before mutation. This packet
applies only if NotificationShade is current, the exact TempleMate package is
the underlying focused app and the device is not credential/PIN/biometric
locked. Stop on any mismatch; do not bypass a lock or request a credential.

## Authorized Foreground Preparation

On the exact serial only, Control may:

1. read the physical display width and height;
2. while NotificationShade is proven current, issue exactly one vertical
   upward input swipe at horizontal center, from 85% to 5% of physical display
   height, with 300ms duration;
3. read fresh focus/UI-hierarchy evidence;
4. if NotificationShade is absent, start/foreground exactly
   `com.jimmy1768.komainu.dev/.MainActivity` once; and
5. prove the exact TempleMate package is current with no shade, launcher or
   unrelated package covering it.

The coordinate calculation must use the read physical display dimensions; no
hard-coded coordinate guess is allowed. If the single upward swipe does not
remove NotificationShade, stop. No second swipe, Back, status-bar collapse,
notification selection, launcher navigation, settings/accessibility/keyboard
change, unrelated package action, app-data clear, force-stop, uninstall or
package mutation is authorized.

## Authorized Runtime Retry

After foreground proof:

- start one explicit dummy/development localhost Metro session on port 8081
  from isolated accepted source;
- wait for the listener before creating exact serial
  `adb reverse tcp:8081 tcp:8081`;
- deliver the exact local `exp+templemate` URL once to the exact package;
- enter deterministic signed-in dummy state and visibly reset to
  authenticated-unbound state; and
- verify the accepted unbound-gate matrix: Header sign-out, QR-first
  finish-setup copy, one in-app scan action, no ordinary navigation/account
  screens/fixture-link field/Contact Temple, CameraView Cancel returning to the
  same gate, and Back unable to expose hidden account screens.

Return exactly
`director_action_required: phase3_updated_unbound_gate_review`
only when the gate is visibly ready. Leave packet Metro and exact reverse
running and wait. Do not scan a trusted QR or advance the remaining review
matrix without a subsequent Planning direction.

## Cleanup And Exclusions

On failure or later explicit completion, remove only packet Metro, exact
reverse, temporary dependency access and named package-scoped evidence;
preserve the installed client and unrelated device state.

No source/test/config/dependency/native edit, repair, build/install/version
increment, real QR/API/OAuth/provider/email, payment/admin, production,
deployment, release, push, secret or unrelated external action is authorized.

Current blocker: none before the one target-sized shade-dismissal gesture.
