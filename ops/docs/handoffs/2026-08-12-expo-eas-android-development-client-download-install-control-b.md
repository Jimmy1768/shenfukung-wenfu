# TempleMate EAS Android Development-Client Download and Install Receipt

Status: closed Control receipt. The Implementer performed no protected action;
Control completed the allowed preflight and one-use download attempt below.

Date: 2026-08-12

## Immutable Target

- EAS owner/project: `@jimmy1768/templemate` /
  `c7b8523a-2fad-4123-bc96-0c0c85a23dec`.
- Required finished build: `ca45b77c-cb45-458c-a298-6be449a9e396`.
- Required build source: `a67aa8fa6f57885461af91c319f7a830b99f0764`.
- Required build shape: Android, `development`, internal distribution, one
  application APK.
- Required artifact identity: `TempleMate (Dev)`,
  `com.jimmy1768.komainu.dev`, version `1.0.0`, version code `1`, target SDK
  `36`.
- Sole device fence: serial `39011FDJH00FQ8`, Pixel 8 / `shiba`, Android 17 /
  API 37, in ADB state `device`.

The accepted build receipt documents this build as `FINISHED` with an available
artifact. That is historical documented evidence only. Its current remote
metadata and availability must be re-established by Control immediately before
the protected download.

## Static Local Evidence

`mobile/app.config.js` currently resolves the development-client identity to
`TempleMate (Dev)` and `com.jimmy1768.komainu.dev`, with `compileSdkVersion`
and `targetSdkVersion` 36. It declares the linked EAS project ID above. The
accepted build source is an ancestor of this packet's base
`aa2a3c408377f9e1f58ae93ce050060d90dfccea`.

This receipt does not use static source configuration as a substitute for APK
inspection or current device/package evidence.

## Ordered Control-Only Gates

Every field below is **Control-observed pending** until the single protected
execution records a sanitized result. A failed or ambiguous gate stops at the
point specified; it never selects another build, artifact, package, or device.

1. **Repository and remote build gate.** Confirm clean canonical and isolated
   Git state with empty staging; confirm plan/build-receipt/source ancestry;
   then use the exact read-only EAS build view to confirm the immutable project,
   finished build, Android/development/internal shape, source commit, and one
   application artifact. An unexpected result, prompt, or unavailable artifact
   stops before download.
2. **Local and physical-device gate.** Confirm at least 2 GB temporary-filesystem
   space. On serial `39011FDJH00FQ8` only, confirm USB `device` state, Pixel 8 /
   `shiba`, Android 17/API 37, at least 1 GB `/data` space, and that
   `com.jimmy1768.komainu.dev` is absent. Any absent, mismatched, ambiguous, or
   already-installed state stops before download/install.
3. **One-download and archive gate.** Create one new system temporary directory
   and download exactly build `ca45b77c-cb45-458c-a298-6be449a9e396` once with
   the installed EAS CLI. Retain no signed URL. Require exactly one regular APK
   there; record only byte size and SHA-256. Local archive inspection must prove
   the required package, label, version name/code, and target SDK. A malformed,
   additional, split, AAB, production, or mismatched artifact stops before
   install.
4. **Fresh install gate.** Re-confirm the exact connected serial and package
   absence. Control alone may make exactly one unflagged standard install of
   the inspected APK on that serial. No replace, downgrade, test, grant-all,
   update, or second installation is permitted.
5. **Reconciliation and post-install gate.** After the install mutation
   boundary, any timeout/disconnect/ambiguous outcome receives only read-only
   exact-package reconciliation; it is never retried. A successful result must
   prove installed base path, version `1.0.0`/code `1`, target SDK `36`, and
   launcher resolution. The app must not launch.
6. **Mandatory cleanup gate.** On success, certain failure, rejection, or
   reconciliation-required outcome, delete only the newly created exact
   temporary directory and prove it absent. Confirm no APK/AAB/native tree or
   signing material entered the repository and that Git/staging are clean.

## Final Sanitized Control Evidence

- **P1 target preflight: passed.** Serial `39011FDJH00FQ8` was the exact Pixel
  8 / `shiba` target in Android 17/API 37 state. Its `/data` free-space reading
  was approximately `55,046,000 KiB`; battery was 100%. The exact
  `com.jimmy1768.komainu.dev` package was absent (`pm path` exited 1).
- **Remote build identity: passed.** The safe build-view receipt resolved build
  `ca45b77c-cb45-458c-a298-6be449a9e396` as `FINISHED`, Android/internal/
  `development`, owned by `jimmy1768/templemate` with project ID
  `c7b8523a-2fad-4123-bc96-0c0c85a23dec`, source
  `a67aa8fa6f57885461af91c319f7a830b99f0764`, and an available artifact.
- **Local disk fence: passed.** The selected temporary filesystem had more
  than 2 GB free.
- **One-use download result: uncertain then reconciled.** Control invoked the
  single authorized exact-build download. Its local zsh wrapper reached a
  read-only status-variable failure after command invocation, so Control did
  not infer download success and did not retry. Targeted read-only
  reconciliation found only the exact newly created temporary directory
  `/private/tmp/templemate-eas-apk.LqNs24`, empty with zero artifact files.
- **Cleanup: passed.** Control deleted that exact empty temporary directory and
  verified its absence. A temporary `node_modules` symlink was removed. No
  APK, AAB, `app.json`, native tree, signing material, or other artifact
  residue remained; Git changes are limited to this receipt and the Control
  packet.
- **Mutation boundary: not reached.** No APK identity inspection, ADB install,
  app launch, Metro, reverse mapping, or other device/runtime action occurred.

## Sanitized Receipt Fields

Control may fill only these fields after execution:

| Field | Result |
| --- | --- |
| EAS project/build and finished/artifact-available classification | exact target; `FINISHED` / available |
| Target serial, model/codename, OS/API, and package-before classification | exact Pixel 8 / `shiba`, Android 17/API 37; package absent |
| Temporary filesystem and `/data` disk-fence classifications | passed; >2 GB temporary / ~55,046,000 KiB `/data` |
| APK byte size and SHA-256 | unavailable: no APK was present |
| APK package, label, version name/code, and target SDK | unavailable: identity inspection not reached |
| One install result; package-after/version/launcher classification | not attempted: install boundary not reached |
| Exact temporary-directory cleanup result | `/private/tmp/templemate-eas-apk.LqNs24` removed and absent |
| Final Git/staging/diff-check result, terminal classification, next owner | report + Control packet only; `artifact_download_or_identity_failed`; Planning/Director |

Do not include signed artifact URLs, session tokens, cookies, keys, passwords,
credential JSON, signing material, broad device information, logs, or package
inventory.

## One-Use Boundary and Terminal Outcomes

The download is one use for the exact build only. The installation is one use
for the exact APK and serial only. A safe remote-created/download result with a
later local failure is not authority to repeat either protected action. After
the install command crosses the device-mutation boundary, a second install is
forbidden even if the package remains absent.

The only terminal classifications are:

- `eas_android_development_client_installed`;
- `target_device_precondition_failed`;
- `artifact_download_or_identity_failed`;
- `device_install_failed`;
- `device_install_reconciliation_required`; or
- `no_evidence_backed_direct_repair_remaining`.

## Terminal Closeout

Terminal classification: `artifact_download_or_identity_failed`.

Continuation disposition: `no_evidence_backed_direct_repair_remaining`.

The first prevented action was APK identity inspection and installation: the
single permitted download invocation did not produce an APK. The next owner is
Planning/Director, which must investigate EAS artifact delivery and, if it
chooses to continue, authorize a new separately bounded artifact-download
attempt. This packet does not authorize a retry.

No runtime launch, Metro, ADB reverse, QR/camera, OAuth, real API, provider,
server, signing, build, release, deployment, push, or source/config/version
change belongs to this packet. A later separately authorized phase may perform
dummy launch and fixture-camera validation only after a successful clean
install; real API/OAuth validation remains separately gated.
