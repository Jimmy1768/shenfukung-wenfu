# Expo V1 Final UI Refinement Evidence Continuation Plan

Status: accepted for direct runtime dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Canonical Planning base:
`bb4099bb03df62bd8287bcd7f26b039872b9c7bf`

Accepted source baseline:
`46e8f3f94059fb7faf070e345c3df4bd54b4a9f2`

Accepted partial-evidence commit:
`396aee203b0d8d13f3e12f0fd8fa7b740ab525fa`

Accepted predecessor plan:
`ops/docs/plans/EXPO_V1_FINAL_UI_REFINEMENT_RUNTIME_VALIDATION_PLAN.md`

## Objective

Complete only the remaining installed-client evidence from the accepted
partial report:

1. visibly invoke CameraView's existing Cancel control without a QR result;
2. visibly complete dependent create/edit/delete transitions; and
3. visibly complete draft-registration create/edit transitions while retaining
   the paid fixture's read-only/no-payment state.

The feedback repairs, CameraView Android Back, paid read-only fixture, reset,
tests, and cleanup already passed. Do not repeat them except for entry/final
state or safe recovery required by this narrow continuation.

This is observation-only. It changes the evidence method, not product behavior
or acceptance semantics.

## Accepted Evidence-Method Corrections

### CRUD text input

The predecessor prescribed non-Latin temporary values, but the Pixel's stock
ADB input mechanism crashed before committing any mutation. Existing accepted
device evidence already proves zh-TW rendering throughout TempleMate. This
continuation validates CRUD state transitions, not Unicode keyboard support.

Use only these packet-local ASCII values:

- dependent create: `Test Dependent`, relationship `Family`;
- dependent edit: `Test Dependent Updated`;
- draft registration create: `Test Registration`;
- draft registration edit: `Test Registration Updated`.

Do not type personal data. Use only ordinary visible controls and the accepted
target-fenced ADB interaction mechanism. If ASCII input also fails before a
committed mutation, record the exact evidence and stop that subslice without
classifying a product defect.

### QR-free CameraView Cancel

Before the camera subslice, Planning may request one Director physical
precondition: leave the connected Pixel aimed at a blank, non-reflective
surface containing no QR code, barcode, screen text, or other machine-readable
pattern. This is not a scan or payload presentation.

Control must stop and send exactly
`director_action_required: blank_camera_surface` if it cannot truthfully prove
that precondition from the visible camera state. Planning owns the Director
callback. Control must not ask the Director to scan, open another scanner, or
show a QR.

After the precondition:

1. open only TempleMate's in-app CameraView;
2. require its visible Cancel control before any scan result;
3. press Cancel once;
4. require CameraView to close to signed-in, unbound TempleMate home with no
   prompt, error, tenant change, or app exit.

If an unsolicited result occurs again, record Cancel as untested and do not
inspect, retain, or retry against any image/payload.

## Entry Gate And Runtime Method

Control independently verifies:

- canonical source contains the accepted source baseline and is clean;
- the accepted partial report commit is available and changes only its named
  report path;
- full mobile tests remain 48/48, followed by `yarn lint` and `yarn verify`;
- exact Pixel serial `39011FDJH00FQ8`, installed
  `com.jimmy1768.komainu.dev`, MainActivity, `1.0.0`/code `1`/target SDK 36,
  TCP 8081, reverse-map, dependency-equivalence, and temporary-symlink fences
  pass.

Use only:

    adb -s 39011FDJH00FQ8 reverse tcp:8081 tcp:8081
    TEMPLEMATE_CLIENT_MODE=dummy BUILD_MODE=development npx expo start --dev-client --localhost --port 8081

Open only Metro's emitted local `exp+templemate` URL through target-fenced ADB.
Never ask the Director to scan a Metro/Expo QR.

## Runtime Sequence

1. Reach canonical dummy fixture state and sign in with the existing fixture
   account.
2. Complete the QR-free CameraView Cancel observation above.
3. Create, visibly verify, edit, visibly verify, and delete only the packet's
   temporary dependent. Require no duplicate row and preservation of fixture
   rows.
4. Confirm the paid registration remains read-only with no payment/checkout
   action.
5. Create and visibly verify only the packet's temporary draft registration;
   edit it and require the updated row without duplication. Registration
   deletion is not part of V1.
6. Use visible dummy reset once to remove all packet-created state and require
   restoration of the canonical one-dependent/one-registration fixture.
7. Perform exact runtime cleanup.

## Evidence And Acceptance

The immutable report records `passed`, `untested`, or `defect` for:

- QR-free visible CameraView Cancel to foreground unbound home;
- dependent create;
- dependent edit without duplication;
- dependent delete preserving fixture rows;
- paid registration read-only/no payment;
- draft registration create;
- draft registration edit without duplication;
- final reset;
- exact cleanup and Git state.

Completion requires affirmative visible evidence for CameraView Cancel and all
five CRUD transitions. An input/camera automation limitation remains an
evidence gap, not a defect. A reproducible app behavior failure is a defect and
must include the first prevented criterion without source repair.

Control may use one ephemeral Implementer only for immutable report preparation
and static/diff checks. Control owns runtime/device actions, review, cleanup,
accepted-report integration, and terminal delivery. Incorporate the accepted
partial report commit unchanged when integrating an accepted continuation
outcome.

## Cleanup

At terminal, reset dummy fixture state if runtime reached a safe resettable
state; stop only packet Metro; remove only exact serial `tcp:8081` reverse,
temporary dependency symlink, and packet-created ephemeral evidence. Preserve
the installed development client and camera permission. Prove no listener,
reverse, symlink, evidence, Git, or staging residue.

## Explicit Exclusions

- no source/config/test/dependency/lockfile/native/Rails/Vue edit or repair;
- no QR presentation, intentional/physical QR scan, payload inspection,
  simulation, injection, media retention, Expo launcher scanner, or Pixel
  native scanner;
- no OAuth/provider/browser, real API, payment, production, deployment,
  release, push, or external service;
- no build, EAS, prebuild, APK/AAB, signing, install/uninstall, or package
  mutation;
- no version/build change: retain `1.0.0 / Android 1 / iOS 1`;
- no work on the separate Rails/web OAuth account-resolution track owned by
  Control A.

## Terminal Classifications

- `expo_v1_final_ui_refinement_runtime_validation_complete`;
- `expo_v1_final_ui_refinement_runtime_defect_found`;
- `expo_v1_final_ui_refinement_runtime_evidence_partial`;
- `director_action_required`;
- `runtime_cleanup_reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

Current classification:
`expo_v1_final_ui_refinement_evidence_continuation_authorized`.

First blocker: none at dispatch. The optional Director physical precondition is
requested only if Control cannot prove a QR-free blank camera surface.
