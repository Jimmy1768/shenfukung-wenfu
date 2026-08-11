# Expo Development Client Build Readiness Scan Plan

Status: accepted for direct report-only dispatch to Control B after this plan
is committed

Created: 2026-08-11

Owner: Wenfu Planning

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted source baseline:
`b476d42a422f28fbe9918fb8870a93e633486d99`

Mature read-only build reference:
`/Users/jimmy1768/Projects/DojoMate-Expo`

## Objective

Produce a source- and evidence-backed readiness report for one future Android
TempleMate development-client APK built by EAS cloud. The new binary is needed
because the accepted OAuth and camera packages were added after the currently
installed historical development client was built.

This is a readiness scan only. It does not configure EAS, start a build,
download an artifact, install an APK, run Metro, touch the Pixel, configure an
OAuth provider, access a secret, deploy Rails, or mutate any external system.

The report must distinguish:

- source-ready conditions;
- externally verifiable prerequisites;
- configuration or source gaps requiring a later bounded implementation;
- build-time gates;
- post-build installation and physical validation gates; and
- release-only concerns that do not block this development client.

## Target Artifact And Build Policy

The intended future artifact is one Android internal-distribution development
client APK for `TempleMate (Dev)` / `com.jimmy1768.komainu.dev`, using the
`development` EAS profile and EAS cloud.

It is not an AAB, Play upload, release candidate, production APK, OTA publish,
or iOS/TestFlight build. Local prebuild, Gradle, `expo run:android`, and local
EAS build remain prohibited absent a separately accepted concrete native-debug
reason or explicit Director request.

DojoMate is the mature reference for cloud-first build policy, named build
commands, environment/profile separation, project linkage, artifact handling,
and local-build fallback boundaries. TempleMate must not copy DojoMate's
product identifiers, versions, runtime channels, Firebase files, production
profiles, or unrelated dependencies.

## Readiness Questions

### 1. Source and dependency closure

Verify that the accepted source contains every native module intended for this
binary and that another known V1 native module is not waiting immediately
behind the build. At minimum inventory:

- Expo SDK 54 / React Native 0.81 and API 36;
- `expo-dev-client`;
- `expo-secure-store`;
- OAuth: `expo-auth-session`, `expo-web-browser`, and `expo-crypto`;
- QR camera: `expo-camera`, camera permission, QR-only scanning, and Android
  audio disabled;
- native scheme and public development identifier/artwork.

Run the existing package/config/source checks and offline Doctor. Report exact
patch recommendations or native-config gaps without upgrading or editing them.

### 2. EAS project and account linkage

Map the exact local evidence for:

- `mobile/eas.json` schema/profile validity;
- development-client/internal/APK semantics;
- Expo account owner and EAS project identity/linkage;
- whether `extra.eas.projectId` or another project-link field is absent,
  present, stale, or externally unknown;
- whether a future noninteractive build would prompt to create/link a project;
- EAS CLI version/availability and any package-script wrapper gap;
- Android development signing/keystore ownership and whether EAS can manage it
  without Google Play or provider credentials.

Do not log in, query EAS cloud/account state, create/link a project, initialize
credentials, or mutate configuration. Classify all unverified cloud facts as
unknown and name the exact later read-only or protected check needed.

### 3. Development configuration and runtime seam

Prove what the binary receives from the `development` EAS profile and what can
still be selected when Metro serves JavaScript. Determine whether:

- the built launcher is `TempleMate (Dev)` with
  `com.jimmy1768.komainu.dev` and `templemate://oauth/complete`;
- dummy mode remains the safe default;
- explicit real local/test mode and its API base URL/tenant slug can be
  selected at Metro start without another native rebuild;
- Android `localhost` requires ADB reverse for Rails and Metro, including the
  exact ports only when source evidence identifies them;
- cleartext local HTTP is accepted or needs native network-security config;
- a LAN or deployed HTTPS origin is rejected by the current real-mode guard;
- OAuth return handling works with a development client and does not require a
  provider SDK, Google services file, or client secret in the binary.

Do not invent a permanent TempleMate domain or a live tenant-binding contract.

### 4. Rails and central OAuth prerequisites

Separate binary readiness from server/provider readiness. Inventory the exact
later prerequisites for a real OAuth device test:

- deployed Wenfu Rails source containing the accepted native start/exchange
  endpoints;
- fixed `AUTH_NATIVE_RETURN_URL=templemate://oauth/complete` behavior;
- SourceGrid central-auth tenant/start/exchange and return allowlisting;
- Google and Apple provider configuration already used by browser OAuth versus
  any TempleMate-native return registration still missing;
- account-only scope, profile-required behavior, invalid-grant handling, and
  no provider secret in Expo.

Use local source and existing accepted readiness evidence. Do not access
provider consoles, credentials, SourceGrid runtime, staging secrets, or live
OAuth.

### 5. Device, installation, and artifact handling

Prepare the later acceptance checklist without touching a device:

- exact expected package/name/version/build/target-SDK before installation;
- exact identity of any historical wrong-identifier development package and a
  later Director-performed uninstall precondition; the Director has confirmed
  the app on the Pixel can be uninstalled, so coexistence is not a blocker;
- clean install behavior for the accepted Komainu package after that uninstall;
- Android OS level versus target SDK: a device newer than Android 16 is not a
  blocker merely because the app targets API 36;
- Metro/ADB reverse setup and cleanup ownership;
- camera permission reset/denial/retry and physical fixture-QR scan;
- dummy smoke test before real OAuth;
- Google and Apple central-browser success, cancellation, denial,
  profile-required, restart/interruption, and logout/cleanup where later
  provider authority permits;
- app-scoped log review with no secrets, codes, provider tokens, or raw central
  bodies;
- low-disk preflight, temporary APK location, and immediate artifact deletion
  after installation unless the Director explicitly requests retention.

The report must not require Android 16/API 36 hardware. The API 36 requirement
belongs to the generated/built target; current physical QA may use a newer
Android version.

### 6. Version/build invariant

Verify, as one bounded readiness check rather than the organizing purpose of
the scan:

- app version remains `1.0.0`;
- Android version code remains `1`;
- iOS build remains `1`;
- `appVersionSource` remains local;
- no profile or command enables `autoIncrement`;
- the development APK does not consume the Android Play release-code ledger or
  an iOS TestFlight version/build pair;
- no readiness correction, EAS project linking, cloud build, failed build,
  download, installation, or device test changes these values.

Do not propose an increment. Version/build advancement remains a later mobile
release decision under the already accepted platform-specific consumption
rules.

## Required Deliverable

Control B returns one immutable report at:

`ops/docs/handoffs/2026-08-11-expo-development-client-build-readiness-control-b.md`

The report must contain:

- observed canonical commit/status/staging and all evidence sources;
- a concise readiness verdict for source, EAS cloud, server/OAuth, device, and
  cleanup surfaces;
- exact blockers ordered by the first action each prevents;
- a proposed later execution sequence split into separately authorizable
  packets where external/provider/deployment authority differs;
- the exact future EAS profile/command interface and artifact type, or an
  explicit gap if source does not yet define them safely;
- a pre-build invariant checklist and a post-build/device acceptance matrix;
- explicit unknowns rather than inferred account, project, credential,
  provider, or deployment facts;
- confirmation that `1.0.0 / 1 / 1` remains unchanged without allowing that
  minor invariant to crowd out broader readiness findings.

Only this report and Control B's immutable implementation record may change.
Product source, config, dependencies, lockfiles, Planning documents, sibling
repositories, and external systems are read-only.

## Checks

- focused canonical source/config/dependency inventory;
- `yarn test`, `yarn lint`, `yarn verify`, and project-local/offline Doctor;
- public development and production Expo config inspection without prebuild;
- read-only DojoMate EAS/config/version/artifact workflow comparison;
- focused Rails/native OAuth route/config/test inventory without runtime call;
- secret-value, provider-token, generated-native-artifact, rejected-identifier,
  and unintended version/build increment scans;
- report diff and `git diff --check`;
- final isolated branch clean with staging empty; canonical main unchanged by
  report preparation until Control's accepted local integration.

## Explicit Exclusions

- source/config/dependency correction;
- EAS account/project/credential query or mutation;
- EAS or local build, prebuild, native generation, APK/AAB download;
- Metro, ADB, device installation, permission prompt, or physical QR/OAuth
  test;
- provider/Google Cloud/Apple Developer/SourceGrid console, account, credential,
  secret, allowlist, or runtime access;
- Rails/Vue deployment, production data, payment, store, OTA, release, push,
  or domain action.

## Acceptance Criteria

1. The report distinguishes source readiness from EAS, server/provider,
   installation/device, and release gates using direct evidence.
2. It proves whether one cloud-built Android development APK can contain the
   accepted OAuth and camera native modules without a second known native
   rebuild immediately afterward.
3. It identifies the exact EAS project/linkage, command/profile, signing,
   environment, artifact, and cleanup prerequisites without external access or
   mutation.
4. It maps the local/test real-mode and OAuth server prerequisites without
   inventing provider, domain, tenant-trust, or secret facts.
5. It provides a bounded future build/install/validation sequence that keeps
   cloud build, deployment/provider configuration, and device actions under
   their proper later authorities.
6. It confirms `1.0.0`, Android `1`, and iOS `1` remain unchanged and no
   auto-increment is introduced, while treating that as one minor invariant.
7. Only the report and Control record change; required checks pass and final
   Git states are clean.

## Current Gate

Current classification: `expo_development_client_build_readiness_scan_authorized`.

First blocker: none for the report-only scan. Any EAS/cloud, provider,
deployment, build, artifact, or device action remains separately unauthorized.
