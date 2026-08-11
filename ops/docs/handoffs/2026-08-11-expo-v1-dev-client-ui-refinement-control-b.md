# Expo V1 Development-Client UI Refinement — Control B Packet

## Identity

- Accepted plan and immutable criteria:
  `ops/docs/plans/EXPO_V1_DEV_CLIENT_UI_REFINEMENT_PLAN.md`; Planning’s direct
  dispatch dated 2026-08-11.
- Control and Planning tasks: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0` -> Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Repository, worktree, branch, and base HEAD:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`;
  `/private/tmp/shengfukung-wenfu-expo-ui-refinement`;
  `codex/expo-v1-dev-client-ui-refinement`;
  `6173c6bccf24ac335d400b5a6d681224e9368914`.
- Immutable packet identity and implementation attempt:
  `2026-08-11-expo-v1-dev-client-ui-refinement-control-b`; attempt 1.

## Scope

- Objective: refine the integrated account-only TempleMate Expo client’s
  existing screens, states, locale/theme presentation, and navigation for
  deterministic dummy-mode device review. Product operations and adapter
  contracts remain unchanged.
- Exact editable paths:
  - `mobile/App.js` and existing/new native presentation paths below
    `mobile/app/ui/`, `mobile/app/locales/`, and `mobile/theme/`;
  - existing mobile test/guard paths below `mobile/__tests__/` and
    `mobile/scripts/`;
  - `mobile/package.json` and `mobile/yarn.lock` for only pinned
    `expo-doctor@1.20.1` plus the project-local `yarn doctor` script;
  - this Control packet only.
- Explicit exclusions: all Rails/Vue/Planning files; adapter contract/domain
  semantics below `mobile/app/real/`; dummy repository/business behaviors;
  OAuth, payment/provider, admin/guest/staff, live tenant/QR camera, secrets,
  production/deployment, EAS/cloud, AAB/signing/store/OTA, pushes, version or
  build-number changes, canonical-main merge, Control A coordination, and any
  new runtime dependency.
- Required implementation:
  - extract reusable presentational primitives/screens from the current
    monolithic account UI where useful; keep every existing account destination
    and operation reachable with predictable native back behavior and no
    horizontal primary navigation clipping;
  - derive coherent light/dark surfaces, cards, fields, notices/errors,
    typography, system bars, and state cues from existing TempleMate tokens;
  - replace mixed hard-coded bilingual control copy with complete zh-TW/en
    presentation copy for this surface; retain visible dummy disclosure and
    non-secret fixture credentials;
  - preserve/clarify loading, empty, validation, pending, success,
    retry/error, confirmation, paid-read-only, binding-failed, switch-cleanup,
    keyboard/safe-area/back/resume states; use existing assets only;
  - preserve strict dummy/real adapter selection and no-network dummy behavior.
- Required package boundary: add only `expo-doctor@1.20.1` as a pinned project
  local `devDependency`, lock it, and expose `yarn doctor` without npx/global
  lookup. Registry access is limited to that package’s normal metadata/integrity
  resolution if cache is insufficient.
- Required automated evidence: frozen dependency install; offline
  `EXPO_OFFLINE=1 CI=1 yarn doctor`; mobile tests; lint; version/API config
  verification; focused presentation/state and real-adapter/dummy-boundary
  regression proof; `git diff --check`.
- Device evidence (Control-only after accepted implementation): repeated
  serial/model/OS/status/storage/package preflight for `39011FDJH00FQ8` Pixel
  8; APK identity/digest verification or local debug rebuild; target-fenced
  install/replace of only `tw.com.templemate.dev`; only required ADB reverse
  mappings; local Metro in explicit dummy/development mode; app launch/reload,
  app-scoped logs, and sanitized dummy screenshots covering the plan’s journey.
  Android 17/API 37 is accepted runtime evidence for target SDK 36.
- Uncertain device outcome fence: any disconnect/timeout/ambiguous install
  requires read-only package reconciliation on this exact serial before retry.
  Do not inspect or alter unrelated device data/packages. Leave the accepted
  dev client installed; no uninstall/rollback is planned.

## Evidence And Boundaries

- Observed at dispatch: clean canonical main at exact base; prior integration
  ancestor `6cab3f1b52ebaeaf68667f19a3c804f8d9c43079`; Pixel serial is observed
  connected and package absent but must be preflighted again; previous debug
  APK/digest is documented candidate only and must be verified.
- Unknown until checks: exact package cache state, final local APK identity,
  current device storage, and visual runtime evidence.
- Incident correction: no. `AGENTS.md` is excluded.

## Repair, Handoff, And Dispatch

- This is not a repair. Planning receives no packet before terminal outcome.
- Persistent Handoff: no; eligibility checked before model selection.
- One ephemeral Implementer: `gpt-5.6-terra/high`. Coupled extraction of the
  complete native account presentation, dual locale/theme state coverage,
  offline project-local Doctor reproducibility, and device-ready verification
  make this deeper bounded implementation; Sol is not needed and Luna is never
  ephemeral.
- Implementer boundaries: edit only listed paths; do not stage, commit, merge,
  push, deploy, access secrets/providers, mutate physical devices, operate
  Metro/ADB, expand dependencies, or contact Planning/Control A. Return direct
  evidence to Control.

## Control Closeout

- Implementer result accepted after independent Control review. Source commit:
  `afcee90ad2e4ab019389a929c12b13af99c6cc3f` (`feat: refine TempleMate Expo
  UI`). The committed source changes are limited to `mobile/App.js`, the three
  reusable `mobile/app/ui/` modules, `mobile/__tests__/ui-refinement.test.js`,
  and the pinned Doctor entry/lockfile. No adapter/domain, Rails/Vue, runtime
  dependency, version, build-value, or excluded path changed.
- Independent local checks passed:
  - `yarn install --frozen-lockfile --offline`;
  - `yarn test` (17/17); `yarn lint` (23 application modules); and `yarn
    verify` (TempleMate (Dev), `1.0.0`, target/compile SDK 36, Android/iOS
    build values 1);
  - `EXPO_OFFLINE=1 CI=1 yarn doctor` (17/17 checks passed, using the pinned
    project-local `expo-doctor@1.20.1`);
  - `EXPO_OFFLINE=1 CI=1 yarn expo export --platform android` (Android bundle,
    601 modules); and `git diff --check`.
- Physical-target preflight and result:
  - only serial `39011FDJH00FQ8`: Pixel 8 / `shiba`, Android 17 / API 37;
    `tw.com.templemate.dev` was absent before this packet;
  - local foreground `npx expo prebuild --platform android --no-install` plus
    `./gradlew :app:assembleDebug --no-daemon --console=plain` passed. The
    build reported compile/target SDK 36 and the Expo dev-client/launcher
    plugins; it produced `app-debug.apk` SHA-256
    `c510d6a297c6bd809838a8d373f9efa061de3490371a9227ba7c0df566c70ced`;
  - artifact metadata and `aapt` proved `tw.com.templemate.dev`, debug,
    `1.0.0`/code 1, min SDK 24, target SDK 36. One exact `adb install` returned
    `Success`; subsequent package evidence confirms the same identity;
  - Control created only `adb reverse tcp:8081 tcp:8081`, started Metro with
    `TEMPLEMATE_CLIENT_MODE=dummy BUILD_MODE=development npx expo start
    --dev-client --localhost --port 8081`, opened the exact local
    `exp+templemate` development-client URL, and captured app-scoped logs.
    Metro was then stopped and the temporary reverse mapping removed. The
    installed development client remains on the Pixel as authorized.
- Sanitized local visual evidence under
  `/private/tmp/templemate-ui-refinement-evidence/` proves the real Pixel
  journey: visible signed-out dummy disclosure; deterministic sign-in; account
  home; profile; dependent management; registration’s paid fixture as
  read-only; explicit tenant-switch cleanup confirmation and completed switch;
  and English/dark settings. The Expo developer overlay initially appeared
  over the successfully loaded JS bundle and was dismissed with standard Back;
  it was not an application exception. App-scoped log review showed `Running
  \"main\"` with no fatal JS error. All captured product content is dummy-only
  and contains no provider, Rails, or personal data.
- Final packet disposition: `accepted_frozen_outcome`. No repair, rollback,
  cross-track merge, real adapter, or external action remains authorized.
  The isolated branch contains the source commit above and this closeout commit;
  canonical `main` remains untouched at the dispatch base. Planning owns the
  next separately authorized V1 candidate gate; Control B has no continuation
  after the paired receipt.
