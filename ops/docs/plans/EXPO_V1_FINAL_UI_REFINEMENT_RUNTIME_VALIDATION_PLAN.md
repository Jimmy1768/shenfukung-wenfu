# Expo V1 Final UI Refinement Runtime Validation Plan

Status: accepted for direct runtime dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Director authority: approved the plan-sequenced next step after the final UI
readiness scan; the accepted implementation plan explicitly sequences this
installed-client validation

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted source baseline:
`46e8f3f94059fb7faf070e345c3df4bd54b4a9f2`

Accepted source plan:
`ops/docs/plans/EXPO_V1_FINAL_UI_REFINEMENT_IMPLEMENTATION_PLAN.md`

Accepted source evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-final-ui-refinement-control-a.md`

Accepted failure/readiness evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-final-ui-refinement-readiness-control-b.md`

## Objective

Reuse the installed TempleMate development client and established USB Metro
method to validate the two accepted JavaScript UI repairs:

1. transient feedback remains scoped and localized across navigation, dummy
   reset, and locale changes; and
2. Android Back from TempleMate's active CameraView closes the scanner to the
   TempleMate home surface without exiting the app.

In the same bounded dummy session, complete the previously missing visible
dependent create/edit/delete and draft-registration create/edit transition
evidence. These are validation gaps, not predetermined product defects.

This packet is observation-only. It does not edit or repair source.

## Parent Classification

The final UI refinement source subslice is complete at the accepted baseline.
The final UI refinement parent remains incomplete pending affirmative installed-
client evidence for both repairs and truthful classification of the two CRUD
transition gaps.

Passing this packet may complete the V1 dummy development-client final UI
refinement parent. It does not complete real API/OAuth, payment, distribution,
production, release, or store readiness.

## Entry Gate

Before runtime setup, Control independently verifies:

- canonical source contains accepted commit `46e8f3f` or retains the accepted
  feedback/back helpers and integration unchanged;
- feedback state stores localized keys with explicit screen owners, navigation
  filters feedback by destination, and reset/locale/sign-out/resume clear the
  accepted transient state;
- the active-camera Back resolver consumes Back to home while closed-camera
  home/non-home behavior remains unchanged;
- the CameraView component, Cancel path, permission/session behavior, QR trust,
  adapters, and tenant lifecycle remain unchanged;
- focused feedback/UI and camera/back tests, full `yarn test` with 48 tests,
  `yarn lint`, and `yarn verify` pass;
- exact Pixel serial `39011FDJH00FQ8`, installed package
  `com.jimmy1768.komainu.dev`, launcher, `1.0.0`/code `1`/target SDK 36, TCP
  8081, reverse-map, dependency-equivalence, and temporary-symlink
  preconditions pass.

Use only the established USB attachment:

    adb -s 39011FDJH00FQ8 reverse tcp:8081 tcp:8081
    TEMPLEMATE_CLIENT_MODE=dummy BUILD_MODE=development npx expo start --dev-client --localhost --port 8081

Open only Metro's emitted local `exp+templemate` URL through target-fenced ADB.
Never ask the Director to scan a Metro/Expo QR. A standard Back action may
dismiss the expected developer overlay after bundle load.

No Director physical action is required. Do not use or present any QR code.

## Deterministic Starting State

1. Reach TempleMate's explicit dummy signed-out surface.
2. Use the accepted fixture email credentials to reach account-only home.
3. Use visible dummy reset once if necessary to restore canonical fixture data,
   zh-TW/light preferences, unbound temple state, and known account data.
4. Do not type personal data. Use only packet-local generic values for the
   temporary CRUD records and remove them through the visible flow or final
   dummy reset.

## Required Runtime Sequence

### A. Feedback navigation and localization

1. Set English and dark mode through the visible Settings controls.
2. Open `Need help`, leave the message empty, and activate `Send` once.
3. Require the validation error to be visible on the originating assistance
   screen.
4. Return to Settings, then open Privacy and Closure through visible controls.
   Require the assistance validation error to be absent on every unrelated
   destination.
5. Return to `Need help`, submit one harmless nonpersonal dummy message, and
   require the intentional English `Saved` success notice on Settings.
6. Navigate to Privacy and require that success notice to be absent there.
7. Return to Settings, establish one current English success notice through an
   ordinary accepted dummy action if needed, then activate visible dummy reset
   exactly once.
8. Require the resulting locale to be zh-TW and require no retained English
   `Saved` or pre-reset error/success notice.

If any required visible state fails, record the exact screen/action/outcome,
stop that subslice, and continue only with independent subslices that remain
safe and truthful. Do not retry repeatedly or repair source.

### B. Camera Android Back

1. From the reset unbound home surface, activate only TempleMate's visible
   `掃描示範 QR` action.
2. Require TempleMate's in-app CameraView to be visible. Do not present, scan,
   simulate, inject, or retain any QR image/payload/media.
3. Press Android Back exactly once through target-fenced device control.
4. Require all of the following:
   - the CameraView is closed;
   - TempleMate remains foregrounded;
   - the account home/temple-connection surface is visible;
   - the account remains signed in and temple state remains unbound;
   - no permission prompt, scanner retry, error, or app exit occurs.
5. Reopen CameraView once and use the visible Cancel control once to confirm it
   retains the same in-app return behavior. Do not scan a QR.

Do not inspect or alter camera permission outside the app. The prior
CameraView child-warning is excluded; this packet validates only the accepted
Back and existing Cancel outcomes.

### C. Dependent CRUD visible transitions

1. Open Dependents and record the initial deterministic list.
2. Create one temporary dependent using the generic packet-local values
   `測試家屬` and `家人`; require a new visible list row.
3. Select only that row, change its name to `測試家屬更新`, and activate the
   visible update action once; require the visible row to update without a
   duplicate row.
4. Select only the updated temporary row and activate visible delete once;
   require the row to disappear while pre-existing fixture rows remain.

If keyboard automation cannot produce a truthful committed transition, record
the exact control/state reached and classify the row as untested. Do not call
the feature broken without a reproducible product failure.

### D. Draft registration visible transitions

1. Open Registrations and confirm the paid fixture remains visibly read-only
   with no payment/checkout action.
2. Create one temporary draft registration using generic dummy values; require
   one new visible draft row.
3. Select only that editable draft row, change its registrant name to
   `測試登記更新`, and activate visible update once; require the visible row to
   update without duplication.
4. Do not attempt to edit the paid fixture. Registration deletion is not a V1
   account surface and is not part of this packet.
5. Use visible dummy reset after evidence capture to remove the temporary draft
   and restore fixture state.

As with dependents, an automation limitation is an evidence gap rather than a
defect unless a reproducible app failure is observed.

## Evidence Matrix

The immutable Control report must record one factual status—`passed`,
`partial`, `untested`, or `defect`—for each row:

- assistance error scoped to its originating screen;
- intentional support success forwarded to Settings only;
- reset/locale clears stale English and pre-reset feedback;
- active CameraView Back closes to foreground TempleMate home;
- visible CameraView Cancel still closes to home;
- dependent create visible transition;
- dependent edit visible transition without duplication;
- dependent delete visible transition preserving fixture rows;
- paid registration remains read-only/no payment;
- draft registration create visible transition;
- draft registration edit visible transition without duplication;
- final dummy reset restores fixture state;
- exact runtime/repository cleanup.

For a defect, retain only the exact visible symptom, reproducible action,
likely JavaScript/native/unknown boundary, and the first prevented acceptance
criterion. Do not invent repair scope in this observation packet.

## Evidence Handling And Cleanup

Control may use one ephemeral Implementer only for immutable report preparation
and static/diff checks. Control owns exact Metro, target-fenced ADB, device/UI,
acceptance, cleanup, integration, and terminal delivery.

Retain only sanitized app outcomes and test summaries. Do not retain fixture
credentials, raw Metro URL, QR image/payload/media, camera media, broad logs,
personal data, secrets, or provider/browser content. Packet-created screenshots
or UI hierarchies are temporary and must be deleted after factual transcription.

At terminal:

- restore deterministic fixture state through visible dummy reset if runtime
  reached a safe resettable state;
- stop only packet Metro;
- remove only exact serial `tcp:8081` reverse, temporary dependency symlink,
  and packet-created ephemeral evidence;
- preserve the installed development client and existing camera permission;
- prove no listener, reverse, symlink, evidence, Git, or staging residue.

Control integrates only its immutable safe report/packet and sends exactly one
terminal directly to Planning.

## Explicit Exclusions And Invariants

- no source/config/test/dependency/lockfile/version/native/Rails/Vue edit or
  repair;
- no physical QR callback, CameraView scan, Expo launcher scanner, Pixel native
  scanner, payload injection, or camera media;
- no Google/Apple OAuth repeat, real API/OAuth, provider/browser/account,
  secret, Rails/server, payment, analytics, push, deployment, production,
  release, OTA, store, or external action;
- no prebuild, local/EAS build, APK/AAB, signing, install/uninstall, or package
  mutation;
- no version/build increment: retain `1.0.0 / Android 1 / iOS 1`;
- no CameraView warning investigation/repair, design-system work, new feature,
  dependent/registration redesign, or registration delete behavior.

## Acceptance Criteria

1. The former assistance-error leak is absent across Settings, Privacy, and
   Closure.
2. Intentional support success appears on Settings but disappears on unrelated
   navigation.
3. Dummy reset restores zh-TW without stale English or pre-reset feedback.
4. Android Back from active CameraView returns to foreground TempleMate home,
   and visible Cancel retains the same in-app outcome.
5. Dependent create/edit/delete transitions are visibly committed, without
   duplicate/collateral fixture changes, or any exact remaining automation gap
   is truthfully recorded.
6. Paid registration remains read-only; draft create/edit transitions are
   visibly committed without duplication, or any exact remaining automation
   gap is truthfully recorded.
7. Final reset and exact runtime cleanup pass; canonical source stays clean and
   unchanged.
8. TempleMate/Komainu identity, API 36, and `1.0.0 / Android 1 / iOS 1` remain
   unchanged.

## Terminal Classifications

- `expo_v1_final_ui_refinement_runtime_validation_complete`;
- `expo_v1_final_ui_refinement_runtime_defect_found`;
- `expo_v1_final_ui_refinement_runtime_evidence_partial`;
- `metro_or_device_attachment_failed`;
- `runtime_cleanup_reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

Current classification:
`expo_v1_final_ui_refinement_runtime_validation_authorized`.

First blocker: none.
