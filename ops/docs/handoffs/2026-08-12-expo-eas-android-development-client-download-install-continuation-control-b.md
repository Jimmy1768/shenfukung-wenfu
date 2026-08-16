# TempleMate EAS Android development-client download/install continuation — safe receipt

## Immutable identity and boundary

- Packet: `2026-08-12-expo-eas-android-development-client-download-install-continuation-control-b`, attempt 2.
- Accepted continuation plan/base: `ops/docs/plans/EXPO_EAS_ANDROID_DEVELOPMENT_CLIENT_DOWNLOAD_INSTALL_CONTINUATION_PLAN.md` at `35ff790e32185baf10d41be5793b01cd1c982a62`.
- Exact remote build: `@jimmy1768/templemate` / project `c7b8523a-2fad-4123-bc96-0c0c85a23dec`; build `ca45b77c-cb45-458c-a298-6be449a9e396`; accepted source `a67aa8fa6f57885461af91c319f7a830b99f0764`.
- Sole device fence: serial `39011FDJH00FQ8`, Pixel 8 / `shiba`, Android 17/API 37; the target package is `com.jimmy1768.komainu.dev`.
- This document contains only safe receipt fields. It must never contain an artifact URL, token, cookie, credential, private session value, or raw protected-command output.

## Implementer static preparation

The Implementer performed no EAS, ADB, network, download, temporary-directory, generated-config, dependency, device, or other external action. Local source review establishes the fixed identity that Control must verify from the downloaded artifact before the one install:

- [`mobile/app.config.js`](../../../mobile/app.config.js) resolves development mode to owner `jimmy1768`, project ID `c7b8523a-2fad-4123-bc96-0c0c85a23dec`, public name `TempleMate (Dev)`, Android package `com.jimmy1768.komainu.dev`, version `1.0.0`, and compile/target SDK `36`.
- [`mobile/eas.json`](../../../mobile/eas.json) defines the development-client/internal Android APK profile with `BUILD_MODE=development`, and local app-version authority.
- [`mobile/__tests__/native-config.test.js`](../../../mobile/__tests__/native-config.test.js) fixes the version invariants: application `1.0.0`, Android version code `1`, iOS build number `1`, and no `autoIncrement` setting.

This static evidence does not prove remote artifact identity, target presence, package absence, disk capacity, install outcome, or cleanup. Those are Control-observed protected steps below.

## Control-observed protected preflight — passed

Control recorded the following sanitized preflight evidence before the one download invocation:

- the exact accepted build source is an ancestor of the fenced source state;
- the temporary filesystem had more than 19 GB free space;
- serial `39011FDJH00FQ8` reported Pixel 8 / `shiba`, Android 17/API 37, state `device`, approximately `55,045,944 KiB` free device data, and 100% battery;
- `com.jimmy1768.komainu.dev` was absent on that exact target.

The preflight did not cross the APK or device-mutation boundary.

## One-use download and artifact gate — stopped before artifact creation

Control created literal directory `/private/tmp/templemate-eas-apk.H7xg5Z` in its own command. In a separate process with that literal directory as its working directory, Control invoked exactly once, without a wrapper, the accepted direct command:

```text
/opt/homebrew/bin/eas build:download --build-id ca45b77c-cb45-458c-a298-6be449a9e396 --non-interactive
```

The CLI stopped before download with the sanitized message: `Run this command inside a project directory.` The literal directory was empty. No source materialization, dependency link, generated `app.json`, artifact, artifact identity inspection, ADB install, or runtime action occurred. Cleanup removed the exact literal directory and confirmed it absent.

The invocation had no shell status assignment, command substitution, trap, loop, pipeline, conditional wrapper, compound expression, retry, URL option, or `--all-artifacts`. No second download is authorized.

## One-install and read-only reconciliation — not reached

Only after the artifact gate passes and Control rechecks the fenced target and package absence may Control invoke exactly once:

```text
adb -s 39011FDJH00FQ8 install <literal-inspected-apk-path>
```

No install flags, replacement, downgrade, test, grant-all option, launch, Metro, reverse mapping, runtime validation, or retry is authorized. An ambiguous install result permits only read-only reconciliation of the exact package. A successful outcome additionally requires sanitized proof of package path, version `1.0.0`, code `1`, target SDK `36`, and launcher resolution, without launching the app.

## Mandatory cleanup and terminal boundary

The exact literal temporary directory was deleted and proven absent. No local artifact, native tree, signing material, generated config, or dependency residue was created; the remote EAS artifact remains untouched.

Permitted terminal classifications are:

- `eas_android_development_client_installed`;
- `target_device_precondition_failed`;
- `artifact_download_or_identity_failed`;
- `device_install_failed`;
- `device_install_reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

Terminal classification: `artifact_download_or_identity_failed`.

Continuation disposition: `no_evidence_backed_direct_repair_remaining`.

First prevented action: the APK download. The accepted continuation simultaneously requires the EAS command to run inside a project directory and requires its process working directory to be the literal temporary directory. Control must not improvise a workaround or retry.

Next owner/action: Planning must resolve the command interface and authority for a new packet. No source/config/version/build, signing, EAS build/retry/cancel/delete, provider/server/deployment, release/payment/push, or further device action is authorized by this receipt.
