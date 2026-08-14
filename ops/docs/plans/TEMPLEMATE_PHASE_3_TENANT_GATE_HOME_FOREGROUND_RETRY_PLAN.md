# TempleMate Phase 3 Tenant Gate Home-Foreground Runtime Retry Plan

Status: accepted for direct runtime retry after commit

Accepted: 2026-08-14

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`812aaa06886bb55aaa4244711a859dcafc3c3ac4`

Accepted implementation:
`1e37e3853e9d576f07a01cb6f07cebc83ebd6bc2`

## Objective

Complete only the updated authenticated-unbound tenant-gate observation. The
Android 17 shade ignored ordinary collapse, Back and one display-derived
upward swipe. This retry uses the standard deterministic package-selection
sequence: one Home event to leave system shade context, followed by one exact
TempleMate MainActivity start. Control performs it; no Director device action
is requested.

## Entry Fence

Reverify accepted implementation ancestry, clean isolated/canonical states,
exact Pixel serial `39011FDJH00FQ8` in ADB `device` state, Pixel 8 / `shiba`,
installed `com.jimmy1768.komainu.dev` version `1.0.0`, code `1`, target SDK 36
and expected MainActivity, unowned TCP 8081/reverse, byte-identical temporary
dependency access, full mobile tests, lint and verify.

Read focus before mutation. Apply this packet only when NotificationShade is
current, TempleMate is the underlying focused package and the device is not
credential/PIN/biometric locked. Stop on mismatch; never bypass a lock or
request a credential.

## Authorized Foreground Preparation

On the exact serial only, Control may:

1. issue exactly one ordinary Android `KEYCODE_HOME`;
2. read fresh focus evidence, without interacting with the launcher;
3. start/foreground exactly
   `com.jimmy1768.komainu.dev/.MainActivity` once; and
4. read fresh focus/UI-hierarchy evidence proving TempleMate is the current
   visible package and NotificationShade/launcher/another package is not
   covering it.

If the sequence does not establish exact TempleMate focus, stop. No second
Home/start, launcher selection, swipe, Back, status-bar command, notification
interaction, settings/accessibility/keyboard change, unrelated package
action, app-data clear, force-stop, uninstall or package mutation is
authorized.

## Authorized Runtime And Review Checkpoint

After foreground proof:

- start one explicit dummy/development localhost Metro session on port 8081
  from isolated accepted source;
- wait for the listener, create exact serial
  `adb reverse tcp:8081 tcp:8081`, and deliver the exact local
  `exp+templemate` URL once;
- enter deterministic signed-in dummy state and visibly reset to
  authenticated-unbound state;
- verify Header sign-out, QR-first finish-setup copy and one in-app scan action;
- verify ordinary navigation, account screens, fixture-link field and Contact
  Temple are absent;
- verify CameraView Cancel returns to the same unbound gate without mutation;
  and
- verify Android Back cannot expose hidden account content.

Return exactly
`director_action_required: phase3_updated_unbound_gate_review`
only when the updated gate is visibly ready. Leave Metro and exact reverse
running and wait. Do not scan trusted QR or advance further without a later
Planning direction.

## Cleanup And Exclusions

On failure or later explicit completion, remove only packet Metro, exact
reverse, temporary dependency access and named package-scoped evidence;
preserve the installed client and unrelated device state.

No source/test/config/dependency/native edit, repair, build/install/version
increment, real QR/API/OAuth/provider/email, payment/admin, production,
deployment, release, push, secret or unrelated external action is authorized.

Current blocker: none before the one Home-plus-exact-package sequence.
