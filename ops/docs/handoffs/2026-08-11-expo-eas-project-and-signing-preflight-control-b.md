# Expo EAS project and signing preflight — Control B

Date: 2026-08-11
Packet: `2026-08-11-expo-eas-project-and-signing-preflight-control-b`
Plan/base: `18bf7503e769be2bce7e6c062091ad651ff9216e`
Accepted readiness baseline: `84ca6f8c5f4afbd6d29cc29751f49977ef452158`

## Scope and provenance

This is an authenticated, read-only EAS preflight for the future Android
development-client APK only. The protected commands were issued by Control;
this report records only Control-sanitized safe receipts. No command was
rerun while preparing this report.

The isolated preflight worktree was
`/private/tmp/shengfukung-wenfu-expo-eas-project-signing-preflight` on
`codex/expo-eas-project-signing-preflight` at the plan commit. Its initially
unmaterialized ignored `mobile/node_modules` prevented P3 before any remote
project result. Control proved tracked mobile-source equivalence with:

```
git diff --quiet b476d42a422f28fbe9918fb8870a93e633486d99 \
  18bf7503e769be2bce7e6c062091ad651ff9216e -- mobile
```

Control then used the clean, source-identical materialized camera worktree
`/private/tmp/shengfukung-wenfu-expo-temple-qr-camera` at
`b476d42a422f28fbe9918fb8870a93e633486d99` for the distinct P3 and P4 calls.
That was a provenance-preserving environment repair, not a retry or source
change. No installation, build, generated artifact, repository write, or
external mutation occurred.

## Sanitized protected-command receipts

| ID | Exact command and cwd | Safe receipt | Classification |
| --- | --- | --- | --- |
| P1 | `/opt/homebrew/bin/eas --version` (local shell) | `/opt/homebrew/bin/eas`; `eas-cli/18.12.2 darwin-arm64 node-v20.20.2` | Existing CLI; an upgrade notice was ignored. |
| P2 | `CI=1 /opt/homebrew/bin/eas whoami` (`…/expo-eas-project-signing-preflight/mobile`) | Existing authenticated account label: `jimmy1768` | Session available; no login or account switch. |
| P3 | `CI=1 /opt/homebrew/bin/eas project:info` (`…/expo-temple-qr-camera/mobile`) | `EAS project not configured` | Unlinked. The noninteractive CLI indicated that forbidden `eas init` would be required. No input, selection, retry, or write occurred. |
| P4 | `CI=1 /opt/homebrew/bin/eas config --platform android --profile development --json` (`…/expo-temple-qr-camera/mobile`) | Same unlinked classification; no resolved EAS configuration returned | Source cannot yet be proven noninteractive-build-ready. No input, selection, retry, or write occurred. |

Local help inspection showed `eas credentials` as interactive credential
management, including `credentials:configure-build`, and exposed no
provably non-mutating Android signing-metadata path. It was not invoked.
Android signing is therefore **unknown**; no credential state or material was
inspected.

## Target correspondence and static source evidence

The unlinked EAS state cannot prove an EAS project corresponds to TempleMate;
no similarly named remote project was guessed. Checked-in public source,
which is not an EAS-resolved receipt, identifies the intended development
target as:

- public name `TempleMate (Dev)`, slug `templemate`, and scheme `templemate`;
- Android package `com.jimmy1768.komainu.dev`;
- development-client, internal-distribution APK profile;
- app version `1.0.0`, Android version code `1`, and iOS build number `1`;
- compile/target SDK 36;
- camera purpose declaration with `recordAudioAndroid: false`;
- native OAuth return `templemate://oauth/complete`.

The development profile is defined in `mobile/eas.json`; the public Expo
configuration is defined in `mobile/app.config.js`. Those values remain static
source evidence only because P4 could not resolve a linked EAS project.

## Verdict and next state

**Next-state classification:** `eas_project_link_source_correction_required`.

The first prevented action is a noninteractive project/config resolution:
P3 and P4 both stop because this source has no configured EAS project and the
CLI would require the forbidden `eas init`/link path. The available session
does not authorize creating, selecting, linking, or transferring a project.
Consequently this preflight cannot establish project correspondence, signing
classification, or that the existing source can run a noninteractive EAS
build.

The smallest next packet is a separately authorized **EAS project
link/selection decision or source-correction packet**. It must identify the
intended Director-owned EAS project (or explicitly authorize project creation
if none exists), bound any permitted link/source change such as
`extra.eas.projectId`, and rerun bounded read-only project/config verification
afterward. It must separately decide whether signing inspection or credential
configuration is authorized; neither is implied here.

The `1.0.0 / 1 / 1` values remain unchanged as a minor invariant, not the
readiness verdict. No token, cookie, key, password, credential JSON, private
material, or secret-bearing command output is recorded in this report.

## Postconditions

Only this report and the two Control packet records are present as worktree
changes. No EAS project/account/credential/build/artifact state, product
source/configuration/dependency/lockfile, provider, deployment, Metro, ADB,
device, or release surface was changed. `git diff --check` for this report is
the required documentation-only check.
