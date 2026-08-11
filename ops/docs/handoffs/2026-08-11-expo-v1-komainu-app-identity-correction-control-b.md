# Expo V1 Komainu App-Identifier Correction — Control B Packet

## Identity And Authority

- Accepted authority: canonical `main` at
  `35f06e50a75062584a6375ca8e04a2672a385b96`, with the Director-corrected
  criteria in `ops/docs/plans/EXPO_V1_DEV_CLIENT_UI_REFINEMENT_PLAN.md`.
- Source Control / target Planning: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0` -> Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Immutable packet identity / implementation attempt:
  `2026-08-11-expo-v1-komainu-app-identity-correction-control-b`; attempt 3.
- Candidate worktree/branch/accepted UI tip:
  `/private/tmp/shengfukung-wenfu-expo-ui-refinement`;
  `codex/expo-v1-dev-client-ui-refinement`;
  `f4ad7e6c14d259d2870d5abd9b9ebac2c875650a`.

## Bounded Source Correction

- The interrupted uncommitted `com.sourcegridlabs` attempt is rejected. Retain
  the accepted UI tip and replace only its uncommitted identifier edits with
  the current authority:
  - internal project name: `komainu`;
  - public names: TempleMate / TempleMate (Dev);
  - production iOS bundle identifier and Android application ID:
    `com.jimmy1768.komainu`;
  - development-client iOS bundle identifier and Android application ID:
    `com.jimmy1768.komainu.dev`.
- Both platform values must follow the same deterministic development/production
  selection in active mobile configuration and project authority. No
  `tw.com.templemate.dev`, `com.sourcegridlabs.*`, tenant, or admin identifier
  may remain in active mobile source.
- Exact owned paths: `mobile/app.config.js`,
  `mobile/app/lib/app_constants/project.js`,
  `mobile/__tests__/native-config.test.js`,
  `mobile/scripts/verify-native-client.js`, and a focused existing/new test
  below `mobile/__tests__/` only when required; this packet only.
- Preserve Expo 54/API 36, `1.0.0`, Android/iOS build values `1`, UI behavior,
  account-only scope, dummy default, real adapter, and pinned project-local
  `expo-doctor@1.20.1`.

## Hard Boundaries

- Do not edit Rails, Vue, Planning documents, EAS/build profiles, package
  dependencies, versioning, assets, adapters, or generated native directories.
- Do not run Expo prebuild, Gradle, `expo run:android`, EAS, a native artifact,
  Metro, ADB/device action, provider/Google Cloud/secret access, deployment,
  or push. Do not recreate deleted Android build trees.

## Evidence And Closeout

- Required: mobile tests, lint, verify, and `EXPO_OFFLINE=1 CI=1 yarn doctor`;
  public development and production Expo config proof; focused active-source
  identifier scan; `git diff --check`; and clean candidate/canonical staging.
- One fresh normal ephemeral Implementer: `gpt-5.6-terra/medium`. This is a
  bounded config/constants/test replacement with no persistent handoff need;
  deeper reasoning is not justified.
- Implementer edits only listed paths, runs local checks, and does not stage,
  commit, merge, push, build, operate Metro/ADB/device, access external state,
  or message Planning.
- Implementer result accepted after Control review. It edited only
  `mobile/app.config.js`, `mobile/app/lib/app_constants/project.js`,
  `mobile/__tests__/native-config.test.js`, and
  `mobile/scripts/verify-native-client.js`. Accepted source commit:
  `2610b45bdb6485da7e1b56b8ea56557efda0c171`.
- Independent evidence passed: `yarn install --frozen-lockfile --offline`;
  `yarn test` (19/19); `yarn lint` (23 mobile application modules);
  `yarn verify`; and `EXPO_OFFLINE=1 CI=1 yarn doctor` (17/17). `git diff
  --check` passed.
- Deterministic public configuration evidence:
  - `BUILD_MODE=development` reports `TempleMate (Dev)`, iOS/Android
    `com.jimmy1768.komainu.dev`, version `1.0.0`, build values `1`, and
    compile/target SDK 36;
  - `BUILD_MODE=production` reports `TempleMate`, iOS/Android
    `com.jimmy1768.komainu`, with the same version/build/API values.
- Focused scan of active `mobile/app` and `mobile/app.config.js` found no
  `tw.com.templemate.dev`, `com.sourcegridlabs.*`, or tenant/admin native-ID
  form. The prior superseded source-only work was replaced in place; no native
  build, Metro, ADB/device, network, provider, secret, deployment, or push
  action occurred.
- Candidate integration and direct terminal delivery remain pending Control's
  final canonical-main merge and terminal packet.
