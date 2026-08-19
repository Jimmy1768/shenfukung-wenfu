# Expo EAS Android Development-Client Source-Backed Download And Install Plan

Status: accepted for direct dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Director authority: the still-current instruction to download the completed
TempleMate development-client APK and install it on the reconnected Pixel

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Predecessor terminals:

- `2026-08-12-expo-eas-android-development-client-download-install-control-b`
  at isolated receipt `4b1fd08fa2e9e02085d32ed1ddec4e80a8a85704`;
- `2026-08-12-expo-eas-android-development-client-download-install-continuation-control-b`
  at isolated receipt `95a851807270dc4896dc1637d20cc653646c2c0f`.

## Resolved CLI Contract

Planning inspected the installed `eas-cli` 18.12.2 implementation after the
second terminal. `build:download` requires EAS ProjectId context, so its process
working directory must be a linked Expo project. Independently, the command
does not place the application archive in that working directory. It derives a
deterministic path under the EAS CLI temporary cache:

`<eas-cli temp>/eas-build-run-cache/<project-id>_<build-id>.apk`

For this packet the installed helper currently resolves the exact artifact path
to:

`/var/folders/7d/lv5mnq115d1gf833_p5zwdfr0000gn/T/eas-cli-nodejs/eas-build-run-cache/c7b8523a-2fad-4123-bc96-0c0c85a23dec_ca45b77c-cb45-458c-a298-6be449a9e396.apk`

The source-backed working directory and the cache path are therefore separate.
This plan uses the linked source only to satisfy ProjectId/config resolution,
then inspects, installs, and deletes the exact cache file.

## Frozen Build, Identity, And Device

- EAS project: `@jimmy1768/templemate` /
  `c7b8523a-2fad-4123-bc96-0c0c85a23dec`;
- build: `ca45b77c-cb45-458c-a298-6be449a9e396`;
- build source: `a67aa8fa6f57885461af91c319f7a830b99f0764`;
- expected APK: `TempleMate (Dev)`, package
  `com.jimmy1768.komainu.dev`, version `1.0.0`, version code `1`, target SDK
  36;
- device: serial `39011FDJH00FQ8`, Pixel 8 / `shiba`, ADB state `device`;
- Android 17/API 37 is accepted for the API-36-targeted APK.

## Source Materialization Fence

Control creates a fresh isolated worktree/branch from this committed plan.
Before any external action it proves:

1. canonical and isolated Git/staging are clean and exact ancestry holds;
2. `mobile/app.config.js` resolves the linked project ID and accepted Komainu
   development identity;
3. canonical `mobile/package.json` and `mobile/yarn.lock` are byte-identical to
   `/private/tmp/shengfukung-wenfu-expo-temple-qr-camera/mobile/package.json`
   and `yarn.lock`;
4. that accepted camera worktree has an existing real `mobile/node_modules`
   directory;
5. the isolated worktree has no `mobile/node_modules` path.

Control may then create exactly one temporary ignored symlink at isolated
`mobile/node_modules` pointing to the existing dependency directory above.
No package manager, dependency install, registry access, copy, manifest edit,
or lockfile edit is authorized. If any identity/equivalence condition fails,
stop without creating the link.

Record the isolated worktree status and ignored/untracked inventory before the
EAS command so any unexpected source/config residue can be detected and
removed exactly. `app.json`, native directories, or other generated project
files are not expected or authorized.

## Preflight

Immediately before download, independently prove:

- the exact remote build is still `FINISHED`, Android/internal/development,
  has the expected project/source/version/build metadata, and has an available
  application archive;
- at least 2 GB is free on the filesystem containing the EAS cache;
- the installed CLI helper recomputes exactly the frozen cache APK path above;
- that exact APK path is absent before download;
- exactly one connected device matches the accepted serial/model/codename and
  state, has at least 1 GB free under `/data`, and the expected package remains
  absent.

Any mismatch or pre-existing cache APK is a hard stop. Do not adopt, overwrite,
or delete a pre-existing artifact.

## One Direct Source-Backed Download

From the isolated worktree's literal `mobile/` directory, invoke exactly once
as a direct process:

    /opt/homebrew/bin/eas build:download --build-id ca45b77c-cb45-458c-a298-6be449a9e396 --json --non-interactive

Do not assign shell status variables, wrap the command in substitution/traps/
loops/pipelines/conditionals, request all artifacts, or retry. The sanitized
JSON path must equal the frozen cache APK path. Do not record the signed URL.

After the command, require exactly one regular file at the frozen path and no
new repository source/config/native file. A command failure, path mismatch,
missing APK, additional artifact, or unexpected project write stops before
device mutation.

## APK Inspection And Single Install

Record byte size and SHA-256. Inspect the exact APK with installed Android build
tools and require package `com.jimmy1768.komainu.dev`, launcher label
`TempleMate (Dev)`, version name `1.0.0`, version code `1`, and target SDK 36.
Reject an AAB, split set, malformed archive, or any mismatch.

Recheck the exact connected serial and package absence. Then invoke exactly
once, with no extra install flag:

    adb -s 39011FDJH00FQ8 install <frozen-cache-apk-path>

After this device-mutation boundary, never retry. Reconcile ambiguous output
only with exact read-only package queries. Success requires installed base path,
version `1.0.0`, code `1`, target SDK 36, and launcher resolution. Do not launch
the app.

## Mandatory Cleanup

On every terminal path after link creation:

1. delete the exact frozen cache APK if and only if this packet created it;
2. prove that exact APK path is absent;
3. remove the exact isolated `mobile/node_modules` symlink;
4. remove an empty `eas-build-run-cache` directory only if this packet created
   that directory and it remains exactly empty;
5. remove only packet-created unexpected ignored residue, if any, after exact
   before/after attribution;
6. prove no APK/AAB, generated app/native tree, signing material, dependency
   link, or source/config residue remains and both worktrees are clean with
   staging empty.

Do not delete the remote EAS artifact or use a broad path, glob, unresolved
variable, home directory, repository root, or unrelated cache entry.

## Invariants And Exclusions

- `1.0.0 / Android 1 / iOS 1` remains unchanged.
- No source/config/dependency/lockfile edit; no dependency installation.
- No EAS build/rebuild/cancel, signing/credential action, local build/prebuild,
  artifact deletion, AAB, release, submission, OTA, or push.
- No app launch, Metro, ADB reverse, camera/QR, dummy/account smoke, OAuth, real
  API, logs, screenshots, or broad device/package inspection.
- No provider/server/deployment/payment/production action.

## Acceptance And Terminal

Acceptance requires a source-backed exact-build download to the frozen cache
path, full APK identity match, exactly one successful fresh install on the
exact Pixel, read-only installed-package verification, mandatory exact cleanup,
clean Git/staging, and all invariants above.

Terminal classifications:

- `eas_android_development_client_installed`;
- `source_materialization_or_target_precondition_failed`;
- `artifact_download_or_identity_failed`;
- `device_install_failed`;
- `device_install_reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

On success, Control integrates only its immutable safe receipt to canonical
main. On failure, canonical main remains unchanged. The terminal contains no
signed artifact URL, credentials, session material, or private signing data.

Current classification:
`expo_eas_android_development_client_source_backed_download_install_authorized`.

First blocker: none. The installed CLI's project-context and deterministic
cache-path behavior are now directly mapped into the procedure.
