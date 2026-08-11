# Expo EAS Project And Signing Preflight Plan

Status: accepted for direct authenticated preflight dispatch to Control B after
this plan is committed

Created: 2026-08-11

Owner: Wenfu Planning

Director authorization: explicit one-off authorization received after the
accepted development-client build readiness scan

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline and readiness report:

- canonical `main`: `84ca6f8c5f4afbd6d29cc29751f49977ef452158`
- `ops/docs/handoffs/2026-08-11-expo-development-client-build-readiness-control-b.md`

Observed local tool before plan commit: `/opt/homebrew/bin/eas`,
`eas-cli/18.12.2 darwin-arm64 node-v20.20.2`.

## Objective

Perform one authenticated, read-only EAS preflight for the future TempleMate
Android development-client APK. Establish the logged-in Expo account, current
TempleMate/Komainu EAS project-link state, noninteractive resolved development
configuration, and the safest available non-mutating Android signing-state
classification.

The preflight must answer what already exists. It must not create, link,
initialize, configure, rename, transfer, or delete an EAS project; generate,
rotate, upload, download, expose, or delete credentials; or start a build.

## Exact Target Identity

The only accepted target is:

- public development name: `TempleMate (Dev)`;
- internal project name: `komainu`;
- Expo slug: `templemate`;
- Android package: `com.jimmy1768.komainu.dev`;
- future artifact: Android internal-distribution development-client APK;
- EAS profile: `development`;
- version/build invariant: app `1.0.0`, Android code `1`, iOS build `1`.

Do not infer that a project named TempleMate, Komainu, Wenfu, or
shengfukung-wenfu is the accepted EAS project merely because its display name
looks related. Prove correspondence using account/project identity plus the
checked-in Expo slug/package/config. Do not attach TempleMate to DojoMate/Thea
or another existing project.

## Authorized Read-Only Surfaces

Control B may use the already installed EAS CLI and authenticated session only
for bounded read-only evidence. Expected safe commands include:

- `eas --version`;
- `eas whoami`;
- `eas project:info` from `mobile/`;
- `eas config --platform android --profile development --json` from `mobile/`;
- local `eas ... --help` discovery needed to prove whether a signing inspection
  path is read-only before invoking it.

Control owns the exact immutable command list after inspecting local help. It
may inspect Android signing metadata only if it can prove a non-mutating path
that returns classification such as absent/present/managed/owner without
revealing key material, passwords, private files, or recovery values.

`eas credentials --platform android` is not automatically authorized merely
because it exists. It is interactive and belongs in the packet only if Control
first proves the exact input/exit path cannot create, configure, rotate,
download, upload, or delete credentials. Otherwise signing remains unknown and
the report names the missing safe inspection mechanism.

## Hard-Stop And Uncertain-Outcome Fence

Before each authenticated call, Control records the target repository,
worktree, commit, working directory, expected command, expected safe output
fields, and the no-mutation postcondition.

Stop without responding to any prompt that offers or requires:

- EAS project creation, initialization, linking, or transfer;
- `eas init`, `project:init`, or a write to `extra.eas.projectId`;
- credential generation, configuration, repair, rotation, upload, download,
  deletion, or replacement;
- keystore/private-key/certificate file access or password display;
- a cloud build, submission, artifact, channel, update, or distribution action;
- account login/change if the existing authenticated session is absent or is
  not clearly the intended Director-owned account.

If a command's outcome is ambiguous, treat it as `reconciliation_required`.
Do not retry it blindly, select a guessed option, or use a write command to
learn what would happen.

## Safe Evidence And Redaction

The durable report may record only:

- installed EAS CLI version/path;
- logged-in Expo username/account label;
- EAS project present/absent/unlinked/ambiguous classification;
- nonsecret project ID, slug, owner, and display label when returned by the
  read-only project command;
- resolved development profile/name/package/scheme/artifact/config values;
- Android signing classification such as absent, present, EAS-managed,
  locally supplied, or unknown;
- whether the next build would require a separately authorized project-link,
  credential-generation/configuration, or source-correction packet.

Never record access tokens, cookies, session values, API keys, keystore files,
private keys, certificates, passwords, credential download URLs, raw
credential JSON, or environment-secret values. Command output containing a
secret must be suppressed from chat and repository records.

## Required Deliverable

Control B returns one immutable report at:

`ops/docs/handoffs/2026-08-11-expo-eas-project-and-signing-preflight-control-b.md`

The report must contain:

- canonical/isolated Git evidence and exact authenticated read-only commands;
- safe receipt fields for account, project link, resolved config, and signing;
- whether the existing source can run a noninteractive EAS build without a
  project-link/configuration prompt;
- exact first prevented action and evidence;
- one of these next-state classifications:
  - `eas_preflight_ready_for_build_plan`;
  - `eas_project_link_source_correction_required`;
  - `eas_project_creation_or_selection_decision_required`;
  - `eas_signing_configuration_authority_required`;
  - `eas_authenticated_session_unavailable`;
  - `reconciliation_required`;
- the smallest separately authorizable next packet without performing it;
- confirmation that version/build values remain unchanged as a minor
  invariant, not the main readiness verdict.

Only this report and Control B's immutable implementation record may change.
Product/config/dependency/lockfile/Planning/sibling files remain read-only.

## Checks

- clean canonical and isolated worktrees with staging empty before protected
  calls;
- exact baseline ancestry and current public development config;
- EAS CLI path/version and local help inspection;
- authenticated safe receipts with secret suppression;
- `eas config` development JSON checked against TempleMate/Komainu identity,
  internal APK/dev-client profile, OAuth/camera native configuration, SDK 36,
  and `1.0.0 / 1 / 1`;
- post-call repository equivalence, clean status/staging, and no EAS-generated
  local config/credential/artifact files;
- report redaction scan and `git diff --check`.

Running mobile tests, Rails tests, Expo Doctor, native generation, or a build is
not required: the accepted source baseline already passed those checks, and
this packet changes documentation only.

## Explicit Exclusions

- EAS project/source linking or `extra.eas.projectId` edit;
- EAS project/account/organization creation, transfer, rename, or deletion;
- Android credential/keystore generation, rotation, upload, download,
  deletion, or repair;
- EAS/local build, prebuild, native generation, artifact, submission, OTA, or
  channel action;
- provider/Google Cloud/Apple/SourceGrid console, secret, account, allowlist,
  deployment, or live OAuth;
- Metro, ADB, Pixel/device, APK installation, camera, or runtime action;
- version/build increment, `autoIncrement`, AAB, Play, iOS/TestFlight,
  payment, production data, push, or release.

## Acceptance Criteria

1. Authenticated account/project/config evidence is collected through bounded
   read-only EAS calls with no source or external mutation.
2. TempleMate/Komainu correspondence is proven or classified as absent/
   ambiguous; no similarly named project is guessed or linked.
3. Android signing is safely classified only to the extent a provably
   non-mutating path permits; otherwise the precise safe-inspection gap is
   reported.
4. Every project or credential write prompt is rejected without input, and
   ambiguous outcomes enter the uncertain-outcome fence.
5. The report identifies the smallest next packet and whether a build can be
   noninteractive after it, without starting that build.
6. No secrets or credential material enter chat, logs, source, or the durable
   report.
7. `1.0.0 / 1 / 1` remains unchanged as one minor invariant; Git and EAS
   external state remain unmodified by this packet.

## Current Gate

Current classification: `expo_eas_project_and_signing_preflight_authorized`.

First blocker: none for the bounded read-only account/project/config calls.
Signing inspection may stop as unknown if the installed CLI exposes no proven
non-mutating path.
