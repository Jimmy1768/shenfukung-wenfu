# Expo Temple QR camera foundation — Control B implementation packet

## Identity

- Accepted-plan path and immutable criteria:
  `ops/docs/plans/EXPO_TEMPLE_QR_CAMERA_FOUNDATION_PLAN.md`.
- Control task and authority state: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0`; direct Planning dispatch accepted.
- Repository, worktree, branch, and base HEAD:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`,
  `/private/tmp/shengfukung-wenfu-expo-temple-qr-camera`,
  `codex/expo-temple-qr-camera-foundation`,
  `c724517125bfcb961beba8f24b1aee15083e9a35`.
- Packet status and date: immutable implementation packet recorded 2026-08-11.
- Immutable packet identity and implementation attempt:
  `2026-08-11-expo-temple-qr-camera-foundation-control-b`, attempt 1.

## Scope

- Objective: add the Expo SDK 54 camera capability and a user-initiated,
  rear-facing QR-only TempleMate scan surface that passes exactly one scanned
  fixture string through the existing tenant parser/binding seam.
- Exact owned editable paths:
  - `mobile/package.json`, `mobile/yarn.lock`, and `mobile/app.config.js`;
  - `mobile/App.js`, `mobile/app/ui/copy.js`, and focused files below
    `mobile/app/tenant/` for the camera UI/scanner integration only;
  - focused `mobile/__tests__/` camera, tenant, config, and boundary tests;
  - `mobile/scripts/lint-source.js` and `mobile/scripts/verify-native-client.js`
    only for camera/config guardrails;
  - this Control packet only by Control, not the Implementer.
- Explicit exclusions: Rails/Vue/database/real tenant behavior, QR payload or
  trust invention, generated native projects, prebuild/build/EAS/Metro/device,
  provider/secret/console work, deployment/push/release, audio/microphone,
  photo/video/gallery/location/contact permissions, admin, payment, OAuth
  implementation changes, and sibling repositories.
- Required checks and expected evidence:
  - only Expo SDK 54 `expo-camera ~17.0.10` and lock closure;
  - public config proves camera purpose message, `recordAudioAndroid: false`,
    Komainu IDs, scheme, 1.0.0/build 1/API 36;
  - deterministic tests cover explicit initiation, loading/grant/denial/
    cannot-ask-again/cancel/retry, rear-camera QR-only settings, one-preview
    activation, first-result lock, invalid/untrusted no-mutation, fixture parse
    success, and real-mode no binding/no-network behavior;
  - `yarn test`, `yarn lint`, `yarn verify`,
    `EXPO_OFFLINE=1 CI=1 yarn doctor`, both public config modes, source
    boundary/artifact scans, and `git diff --check`.
- Evidence sources and status:
  - accepted OAuth baseline `e5ae5e8fd76b9b152b24e7b3c9e142b12cff2427`
    is an observed ancestor of the base;
  - existing Wenfu tenant scanner/parser is observed source authority;
  - DojoMate `AcademySearch.js` is read-only interaction reference only;
  - Expo SDK 54 camera package line is documented plan authority;
  - physical permission/scan proof remains deferred to later EAS/device work.
- First blocked surface, if known: none for source implementation. Registry
  access is authorized only for the stated package and locked closure if absent.

## Incident-Correction Placement

- Is this an incident correction? no.
- Selected surface: bounded Expo source/tests/config only.
- `AGENTS.md` excluded unless explicit Director authorization is recorded.

## Repair And Terminal Boundary

- Is this a bounded nonterminal repair within unchanged immutable criteria: no.
- Failed attempt identity and evidence: not applicable.
- Immutable repair packet direct mechanism, owned paths, and checks: not
  applicable unless an observed conformance defect occurs.
- True Planning design gap, Director authority decision, or no evidence-backed
  direct repair remaining: none known before implementation.
- Planning packet prohibited until a terminal disposition: yes.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no; no exceptional durable continuity need.
- Eligibility confirmed before selecting a model: yes.
- Luna disqualifiers checked: availability, cost, mechanical simplicity, and
  rejection do not qualify.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra/medium`.
- Selection reason and lowest-sufficient configuration: contained Expo UI,
  permission-state, first-result-lock, and parser-seam work with deterministic
  tests; it has no persistence migration, shared-state mutation, or new server
  contract requiring the deeper allocation.
- Ephemeral allocation: `gpt-5.6-terra/medium`; Luna is never ephemeral.
- One ephemeral Implementer task: `expo_temple_qr_camera_implementer`.
- Return destination: this Control directly.
- Implementer boundaries: owned paths only; no acceptance, staging, commit,
  merge, push, deployment, approval handling, secret access, external mutation,
  build, Metro, or device action.

## Control Review And Closeout

- Conformance review against immutable criteria: accepted after attempt 1.
  The result adds only `expo-camera ~17.0.10`, explicit camera/no-audio config,
  a user-initiated rear-facing QR-only surface, one-preview/first-result
  locking, permission/cancel/retry/invalid states, and dummy fixture parsing
  through the existing tenant seam. Real mode remains deferred and nonbinding.
- Acceptance decision and rationale: accepted. Independent Control checks
  passed: 41 mobile tests, lint, verification, both public configuration modes,
  package/lock evidence, source boundary/artifact scans, offline project-local
  Doctor (exit 0; the unavailable remote schema fetch is the configured offline
  warning), and `git diff --check`.
- Integration, staging, and commit evidence when accepted: pending Control
  staging/commit, then local canonical-main integration as authorized.
- Immutable terminal packet direct delivery, source Control, target Planning,
  implementation attempt, and continuation disposition: pending;
  `accepted_frozen_outcome` after integration.
- Paired Planning receipt: pending.
- Parent classification, continuation disposition, and next owner/action:
  Planning decides later EAS/device validation.
- `active_packet: none` only with the exact missing decision and owner: not
  applicable until terminal delivery and paired receipt.
- Residual risk, production gap, and next owner: a new EAS development client
  and physical permission/QR evidence remain later Planning-owned gates.
- Authority confirmation: Planning reported criteria only; Strategy owns any
  cross-repository policy and the Director accepts it.
