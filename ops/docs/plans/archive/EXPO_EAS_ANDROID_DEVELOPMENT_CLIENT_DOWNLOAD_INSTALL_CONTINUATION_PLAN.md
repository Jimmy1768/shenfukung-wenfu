# Expo EAS Android Development-Client Download And Install Continuation Plan

Status: accepted for direct dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Director authority: the still-current instruction to download the completed
TempleMate development-client APK and install it on the reconnected Pixel

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Predecessor plan:
`ops/docs/plans/EXPO_EAS_ANDROID_DEVELOPMENT_CLIENT_DOWNLOAD_INSTALL_PLAN.md`

Failed predecessor terminal:
`2026-08-12-expo-eas-android-development-client-download-install-control-b`
at isolated receipt commit `4b1fd08fa2e9e02085d32ed1ddec4e80a8a85704`

## Reason For Continuation

The predecessor passed the EAS-build, device, package-absence, and disk gates.
Its sole download invocation produced no APK because the local zsh wrapper used
the reserved read-only variable `status`. Control correctly did not retry under
that packet, removed the empty temporary directory and all incidental residue,
and did not cross the device-mutation boundary.

This is a command-wrapper defect, not evidence that the finished EAS artifact,
Pixel, source identity, or Android package is invalid. This continuation grants
one new download attempt using a direct command with no status-capture wrapper,
then retains the predecessor's exact inspection, one-install, verification, and
cleanup criteria.

## Frozen Artifact And Target

- EAS project: `@jimmy1768/templemate` /
  `c7b8523a-2fad-4123-bc96-0c0c85a23dec`;
- build: `ca45b77c-cb45-458c-a298-6be449a9e396`;
- build source: `a67aa8fa6f57885461af91c319f7a830b99f0764`;
- expected APK: `TempleMate (Dev)`, package
  `com.jimmy1768.komainu.dev`, version `1.0.0`, version code `1`, target SDK
  36;
- target: serial `39011FDJH00FQ8`, Pixel 8 / `shiba`, state `device`;
- Android 17/API 37 is accepted for an APK targeting API 36.

## Corrected Download Procedure

Control B records a new immutable packet. One ephemeral Implementer may prepare
only packet-local/read-only evidence; Control owns EAS and ADB actions.

1. Recheck clean Git/staging, the exact finished/artifact-available EAS build,
   at least 2 GB temporary free space, the exact one connected Pixel, at least
   1 GB device free space, and absence of
   `com.jimmy1768.komainu.dev`.
2. Create one new temporary directory in `/private/tmp` using `mktemp -d` and
   retain the literal returned path for later exact cleanup.
3. In a separate command invocation whose process working directory is that
   literal temporary path, run only:

       /opt/homebrew/bin/eas build:download --build-id ca45b77c-cb45-458c-a298-6be449a9e396 --non-interactive

   Do not wrap this command in shell status assignment, command substitution,
   traps, loops, pipelines, conditional retry logic, or a compound shell
   expression. Do not use `--all-artifacts`. Do not record a signed URL.
4. Reconcile the literal temporary directory. Require exactly one regular APK.
   If the direct command fails or produces no exact APK, stop, delete the exact
   directory, and return without a second download.

No generated `app.json`, dependency link, source-tree materialization, or
dynamic Expo configuration is needed for this exact build-ID download. If EAS
unexpectedly attempts a source/config write or requires project materialization,
stop and clean up rather than modifying source.

## APK Inspection And One Install

Before device mutation, record the APK byte size and SHA-256 and inspect it with
the installed Android build tools. Require all of:

- package `com.jimmy1768.komainu.dev`;
- launcher label `TempleMate (Dev)`;
- version name `1.0.0`;
- version code `1`;
- target SDK 36;
- one ordinary APK, not an AAB or split collection.

Recheck the exact serial and package absence. Then invoke exactly once:

    adb -s 39011FDJH00FQ8 install <literal-inspected-apk-path>

Use no replacement, downgrade, test, grant-all, or other install flag. After
this mutation boundary, never retry. Reconcile ambiguous output only through
read-only exact-package queries.

Success requires `pm path` for `com.jimmy1768.komainu.dev`, version name
`1.0.0`, version code `1`, target SDK 36, and launcher resolution. Do not launch
the app.

## Mandatory Cleanup

On success or any failure, delete only the literal temporary directory created
by this continuation and prove it absent. Confirm no APK/AAB, native tree,
signing material, generated config, dependency link, or source residue remains,
and both worktrees are clean with staging empty.

The remote EAS artifact must remain intact.

## Invariants And Exclusions

- Version remains `1.0.0`; Android version code remains `1`; iOS build remains
  `1`. No source, version, build, EAS project, or signing change is authorized.
- No EAS build/rebuild/retry/cancel, local build/prebuild, credential inspection,
  artifact deletion, AAB, release, submission, OTA, or push.
- No app launch, Metro, ADB reverse, camera permission, QR scan, dummy/account
  smoke, OAuth, real API, logs, screenshots, or broad device/package inspection.
- No provider/server/deployment/payment/production action.

## Acceptance And Terminal

Acceptance requires the exact direct download, full APK identity match, exactly
one successful fresh install on the exact Pixel, read-only installed-package
verification, mandatory local artifact cleanup, clean Git/staging, and all
invariants above.

Terminal classifications:

- `eas_android_development_client_installed`;
- `target_device_precondition_failed`;
- `artifact_download_or_identity_failed`;
- `device_install_failed`;
- `device_install_reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

On success, Control may integrate only its immutable safe receipt to canonical
main and return one terminal packet. On failure, canonical main remains
unchanged. The safe receipt must omit signed artifact URLs, credentials, and
private session material.

Current classification:
`expo_eas_android_development_client_download_install_continuation_authorized`.

First blocker: none. The previous failure mechanism is understood and removed
from this bounded procedure.
