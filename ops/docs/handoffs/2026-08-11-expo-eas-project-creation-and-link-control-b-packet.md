# Expo EAS project creation and link — Control B implementation packet

## Identity

- Accepted plan and immutable criteria:
  `ops/docs/plans/EXPO_EAS_PROJECT_CREATION_AND_LINK_PLAN.md`, actual
  authoritative plan commit `f16bb85dc718423030d29cca27ba0e29ba90e5c6`.
  The dispatch's longer hash was not a Git object; its unique short prefix
  `f16bb85` resolves to this current canonical commit.
- Control: Wenfu Control B `019fe020-e92e-7770-984f-b59acd547ab0` under the
  Director's explicit one-off “yes, create a new EAS project” authority.
- Repository/worktree/branch/base:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`,
  `/private/tmp/shengfukung-wenfu-expo-eas-project-creation-link`,
  `codex/expo-eas-project-creation-link`,
  `f16bb85dc718423030d29cca27ba0e29ba90e5c6`.
- Immutable packet identity and attempt:
  `2026-08-11-expo-eas-project-creation-and-link-control-b`, attempt 1.

## Scope And Two-Step Local Preparation

- Exact external target only: a new EAS project `@jimmy1768/templemate`.
  `komainu` remains internal; accepted development package is
  `com.jimmy1768.komainu.dev` and production identifier is
  `com.jimmy1768.komainu`.
- First bounded local correction before the external mutation: the sole
  Implementer sets `expo.owner` to exact literal `jimmy1768` in
  `mobile/app.config.js` and adds focused owner/config proof only in
  `mobile/__tests__/native-config.test.js` and
  `mobile/scripts/verify-native-client.js`. It must not guess/add a project
  ID. Control reviews, tests, and commits this preparation on the isolated
  branch before the protected calls, so the source presented to EAS has exact
  owner/slug identity and a clean Git state.
- After a certain remote creation receipt only, the same bounded packet allows
  the Implementer to add the returned nonsecret UUID as
  `extra.eas.projectId` and extend the focused config/verification proof. If
  creation/UUID is uncertain, no project-ID source edit occurs.
- Exact product-owned paths: `mobile/app.config.js`,
  `mobile/__tests__/native-config.test.js`, and
  `mobile/scripts/verify-native-client.js` only. Report and Control records
  under `ops/docs/handoffs/` are allowed. All other source/config/dependency/
  lockfile/eas.json/versioning/OAuth/camera/Rails/Vue/sibling paths excluded.

## Protected External Manifest

- Read-only preparation and preconditions: clean canonical/isolated status and
  staging; exact base/source-preparation commit; static public development and
  production config proves owner `jimmy1768`, slug `templemate`, no durable
  `extra.eas.projectId`, TempleMate/Komainu identifiers, development internal
  APK, API 36, and `1.0.0 / 1 / 1`; `CI=1 /opt/homebrew/bin/eas whoami` must
  return existing account label `jimmy1768` only.
- Materialized local dependency provenance: the isolated worktree has no
  ignored `node_modules`. Before any EAS call, Control may create one temporary
  symlink at `mobile/node_modules` to the already materialized accepted
  dependency tree in `/private/tmp/shengfukung-wenfu-expo-temple-qr-camera/
  mobile/node_modules`, only after proving the prepared tracked `mobile/`
  source is identical apart from the intended owner/project-ID correction.
  It is neither a dependency install nor a source/lockfile change and must be
  removed after the protected calls; Git status/staging and no generated files
  are recorded before and after.
- P1 collision preflight (one call, no mutation): from prepared `mobile/`,
  `CI=1 /opt/homebrew/bin/eas project:init --non-interactive`. Installed CLI
  source shows it queries exact owner/slug then fails before link/create:
  existing target returns an existing-project collision; absent target returns
  “Project does not exist … Use --force”. No input, prompt, link, overwrite,
  or retry is permitted.
- P2 one-use creation (only if P1 proved exact target absent): from the same
  prepared `mobile/`, `CI=1 /opt/homebrew/bin/eas project:init --force
  --non-interactive`. It may create only `@jimmy1768/templemate`. Control
  records only result classification plus returned owner/slug/UUID. No second
  P2 attempt is ever authorized.
- P3/P4 read-only reconciliation after a certain creation/UUID and durable
  source link: `CI=1 /opt/homebrew/bin/eas project:info`; then
  `CI=1 /opt/homebrew/bin/eas config --platform android --profile development
  --json`. Report only safe project correspondence and resolved public config
  fields. Each command is one-time; prompt, secret-bearing output, disconnect,
  timeout, unexpected project, or uncertain result is
  `reconciliation_required` and stops further external activity.
- Hard exclusions: any account login/change, `--id` link to existing project,
  project rename/transfer/delete/alternate slug, credential/signing action,
  build/prebuild/artifact, provider/deployment/secret, Metro/ADB/device,
  release/payment/push, CLI install/upgrade, and every command outside P1–P4.

## Evidence, Checks, And Boundaries

- Durable safe fields only: CLI path/version, account label, collision/creation
  classification, full project name/owner/slug/UUID, final project/config
  correspondence, source-link location, Git/check status, and next state.
  Never record session/token/cookie/key/credential/private output.
- Required local proof: focused tests; `yarn test`, `yarn lint`, and
  `yarn verify`; static and final EAS-resolved public development config;
  explicit development/production owner/project-ID equality; target/version/
  no-autoIncrement/rejected-ID/secret/generated-artifact/signing-material
  scans; `git diff --check`; clean isolated/canonical final status/staging.
- First blocked surface before P1: none. Any collision is
  `eas_project_name_collision_decision_required`; absent/permission/login
  failure is typed as plan requires; a safe Created receipt followed by local
  dynamic-config failure is reconciled forward only through the returned UUID.

## Allocation And Terminal Boundary

- Persistent Handoff requested/eligible: no; Luna disqualifiers checked.
- Selected Implementer: one ephemeral `gpt-5.6-terra/high`. This packet has a
  staged external one-use mutation, dynamic-config reconciliation, a returned
  UUID that must not be guessed/replayed, and post-create forward-only repair;
  those coupled external/replay/retained-source boundaries require the deeper
  bounded allocation.
- Implementer boundaries: exact owned source/test/report paths only; no EAS or
  external command, staging/commit/merge/push, secret access, acceptance, or
  scope expansion. It returns directly to Control; it may receive the
  sanitized certain UUID only after Control's P2 receipt.
- Control reviews, stages, commits, integrates accepted source/reports, and
  sends one immutable terminal directly to Planning. No intermediate Planning
  traffic. `AGENTS.md` remains excluded.

## Control Review And Closeout

- Conformance review: accepted. P1 proved exact target absence without a
  write; P2 created exactly `@jimmy1768/templemate` once, then stopped at the
  expected dynamic-config auto-write refusal. The exact returned UUID was
  reconciled forward through the allowed dynamic config paths, never guessed
  or retried.
- Read-only reconciliation: P3 confirmed the exact project correspondence;
  P4 resolved the expected linked Android development-client profile and
  retained every accepted native/configuration invariant. No credential or
  signing path was invoked.
- Acceptance rationale: focused config proof, full mobile checks, safe scans,
  temporary-materialization cleanup, status/staging evidence, and diff checks
  satisfy the plan. The external project is intentionally retained; deletion,
  transfer, rename, signing, and build are outside this packet.
- Terminal disposition: `eas_project_created_and_linked`; Planning owns any
  separately authorized signing/build continuation.
