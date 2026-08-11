# Expo Native Infrastructure Track B — Pixel 8 Install/Run Packet

## Identity

- Accepted authority: `ops/docs/plans/EXPO_NATIVE_CLIENT_INFRA_TRACK_PLAN.md`
  and Planning’s direct 2026-08-11 install/run-only continuation.
- Control/Planning tasks: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0` -> Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Repository/worktree/branch/base: `/Users/jimmy1768/Projects/shengfukung-wenfu`;
  `/private/tmp/shengfukung-wenfu-expo-native-track-b`;
  `codex/expo-native-infra-track-b`; base/final source candidate
  `0e744b09c22127747b40e1b477bac139887a4ae0`.
- Immutable packet identity and implementation attempt:
  `2026-08-11-expo-native-track-b-pixel8-install-run-3-control-b`; attempt 3.

## Fenced Objective And Authority

- Close only the physical install-and-run criterion for one debug TempleMate
  development client. No source redesign or integration occurs.
- Sole mutable target: ADB serial `39011FDJH00FQ8`, observed as Pixel 8
  (`shiba`). If this identity/status changes, stop before mutation.
- Sole mutable package: `tw.com.templemate.dev`, debug development-client APK,
  version `1.0.0`, Android version code `1`, from the source candidate above,
  compile/target SDK 36. No other package, account, storage, device, emulator,
  external system, or version/build value may be changed.
- Director’s one-off authority permits exactly one target-fenced `adb install`
  attempt, then target-fenced launch and only necessary local Metro/ADB reverse
  support. Dummy mode must make no live Rails/API/provider request.

## Required Preflight And Uncertain-Outcome Fence

- Before any device mutation record: `adb -s` identity/status; Android release
  and SDK level; current `pm path tw.com.templemate.dev` state; exact local APK
  package/version/code/debug identity; artifact digest; and source branch/HEAD.
- Stop with a truthful terminal if the Pixel is not Android 16/API 36, package
  identity/version/code/debug identity differs, package state is ambiguous, or
  an existing package could contain retained state not created by this packet.
- If the single install disconnects, times out, or otherwise has ambiguous
  outcome, do not retry. Reconcile target package/version state first. A second
  install needs direct proof that the first did not install or mutate it.
- Rollback is limited to uninstalling `tw.com.templemate.dev` on this serial,
  and only after preflight proves it was absent. It is not a default cleanup.

## Scope And Evidence

- Exact editable path: this packet only. No source changes are expected.
- Implementer work: one `gpt-5.6-terra/medium` ephemeral Implementer prepares
  artifact/preflight evidence only. It does not mutate any device, stage,
  commit, merge, push, deploy, access secrets/providers, or contact Planning.
  Medium is the lowest sufficient allocation because work is mechanical
  artifact/static-target verification with no stateful implementation.
- Control-only mutable action: after accepted preflight, run the one fenced
  install/launch attempt and inspect sanitized package/activity/log/screenshot
  evidence. Control does not access a live Rails/API/provider origin.
- Required evidence: physical Android 16/API 36; installed exact package and
  version/code; TempleMate (Dev) Expo development-client launch rather than
  Expo Go; visible dummy runnable state; artifact digest; source/branch status;
  no rollback or exact rollback result; `git diff --check`; clean status.
- Excluded: Rails/Vue; real adapter/integration; OAuth; payment/providers;
  admin/guest/staff; secrets; production/deployment; EAS/cloud; AAB/store;
  OTA; push; version consumption; canonical-main merge; Control A; UI
  refinement; all Android SDK/image downloads.

## Control Closeout

- Conformance review: device/package preflight is complete and rejects the
  target before mutation. The observed serial/model/codename match the target
  fence, and `pm path tw.com.templemate.dev` returned no installed path, but
  `ro.build.version.release=17` and `ro.build.version.sdk=37` violate the
  immutable Android 16/API 36 fence. The local artifact remains
  `a4b99e84363135aca0a38eb291e51ff38140d0eae8645169e0f282e3ee4bd371`.
- Device action result: no install, launch, Metro process, ADB reverse,
  uninstall, rollback, device/storage mutation, source modification, or
  external action occurred.
- Terminal disposition: `no_evidence_backed_direct_repair_remaining`.
  The first prevented action is the one permitted ADB install; Planning must
  obtain an Android 16/API 36 device or route an explicit accepted-criteria
  change before any target mutation. Control cannot substitute Android 17/API
  37.
- Source/branch status: source remains at
  `0e744b09c22127747b40e1b477bac139887a4ae0` plus this Control packet only;
  `git diff --check` passed. Canonical main remains unmodified.
- Planning receives no intermediate packet. A paired `released_terminal_idle`
  receipt is required after the terminal disposition.
