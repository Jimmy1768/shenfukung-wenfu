# Expo EAS Android development-client download/install continuation — Control packet

## Identity

- Accepted plan and immutable criteria:
  `ops/docs/plans/EXPO_EAS_ANDROID_DEVELOPMENT_CLIENT_DOWNLOAD_INSTALL_CONTINUATION_PLAN.md`
  at `35ff790e32185baf10d41be5793b01cd1c982a62`.
- Failed predecessor: terminal
  `2026-08-12-expo-eas-android-development-client-download-install-control-b`
  / isolated receipt `4b1fd08fa2e9e02085d32ed1ddec4e80a8a85704`;
  local zsh reserved-variable wrapper error only.
- Control: Wenfu Control B `019fe020-e92e-7770-984f-b59acd547ab0`.
- Repository/worktree/branch/base:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`,
  `/private/tmp/shengfukung-wenfu-expo-eas-android-dev-client-download-install-2`,
  `codex/expo-eas-android-dev-client-download-install-2`,
  `35ff790e32185baf10d41be5793b01cd1c982a62`.
- Packet identity/attempt:
  `2026-08-12-expo-eas-android-development-client-download-install-continuation-control-b`,
  attempt 2.

## Exact Target And Protected Manifest

- Exact remote build only: `@jimmy1768/templemate` /
  `c7b8523a-2fad-4123-bc96-0c0c85a23dec`, build
  `ca45b77c-cb45-458c-a298-6be449a9e396`, source
  `a67aa8fa6f57885461af91c319f7a830b99f0764`, finished Android/
  `development`/internal application APK.
- Exact device only: ADB serial `39011FDJH00FQ8`, Pixel 8 / `shiba`, state
  `device`; package must be absent before the one install.
- P1 read-only preflight: clean canonical/isolated status/staging; exact build
  receipt; temp filesystem >=2GB; exact target/model/codename/API/device disk
  >=1GB/battery; package absence. Any failure stops before download.
- P2: `mktemp -d /private/tmp/templemate-eas-apk.XXXXXX` is its own command;
  record one literal returned directory. No source tree, dependency link, or
  generated config is permitted.
- P3 one-use direct download: the process working directory is the literal P2
  directory and the command is exactly `/opt/homebrew/bin/eas build:download
  --build-id ca45b77c-cb45-458c-a298-6be449a9e396 --non-interactive`. It has no
  shell status assignment/variable, substitution, trap, loop, pipeline,
  conditional, compound wrapper, or URL/log/all-artifacts flag. There is no
  second P3 invocation.
- P4 artifact gate: reconcile literal P2 directory; exactly one regular APK;
  size/SHA-256 and aapt prove `com.jimmy1768.komainu.dev`, `TempleMate (Dev)`,
  `1.0.0`, code `1`, target SDK `36`. Otherwise cleanup and terminal failure.
- P5 one install: recheck exact device/package absence; exactly one literal
  `adb -s 39011FDJH00FQ8 install <literal-inspected-apk-path>` with no flags.
  No retry after device mutation. Ambiguous outcome gets exact-package
  read-only reconciliation only.
- P6 post-install: exact package path/version/code/target-SDK and launcher
  resolution; do not launch. P7 cleanup: remove only literal P2 directory,
  prove absent/no local residue, and preserve remote artifact.
- Durable receipt fields only: specified build/project fields; serial/model/
  codename/API/package status; APK size/SHA; inspected identity; one install
  result/postinstall fields; cleanup/Git state/next owner. Never artifact URL,
  token/session/cookie/credentials/private output.
- Explicit exclusions: extra download/build/retry/cancel/artifact deletion,
  signing/credential, source/config/dependency/version change, native build,
  launch/Metro/reverse/runtime/camera/OAuth/API, provider/server/deployment,
  release/payment/push.

## Implementer, Checks, And Terminal Boundary

- Exact owned report path (Implementer):
  `ops/docs/handoffs/2026-08-12-expo-eas-android-development-client-download-install-continuation-control-b.md`.
  This packet is Control-owned. No other path is editable.
- One ephemeral Implementer: `gpt-5.6-terra/medium`, packet-local/read-only
  report scaffold only; it may not execute EAS/ADB, download, inspect an APK,
  create a temp directory, stage/commit, or mutate external state.
- Persistent Handoff requested/eligible: no; Luna disqualifiers checked.
- Required evidence: exact clean/ancestry/source config, remote metadata,
  target/disk/package preconditions, artifact identity, one install, exact
  postinstall verification, literal cleanup, no residue, `git diff --check`,
  clean final worktrees/staging. No product test suite is required for this
  receipt-only continuation.
- On all success criteria, integrate only safe receipt/packet to canonical
  main; otherwise canonical is unchanged. Control sends exactly one direct
  terminal packet to Planning.

## Control Review And Closeout

- Conformance review: exact device/disk/package-absence preflight passed. P2
  created the literal temporary directory. P3 then ran exactly once with no
  wrapper in that literal directory and was rejected before download because
  the installed CLI requires a project-directory cwd.
- Acceptance decision: `artifact_download_or_identity_failed` with
  `no_evidence_backed_direct_repair_remaining`. The accepted continuation
  simultaneously required the literal temporary cwd and the CLI's project
  directory condition; Control cannot substitute or retry under this packet.
  No APK was created, inspected, or installed.
- Cleanup/postcondition: exact empty temporary directory was removed and
  absence proven. No `app.json`, dependency link, APK/AAB, native tree,
  signing material, source/config/version change, or device mutation remains.
- Integration: prohibited because all success criteria did not pass. Control
  commits the safe receipt/packet only on this isolated branch; canonical main
  remains unchanged. Planning must resolve a new command-interface/authority
  packet before any further download attempt.
