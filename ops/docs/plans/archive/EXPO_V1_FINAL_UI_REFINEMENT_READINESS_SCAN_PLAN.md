# Expo V1 Final UI Refinement Readiness Scan Plan

Status: accepted for direct report-only dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Director authority: the accepted V1 roadmap places final UI refinement after
functional stabilization and uses the installed development client for UI work

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted runtime baseline:
`9d3fcc5ef28aadb56c3889cb721f9ba2f40a419e`

Relevant accepted evidence:

- `ops/docs/plans/EXPO_V1_FUNCTIONAL_STABILIZATION_PLAN.md`;
- `ops/docs/plans/EXPO_V1_DEV_CLIENT_UI_REFINEMENT_PLAN.md`;
- `ops/docs/handoffs/2026-08-12-expo-v1-dummy-device-validation-after-render-repair-control-b.md`;
- `ops/docs/handoffs/2026-08-12-expo-v1-dummy-oauth-and-temple-qr-runtime-validation-control-b.md`;
- `ops/docs/handoffs/2026-08-12-expo-v1-tenant-switch-confirmation-runtime-validation-control-b.md`.

Mature structural reference, read-only:
`/Users/jimmy1768/Projects/DojoMate-Expo`

DojoMate is evidence only for established native layout, safe-area, form,
keyboard, navigation, loading, and accessibility patterns. Its roles, product
copy, features, dependencies, OAuth, payments, push, and branding are not
TempleMate authority.

## Objective

Perform one report-only installed-client readiness scan that inventories the
concrete remaining UI-refinement work for TempleMate V1 after functional
stabilization. Do not refine or repair the UI in this packet.

The scan must distinguish:

- confirmed UI defects;
- usable-but-rough presentation findings;
- interaction paths that pass visibly;
- evidence gaps that remain untested;
- non-UI product, provider, payment, deployment, and release work that is
  intentionally outside final UI refinement.

This is the input to a later bounded final-UI implementation plan. It must not
invent a design system, new feature, navigation architecture, or product
requirement.

## Parent Classification

The V1 dummy development-client functional-stabilization parent is complete at
the accepted baseline:

- all ten source acceptance criteria in
  `EXPO_V1_FUNCTIONAL_STABILIZATION_PLAN.md` have accepted implementation and
  automated evidence;
- the installed client now visibly passes signed-out rendering, fixture email
  sign-in, account-only navigation, profile and principal account surfaces,
  preferences, support/privacy/reset/sign-out, dummy Google and Apple success,
  camera permission behavior, untrusted QR rejection, trusted binding, retained
  prior temple before switch confirmation, and final switch to
  `示範宮廟二號`;
- `1.0.0 / Android 1 / iOS 1`, API 36, Komainu identifiers, dummy no-network,
  account-only scope, and no-payment behavior remain intact.

This classification does not claim real API/OAuth validation, payment,
distribution, production readiness, or final UI acceptance.

## Known Evidence To Reconcile

Do not treat these as predetermined defects; inspect and classify them:

1. The latest broad device run could not obtain deterministic visible list
   transitions for dependent create/edit/delete and registration create/edit
   through keyboard automation, although repository/interaction tests pass and
   earlier device evidence reached dependent management and paid registration
   presentation.
2. One earlier Metro session emitted an Expo `CameraView` warning that children
   are unsupported. Both physical QR scans later succeeded, and warning
   recurrence/impact was not retained. Inspect the current in-app camera
   presentation without scanning a QR and classify whether source/layout work
   belongs in final UI refinement.
3. Earlier accepted UI evidence found the account menu, keyboard-safe forms,
   scrolling, locale/theme changes, and edge-to-edge presentation usable. Recheck
   only for concrete remaining roughness after subsequent feature additions.

## Entry Gate And Runtime Method

Control independently verifies:

- canonical source includes the accepted runtime baseline and is clean;
- full `yarn test` passes with 46 tests, followed by `yarn lint` and `yarn
  verify`;
- exact Pixel serial `39011FDJH00FQ8`, installed package
  `com.jimmy1768.komainu.dev`, launcher, `1.0.0`/code `1`/target SDK 36, TCP
  8081, reverse-map, dependency-equivalence, and temporary-symlink preconditions
  pass.

Use only:

    adb -s 39011FDJH00FQ8 reverse tcp:8081 tcp:8081
    TEMPLEMATE_CLIENT_MODE=dummy BUILD_MODE=development npx expo start --dev-client --localhost --port 8081

Open only Metro's emitted local `exp+templemate` URL through target-fenced ADB.
Never ask the Director to scan a Metro/Expo QR. A standard Back action may
dismiss the expected developer overlay after bundle load.

No Director physical action is required. Do not open another scanner or present
a QR fixture.

## Observation Matrix

Use deterministic dummy data and inspect each surface only far enough to record
presentation and interaction findings.

### Signed-out and authentication

- zh-TW and English signed-out layout;
- dummy disclosure, fixture credentials, email form, Google/Apple controls,
  OAuth result label, signup, and recovery;
- keyboard visibility, focus, scrolling, error/notice stacking, and touch
  targets.

Do not repeat real OAuth or provider/browser behavior.

### Signed-in shell and navigation

- safe area, status bar, header, sign-out action, wrapped account navigation,
  selected state, scroll position, and long localized labels;
- light and dark presentation in zh-TW and English;
- no admin surface or role switch.

### Account forms and collections

- profile form;
- dependent create, select/edit, and delete with visible list transitions;
- unpaid/draft registration create and edit with visible list transitions;
- paid fixture remains clearly read-only and has no payment/checkout action;
- certificates, events, services, galleries, empty/loading/error presentation
  available through deterministic test state without inventing server data;
- assistance, contact, privacy, closure confirmation, and safe unknown-screen
  behavior.

If targeted automation cannot produce a truthful visible transition, record the
exact evidence limitation rather than classifying the feature broken.

### Temple connection and camera presentation

- unbound, trusted-bound, pending-switch, and final switched presentations
  using existing deterministic link/state actions only;
- open TempleMate's `Scan demo QR` CameraView only to inspect its layout,
  instruction placement, cancel action, safe area, and current scoped warning;
- do not scan, simulate, inject, retain, or display any QR payload/media;
- do not revoke/reset camera permission or access microphone/audio.

## Review Criteria

For every finding, record:

- exact screen/state/locale/theme;
- visible symptom and reproducible action;
- severity: blocking interaction, misleading state, accessibility/usability,
  or polish;
- likely surface: JavaScript layout/component/copy/state, native configuration,
  or unknown;
- whether it is already covered by a focused test;
- smallest bounded refinement direction without writing implementation detail.

Do not create findings from taste alone. A proposed visual change needs visible
evidence or a direct inconsistency with the accepted TempleMate theme/copy/
interaction authority.

## Evidence And Report

Control may use one ephemeral Implementer only for immutable report preparation
and static/diff checks. Control owns exact Metro/ADB/device/UI observation,
acceptance, cleanup, integration, and terminal delivery.

The immutable report must include:

- complete pass/finding/untested matrix for the surfaces above;
- prioritized confirmed findings grouped into one later implementation packet
  where possible;
- explicit nonfindings and rejected inventions;
- CameraView warning recurrence and impact classification;
- dependent/registration runtime-evidence classification;
- exact cleanup and Git state;
- first blocker, if any, to a later final-UI refinement phase.

Retain only sanitized app-scoped evidence. Do not retain credentials, raw Metro
URL, QR image/payload/media, provider/browser content, secrets, personal data,
or broad logs. Delete packet-created screenshots/hierarchies after extracting
the sanitized findings unless the report requires an explicitly safe,
repository-owned visual artifact; none is required by default.

## Cleanup

At terminal, stop only packet Metro; remove only exact serial `tcp:8081`
reverse, temporary dependency symlink, and packet-created temporary UI
evidence. Preserve installed app and camera permission. Prove no listener,
reverse, symlink, evidence, Git, or staging residue.

Control integrates only its immutable report/packet and sends one terminal
directly to Planning.

## Explicit Exclusions

- any source, UI, copy, test, dependency, configuration, lockfile, native,
  Rails, or Vue edit;
- QR scanning or physical callback, real API/OAuth, provider, secrets, payment,
  admin, deployment, production, release, OTA, store, analytics, push, or media;
- prebuild, local/EAS build, APK/AAB, signing, install/uninstall, or package
  mutation;
- version/build increment: retain `1.0.0 / Android 1 / iOS 1`;
- adopting DojoMate product behavior or adding new TempleMate features.

## Terminal Classifications

- `expo_v1_final_ui_refinement_readiness_report_complete`;
- `runtime_observation_failed`;
- `runtime_cleanup_reconciliation_required`;
- `true_planning_design_gap`;
- `no_evidence_backed_direct_repair_remaining`.

Current classification:
`expo_v1_final_ui_refinement_readiness_scan_authorized`.

First blocker: none.
