# TempleMate EAS Android source-backed download/install — safe receipt scaffold

## Immutable identity and boundary

- Packet: `2026-08-12-expo-eas-android-source-backed-download-install-control-b`, attempt 3.
- Accepted plan/base:
  `ops/docs/plans/EXPO_EAS_ANDROID_DEVELOPMENT_CLIENT_SOURCE_BACKED_DOWNLOAD_INSTALL_PLAN.md`
  at `e841bf11be84220b462a77ecc9f9beb6df62eb0f`.
- Exact remote target: `@jimmy1768/templemate` / project
  `c7b8523a-2fad-4123-bc96-0c0c85a23dec`; build
  `ca45b77c-cb45-458c-a298-6be449a9e396`; source
  `a67aa8fa6f57885461af91c319f7a830b99f0764`.
- Sole device fence: serial `39011FDJH00FQ8`, Pixel 8 / `shiba`, Android 17 /
  API 37. The only installable package is
  `com.jimmy1768.komainu.dev` and it must be absent before installation.
- Frozen cache APK path:
  `/var/folders/7d/lv5mnq115d1gf833_p5zwdfr0000gn/T/eas-cli-nodejs/eas-build-run-cache/c7b8523a-2fad-4123-bc96-0c0c85a23dec_ca45b77c-cb45-458c-a298-6be449a9e396.apk`.

This receipt contains safe fields only. It must not contain a signed artifact
URL, token, cookie, credential, private session value, key, password, or raw
protected-command output.

## Implementer static preparation

The Implementer performed only local static and Git review. It did not run EAS
or ADB, access a network, create a dependency symlink, create or inspect an
EAS cache artifact, download an APK, mutate a device, stage, commit, or make
any external change.

The accepted plan fixes the expected APK identity for Control's later archive
inspection: launcher label `TempleMate (Dev)`, package
`com.jimmy1768.komainu.dev`, version `1.0.0`, version code `1`, and target SDK
`36`. The plan also requires isolated `mobile/package.json` and `yarn.lock` to
be byte-identical to the accepted camera worktree before the sole temporary
`mobile/node_modules` symlink may be created.

Static plan evidence is not a substitute for Control's remote-build, cache,
archive, device, package-absence, installation, or cleanup evidence.

## Control-observed protected gates — pending

Every result in this section is **Control-observed pending**. A mismatch,
ambiguous result, unexpected prompt, or failed gate must stop at the plan's
specified boundary without selecting another source, build, artifact, package,
or device.

1. **Source materialization and residue gate.** Prove clean canonical and
   isolated Git/staging plus exact plan/source ancestry; prove the linked public
   Expo configuration and the required byte-identical manifests/lockfiles;
   prove the accepted camera worktree has a real `mobile/node_modules` directory
   while the isolated worktree has none. Record ignored/untracked inventory.
   Only then may Control create the one ignored isolated symlink to that exact
   dependency directory.
2. **Remote/cache/device preflight.** Re-establish that the frozen build is
   finished Android/internal/development with the exact project/source and an
   available application artifact; require at least 2 GB free on the cache
   filesystem; recompute the exact frozen cache path and prove it absent. On
   the exact serial only, prove the fenced model/codename/state, at least 1 GB
   `/data` space, and package absence.
3. **One-use source-backed download.** From the literal isolated `mobile/`
   directory, Control alone may invoke once as a direct process:

   ```text
   /opt/homebrew/bin/eas build:download --build-id ca45b77c-cb45-458c-a298-6be449a9e396 --json --non-interactive
   ```

   The sanitized JSON path must equal the frozen cache path. No wrapper,
   substitution, shell status variable, trap, loop, pipeline, conditional,
   extra-artifact request, or retry is allowed. A failure, missing/mismatched
   path, or unexpected repository write stops before device mutation.
4. **Artifact identity gate.** Only one regular APK at the exact cache path
   may be inspected. Control records only byte size and SHA-256, then requires
   the frozen package, label, version name/code, and target SDK. An AAB, split,
   malformed archive, or mismatch stops before installation.
5. **One-install and verification gate.** After a fresh exact-target/package
   absence check, Control alone may run exactly one unflagged ordinary install:

   ```text
   adb -s 39011FDJH00FQ8 install <frozen-cache-apk-path>
   ```

   It must not launch the app. After the mutation boundary, no retry is
   authorized; ambiguity permits only exact-package read-only reconciliation.
   Success additionally requires sanitized installed-path, version/code,
   target-SDK, and launcher-resolution evidence.
6. **Mandatory exact cleanup gate.** On every terminal path after link
   creation, remove the packet-created cache APK, remove the exact symlink, and
   remove an empty packet-created cache directory only when exact attribution
   permits. Prove no artifact, native/generated tree, signing material,
   dependency link, or source/config residue remains, with clean/staging-empty
   isolated and canonical worktrees.

## Sanitized Control evidence

Control completed the protected sequence with the following safe receipts.

- **Source materialization: passed.** The isolated `mobile/package.json` and
  `mobile/yarn.lock` were byte-identical to the accepted camera worktree. The
  required temporary dependency symlink was created and later removed.
- **Remote/cache preflight: passed.** The frozen cache APK path was absent
  before download. The exact build was `FINISHED`, Android/internal/
  development, with the accepted project, source, version/build metadata, and
  available application artifact.
- **Target preflight: passed.** Serial `39011FDJH00FQ8` reported Pixel 8 /
  `shiba`, Android 17/API 37, `55,047,280 KiB` free `/data`, and 100% battery.
  `com.jimmy1768.komainu.dev` was absent before installation.
- **One-use download and artifact identity: passed.** The direct download
  returned the exact frozen cache path. Its sole APK was `148,549,454` bytes
  with SHA-256
  `5126cd6f88e185a0006b0d793e2c256bf0db051d3abe106535212b39c785c4e6`.
  Local archive inspection established package `com.jimmy1768.komainu.dev`,
  launcher label `TempleMate (Dev)`, version `1.0.0`, version code `1`, target
  SDK `36`, and `MainActivity`.
- **One-install and read-only verification: passed.** The sole unflagged
  install succeeded. Control then verified the installed base path, version
  `1.0.0`, code `1`, target SDK `36`, and launcher resolution to
  `.MainActivity`. The app was not launched.
- **Cleanup and residue: passed.** Control deleted the exact packet-created
  cache APK, removed its now-empty cache directory, and removed the temporary
  dependency symlink. No `app.json`, APK, AAB, native tree, signing material,
  or source residue remains; changes are limited to this report and the
  Control packet.

## Sanitized Control receipt fields

| Field | Control-observed result |
| --- | --- |
| Remote build/project/source/artifact classification | `FINISHED`; exact Android/internal/development build and application artifact |
| Source-equivalence, dependency-link, and pre-download residue classification | byte-identical manifests/lockfile; temporary link removed |
| Cache filesystem and exact-cache-path-absent classification | passed; absent before download |
| Target serial/model/codename/OS/API/disk/package-before classification | exact Pixel 8 / `shiba`, Android 17/API 37; `55,047,280 KiB` free; package absent |
| APK byte size and SHA-256 | `148,549,454` bytes; `5126cd6f88e185a0006b0d793e2c256bf0db051d3abe106535212b39c785c4e6` |
| APK package/label/version name/code/target SDK | `com.jimmy1768.komainu.dev`; `TempleMate (Dev)`; `1.0.0` / `1` / `36` |
| Sole install result and package-after/launcher classification | succeeded; base package verified; `.MainActivity` resolves; no launch |
| Exact cache-file, cache-directory, and symlink cleanup | all packet-created paths removed; no prohibited residue |
| Final Git/staging/diff classification | report and Control packet only; Control-observed final clean/staging-empty result |

## Terminal boundary

The sole download and sole installation remain one-use protected actions. A
safe remote result followed by any local failure never authorizes a retry. The
permitted terminal classifications are:

- `eas_android_development_client_installed`;
- `source_materialization_or_target_precondition_failed`;
- `artifact_download_or_identity_failed`;
- `device_install_failed`;
- `device_install_reconciliation_required`; or
- `no_evidence_backed_direct_repair_remaining`.

Terminal classification: `eas_android_development_client_installed`.

Continuation disposition: `accepted_frozen_outcome`.

Next owner/action: Planning may define a separately authorized dummy and
fixture-camera validation packet. This receipt authorizes no runtime action.
No app launch, Metro, ADB reverse, runtime/camera/OAuth/API action, EAS build,
signing/credential action, provider/server/deployment/release/payment action,
push, or source/config/dependency/version mutation is authorized by this
scaffold.
