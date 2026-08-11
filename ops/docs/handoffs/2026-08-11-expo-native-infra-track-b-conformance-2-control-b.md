# Expo Native Infrastructure Track B — Conformance Continuation Packet

## Identity

- Accepted plan and immutable criteria:
  `ops/docs/plans/EXPO_NATIVE_CLIENT_INFRA_TRACK_PLAN.md`, plus Planning’s
  direct unchanged-criteria continuation dated 2026-08-11.
- Control/Planning tasks: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0` -> Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Prior terminal and receipt:
  `2026-08-11-expo-native-infra-track-b-control-b`, commit
  `0263b0a6cd387d1e0101b76d4834a50b1f247254`; Planning received it as
  immutable and issued `released_terminal_idle`, classifying the checkpoint
  incomplete for concrete conformance omissions.
- Repository/worktree/branch/base: `/Users/jimmy1768/Projects/shengfukung-wenfu`;
  `/private/tmp/shengfukung-wenfu-expo-native-track-b`;
  `codex/expo-native-infra-track-b`; base `0263b0a6cd387d1e0101b76d4834a50b1f247254`.
- Packet identity and implementation attempt:
  `2026-08-11-expo-native-infra-track-b-conformance-2-control-b`, attempt 2.

## Observed Conformance Gaps And Direct Remedy

1. An APK compilation did not prove the accepted install-and-run gate. Remedy:
   use only a local Android 16 emulator or attached Android device to install
   and launch the existing debug development client. Do not use Expo Go,
   EAS/cloud, AAB, signing, or release tooling. Current observed local state:
   `adb devices` is empty; AVD `Medium_Phone_API_36.0` exists but cannot load
   because `Google Play arm64-v8a Medium Phone API 36.0` system image is absent.
   The Implementer may inspect and use installed local Android tooling. It may
   not use an external build substitute. If the exact local image/device
   prerequisite cannot be satisfied through an authorized bounded local setup,
   preserve the command/evidence for Control’s truthful terminal disposition.
2. The app has parser/fixture helpers but no native QR scanning path, tappable
   connection link, scanner interface, or safe visible failure path. Remedy:
   add only the accepted local fixture-backed native QR/link interface and
   deterministic trust/tenant-confirmation seams; no live request, staging
   hostname identity, or invented Rails wire contract.
3. Dummy signup/recovery, assistance/contact, privacy request, account closure,
   and tenant switch confirmation/cleanup are notice-only or absent. Remedy:
   make those dummy-only workflows stateful and visibly testable. Tenant switch
   must require confirmation and clear prior tenant session/cache/pending
   state before rebind.
4. Existing five Node tests do not evidence rendered navigation, locale/theme,
   storage adapter/scoping, dummy no-network behavior, paid read-only state,
   binding/switching, or excluded surfaces. Remedy: add deterministic focused
   component/integration or equivalent behavioral tests for every listed area.
5. `expo-doctor` was 17/18 because of compatible patch recommendations. Remedy:
   reconcile only those Expo 54 patch dependencies and their lockfile as
   necessary for a passing required compatibility result; do not add unrelated
   packages or upgrade beyond the accepted Expo 54/API 36/version boundaries.
6. The prior packet intentionally remains historical and immutable; its pending
   closeout cannot be rewritten. Remedy: this continuation packet is the
   durable Control closeout record for the Planning-received rejected terminal,
   and its own completed review/commit/terminal fields must be filled in by
   Control after acceptance.

## Scope

- Exact editable paths:
  - existing and new `mobile/App.js`, `mobile/app.config.js`,
    `mobile/package.json`, `mobile/yarn.lock`, `mobile/eas.json`,
    `mobile/versioning.js`, `mobile/assets/`, `mobile/app/`,
    `mobile/__tests__/`, and `mobile/scripts/` paths;
  - Expo-only build/check wrappers in `bin/expo_build` and `bin/expo_prebuild`
    only if directly required for the local debug/emulator gate;
  - this new continuation packet only.
- Excluded: all Planning documents and the prior immutable Control packet;
  Rails/Vue/account-web paths; real adapter/integration; payments/providers;
  OAuth; admin/guest/staff/operations; secrets/env; production/deployment;
  EAS/cloud/OTA; AAB/store/release; push; canonical-main merge; Control A and
  DojoMate reference changes.
- Required checks/evidence:
  - updated focused tests for every remedy and accepted prior dummy behavior;
  - `yarn lint`, `yarn verify`, **passing** `npx expo-doctor`, development
    config inspection, and `git diff --check`;
  - local debug development-client assemble evidence and, if device/emulator
    readiness is achievable, exact install/launch evidence with TempleMate
    (Dev), Expo dev client, Android 16/API 36, and no changed build numbers;
  - final clean isolated branch/status. An unavailable image/device must retain
    exact first-prerequisite evidence; never replace it with external tooling.

## Boundaries, Allocation, And Return

- This is a Control-owned bounded nonterminal conformance repair within
  unchanged accepted criteria. No Planning packet is sent until a new terminal
  disposition.
- Persistent Handoff: no; eligibility checked before model selection.
- One ephemeral Implementer: `gpt-5.6-terra/high`. The same coupled native UI
  state, storage/binding cleanup, QR fixture path, dependency compatibility,
  and local Android emulator evidence are deeper bounded work; this is the
  lowest sufficient allocation. Luna is never ephemeral.
- The Implementer edits owned paths only and does not stage, commit, merge,
  push, deploy, access secrets/providers, mutate external systems, expand the
  scope, or contact Planning/Control A. It returns direct evidence to Control.

## Control Closeout

- Review: accepted the repair’s mobile-only source corrections. Direct evidence
  is 9 focused passing tests, lint/verify/config guards, passing Expo Doctor,
  a local SDK-36/dev-client debug assemble, and `git diff --check`. Review
  confirms the functional QR/link fixture seam, switch confirmation/cleanup,
  support/privacy/closure dummy actions, excluded-surface guardrails, and the
  exact Expo 54 patch-only dependency update. No out-of-scope path changed.
- Decision: local correction accepted at
  `a7d0226bbad08d79650515f7ed4f98e28320848c` (`fix: complete Expo dummy
  client conformance`), but the immutable Track B checkpoint as a whole cannot
  be accepted because the required local install-and-run proof is unavailable.
- First prevented action and evidence: install the existing debug development
  client on Android 16. `adb devices` shows no device. The available AVD
  `Medium_Phone_API_36.0` fails to launch because
  `system-images/android-36/google_apis_playstore/arm64-v8a/` is absent. No
  system image was downloaded, no APK was installed, and no EAS/cloud, Expo Go,
  AAB, signing, or release substitute was used.
- Final terminal disposition: `no_evidence_backed_direct_repair_remaining`.
  The next owner is Planning, which must decide whether to provide/authorize a
  local Android 16 emulator image or connected test device before a new
  install/run-only continuation. This Control does not merge canonical main or
  begin real-adapter work.
- Immutable terminal delivery and paired Planning receipt: pending direct
  terminal delivery to Planning for this attempt; the prior terminal’s paired
  receipt remains historical evidence.
