# Expo EAS Android source-backed download/install — Control B packet

## Identity

- Accepted plan and immutable criteria:
  `ops/docs/plans/EXPO_EAS_ANDROID_DEVELOPMENT_CLIENT_SOURCE_BACKED_DOWNLOAD_INSTALL_PLAN.md`
  at `e841bf11be84220b462a77ecc9f9beb6df62eb0f`.
- Failed predecessor receipts:
  `4b1fd08fa2e9e02085d32ed1ddec4e80a8a85704` and
  `95a851807270dc4896dc1637d20cc653646c2c0f`.
- Control: Wenfu Control B `019fe020-e92e-7770-984f-b59acd547ab0`.
- Repository/worktree/branch/base:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`,
  `/private/tmp/shengfukung-wenfu-expo-eas-android-source-backed-download-install`,
  `codex/expo-eas-android-source-backed-download-install`,
  `e841bf11be84220b462a77ecc9f9beb6df62eb0f`.
- Packet identity/attempt:
  `2026-08-12-expo-eas-android-source-backed-download-install-control-b`,
  attempt 3.

## Exact Target And Protected Manifest

- Exact project/build/source only: `@jimmy1768/templemate` /
  `c7b8523a-2fad-4123-bc96-0c0c85a23dec`, build
  `ca45b77c-cb45-458c-a298-6be449a9e396`, source
  `a67aa8fa6f57885461af91c319f7a830b99f0764`.
- Exact device only: serial `39011FDJH00FQ8`, Pixel 8 / `shiba`, state
  `device`; install only when `com.jimmy1768.komainu.dev` is absent.
- Frozen deterministic cache APK path:
  `/var/folders/7d/lv5mnq115d1gf833_p5zwdfr0000gn/T/eas-cli-nodejs/eas-build-run-cache/c7b8523a-2fad-4123-bc96-0c0c85a23dec_ca45b77c-cb45-458c-a298-6be449a9e396.apk`.
- P1 materialization: prove clean/staging/ancestry; linked public Expo config;
  byte-identical isolated/camera `mobile/package.json` and `yarn.lock`; real
  camera-worktree node_modules; isolated path absent. Create only a temporary
  ignored isolated `mobile/node_modules` symlink to that exact directory. No
  install/copy/config/source change. Record residue before/after.
- P2 preflight: exact safe read-only finished Android/internal/development
  metadata/project/source/artifact availability; cache filesystem >=2GB;
  recompute equal frozen cache path and prove it absent; exact device/disk/
  package absence. Any failure stops before download.
- P3 one-use direct source-backed download: from literal isolated `mobile/`
  cwd only, one direct `/opt/homebrew/bin/eas build:download --build-id
  ca45b77c-cb45-458c-a298-6be449a9e396 --json --non-interactive`; no shell
  status variable, substitution, trap, loop, pipeline, conditional, wrapper,
  extra artifacts, or retry. Sanitized JSON path must equal frozen cache path.
- P4 exact cache file only: regular APK, size/SHA-256/aapt must prove
  `com.jimmy1768.komainu.dev`, `TempleMate (Dev)`, `1.0.0`, code `1`, target
  SDK 36. Otherwise cleanup/terminal; no install.
- P5 one install only after rechecking target/package absence: exact
  `adb -s 39011FDJH00FQ8 install <frozen-cache-apk-path>` no flags. Never
  retry after mutation boundary; ambiguity gets exact-package read-only query.
- P6 verify exact installed path/version/code/target SDK/launcher only; no
  launch. P7 remove exact packet-created cache APK, the exact symlink, and
  only an exact empty packet-created cache directory; prove no residue.
- Safe receipt only: frozen IDs, serial/model/codename/API/package state, size/
  SHA, inspected identity, one install/verification result, cleanup/Git/next
  owner. Never URL/token/cookie/credential/private output.
- Explicit exclusions: any source/config/dependency/version change, signing,
  build/retry/cancel/artifact deletion, native build, launch/Metro/reverse/
  runtime/camera/OAuth/API, provider/server/deployment/release/payment/push.

## Implementer, Checks, And Terminal Boundary

- Implementer-only report:
  `ops/docs/handoffs/2026-08-12-expo-eas-android-source-backed-download-install-control-b.md`.
  This packet is Control-owned; nothing else may change.
- One ephemeral Implementer `gpt-5.6-terra/medium`: read-only report scaffold
  only; no EAS/ADB/download/symlink/cache/artifact/stage/commit/external action.
- Persistent Handoff requested/eligible: no; Luna disqualifiers checked.
- On full success only, integrate safe receipt/packet to canonical main.
  Otherwise canonical remains unchanged and Control commits the isolated
  terminal record only. Control sends one direct terminal to Planning.

## Control Review And Closeout

- Conformance review: accepted. Exact linked-source materialization, immutable
  build/cache metadata, target device/disk/package absence, one direct cache
  download, APK identity, one ordinary install, read-only package/launcher
  verification, and exact cache/symlink cleanup all passed.
- Acceptance decision: `eas_android_development_client_installed` with
  `accepted_frozen_outcome`. The app was never launched and no runtime,
  signing, provider, build, or source action followed installation.
- Safe evidence: APK was `148,549,454` bytes with SHA-256
  `5126cd6f88e185a0006b0d793e2c256bf0db051d3abe106535212b39c785c4e6` and
  proved the frozen Komainu development package, TempleMate (Dev), version
  `1.0.0`/code `1`, target SDK `36`, and `MainActivity` launcher. The exact
  Pixel installed it successfully and package verification matched.
- Cleanup/postcondition: the exact packet-created cache APK and empty cache
  directory, plus the exact temporary dependency symlink, were removed; no
  generated config/native/signing/artifact residue remains.
- Integration: Control commits and fast-forwards only this safe receipt and
  packet to canonical main. Planning owns any separately authorized dummy and
  fixture-camera validation continuation.
