# Expo EAS Android Development-Client Download And Install Plan

Status: accepted for direct target-fenced dispatch to Control B after this plan
is committed

Created: 2026-08-12

Owner: Wenfu Planning

Director authorization: explicit instruction to confirm the reconnected Pixel,
download the completed EAS APK, and install it

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`fce68d05a3de7be488991d6ea1fe4e8b9c490573`

Required build receipt:
`ops/docs/handoffs/2026-08-12-expo-eas-android-development-client-build-control-a.md`

## Objective

Download the exact finished TempleMate EAS Android development-client APK into
a newly created temporary directory, inspect its identity, install it once on
the exact connected Pixel 8, verify the installed package/version, and delete
the local APK and temporary directory immediately.

This plan does not launch the app, start Metro, configure ADB reverse, exercise
dummy/account/camera/OAuth behavior, or retain the APK.

## Exact Artifact And Device

Artifact:

- EAS owner/project: `@jimmy1768/templemate`;
- project ID: `c7b8523a-2fad-4123-bc96-0c0c85a23dec`;
- build ID: `ca45b77c-cb45-458c-a298-6be449a9e396`;
- terminal status: `FINISHED`;
- platform/profile/distribution: Android / `development` / internal;
- source build commit: `a67aa8fa6f57885461af91c319f7a830b99f0764`;
- expected application archive: APK;
- expected public/package identity: `TempleMate (Dev)` /
  `com.jimmy1768.komainu.dev`;
- expected version: `1.0.0`, version code `1`, target SDK 36.

Device:

- ADB serial: `39011FDJH00FQ8`;
- observed model/codename: Pixel 8 / `shiba`;
- observed OS/API: Android 17 / API 37;
- expected ADB state: `device` over USB;
- observed package precondition: `com.jimmy1768.komainu.dev` absent;
- observed device free space: approximately 55 GB under `/data`;
- observed battery: 99%.

Android 17/API 37 is accepted for this install. The APK targets API 36; the
device being newer is not a blocker.

## Preflight And Hard Stops

Control B records one immutable implementation packet and uses one ephemeral
Implementer only for bounded report/check preparation. Control retains all EAS
download and ADB device mutation.

Immediately before download, Control independently proves:

1. canonical and isolated Git state are clean with staging empty and the plan,
   build receipt, and build source ancestry are exact;
2. EAS read-only build metadata still resolves the exact finished build and an
   application archive is available;
3. local free space is at least 2 GB in the selected temporary filesystem;
4. exactly one ADB target matches serial `39011FDJH00FQ8`, state `device`, model
   Pixel 8, codename `shiba`;
5. package `com.jimmy1768.komainu.dev` remains absent;
6. the device has at least 1 GB free under `/data`.

Stop before download or installation if the build is not exact, the artifact
is unavailable, the target is missing/unauthorized/ambiguous, the package is
already installed, or either disk fence fails. Do not select another build,
device, package, or artifact.

## Temporary Download And Artifact Inspection

Create a new temporary directory using the system temporary-directory
mechanism. Download only the application archive for exact build ID
`ca45b77c-cb45-458c-a298-6be449a9e396`; do not request logs or all artifacts.

Use the installed EAS CLI's exact build-ID download interface from inside the
temporary directory. Do not expose or retain the signed artifact URL. Do not
download into the repository, home directory, Downloads, DevSSD, or another
persistent project directory.

Before any device mutation:

- prove exactly one downloaded regular APK exists in the temporary directory;
- record its filename only in transient execution evidence, byte size, and
  SHA-256 digest;
- inspect it with the installed Android build-tools `aapt` or equivalent;
- require package `com.jimmy1768.komainu.dev`, version name `1.0.0`, version
  code `1`, target SDK 36, and launcher label `TempleMate (Dev)`;
- reject an AAB, split set, production package, wrong label, wrong version,
  wrong SDK, malformed archive, or additional artifact.

An artifact identity failure is a hard stop. Delete the temporary directory
and do not install.

## One-Use Installation

Immediately before installation, re-prove the exact serial is connected in
state `device` and the expected package remains absent.

Invoke exactly one fresh installation for the inspected APK, fenced to serial
`39011FDJH00FQ8`. Do not use `-r`, `-d`, `-t`, grant-all, downgrade, streaming
fallback selection, or another package-management option unless `adb install`
uses its own default transport internally.

After an installation command reaches the device-mutation boundary:

- never issue a second install under this plan;
- if output is ambiguous or the connection drops, reconcile with read-only
  package queries; do not retry;
- if installation certainly fails and the package remains absent, record the
  exact safe failure classification;
- do not uninstall, clear data, replace another package, or alter device
  settings as rollback.

## Post-Install Verification

Success requires read-only device evidence that:

- `pm path com.jimmy1768.komainu.dev` returns an installed base package;
- package metadata reports version name `1.0.0` and version code `1`;
- the launcher activity resolves for `com.jimmy1768.komainu.dev`;
- no rejected historical TempleMate package is created by this action.

Do not launch the activity. Do not grant camera permission, open a deep link,
start Metro, create ADB reverse mappings, read broad logs, or test runtime
behavior.

## Mandatory Cleanup

After recording the artifact digest/identity and installation result, delete
the exact temporary directory and every downloaded file inside it. Cleanup is
required after success, certain failure, or pre-install artifact rejection.

Verify:

- the temporary path no longer exists;
- no APK/AAB/native project/signing material was added to the repository;
- repository and isolated worktrees are clean with staging empty;
- no EAS artifact deletion occurred; the remote EAS artifact remains intact.

Do not use a broad path, glob, home directory, repository root, or unresolved
variable for cleanup.

## Safe Receipt

The Control terminal may record only:

- exact EAS project/build ID and finished/artifact-available classification;
- target serial/model/codename/OS/API and package-before/after classification;
- APK byte size and SHA-256 digest, but not a signed download URL;
- inspected package, label, version name/code, and target SDK;
- one install result and installed package/version/activity verification;
- exact temporary cleanup result, Git state, checks, first blocker, and next
  owner/action.

Do not record EAS session/token/cookie material, signed artifact URL, private
credentials, device identifiers beyond the accepted ADB serial, broad device
data, or unrelated installed-package inventory.

## Version And Build Invariant

This download/install does not alter source or mobile ledgers:

- app version remains `1.0.0`;
- Android version code remains `1`;
- iOS build remains `1`;
- no EAS build, retry, or version increment occurs.

## Explicit Exclusions

- another EAS build, retry, cancel, rebuild, artifact deletion, source upload,
  credential/signing action, AAB, store, submission, OTA, or release;
- local/prebuild/Gradle/EAS build or generated `android/`/`ios/` tree;
- app launch, Metro, ADB reverse, dummy smoke, camera permission/scan, OAuth,
  real API, logs, screenshot, account interaction, or runtime validation;
- uninstall, update/replace, downgrade, data clearing, device setting changes,
  another device, another package, or broad device inspection;
- provider/server/deployment, Google/Apple/SourceGrid console, secret, payment,
  production data, domain, push, or repository product/source/config change.

## Acceptance Criteria

1. Exact connected Pixel target, package absence, and disk preconditions pass.
2. Exact finished EAS build application archive is downloaded once to a new
   temporary directory only.
3. APK digest and identity match every frozen package/version/SDK/label field
   before device mutation.
4. Exactly one non-replacement install is attempted on the exact serial, with
   no retry after an ambiguous or failed mutation boundary.
5. Installed package path/version/activity are verified without launching the
   app.
6. The temporary APK/directory are deleted immediately and no local artifact,
   native tree, signing material, or source change remains.
7. `1.0.0 / 1 / 1` remains unchanged; no excluded cloud, runtime, provider,
   deployment, or release action occurs.

## Terminal Classifications

- `eas_android_development_client_installed`;
- `target_device_precondition_failed`;
- `artifact_download_or_identity_failed`;
- `device_install_failed`;
- `device_install_reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

On success, the next separate phase may launch the installed development
client with Metro in explicit dummy mode and perform dummy/camera fixture
validation. Real API/OAuth validation remains separately gated.

## Current Gate

Current classification:
`expo_eas_android_development_client_download_install_authorized`.

First blocker: none. The exact Pixel/device, package absence, device disk, and
remote artifact have direct evidence; each must be rechecked immediately before
its protected action.
