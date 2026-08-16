# TempleMate Phase 3 Tenant Gate Runtime After Wake Plan

Status: accepted for direct runtime validation after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`c228bb08219ec5752930d153d6ed786657b95da0`

Accepted implementation:
`1e37e3853e9d576f07a01cb6f07cebc83ebd6bc2`

Accepted prerequisite diagnosis:
`ops/docs/handoffs/2026-08-14-templemate-pixel-foreground-readiness-diagnosis-control-b.md`

## Changed Prerequisite Evidence

Planning directly observed exact serial `39011FDJH00FQ8` on 2026-08-16 as
Pixel 8 / `shiba`, ADB `device`, awake, with
`com.jimmy1768.komainu.dev/expo.modules.devlauncher.launcher.DevLauncherActivity`
current and focused. Installed package evidence remains version `1.0.0`, code
`1`, target SDK 36. This satisfies the prior Director wake/unlock prerequisite.

## Objective

Resume only the accepted Phase 3 tenant-gate and Assistance UI runtime review
against the already integrated JavaScript source. Use the established
target-fenced USB/Metro attachment method, place TempleMate at the updated
authenticated-unbound gate, and pause for Director visual review. No source
repair or native rebuild is part of this packet.

## Entry Fence

Control independently verifies:

- accepted implementation ancestry and clean canonical/isolated states;
- exact Pixel serial/model/codename, ADB `device`, awake/unlocked state and
  exact installed package/version/code/target SDK/MainActivity;
- TempleMate development launcher or package surface is visibly current, with
  no NotificationShade/keyguard covering it;
- TCP 8081 and the exact serial reverse are unowned at entry;
- byte-identical temporary dependency access; and
- full mobile tests, lint and verify.

Stop on a target, lock, ownership, package or source mismatch. Do not ask the
Director to scan a Metro/Expo QR code or enter device input.

## Authorized Runtime

Control may:

1. start one explicit dummy/development localhost Metro session on port 8081
   from an isolated worktree containing the accepted source;
2. wait for the listener, then create only exact serial
   `adb reverse tcp:8081 tcp:8081`;
3. deliver the established exact local `exp+templemate` URL once to the exact
   TempleMate package;
4. reach deterministic signed-in dummy state and use the visible dummy reset
   to establish authenticated-unbound state; and
5. verify the updated unbound-gate checkpoint.

Required visible evidence:

- Header sign-out remains available;
- QR-first finish-setup guidance and one TempleMate in-app scan action are the
  only productive unbound path;
- ordinary navigation/account screens and fixture-link controls are absent;
- Contact Temple is absent;
- CameraView opens only from TempleMate's own scan action and Cancel returns
  to the same unbound gate without binding or data mutation; and
- Android Back cannot reveal hidden account screens.

Return exactly
`director_action_required: phase3_updated_unbound_gate_review`
only after this screen is visibly ready. Leave packet Metro and exact reverse
running and wait for Director review. Do not scan a trusted temple QR, bind a
tenant or advance the remaining Assistance/bound-state matrix without a later
Planning direction.

## Cleanup And Boundaries

On failure or later explicit completion, remove only packet Metro, exact
reverse, temporary dependency access and named package-scoped evidence;
preserve the installed client and unrelated device state.

No source/test/config/dependency/native edit, repair, build/install/version
increment, real QR/API/OAuth/provider/email, payment/admin, production,
deployment, release, push, secret or unrelated external action is authorized.

Current blocker: none.
