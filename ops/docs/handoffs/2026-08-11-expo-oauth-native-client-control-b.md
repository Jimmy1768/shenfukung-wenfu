# Expo OAuth native client — Control B implementation packet

## Identity

- Accepted-plan path and immutable criteria:
  `ops/docs/plans/EXPO_OAUTH_NATIVE_CLIENT_PLAN.md`; Expo source/test phase only.
- Control task and authority state: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0`; direct Planning dispatch accepted.
- Repository, worktree, branch, and base HEAD:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`,
  `/private/tmp/shengfukung-wenfu-expo-oauth-native-client`,
  `codex/expo-oauth-native-client`,
  `e1aa846c987b19438adc38d748b1fecc46b97ed2`.
- Packet status and date: immutable implementation packet recorded 2026-08-11.
- Immutable packet identity and implementation attempt:
  `2026-08-11-expo-oauth-native-client-control-b`, attempt 1.

## Scope

- Objective: add the accepted provider-independent, account-only Expo OAuth
  client transaction for deterministic dummy journeys and the Rails native
  start/exchange contract; retain only the minimum scoped pending record and
  resulting Wenfu account session.
- Exact owned editable paths:
  - `mobile/App.js`;
  - `mobile/package.json`, `mobile/yarn.lock`, and
    `mobile/app.config.js` only as required by the three accepted Expo packages;
  - `mobile/app/dummy/adapter.js`, `mobile/app/dummy/fixtures.js`,
    `mobile/app/real/adapter.js`, `mobile/app/real/config.js`,
    `mobile/app/real/storage.js`, `mobile/app/lib/auth/storage.js`,
    `mobile/app/ui/copy.js`, and `mobile/app/core/storage_scope.js` only where
    directly needed for OAuth state/storage/UI integration;
  - new files below `mobile/app/oauth/` for the provider-independent
    transaction/driver boundary and nonsecret configuration matrix;
  - `mobile/__tests__/` OAuth/config/adapter/UI-state tests and
    `mobile/scripts/verify-native-client.js` / `mobile/scripts/lint-source.js`
    only for required guardrails;
  - `ops/docs/reference/templemate_native_oauth.md` for the local operating
    note and later-reference boundary.
- Explicitly excluded paths and systems: all Rails/Vue changes (including
  routes/controllers/tests), Planning documents, SourceGrid Labs, provider
  configuration/consoles/accounts/secrets, native generated projects, build,
  Metro, device, deployment, release, OTA, push, payments, identity
  list/link/unlink, Facebook, admin, and shared packages.
- Required checks and expected evidence:
  - network-free dummy Google/Apple success, profile-required, cancellation,
    denial, failure, interruption, reset, mismatch/unsolicited callback,
    expiry/tamper/replay, and pending cleanup tests;
  - real start/exchange mapping solely to accepted Rails native endpoints,
    no dummy fallback, fresh S256 PKCE, expected return and account-only
    session handling tests;
  - email/functional-stabilization, tenant/environment scoped-storage,
    logout/closure/switch/reset, account-only, redaction and dependency/config
    regression tests;
  - `yarn test`, `yarn lint`, `yarn verify`,
    `EXPO_OFFLINE=1 CI=1 yarn doctor`, both public Expo config modes, focused
    dependency/identifier/secret/artifact scans, focused Rails contract
    regression fixtures, and `git diff --check`.
- Evidence sources and status:
  - accepted Rails contract `a0f4888c749835f648a5f716237efef89ef29900` is
    an observed ancestor of the exact plan base;
  - existing mobile real adapter/storage/config and Komainu identifiers are
    observed source inputs;
  - provider registrations, deployed return allowlisting, EAS build, and
    device validation remain unknown/deferred external gates.
- First blocked surface, if known: none for source implementation. Registry
  retrieval is authorized only for the accepted packages and their locked
  closure when absent locally.

## Incident-Correction Placement

- Is this an incident correction? no.
- Selected surface: bounded Expo source/tests/reference note only.
- `AGENTS.md` excluded unless explicit Director authorization is recorded.

## Repair And Terminal Boundary

- Is this a bounded nonterminal repair within unchanged immutable criteria:
  yes, attempt 2.
- Failed attempt identity and evidence: attempt 1 review found that the global
  React Native link listener could consume the same callback that
  `WebBrowser.openAuthSessionAsync` returns, and that a malformed real exchange
  result can have reached the adapter's session write before controller-level
  provider/shape validation.
- Immutable repair packet direct mechanism, owned paths, and checks:
  `mobile/App.js`, `mobile/app/oauth/transaction.js`,
  `mobile/app/real/adapter.js`, and focused OAuth/real-adapter tests only.
  Make browser-result and interrupted-return handling mutually exclusive or
  single-consumption safe; clear any just-applied session and scoped state when
  controller validation rejects an exchange result; prove these races and
  malformed-result paths without a live browser/network.
- True Planning design gap, Director authority decision, or no evidence-backed
  direct repair remaining: no; this is an implementation conformance repair.
- Planning packet prohibited until a terminal disposition: yes.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no.
- Eligibility confirmed before selecting a model: yes; no exceptional durable
  continuity need exists.
- Luna disqualifiers checked: availability, cost, mechanical simplicity, and
  rejection do not qualify.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra/high`.
- Selection reason and lowest-sufficient configuration: this bounded packet
  handles security-sensitive PKCE verifier generation, replay/interruption
  correlation, transactional pending-state cleanup, scoped retained storage,
  and redaction. It therefore meets the explicit deeper-bounded Terra/high
  rationale; Sol is not required.
- Ephemeral allocation: `gpt-5.6-terra/high`; Luna is never ephemeral.
- One ephemeral Implementer task: `expo_oauth_native_client_implementer`.
- Return destination: this Control directly.
- Implementer boundaries: owned paths only; no acceptance, staging, commit,
  merge, push, deploy, approval handling, secret access, external mutation, or
  scope expansion.

## Control Review And Closeout

- Conformance review against immutable criteria: accepted after attempt 2.
  The result implements deterministic dummy Google/Apple journeys and the
  provider-independent Rails-only real transaction; uses fresh S256 PKCE;
  retains only environment-and-tenant-scoped pending data; distinguishes and
  clears every required terminal state; preserves email/account-only behavior;
  adds only the three accepted Expo packages and their lock closure; and records
  the local reference note/config matrix.
- Acceptance decision and rationale: accepted. Independent Control checks
  passed: 35 mobile tests, lint, verification, both public configuration modes,
  focused Rails native OAuth contract test (9 runs, 90 assertions), dependency/
  identifier/redaction/artifact scans, offline project-local Doctor (exit 0;
  its unavailable remote schema fetch is the configured offline warning), and
  `git diff --check`. The attempt-2 browser/link race and rejected-exchange
  cleanup tests prove the observed repair mechanism.
- Integration, staging, and commit evidence when accepted: pending Control
  staging/commit, then local canonical-main integration as authorized.
- Immutable terminal packet direct delivery, source Control, target Planning,
  implementation attempt, and continuation disposition: pending;
  `accepted_frozen_outcome` after integration.
- Paired Planning receipt: pending.
- Parent classification, continuation disposition, and next owner/action:
  Planning decides the later provider/EAS/device validation phase.
- `active_packet: none` only with the exact missing decision and owner: not
  applicable until terminal delivery and paired receipt.
- Residual risk, production gap, and next owner: provider registration,
  deployed return allowlist, EAS/cloud binary, and device validation remain
  later Planning-owned gates.
- Authority confirmation: Planning reported criteria only; Strategy owns any
  cross-repository policy and the Director accepts it.
