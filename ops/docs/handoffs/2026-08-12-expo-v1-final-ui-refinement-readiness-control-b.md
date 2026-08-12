# Expo V1 final UI refinement readiness — Control report packet

## Identity and authority

- Accepted plan/base:
  `ops/docs/plans/EXPO_V1_FINAL_UI_REFINEMENT_READINESS_SCAN_PLAN.md` at
  `4f35db981d003e969bbd061b480739de72149042`.
- Accepted runtime baseline:
  `9d3fcc5ef28aadb56c3889cb721f9ba2f40a419e`.
- Source Control -> Planning: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0` -> Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Worktree/branch/base:
  `/private/tmp/shengfukung-wenfu-expo-v1-final-ui-refinement-readiness`;
  `codex/expo-v1-final-ui-refinement-readiness`;
  `4f35db981d003e969bbd061b480739de72149042`.
- Packet/attempt:
  `2026-08-12-expo-v1-final-ui-refinement-readiness-control-b`, attempt 7.

## Bounded report-only observation

- Control records only visible, reproducible UI defects, usable-but-rough
  findings, passes, and exact untested limitations across accepted account-only
  dummy surfaces. It does not edit or repair any product surface.
- Entry gate: accepted baseline ancestry; full mobile test count `46`, lint,
  verify; exact Pixel 8 / `shiba` Komainu dev package/launcher/version/code/SDK;
  clean TCP 8081/reverse preconditions; byte-identical dependency source and
  temporary isolated symlink.
- Runtime uses only the established USB reverse, explicit dummy/development
  Metro, and its local `exp+templemate` URL through the fenced package. No real
  API/OAuth/provider/browser, QR callback, physical scan, link typing, package
  mutation, source/config/test/dependency/version/native change, build/EAS,
  deployment, release, or push.
- CameraView may open only for layout/instruction/cancel/safe-area/warning
  observation: no scan, QR fixture, payload/media interaction, microphone/audio
  action, or permission reset/revoke.
- DojoMate is read-only structural evidence only for established native
  safe-area/form/keyboard/navigation/loading/accessibility patterns; no
  DojoMate feature, product, dependency, OAuth, payment, or branding is
  adopted.

## Evidence and allocation

- One ephemeral Implementer: `gpt-5.6-terra/medium`, lowest sufficient for
  static report preparation only. It may edit only this report, run static/diff
  checks, and inspect DojoMate read-only. It cannot run Metro/ADB/UI/symlink,
  stage/commit, or mutate external/runtime state. Control owns runtime,
  acceptance, cleanup, integration, and terminal delivery. Persistent Handoff
  is ineligible.
- Every finding must name visible state/locale/theme, reproducible action,
  severity, likely surface, focused-test coverage, and the smallest bounded
  refinement direction. No taste-only or invented redesign findings.
- Exact cleanup: only packet Metro process, serial `tcp:8081` reverse,
  temporary isolated `mobile/node_modules` symlink, and temporary app-scoped
  screenshots/hierarchies. Preserve installed client and camera permission.

## Safe receipt and terminal boundary

- Retain only sanitized app outcomes, check summaries, bounded UI finding
  classifications, explicit evidence limits, cleanup/Git state, terminal
  classification/disposition, and next owner/action. Never retain credentials,
  raw Metro URL, link values, QR image/payload/media, provider/browser content,
  secrets, personal data, or broad logs.
- The report is the sole deliverable. Planning receives one terminal after
  cleanup and isolated commit; canonical integration occurs only after Planning
  acceptance.

## Static evidence map (prepared; not a UI observation)

All entries below are source/test mapping only. They neither assert a visible
pass nor create a UI finding. The fourth column records the pre-observation
evidence context used to prepare the now-completed runtime receipt matrix.

| Surface | Direct TempleMate presentation source | Focused static coverage | Known accepted evidence / pending Control receipt |
| --- | --- | --- | --- |
| Signed-out, email, signup/recovery, Google/Apple, result label | `mobile/App.js:97-100`; locale copy `mobile/app/ui/copy.js:1-18`; shared controls `mobile/app/ui/primitives.js:3-15` | `mobile/__tests__/ui-refinement.test.js:9-35` proves complete locale/disclosure and the `oauthOutcome` lookup; OAuth behavior is separately covered in `mobile/__tests__/dummy-oauth.test.js`. | Pre-observation context: earlier runtime sign-in/provider success was accepted baseline evidence. The completed matrix records the current zh-TW/en, theme, keyboard, notice/error, focus, scroll, and touch result. |
| Account shell, header, wrapped menu, locale/theme | `mobile/App.js:90-95,119,123`; `mobile/app/ui/theme.js:1-6`; `mobile/app/ui/primitives.js:3-15` | `mobile/__tests__/account-surface.test.js:6-21`; `mobile/__tests__/ui-refinement.test.js:16-27`. | Pre-observation context: static coverage establishes account-only menu model, locale/theme selectors, token authority, wrapped tab list, and alert role. The completed matrix records visible localized wrapping/selected-state/safe-area results. |
| Profile and dependents | `mobile/App.js:107-108,120,123`; dummy mutation state `mobile/app/dummy/repository.js` | `mobile/__tests__/dummy-repository.test.js:11-30` covers profile plus dependent create/update/delete deterministically. | Pre-observation context: earlier device evidence visibly passed profile save; dependent list transitions were not deterministically witnessed under bounded keyboard automation. The completed matrix retains that evidence gap, not a broken-flow claim. |
| Draft/unpaid and paid read-only registrations | `mobile/App.js:109,120`; labels `mobile/app/ui/copy.js:8,16` | `mobile/__tests__/dummy-repository.test.js:20-25` covers create/update and paid-update rejection; `mobile/__tests__/account-surface.test.js:6-12` asserts paid read-only model. | Pre-observation context: earlier device evidence visibly presented the paid fixture as read-only, while unpaid draft create/edit transitions were not deterministically witnessed. The completed matrix retains that limitation, not a broken-flow claim. |
| Certificates, discover collections, support/contact/privacy/closure, safe unknown | `mobile/App.js:106,110-116`; shared notices/forms `mobile/app/ui/primitives.js:8-15` | `mobile/__tests__/account-surface.test.js:23-38` covers dummy support/privacy/closure/reset; `mobile/__tests__/functional-stabilization-state.test.js:27-31` covers safe declared/unknown screen resolution. | Pre-observation context: earlier accepted runtime evidence covered collections, support/contact/privacy, reset, and sign-out. The completed matrix records the current presentation result and stale-notice defect. |
| Tenant connection: unbound, bound, switching, final switched | `mobile/App.js:94,104-106,115`; binding state `mobile/app/tenant/binding.js` | `mobile/__tests__/tenant-binding.test.js:15-42`; `mobile/__tests__/ui-refinement.test.js:38-46`. | Pre-observation context: static tests preserve the prior visible tenant until confirmation and prove confirmation-only cleanup. The completed matrix distinguishes newly observed bound/unbound states from prior accepted switching evidence. |
| CameraView layout, instruction, cancel, warning | `mobile/app/tenant/camera_surface.js:8-32`; entry in `mobile/App.js:106`; copy `mobile/app/ui/copy.js:7,15` | `mobile/__tests__/camera-session.test.js:10-80` covers permission/session behavior and rear-only QR/no-audio source constraints. | Pre-observation context: source nests instruction `View`/`Text` inside `CameraView` (`camera_surface.js:32`), associated with the earlier unsupported-children warning. The completed matrix records the distinct Android-Back defect; warning recurrence/impact remains untested. |

## Runtime observation receipt matrix

Control records only a visible, reproducible outcome. A row is `passed`,
`partial`, `untested`, or `defect`; no static entry above is promoted to a
finding without runtime evidence. Each defect states its state/action/symptom,
severity, likely surface, focused-test coverage, and smallest bounded
direction.

| Surface | Receipt status | Sanitized runtime observation or exact limitation | Finding fields, if applicable |
| --- | --- | --- | --- |
| Signed-out + auth controls | passed | zh-TW signed-out surface observed; dummy fixture sign-in reached the signed-in account-only state. | No visible refinement finding recorded. |
| Account shell/navigation + locale/theme | passed | Signed-in account shell/navigation observed. English + dark settings presentation was observed; reset later returned locale to zh-TW. | No visible navigation/layout finding recorded. |
| Profile + dependent CRUD | partial | Profile observed. Dependents presentation reached the existing row and form, but no successful dependent create, edit, delete, or committed visible list transition was executed. | Preserve as untested transition evidence, not a broken-flow claim. |
| Draft/unpaid + paid read-only registrations | partial | Paid registration was visibly read-only and draft presentation was reached, but no successful registration create, edit, or committed visible list transition was executed. | Preserve as untested transition evidence, not a broken-flow claim. |
| Collections + support/privacy/closure/unknown | defect | Explore collections, support, privacy-request, and closure-confirmation presentations were observed; support/privacy were not submitted and closure was not executed. An empty-support validation notice persisted onto later Privacy, Closure, and Settings screens; after reset it remained while locale reset to zh-TW and the success notice was still English (`Saved`). | **State/locale:** settings flow; English + dark before reset, zh-TW after reset. **Action:** trigger empty support validation, navigate to Privacy/Closure/Settings, then reset. **Symptom:** stale validation/success notices cross screen and reset/locale boundaries. **Severity:** misleading state. **Likely surface:** JavaScript screen/notice state and localization. **Focused coverage:** `mobile/__tests__/account-surface.test.js:23-38` covers dummy operations but not notice clearing or locale-reset rendering. **Smallest direction:** confine transient notices/errors to their originating screen/action and reset/localize them coherently. |
| Tenant states | partial | Trusted bound state was observed before reset; reset then visibly restored the unbound state. Pending-switch and final-switch presentation are not newly witnessed here and are cited only from accepted prior runtime evidence. | No new tenant UI finding recorded. |
| CameraView presentation | defect | From unbound home, TempleMate's in-app CameraView opened and its instruction was visible. No QR was scanned and no camera media was captured or retained. Android Back exited to the Pixel launcher rather than returning to TempleMate/home. CameraView warning recurrence is untested because logs/media were excluded. | **State/locale/theme:** unbound dummy home, observed in the current scoped presentation pass. **Action:** open `Scan demo QR`, then use Android Back. **Symptom:** Back leaves the app instead of returning to the in-app home connection surface. **Severity:** blocking interaction. **Likely surface:** JavaScript camera/session navigation or Android-back handling; exact mechanism unknown. **Focused coverage:** `mobile/__tests__/camera-session.test.js:10-80` covers session/permission state, not Android Back navigation. **Smallest direction:** make the active CameraView consume Back by closing to the originating TempleMate home surface. |
| DojoMate structural comparison | passed | Read-only structural reference only; it supplied safe-area, form/keyboard, scroll, navigation, loading, and accessibility lenses. No DojoMate feature or dependency was adopted. | No finding or adoption task. |
| Runtime/repository cleanup | passed | Control removed only packet Metro processes, serial `tcp:8081` reverse, temporary `node_modules` symlink, and packet-created evidence directory. Final worktree contained only this report; `git diff --check` passed. | No cleanup defect recorded. |

## DojoMate read-only structural comparison

- Read-only sources inspected: `src/screens/MainAppFrame.js:4,69,365-382`
  (safe-area/insets and shell); `src/screens/member/settings/SettingsAccount.js:1-28,120-140,298-304`
  (scrolling account form and labelled password-visibility control).
- TempleMate already has the relevant structural primitives: safe-area and
  keyboard wrapper in `mobile/App.js:93`, keyboard-persistent scroll surfaces
  in `mobile/App.js:90,99`, explicit control/alert roles and labels in
  `mobile/app/ui/primitives.js:3-15`, and wrapped tab navigation in
  `mobile/App.js:95,123`.
- This comparison creates no adoption task and no finding. It only gives
  Control concrete runtime lenses: safe-area edges, keyboard reachability,
  scroll retention, loading presentation, selected navigation, and accessible
  labels/states. DojoMate roles, navigation architecture, features,
  dependencies, product copy, payment, OAuth, and branding remain excluded.

## Reconciled nonfindings and evidence limits

- Dependent and registration CRUD remain presentation-observed but transition-
  untested: no successful create/edit/delete commit was executed in this scan.
  Deterministic repository coverage exists, so this is not a broken-flow claim.
- CameraView's unsupported-children warning remains untested for recurrence and
  impact because this scan retained no logs or camera media. The Android-Back
  result is separately recorded above as a concrete visible defect.
- Do not propose visual changes for preference/theme, safe-area, keyboard,
  navigation, loading, or accessibility from the DojoMate comparison alone.
  A later refinement direction requires a visible TempleMate inconsistency or
  reproducible usability evidence.
- No static source evidence authorizes or implies real API/OAuth, payment,
  provider, deployment, release, or production work.

## Static check receipt

- Permitted preparation completed: read-only source/test and DojoMate structural
  inspection, followed by this Control-supplied sanitized runtime receipt.
- Prohibited actions not run by this Implementer: Metro, ADB, device/UI,
  network, symlink, build, EAS, external, staging, commit, merge, and push.
- No source/test/configuration path was edited by this Implementer. Control
  owns final cleanup, repository-state confirmation, integration, and any
  terminal disposition.

## Terminal classification and disposition

- Classification: `expo_v1_final_ui_refinement_readiness_complete`.
- Disposition: `accepted_frozen_outcome`.
- Next owner/action: Planning review and canonical integration.
- Active continuation: none.
