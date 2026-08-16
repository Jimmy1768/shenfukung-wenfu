# Expo EAS Android development-client download and install — Control B packet

## Identity

- Accepted plan and immutable criteria:
  `ops/docs/plans/EXPO_EAS_ANDROID_DEVELOPMENT_CLIENT_DOWNLOAD_INSTALL_PLAN.md`
  at `aa2a3c408377f9e1f58ae93ce050060d90dfccea`.
- Control task and authority state: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0`; direct Planning dispatch accepted.
- Repository/worktree/branch/base:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`,
  `/private/tmp/shengfukung-wenfu-expo-eas-android-dev-client-download-install`,
  `codex/expo-eas-android-dev-client-download-install`,
  `aa2a3c408377f9e1f58ae93ce050060d90dfccea`.
- Packet identity and attempt:
  `2026-08-12-expo-eas-android-development-client-download-install-control-b`,
  attempt 1.

## Scope And Protected Manifest

- Exact remote target: EAS `@jimmy1768/templemate`, project
  `c7b8523a-2fad-4123-bc96-0c0c85a23dec`, finished Android/internal/
  `development` build `ca45b77c-cb45-458c-a298-6be449a9e396`, source
  `a67aa8fa6f57885461af91c319f7a830b99f0764`.
- Exact physical target: ADB serial `39011FDJH00FQ8` only; expected Pixel 8 /
  `shiba`, state `device`, Android 17/API 37, and absent
  `com.jimmy1768.komainu.dev` package.
- Exact allowed external commands and order:
  1. Read-only EAS `CI=1 /opt/homebrew/bin/eas build:view
     ca45b77c-cb45-458c-a298-6be449a9e396 --json`; retain only finished/
     project/platform/profile/distribution/source/artifact-available fields.
  2. Target-fenced read-only ADB device identity/status, `df /data`, battery,
     and `pm path com.jimmy1768.komainu.dev`; exact serial only. The initial
     unprivileged ADB read attempt could not start the local daemon and made no
     device connection or mutation; elevated local device access is required
     for the bounded authorized preflight.
  3. Create one new temporary directory using `mktemp -d`; from that directory,
     one `CI=1 /opt/homebrew/bin/eas build:download --build-id
     ca45b77c-cb45-458c-a298-6be449a9e396 --non-interactive`. No URL, logs, or
     all-artifacts request.
  4. Local regular-file/count/size/SHA-256 and `aapt dump badging` inspection;
     accept only one APK with `com.jimmy1768.komainu.dev`, `TempleMate (Dev)`,
     `1.0.0`, version code `1`, target SDK `36`.
  5. Re-prove exact ADB target and absent package, then execute exactly one
     `adb -s 39011FDJH00FQ8 install <exact inspected APK>` with no flags.
  6. Read-only exact-package path/version/target-SDK and launcher resolution;
     never launch activity. Remove the exact temporary directory immediately
     on every terminal path and verify absence.
- Hard stops/uncertain outcome: a wrong/inexact build, missing artifact,
  download/identity failure, device ambiguity/disk/package precondition, prompt,
  connection loss, timeout, or unexpected device output stops before install;
  after the install mutation boundary no second install occurs. Reconcile only
  with target-fenced read-only package queries. No uninstall/replacement/data
  clearing/settings/other device action is permitted.
- Exact owned paths: required report
  `ops/docs/handoffs/2026-08-12-expo-eas-android-development-client-download-install-control-b.md`
  (Implementer-owned) and this Control packet only. No product/source/config/
  dependency/lockfile/plan/sibling changes.
- Required safe receipt fields: stated project/build/finished artifact status;
  allowed serial/model/codename/OS/API/package-before/after; APK byte size and
  SHA-256; inspected identity fields; one install result; temporary cleanup;
  Git status/checks/next owner. Never signed artifact URL, session/token/cookie,
  signing/private credential data, or broad device inventory/logs.
- Explicit exclusions: any build/retry/cancel/artifact deletion/signing action;
  prebuild/local build/native generation; launch/Metro/reverse/runtime/camera/
  OAuth/device data action; providers/server/deployment/release/payment/push.

## Checks And Evidence

- Before protected calls: exact plan/build receipt/source ancestry; clean
  canonical/isolated status/staging; config/version invariants; temporary
  filesystem free >=2GB.
- After: one inspected APK, intended target/path/version/activity evidence,
  deletion of exact temporary path, no APK/AAB/native/signing residue, clean
  Git/staging, and diff check.
- First blocked surface before preflight: none. The elevated-only local ADB
  daemon startup condition is a tooling permission fence, not a device result;
  it must be resolved before asserting a Pixel fact.

## Allocation And Terminal Boundary

- Persistent Handoff requested/eligible: no; Luna disqualifiers checked.
- One ephemeral Implementer: `gpt-5.6-terra/medium`, lowest sufficient for
  packet-local report skeleton and read-only local preparation only. It may not
  run EAS, ADB, download, inspect the artifact, stage, commit, merge, push, or
  mutate anything external.
- Control exclusively owns the protected EAS download and all ADB actions,
  reconciles uncertainty, integrates only an accepted receipt, and sends one
  terminal packet to Planning. No intermediate Planning traffic.

## Control Review And Closeout

- Conformance review: device/disk/package-absence and exact finished-build
  metadata gates passed. The sole download command reached a local wrapper
  error after invocation; targeted reconciliation found the exact temporary
  directory empty. The artifact identity and install gates therefore could not
  be truthfully satisfied.
- Acceptance decision: no accepted install outcome. Terminal classification is
  `artifact_download_or_identity_failed`; continuation disposition is
  `no_evidence_backed_direct_repair_remaining` under the one-use download
  fence. No APK identity inspection or ADB install mutation occurred.
- Cleanup/postcondition: the exact empty temporary directory and temporary
  materialization symlink were removed; no `app.json`, APK/AAB, native tree,
  signing material, or source/config/version change remains.
- Integration: forbidden by the accepted plan because all install criteria did
  not pass. Control commits the immutable failure receipt/packet only on this
  isolated branch for Planning review; canonical `main` remains unchanged.
- Next owner/action: Planning/Director must investigate EAS artifact delivery
  and, if desired, authorize a new separately bounded download attempt.
