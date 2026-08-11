# Expo EAS Android Development-Client Build Plan

Status: accepted for direct protected build dispatch to Control A after this
plan is committed

Created: 2026-08-12

Owner: Wenfu Planning

Director authorization: explicit instruction received to send Control A to run
the EAS cloud development-client APK build

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`306500d879fdc56b4f3eb44884505ccc96fac53c`

Required predecessor evidence:

- `ops/docs/handoffs/2026-08-11-expo-development-client-build-readiness-control-b.md`;
- `ops/docs/handoffs/2026-08-12-expo-eas-project-creation-and-link-control-b.md`.

## Objective

Submit exactly one EAS cloud build for the TempleMate Android development
client, wait for its terminal cloud status, and record a safe build receipt.
Use existing EAS-managed Android signing credentials when present or generate
exactly one EAS-managed development keystore when absent.

This phase ends with the remote build and metadata verification. It does not
download or install the APK, run Metro, touch a device, deploy Rails, configure
OAuth providers, or perform release/store work.

## Exact Build Target

- EAS owner/project: `@jimmy1768/templemate`;
- EAS project ID: `c7b8523a-2fad-4123-bc96-0c0c85a23dec`;
- platform: Android only;
- EAS build profile: `development`;
- distribution: internal;
- artifact type: APK;
- development client: enabled;
- public launcher: `TempleMate (Dev)`;
- internal project: `komainu`;
- Android package: `com.jimmy1768.komainu.dev`;
- scheme/OAuth return: `templemate` /
  `templemate://oauth/complete`;
- compile/target SDK: 36;
- app version: `1.0.0`;
- Android version code: `1`;
- iOS build number retained but unused: `1`.

The build must contain the accepted Expo development client, secure storage,
Google/Apple central-browser OAuth modules, and QR camera module/configuration.
Dummy mode remains the default.

## Preflight

Control A records the immutable implementation packet, creates an isolated
`codex/` branch/worktree from the committed plan, and uses one ephemeral
Implementer for bounded local evidence/report preparation. The Implementer
does not access EAS, credentials, or external state.

Before any credential or build action, Control independently proves:

1. canonical and isolated worktrees are clean with staging empty and the
   accepted baseline/plan ancestry is exact;
2. `/opt/homebrew/bin/eas` is the existing CLI; no installation or upgrade;
3. the existing authenticated account label is exactly `jimmy1768`;
4. `eas project:info` resolves only the exact owner/project/UUID above;
5. resolved Android `development` configuration matches every target field
   above and contains no `autoIncrement`;
6. `yarn test`, `yarn lint`, `yarn verify`, and project-local offline Doctor
   pass from the exact build source;
7. no local `android/` or `ios/` generated directory, APK/AAB, signing file,
   or unaccepted source/config/dependency change exists;
8. read-only build-list checks find no matching Android `development` build in
   `new`, `in-queue`, `in-progress`, or `pending-cancel` state.

If the authenticated account, project correspondence, target configuration,
source checks, or active-build fence fails, stop before credential mutation or
build submission.

## Android Signing Authority

The profile uses remote EAS credentials. Control A may:

- use the existing EAS-managed Android keystore for exact package
  `com.jimmy1768.komainu.dev`; or
- if EAS explicitly reports that no Android keystore exists for this exact
  project/package, select exactly the standard EAS `Generate new keystore`
  action once and allow EAS to retain it remotely.

This is one-off authority to create the minimum Android signing credential
required for this development APK. It does not authorize:

- viewing, printing, downloading, exporting, copying, rotating, replacing, or
  deleting a keystore or password;
- local `credentials.json`, a checked-in keystore, custom signing material, or
  Google Play App Signing;
- any credential for the production package, iOS, another EAS project, or
  another app;
- push/FCM credentials, provider secrets, service-account keys, or store
  credentials.

Any prompt other than use of an existing exact remote credential or generation
of one new exact Android keystore is a hard stop. Never record private signing
material in chat, source, logs, or the durable receipt.

## One-Use Cloud Build

After all preconditions pass, Control A may invoke one cloud submission using
the installed CLI interface equivalent to:

```text
/opt/homebrew/bin/eas build --platform android --profile development --wait
```

The command must not include `--local`, `--auto-submit`, `--clear-cache`, an
alternate profile, or any version-changing option. Control may answer only the
exact signing prompt authorized above. It must not accept an application-ID,
project-link, account-change, source-write, submission, store, provider, or
unrelated configuration prompt.

Exactly one build-job submission is authorized. After the command reaches a
possible submission boundary:

- never invoke a second build command under this plan;
- record the returned build ID immediately when available;
- wait for the existing job and inspect it read-only with `eas build:view` or
  build-list queries;
- if the CLI disconnects, times out, or returns an ambiguous result, reconcile
  by exact project/platform/profile/source commit before any conclusion;
- if no certain job identity can be recovered, return
  `reconciliation_required`; do not resubmit;
- a failed or canceled cloud job is terminal evidence for this packet, not
  authority for a replacement build.

No source correction is authorized during the protected build. A concrete
source/configuration failure returns its exact safe stage and requires a later
accepted repair/build decision.

## Remote Artifact And Disk Boundary

On successful build completion, verify through EAS metadata that the artifact
is an Android internal-distribution development-client APK with the accepted
identity/version/API/profile. Record only artifact availability and the build
dashboard identity.

Do not download the APK in this phase. In particular:

- do not create a large local artifact or native build tree;
- do not use a signed/time-limited artifact download URL as durable evidence;
- do not install on the Pixel or another device;
- do not start Metro or create ADB reverse mappings;
- leave device installation and immediate post-install local artifact deletion
  to a separately authorized device packet.

The successful remote artifact may remain in EAS. No EAS build or artifact
deletion is authorized.

## Safe Receipt

The durable Control terminal may record only:

- CLI version/path and authenticated account label;
- exact project owner/name/UUID;
- source commit and build profile/platform/distribution;
- signing classification: existing remote credential used, or one new
  EAS-managed keystore generated, without key material;
- EAS build ID, dashboard URL, timestamps, queue/build status, failure stage
  when applicable, and artifact-available boolean;
- resolved app name/package/scheme/SDK/version/build values;
- checks, Git status, terminal classification, first blocker, and next owner.

Do not record tokens, cookies, session material, keystore/private key data,
passwords, credential JSON, provider secrets, environment secrets, signed
artifact URLs, or raw private build payloads.

## Required Checks And Acceptance

- local preflight checks listed above pass on exact build source;
- no active matching job exists before submission;
- no more than one build job is submitted;
- signing uses an existing exact remote credential or one newly generated
  exact EAS-managed Android keystore;
- terminal EAS metadata corresponds to the exact project, source commit,
  Android `development` profile, internal distribution, and APK artifact;
- `TempleMate (Dev)`, `com.jimmy1768.komainu.dev`, `templemate`, OAuth/camera,
  dummy default, and API 36 remain intact;
- app `1.0.0`, Android `1`, iOS `1`, `appVersionSource: local`, and no
  `autoIncrement` remain unchanged before and after the build;
- no local APK/native tree/signing material is created and Git finishes clean
  with staging empty;
- report redaction and `git diff --check` pass.

Success means the remote EAS job finishes successfully and exposes an APK
artifact in EAS. It does not mean the APK has been downloaded, installed,
launched, or physically validated.

## Explicit Exclusions

- local Expo/Gradle/EAS build, prebuild, native generation, APK/AAB download,
  device install, Metro, ADB, camera, or runtime action;
- a second cloud build, build retry, cancellation, deletion, rebuild, resubmit,
  auto-submit, Play upload, AAB, store, OTA, channel, or release action;
- version/build increment or remote version authority;
- production Android/iOS signing, credential export/rotation/replacement/
  deletion, local credential files, Google Play signing, FCM, or push setup;
- Rails/Vue/server deployment, provider/Google Cloud/Apple/SourceGrid console,
  OAuth allowlist, account/secret, live OAuth, payment, domain, production data,
  push, or deployment;
- source/config/dependency/lockfile/product changes outside Control packet and
  terminal-report records.

## Terminal Classifications

Control A returns one immutable terminal packet with one of:

- `eas_android_development_client_build_succeeded`;
- `eas_android_development_client_build_failed` with certain build ID/stage;
- `active_matching_build_detected`;
- `eas_signing_authority_or_account_failure`;
- `build_source_or_configuration_repair_required`;
- `reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

On success, the next separate phase is target-fenced APK download/install,
dummy smoke, and fixture-camera validation. Real API/OAuth validation still
requires its separate server/provider authority and does not block this build.

## Current Gate

Current classification:
`expo_eas_android_development_client_cloud_build_authorized`.

First blocker: none for the exact preflight and one-use build. Missing signing
credentials may be resolved only through the exact EAS-managed generation
authority above.
