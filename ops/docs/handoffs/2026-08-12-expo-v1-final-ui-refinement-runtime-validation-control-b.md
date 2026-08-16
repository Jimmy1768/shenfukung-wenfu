# Expo V1 final UI refinement runtime validation — Control packet

## Identity and authority

- Accepted plan/base: `ops/docs/plans/EXPO_V1_FINAL_UI_REFINEMENT_RUNTIME_VALIDATION_PLAN.md` at `44815e184b08f6fe57deb6c16607f5abfb8e1779`.
- Accepted source baseline: `46e8f3f94059fb7faf070e345c3df4bd54b4a9f2`.
- Control/Planning: Wenfu Control B `019fe020-e92e-7770-984f-b59acd547ab0` to Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Worktree/branch: `/private/tmp/shengfukung-wenfu-expo-v1-final-ui-runtime-validation`; `codex/expo-v1-final-ui-runtime-validation`.
- Immutable packet identity/attempt: `2026-08-12-expo-v1-final-ui-refinement-runtime-validation-control-b`, attempt 8.

## Scope

- Objective: record only installed Pixel dummy-mode evidence for accepted feedback scoping/reset, CameraView Back/Cancel, visible dependent CRUD, and draft-registration create/edit transitions.
- Owned editable path: `ops/docs/handoffs/2026-08-12-expo-v1-final-ui-refinement-runtime-validation-control-b.md` only.
- Device fence: serial `39011FDJH00FQ8`; existing `com.jimmy1768.komainu.dev` client only. Use documented USB reverse, explicit dummy Metro, and local `exp+templemate` URL.
- Required checks: source entry scan; full mobile test count 48, lint, verify; target/package/version/SDK/TCP/reverse/dependency-equivalence preflight; exact matrix; fixture reset; Metro/reverse/symlink/evidence cleanup; Git/diff checks.
- Exclusions: all source/config/test/dependency/native/Rails/Vue changes; QR/media/warning investigation; OAuth/provider/real API/payment; build/EAS/install; deployment/release/push; secrets and production.

## Execution and boundaries

- One ephemeral Implementer: `gpt-5.6-terra/medium`, report/static evidence only. It edits only this packet/report and performs no Metro, ADB, device, symlink, external, staging, commit, or integration action.
- Persistent Handoff: ineligible; this is one bounded observation pass.
- Control owns runtime, acceptance, cleanup, integration, commit, and terminal disposition. No intermediate Planning traffic.
- Any observed failure under unchanged criteria is a nonterminal Control repair finding; no repair/source work is authorized by this packet.

## Control closeout state

- Runtime result matrix and cleanup receipt are recorded below. Integration,
  direct terminal delivery, and the paired Planning receipt remain Control- and
  Planning-owned lifecycle actions outside this Implementer return.
- Expected terminal classifications: `expo_v1_final_ui_refinement_runtime_validation_complete`, `expo_v1_final_ui_refinement_runtime_defect_found`, `expo_v1_final_ui_refinement_runtime_evidence_partial`, `metro_or_device_attachment_failed`, `runtime_cleanup_reconciliation_required`, or `no_evidence_backed_direct_repair_remaining`.

## Static source and test-evidence preparation

This preparation is read-only. It does not constitute device, Metro, ADB, or
runtime evidence. The required test commands were deliberately not run by the
Implementer; Control must record its own command summaries if it executes them.

| Surface | Static source evidence | Existing automated coverage | Runtime observation still required |
| --- | --- | --- | --- |
| Feedback ownership/navigation | `mobile/app/ui/feedback.js` represents errors and notices with explicit owners; `mobile/App.js` filters both on navigation. | `mobile/__tests__/ui-refinement.test.js` covers an assistance error disappearing on an unrelated destination and a Settings-owned notice surviving only on Settings. | Verify the visible originating-screen error, Settings-only success, and absence on unrelated screens. |
| Reset, locale, sign-out, and resume feedback clearing | `mobile/App.js` clears transient feedback on dummy reset, locale update, sign-out, and active app resume. | `mobile/__tests__/ui-refinement.test.js` asserts the empty feedback shape for reset/locale; `mobile/__tests__/functional-stabilization-state.test.js` covers resettable preferences. | Verify the visible zh-TW reset state contains no stale English or prior feedback. |
| Active CameraView Android Back | `mobile/app/tenant/back.js` consumes Back while the camera is open and resolves to closed home; `mobile/App.js` installs that resolver. | `mobile/__tests__/camera-session.test.js` asserts the active-camera, non-home, and home Back cases. | Verify foreground app retention, closed CameraView, signed-in/unbound home, and no intervening prompt/error/exit. |
| CameraView Cancel | `mobile/App.js` supplies CameraView `onCancel` through the close handler; `mobile/app/tenant/camera_surface.js` exposes the visible Cancel control. | `mobile/__tests__/camera-session.test.js` covers camera-session close/reopen mechanics, not the rendered Cancel interaction. | Reopen once and verify the visible Cancel route returns to the same in-app home surface without scanning. |
| Dependent transitions | `mobile/App.js` renders row selection plus create/update/delete actions; `mobile/app/dummy/repository.js` assigns new IDs, updates the selected ID, and filters only the selected ID on delete. | `mobile/__tests__/dummy-repository.test.js` covers deterministic create/update/delete/reset state transitions. | Verify rendered create, selected-row edit without duplication, and deletion while fixture rows remain. |
| Registration transitions | `mobile/App.js` disables read-only rows and selects only editable rows; `mobile/app/dummy/repository.js` creates drafts and rejects updates to read-only records. | `mobile/__tests__/dummy-repository.test.js` covers draft create/update and read-only rejection; `mobile/__tests__/account-surface.test.js` covers the read-only predicate. | Verify the paid fixture is visibly read-only/no payment action, then draft create/edit without duplication. |
| Dummy reset mechanics | `mobile/app/dummy/adapter.js` delegates reset to the repository; `mobile/app/dummy/repository.js` restores the seed and counters; `mobile/App.js` clears local dependent/registration/binding/feedback state. | `mobile/__tests__/dummy-repository.test.js` and `mobile/__tests__/functional-stabilization-state.test.js` cover deterministic reset state. | Use final visible reset and verify temporary records are absent and the required deterministic presentation state is restored. |

### Required check record

| Check | Implementer result | Control runtime result |
| --- | --- | --- |
| Source entry scan against accepted baseline | completed read-only; no source edit made | passed; accepted baseline retained for this observation attempt |
| Focused feedback/UI tests | not run by Implementer | covered by full mobile suite; 48/48 passed |
| Focused camera/Back tests | not run by Implementer | covered by full mobile suite; 48/48 passed |
| Full mobile test suite (expected plan count: 48) | not run by Implementer | passed; 48/48 |
| Mobile lint | not run by Implementer | passed |
| Mobile verify | not run by Implementer | passed |
| Exact Pixel/package/launcher/version/code/target-SDK preflight | not run by Implementer | passed: Pixel 8/shiba; `com.jimmy1768.komainu.dev`; MainActivity; `1.0.0`/code `1`/target SDK `36` |
| Dependency equivalence preflight | not run by Implementer | passed |

## Runtime matrix — Control observation only

Each row records exactly one factual status: `passed`, `partial`, `untested`,
or `defect`. A `defect` records only visible
symptom, reproducible action, likely boundary, and first prevented criterion;
an `untested` or `partial` row records the exact reached control/state and
reason. Do not place credentials, URLs, QR data/media, logs, or personal data
in this table.

| Required evidence row | Status | Sanitized factual observation / first prevented criterion if applicable |
| --- | --- | --- |
| Assistance error is scoped to its originating screen | `untested` | System overlay prevented visual observation; no TempleMate UI subslice was reached. |
| Intentional support success forwards to Settings only | `untested` | System overlay prevented visual observation; no TempleMate UI subslice was reached. |
| Reset/locale clears stale English and pre-reset feedback | `untested` | System overlay prevented visual observation; no TempleMate UI subslice was reached. |
| Active CameraView Back closes to foreground TempleMate home | `untested` | System overlay prevented visual observation; CameraView was not opened. |
| Visible CameraView Cancel closes to home | `untested` | System overlay prevented visual observation; CameraView was not opened. |
| Dependent create visible transition | `untested` | System overlay prevented visual observation; no CRUD data mutation occurred. |
| Dependent edit visible transition without duplication | `untested` | System overlay prevented visual observation; no CRUD data mutation occurred. |
| Dependent delete preserves fixture rows | `untested` | System overlay prevented visual observation; no CRUD data mutation occurred. |
| Paid registration remains read-only with no payment action | `untested` | System overlay prevented visual observation; no registration data mutation occurred. |
| Draft registration create visible transition | `untested` | System overlay prevented visual observation; no registration data mutation occurred. |
| Draft registration edit visible transition without duplication | `untested` | System overlay prevented visual observation; no registration data mutation occurred. |
| Final dummy reset restores fixture state | `untested` | No app data mutation occurred before the overlay prevented visual observation. |
| Exact runtime/repository cleanup | `passed` | Packet Metro PIDs stopped; target TCP 8081 reverse absent; temporary symlink/evidence absent; no listener or staging residue; branch worktree contains only this report; `git diff --check` passed. |

### Runtime attachment outcome

The exact dummy Metro/reverse process started and the local app deep link was
delivered once. Android's NotificationShade remained foreground after the
permitted standard Back, status-bar collapse, and target-fenced dismissal
gestures. Window focus evidence identified TempleMate MainActivity as the
focused app while NotificationShade retained current focus; the available UI
hierarchy contained only system-shade controls. This is an attachment/visual-
observation failure, not a product defect. No TempleMate UI validation, CRUD
data mutation, QR/media action, OAuth/provider/real-API action, or source or
product mutation occurred.

## Exact Control cleanup and terminal fields

### Cleanup receipt

| Required terminal field | Control value |
| --- | --- |
| Final visible dummy reset attempted only after a safe resettable state | passed; no app-data mutation occurred, so no reset was required for restoration. |
| Packet Metro identity and stop result | passed; exact packet Metro PIDs stopped. |
| Exact target serial TCP 8081 reverse removal result | passed; reverse absent. |
| Temporary dependency symlink absent | passed. |
| Packet-created screenshots/UI hierarchies/evidence removed | passed; temporary evidence absent. |
| No packet listener remains | passed. |
| Installed development client preserved; camera permission unchanged | passed. |
| Canonical source unchanged from accepted baseline | passed; no source or product mutation occurred. |
| Runtime worktree Git status and staging status | passed; branch worktree contains only this report and no staging residue. |
| No raw URL, QR/payload/media, credential, secret, or personal-data retention | passed. |
| `git diff --check` | passed. |

### Terminal record

| Required terminal field | Control value |
| --- | --- |
| Selected terminal classification | `metro_or_device_attachment_failed` |
| Acceptance decision and first blocker, if any | No product acceptance decision. First blocker: persistent system NotificationShade prevented truthful TempleMate visual observation. |
| Immutable packet identity and implementation attempt | `2026-08-12-expo-v1-final-ui-refinement-runtime-validation-control-b`, attempt 8 |
| Final branch commit and canonical integration | Control commit/integration pending Planning review; report ready for isolated commit. |
| Direct terminal delivery to Planning | Control-owned action after integration; no direct delivery was made by the Implementer. |
| Paired Planning receipt | Planning-owned action after Control direct delivery; no receipt exists for this Implementer return. |
| Parent classification, continuation disposition, and next owner/action | Parent remains incomplete; `no_evidence_backed_direct_repair_remaining`; Planning/Director must clear or unlock the Pixel system overlay and dispatch renewed runtime validation. |
| Authority boundary confirmation | passed: observation-only; no excluded actions. |
