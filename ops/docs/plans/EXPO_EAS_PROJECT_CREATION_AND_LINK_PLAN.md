# Expo EAS Project Creation And Link Plan

Status: accepted for direct one-off external-mutation dispatch to Control B
after this plan is committed

Created: 2026-08-11

Owner: Wenfu Planning

Director authorization: explicit instruction received to create a new EAS
project

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline and preflight evidence:

- canonical `main`: `dfa44bf50c3bab3060af96f3bcd34f509504681a`;
- `ops/docs/handoffs/2026-08-11-expo-eas-project-and-signing-preflight-control-b.md`;
- authenticated Expo account label observed by the accepted preflight:
  `jimmy1768`;
- current source classification: no configured EAS project and no
  `extra.eas.projectId`.

## Objective

Create exactly one new EAS project for the existing TempleMate Expo app under
the Director-owned Expo account `jimmy1768`, then durably link this repository
to the returned nonsecret EAS project ID.

This packet ends after project creation, source linkage, and read-only
project/config verification. It does not configure Android signing, start a
build, create an artifact, access a provider, or touch a device.

## Exact Target Identity

The only authorized external target is the new EAS project derived from the
accepted Expo source identity:

- EAS owner: `jimmy1768`;
- EAS/Expo slug: `templemate`;
- expected full name: `@jimmy1768/templemate`;
- public development name: `TempleMate (Dev)`;
- internal project name: `komainu`;
- development Android package: `com.jimmy1768.komainu.dev`;
- production Android/iOS identifier: `com.jimmy1768.komainu`;
- development iOS identifier: `com.jimmy1768.komainu.dev`;
- scheme/native OAuth return: `templemate` /
  `templemate://oauth/complete`;
- EAS profile retained for later use: `development`, internal-distribution
  development-client APK.

Do not create or link a project named Komainu, Wenfu,
`shengfukung-wenfu`, a tenant name, DojoMate, or Thea. The internal god-name
identifier remains `komainu`; the EAS project follows the already accepted
public Expo slug `templemate`.

## Authorized Source Correction

Control B may integrate the smallest checked-in linkage correction required by
the installed EAS CLI and this dynamic Expo configuration:

- set Expo `owner` to the exact literal `jimmy1768`;
- add `extra.eas.projectId` using only the UUID returned for the newly created
  `@jimmy1768/templemate` project;
- extend the existing native-config test and verification guard only as needed
  to prove that owner/project ID are present and identical in development and
  production public config.

The project ID is nonsecret. It must not be guessed, generated locally, copied
from another app, accepted from a similarly named project, or supplied before
the EAS service returns it.

Allowed product paths are limited to:

- `mobile/app.config.js`;
- `mobile/__tests__/native-config.test.js`;
- `mobile/scripts/verify-native-client.js`.

Control-owned packet/report paths under `ops/docs/handoffs/` are also allowed.
No dependency, lockfile, EAS profile, versioning, OAuth, camera, Rails, Vue, or
sibling-repository edit is authorized.

## One-Use Creation And Collision Fence

Control owns the exact immutable command manifest after rechecking local EAS
CLI help. The accepted interface is the installed `/opt/homebrew/bin/eas`
`project:init`/`init` command from `mobile/`; no CLI upgrade or installation is
authorized.

Before the mutation, Control must prove all of the following:

1. canonical and isolated Git state and staging are clean at the accepted
   source/packet points;
2. the existing authenticated account is exactly `jimmy1768`, with no login,
   account change, token display, or credential transfer;
3. the resolved local Expo owner/slug are exactly
   `@jimmy1768/templemate` and the Komainu identifiers/config remain intact;
4. no durable `extra.eas.projectId` is already present;
5. one non-mutating, noninteractive initialization preflight distinguishes an
   absent remote `@jimmy1768/templemate` from an existing collision.

If `@jimmy1768/templemate` already exists, stop. Do not link it, overwrite it,
rename it, delete it, or create a guessed alternate slug. Return
`eas_project_name_collision_decision_required` with the safe existing-project
classification.

Only when the exact target is observed absent may Control invoke one creation
attempt equivalent to:

```text
CI=1 /opt/homebrew/bin/eas project:init --force --non-interactive
```

from the exact prepared `mobile/` target. This is a one-use authorization for
creation of `@jimmy1768/templemate`; it is not reusable for another owner,
slug, repository, or retry.

## Dynamic-Config Reconciliation And Uncertain Outcome

Local CLI inspection proves that this EAS CLI creates the remote project before
attempting to write `extra.eas.projectId`, and that automatic modification can
fail for dynamic `app.config.js`. Therefore a nonzero command exit after a
safe `Created @jimmy1768/templemate` receipt is not permission to rerun
creation.

After any creation invocation:

- never issue a second forced creation attempt;
- retain only the safe owner/slug/project-ID/result classification;
- reconcile the exact remote outcome first;
- if the returned project ID is certain, add that exact ID to the dynamic
  config and verify it through read-only `eas project:info` and resolved EAS
  config;
- if creation success or the returned ID is uncertain, stop with
  `reconciliation_required`; do not guess, retry, link another project, or
  delete anything;
- if remote creation succeeded but local linkage or tests fail, keep the new
  project untouched and repair only the bounded local linkage under the same
  immutable criteria;
- project deletion, transfer, rename, and alternate-project creation are not
  rollback actions and are not authorized.

Local unaccepted source edits may be discarded safely only when they have no
unreconciled external counterpart. Once remote creation succeeds, rollback is
forward reconciliation to the exact returned ID, not external deletion.

## Safe Receipt

The durable terminal report may record only:

- EAS CLI path/version;
- authenticated owner label `jimmy1768`;
- collision preflight classification;
- creation command result classification;
- nonsecret full project name, slug, owner, and UUID;
- final `eas project:info` correspondence;
- resolved public development configuration and source-link location;
- Git commits/status/check results and next-state classification.

Never record session values, access tokens, cookies, API keys, passwords,
keystores, private keys, certificates, credential JSON, environment secrets,
or unredacted private command output.

## Required Verification

After a certain creation receipt and durable source link, Control must prove:

- `eas project:info` resolves the exact new project ID,
  `@jimmy1768/templemate`, and no other owner/slug;
- `eas config --platform android --profile development --json` resolves
  successfully and retains `TempleMate (Dev)`,
  `com.jimmy1768.komainu.dev`, the `templemate` scheme, internal APK/dev-client
  profile, OAuth/camera native declarations, and API 36;
- development and production public Expo config both carry the same EAS owner
  and project ID while retaining their accepted Komainu identifiers;
- `yarn test`, `yarn lint`, and `yarn verify` pass;
- focused scans find no rejected identifiers, secrets, generated native
  projects, signing material, build artifacts, or unintended configuration;
- `git diff --check` passes and accepted canonical/isolated worktrees finish
  clean with staging empty.

Expo Doctor, prebuild, Gradle, and a native build are not required because this
packet changes no dependency or native module.

## Version And Build Invariant

As one minor invariant within the broader project-creation result:

- app version remains `1.0.0`;
- Android version code remains `1`;
- iOS build remains `1`;
- `appVersionSource` remains local;
- no `autoIncrement` is added.

Creating or linking an EAS project does not consume or advance a build number.

## Explicit Exclusions

- linking an existing or similarly named project;
- a second creation attempt, guessed alternate slug, rename, transfer, or
  project deletion;
- EAS account/login/token/session mutation or CLI/dependency installation;
- Android/iOS credential inspection, generation, configuration, repair,
  rotation, upload, download, deletion, or signing;
- EAS/local build, prebuild, native generation, artifact, submission, OTA,
  channel, store, AAB, TestFlight, or release action;
- provider, Google Cloud, Apple Developer, SourceGrid console/runtime,
  credential, secret, allowlist, live OAuth, Rails/Vue deployment, or domain
  action;
- Metro, ADB, Pixel/device, APK installation, camera/runtime testing, payment,
  production data, push, or deployment.

## Acceptance Criteria

1. Exactly one new EAS project is created as
   `@jimmy1768/templemate`, or the packet stops before mutation on an exact
   collision/authority failure.
2. A successful creation is durably linked through the exact returned
   `extra.eas.projectId`, with `owner: jimmy1768`, and verified by read-only EAS
   project/config resolution.
3. No ambiguous response is retried; uncertain outcomes require reconciliation
   and no duplicate, deletion, rename, transfer, or alternate project is
   created.
4. TempleMate/Komainu names, native identifiers, account-only OAuth/camera
   configuration, dummy default, development APK profile, and API 36 remain
   intact.
5. `1.0.0 / 1 / 1` and local version authority remain unchanged as a minor
   invariant.
6. No signing, build, artifact, provider, deployment, device, secret, release,
   or push action occurs; required source/EAS/Git checks pass.

## Terminal Classification

Control B returns one immutable terminal packet with one of:

- `eas_project_created_and_linked`;
- `eas_project_name_collision_decision_required`;
- `eas_project_creation_authority_or_account_failure`;
- `reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

On `eas_project_created_and_linked`, the smallest later phase is a separately
authorized Android signing/build preflight or EAS cloud development-client
build packet. Neither is implied by this plan.

## Current Gate

Current classification: `expo_eas_project_creation_and_link_authorized`.

First blocker: none for the exact collision preflight and one-use creation
attempt. An existing target slug or an uncertain mutation outcome is a hard
stop under the classifications above.
