# Expo V1 final UI refinement runtime validation — renewed Control packet

## Identity

- Accepted unchanged plan/base: `ops/docs/plans/EXPO_V1_FINAL_UI_REFINEMENT_RUNTIME_VALIDATION_PLAN.md` at `44815e184b08f6fe57deb6c16607f5abfb8e1779`.
- Source baseline: `46e8f3f94059fb7faf070e345c3df4bd54b4a9f2`.
- Prior attempt: `2026-08-12-expo-v1-final-ui-refinement-runtime-validation-control-b`, `metro_or_device_attachment_failed`; changed prerequisite is the Director-reported foreground TempleMate app.
- Control/Planning: Wenfu Control B `019fe020-e92e-7770-984f-b59acd547ab0` to Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Worktree/branch: `/private/tmp/shengfukung-wenfu-expo-v1-final-ui-runtime-validation-2`; `codex/expo-v1-final-ui-runtime-validation-2`.
- Immutable packet identity/attempt: `2026-08-12-expo-v1-final-ui-refinement-runtime-validation-renewal-control-b`, attempt 9.

## Bounded authority

- Observe only: accepted feedback localization/scoping, CameraView Back and Cancel without QR/media, and dummy dependent create/edit/delete plus draft registration create/edit visible transitions.
- Device fence: only Pixel serial `39011FDJH00FQ8`; only installed `com.jimmy1768.komainu.dev`; only documented USB reverse and Metro local `exp+templemate` method.
- Packet-owned editable path: this report only. No source/config/test/dependency/native/Rails/Vue or product changes; no OAuth/provider/real API/payment/EAS/build/install/deploy/release/push.
- Required evidence: preflight; 48 test/lint/verify; each runtime matrix row; final visible fixture reset; exact Metro/reverse/symlink/evidence cleanup; clean Git/diff.

## Implementer and lifecycle

- One ephemeral Implementer: `gpt-5.6-terra/medium`, report/static preparation only; may edit only this report; cannot run Metro/ADB/device/symlink/external action/stage/commit/merge.
- Persistent Handoff ineligible. Control owns runtime, cleanup, acceptance, commit/integration, and one terminal delivery. No intermediate Planning traffic.
- No product repair is authorized if validation fails; record evidence truthfully.

## Closeout

- Runtime matrix is transcribed below. Exact runtime cleanup, disposition,
  commit/integration, terminal delivery, and paired Planning receipt remain
  Control/Planning lifecycle action.

## Implementer static-preparation evidence (attempt 9)

Prepared by the packet's one report-only ephemeral Implementer. This is
read-only source inspection at the packet base, not Metro, device, or runtime
evidence. It neither changes nor substitutes for Control's required visible
validation. No fixture credentials, URLs, QR/media, payloads, personal data,
or broad logs were retained.

- Repository/worktree/branch/HEAD observed: `/private/tmp/shengfukung-wenfu-expo-v1-final-ui-runtime-validation-2`, `codex/expo-v1-final-ui-runtime-validation-2`, `44815e184b08f6fe57deb6c16607f5abfb8e1779`.
- `mobile/App.js` retains scoped feedback construction, destination filtering,
  and clear-on-resume/reset/locale paths. The assistance submission requests a
  Settings-owned saved notice; unrelated navigation must remove it.
- `mobile/app/tenant/back.js` resolves an open camera to handled home with the
  camera closed. `mobile/App.js` wires that resolver to Android Back and keeps
  the existing CameraView cancel callback on the same close path.
- `mobile/App.js` retains dummy dependent create/update/delete controls and
  registration create/update controls; paid registration cards are disabled
  before their press callback. Source inspection cannot prove a keyboard entry
  or a visually committed mutation.
- `mobile/App.js` retains dummy reset state restoration and clears transient
  feedback. Source inspection cannot prove the final visible fixture state.
- No runtime command, test, dependency action, device/ADB action, symlink,
  external action, staging, or commit was performed by this Implementer.

## Runtime evidence matrix — resumed Control observations

Control reported the required preflight checks passed: focused tests and full
`yarn test` completed with 48/48 passing tests, and `yarn lint` plus `yarn
verify` passed. The Pixel/package/version fence and dependency equivalence also
passed. `Static seam` is readiness context, never pass proof.

| Criterion | Status | Static seam | Control runtime outcome |
| --- | --- | --- | --- |
| Assistance error is scoped to its originating screen | passed | `mobile/App.js`: feedback owner plus navigation filter | In English/dark, empty Need help Send showed its error on Need help only; it was absent after navigation to Settings, Privacy, and Closure. |
| Intentional support success is forwarded to Settings only | passed | `mobile/App.js`: assistance action supplies `noticeOwner: 'settings'` | A harmless packet-local support message returned to Settings with visible English Saved; Privacy showed no Saved. |
| Reset/locale clears stale English and pre-reset feedback | passed | `mobile/App.js`: locale success clears feedback; dummy reset clears feedback and restores adapter snapshot | Visible reset returned zh-TW, unbound state, and no prior feedback or Saved notice. |
| Active CameraView Android Back closes to foreground TempleMate home | passed | `mobile/app/tenant/back.js` and `mobile/App.js` BackHandler wiring | Initial in-app CameraView showed its instruction and Cancel. One Android Back closed it to foreground signed-in, unbound TempleMate home with no prompt, error, or exit. |
| Visible CameraView Cancel still closes to home | untested | `mobile/App.js`: CameraView `onCancel` uses its existing close callback | On the one reopened CameraView, preview exited immediately after an unsolicited camera result before Cancel could be used. No QR image, payload, or media was inspected or retained; no scan, presentation, or injection was intended. This is an evidence gap, not a product defect. |
| Dependent create visible transition | untested | `mobile/App.js`: dummy dependent add action invokes adapter create path | Initial fixture row/form presentation was reached. Standard Android text entry rejected the required non-Latin packet-local value with an InputShellCommand NullPointerException; no mutation occurred. This is an automation gap, not a product defect. |
| Dependent edit visible transition without duplication | untested | `mobile/App.js`: selected list row sets dependent id; update path is id-gated | No temporary dependent could be created because of the stated text-entry automation gap; no edit mutation occurred. |
| Dependent delete visible transition preserving fixture rows | untested | `mobile/App.js`: delete is disabled without a selected id and invokes adapter delete path | No temporary dependent could be created because of the stated text-entry automation gap; no delete mutation occurred. |
| Paid registration remains read-only/no payment | passed | `mobile/App.js`: read-only registration card is disabled before edit callback; no payment action is rendered here | The paid fixture was visibly read-only and exposed no payment action. |
| Draft registration create visible transition | untested | `mobile/App.js`: blank registration invokes adapter create path | The same non-Latin text-entry automation gap prevented temporary draft creation; no mutation occurred. |
| Draft registration edit visible transition without duplication | untested | `mobile/App.js`: editable list row selects id; update path is id-gated | No temporary draft could be created because of the stated text-entry automation gap; no edit mutation occurred. |
| Final dummy reset restores fixture state | passed | `mobile/App.js`: dummy reset reloads adapter snapshot, clears forms/binding/feedback | Visible reset restored the unbound zh-TW fixture with one registration and one dependent. |
| Exact runtime/repository cleanup | passed | This Implementer performed no runtime setup or created evidence | Packet Metro stopped; the serial reverse was absent; temporary symlink and evidence were absent; no listener remained; only this report was unstaged; diff check passed. |

## Control recording boundary

- Record `passed` or `untested` for each row only from the resumed runtime
  observation.
- For a defect, record only the visible symptom, one reproducible action, the
  JavaScript/native/unknown boundary, and first prevented criterion; do not
  propose a repair in this report.
- If keyboard automation cannot truthfully commit a CRUD mutation, retain the
  exact reached control/state as `untested` or `partial`; it is not a product
  defect without a reproducible visible failure.
- Control alone owns Metro, target-fenced device operation, visible reset,
  cleanup, acceptance, integration, and terminal delivery.

## Terminal boundary

- Classification: `expo_v1_final_ui_refinement_runtime_evidence_partial`.
- Continuation disposition: `no_evidence_backed_direct_repair_remaining`.
- Parent classification: incomplete; affirmative CameraView Cancel and
  dependent/draft CRUD transition evidence remains absent.
- Next owner/action: Wenfu Planning decides whether this partial evidence is
  sufficient or issues a narrow continuation that (a) authorizes/directs a
  controlled text-entry mechanism for the required generic non-Latin CRUD
  values and (b) establishes a QR-free camera environment to test visible
  Cancel without a result.
- Authority boundary: passed. No product repair, source/config/test/dependency/
  native/Rails/Vue change, external/provider/secret action, payment,
  build/install, deployment, release, staging, commit, merge, push, or
  intentional QR presentation, scan, injection, inspection, or retention
  occurred; all packet exclusions remain intact.
