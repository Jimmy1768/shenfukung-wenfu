# Expo V1 Final UI Refinement Implementation Plan

Status: accepted for direct implementation dispatch to Control A after commit

Created: 2026-08-12

Owner: Wenfu Planning

Director authority: approved the next step after accepting the final UI
refinement readiness scan

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`74ffad700af204d6c839db6fa5e6227099d41fcf`

Accepted runtime evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-final-ui-refinement-readiness-control-b.md`

## Objective

Implement the two concrete JavaScript presentation repairs confirmed by the
installed-client readiness scan:

1. keep transient success/error feedback scoped to its originating screen or
   an explicit destination, so it cannot persist across unrelated Settings
   surfaces or a dummy reset and cannot retain stale-language text; and
2. consume Android Back while TempleMate's in-app CameraView is active, close
   the scanner, and return to the originating TempleMate home surface instead
   of exiting to the Pixel launcher.

Add focused deterministic regression proof. Do not redesign the UI, add a
navigation framework, change product copy, or treat the dependent and
registration device-evidence gaps as implementation defects.

## Parent Classification

The report-only final UI readiness scan is complete and accepted at the
baseline above. It found no broad usability failure and no visual redesign
requirement. The final UI refinement parent remains incomplete until:

- this bounded source repair is accepted and integrated; and
- a separately planned Control B installed-client run visibly validates both
  repairs and completes the still-missing dependent/registration transition
  evidence where deterministic device interaction permits.

Real API/OAuth, payment, distribution, production, and final release
acceptance remain separate parents.

## Confirmed Mechanisms

### Transient feedback

The accepted Pixel observation reproduced this sequence:

- an empty support submission created a validation error;
- the same error remained visible after navigation to Privacy, Closure, and
  Settings;
- dummy reset returned the locale to zh-TW while a success notice remained in
  English as `Saved`.

Canonical source confirms one global `error` and one global rendered-string
`notice` are displayed above every signed-in `AccountSurface`. Ordinary
`setScreen` navigation does not assign feedback ownership or clear unrelated
feedback. `reset()` calls `setNotice(t.saved)` before the reset preference data
causes the locale to return to zh-TW, so the stored English string survives the
locale transition.

This is a JavaScript feedback-lifecycle and localization defect. It is not an
adapter, persistence, Rails, or native defect.

### Android Back from CameraView

The accepted Pixel observation opened TempleMate's own CameraView from the
unbound home surface and pressed Android Back. The app exited to the Pixel
launcher.

Canonical source confirms the app-level BackHandler consumes Back only when
`screen !== 'home'`. CameraView is represented by `cameraOpen` while the screen
remains `home`, so the handler returns `false` and Android performs its default
app-exit behavior.

This is a JavaScript camera/session navigation defect. The repair must close
only TempleMate's active scanner through an in-app close outcome; it must not
change permission, scan, binding, or native configuration semantics.

## Owned Paths

Control A may authorize one ephemeral Implementer to edit only:

- `mobile/App.js`;
- `mobile/app/ui/` for at most one small pure transient-feedback helper, if
  needed;
- `mobile/app/tenant/camera_surface.js` and/or one small pure camera/back
  helper under `mobile/app/tenant/`, if needed;
- `mobile/__tests__/ui-refinement.test.js`;
- `mobile/__tests__/camera-session.test.js`;
- at most one new focused JavaScript state test under `mobile/__tests__/`.

Control-owned immutable packet/report paths under `ops/docs/handoffs/` are
also allowed. No other product, adapter, OAuth, QR trust, dummy repository,
configuration, dependency, lockfile, native, Rails, Vue, version, build, or
Planning path is owned.

## Required Implementation

### Feedback ownership and localization

1. A validation error or success notice must have an explicit presentation
   lifetime tied to its originating screen/action or an intentional destination
   screen.
2. Leaving that owning screen for an unrelated screen must remove the transient
   feedback before the destination renders.
3. An action that intentionally returns to a destination with success feedback
   may still show that feedback there, but later navigation must not leak it to
   Privacy, Closure, another account menu surface, or signed-out state.
4. Dummy reset must clear every pre-reset error/notice. If reset presents new
   success feedback, it must render from the resulting locale rather than a
   stored string from the previous locale; showing no reset success notice is
   also acceptable.
5. A locale change must never leave visible transient feedback in the previous
   language. Clear it or render it from a stable localized key in the current
   locale.
6. Preserve existing pending guards, failure rollback, retry dismissal,
   support/contact/privacy/closure adapter calls, sign-out cleanup, and
   account-only behavior.

Prefer one small testable feedback-lifecycle authority over scattered
screen-specific clears. Do not introduce a global state library or navigation
dependency.

### Camera Android Back behavior

1. While TempleMate's in-app camera surface is active, Android Back must be
   consumed and must close the scanner to the existing unbound home connection
   surface.
2. The close outcome must preserve current binding, account, locale/theme,
   camera permission, and any unrelated form state.
3. The visible Cancel control must retain its existing behavior.
4. When CameraView is not active, preserve existing behavior: Back from a
   non-home account screen returns home, while Back from ordinary home remains
   available to Android.
5. Preserve first-result locking, permission loading/denial/retry/blocked
   behavior, invalid/untrusted safety, QR-only rear-camera configuration, and
   no-audio behavior.

Use one active Back authority for the scanner path. Do not add React Navigation
or change Expo/native configuration.

## Focused Regression Proof

Deterministic tests must prove:

- an assistance/contact validation error is removed before an unrelated
  Privacy, Closure, Settings, or account-menu destination renders;
- an intentionally forwarded success notice is owned by its destination and
  is cleared on later unrelated navigation;
- reset cannot retain pre-reset feedback;
- after English -> reset/zh-TW, no stored English `Saved` notice remains;
- preference-write failure and locale/theme rollback remain intact;
- active CameraView consumes one Android Back action, closes the camera, keeps
  the screen at home, and preserves binding/account state;
- camera-closed Back behavior remains unchanged for home and non-home screens;
- visible Cancel and permission/session state behavior remain covered;
- no feedback or Back-handler path changes adapter, OAuth, QR parsing/trust,
  tenant cleanup, or native behavior.

Source-regex-only assertions are insufficient for the new state transitions;
at least one focused test must exercise the selected pure feedback and Back
state authority directly.

## Checks

Control independently runs:

- focused feedback/UI and camera/back tests;
- full `yarn test`;
- `yarn lint`;
- `yarn verify`;
- `git diff --check`, staged diff check, and exact owned-path review;
- focused scans proving no dependency, lockfile, config, native, version/build,
  adapter, OAuth, QR-trust, Rails, or Vue change.

Use only an already available byte-identical dependency tree through the
accepted temporary-symlink method if the isolated worktree lacks
`node_modules`; remove it before acceptance. Do not install or copy
dependencies.

Expo Doctor, export, prebuild, Gradle, EAS, APK, and physical-device evidence
are not acceptance criteria for this JavaScript-only source packet. Runtime
proof is separately sequenced through Control B using the installed client and
the established USB Metro method.

## Acceptance Criteria

1. Transient feedback no longer crosses unrelated screen, reset, or locale
   boundaries.
2. Intentional destination feedback remains possible without becoming global
   stale state.
3. Android Back from active CameraView closes to TempleMate home and does not
   exit the app.
4. Ordinary Android Back, visible camera Cancel, permission, scan-lock, QR
   trust, binding, and account behavior remain unchanged.
5. Focused behavioral tests and the full mobile checks pass.
6. TempleMate/Komainu identity, API 36, and `1.0.0 / Android 1 / iOS 1` remain
   unchanged.
7. No dependency, configuration, lockfile, native, adapter, Rails, Vue, or
   unrelated UI change occurs.
8. Canonical and isolated Git states are clean with staging empty after Control
   integration.

## Explicit Exclusions

- dependent or registration CRUD implementation changes; their remaining gap
  is installed-device transition evidence only;
- CameraView child-warning repair; its recurrence/impact remains unconfirmed
  and it is not one of the accepted implementation defects;
- design-system, navigation-architecture, branding, copy, feature, admin,
  payment, provider, real API/OAuth, analytics, push, or media work;
- dependency/manifest/lockfile/config/version/build/native changes;
- Metro, ADB, Pixel/device interaction, screenshots, QR scan, camera media, or
  runtime validation;
- Expo Doctor, prebuild, local/EAS build, APK/AAB, install/uninstall, signing,
  deployment, release, OTA, store, production, or push.

## Sequencing

After accepted source integration, Planning will write and dispatch one
separate Control B runtime-validation plan. It will reuse the installed
development client and exact accepted USB Metro method to:

- reproduce the former feedback sequence and prove feedback is scoped and
  localized after navigation/reset;
- open TempleMate's in-app CameraView and prove Android Back returns to home;
- complete dependent create/edit/delete and draft registration create/edit
  visible transitions where deterministic device interaction permits, recording
  any exact remaining evidence limitation without inventing a product defect.

No native rebuild is expected for either accepted JavaScript repair.

Current classification:
`expo_v1_final_ui_refinement_implementation_authorized`.

First blocker: none.
