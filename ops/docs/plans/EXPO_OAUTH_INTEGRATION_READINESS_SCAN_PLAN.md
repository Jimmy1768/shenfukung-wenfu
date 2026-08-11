# Expo OAuth Integration Readiness Scan Plan

Status: Director-corrected documentation/readiness scan; prior DojoMate-based
dispatch stopped and superseded; authorized for redispatch to Control B after
this correction is committed

Created: 2026-08-11

Owner: Wenfu Planning

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Canonical input: `main` at the commit containing this plan

Parallel independent track:
`ops/docs/plans/EXPO_V1_FUNCTIONAL_STABILIZATION_PLAN.md`, owned by Control A

Existing deferred phase pointer:
`ops/docs/plans/EXPO_OAUTH_PHASE_PLAN.md`

Candidate SourceGrid read-only evidence roots:

- `/Users/jimmy1768/Projects/sourcegrid-labs`
- `/Users/jimmy1768/Projects/Golden-Template`
- checked-in Wenfu and SourceGrid documentation/history that identifies an
  exact SourceGrid APK or its source commit

## Objective

Produce a source-backed readiness scan for adding the existing Rails web OAuth
behavior to the account-only TempleMate Expo app.

Email/password was the simplest first smoke-test path; it is not the intended
final authentication boundary. Google and Apple OAuth already work through the
Rails account/admin web authentication surface and centralized SourceGrid auth.
The native app should incorporate that existing behavior rather than inventing
a second identity model.

This track discovers the exact contracts, the actual SourceGrid native/APK
OAuth test evidence, missing TempleMate surfaces, platform/config
prerequisites, tests, sequencing, and authority gates. It does not implement
OAuth.

DojoMate is explicitly not an OAuth reference. It does not use OAuth and must
not be cited as evidence for OAuth dependencies, redirect handling, provider
configuration, state machines, or native implementation patterns.

## Accepted Product Direction

- TempleMate remains account-only. Admin OAuth behavior is inspected because
  it shares the existing Rails identity/session system and supplies dual-role
  isolation evidence; no admin screen, token scope, role switch, or admin
  navigation is added to Expo.
- The scan covers Google and Apple, the providers already accepted and working
  in the current web scope. Facebook remains deferred.
- Existing Rails user identity, signup/linking, unlink, last-login-method,
  closure, tenant, and account/admin authority rules remain source truth.
- Centralized auth remains provider-secret owner. Temple runtimes and Expo do
  not receive Google or Apple client secrets.
- The internal native project name is `komainu`; public product naming remains
  TempleMate. Native application identifiers are
  `com.jimmy1768.komainu` and `com.jimmy1768.komainu.dev`.
- The Director reports that the Komainu Google Cloud project already exists.
  The scan records repository prerequisites and later verification needs but
  does not open the console, enumerate credentials, access providers, or infer
  unrecorded project/client identifiers.

## Preliminary SourceGrid Artifact Evidence

Planning's initial read-only scan found:

- SourceGrid Labs history includes the Expo admin-demo source commit
  `852531f6` and APK-download-link commit `4b477a0f`;
- `sourcegrid-labs/ops/docs/COMMANDS.md` records old local paths
  `/Volumes/DevSSD/Projects/sourcegrid-labs/mobile/dev-client-2.apk` and
  `/Volumes/DevSSD/Projects/sourcegrid-labs/mobilebuild-1765454955888.apk`;
- the download-link commit identifies a hosted
  `sourcegrid-labs-demo.apk`, but its accompanying UI describes demo-credential
  login rather than OAuth;
- the recorded DevSSD artifacts are not present on the currently mounted local
  filesystem;
- current SourceGrid Labs mobile source contains a demo console and email/JWT
  client helpers, not a proven native OAuth flow;
- Golden Template mobile source exposes only an OAuth availability/stub UI and
  explicitly says the real flow is not wired.

These facts neither disprove the Director's recollection nor identify the
OAuth test APK. The readiness scan must search SourceGrid repository history,
branches, documentation, artifact references, and existing local files to find
the exact source/artifact evidence. If it cannot, it must report that result
and the next evidence owner rather than substituting another app.

## Source Inventory

Control B and its Implementer must inspect and cite at minimum:

### Wenfu Rails and Vue

- account/admin login entry points, enabled-provider presentation, OAuth start,
  callback, token exchange, session creation, and destination selection;
- centralized-auth client/service objects and error handling;
- user identity persistence, provider/subject matching, signup behavior,
  profile-completion behavior, link/unlink, and last-login-method protection;
- account closure/session revocation interactions;
- route, request, service, and browser integration tests proving current Google
  and Apple behavior;
- tenant context and dual-role user behavior, including why a native OAuth
  result can grant account scope without exposing admin scope;
- current environment/config key names and which values are server-only,
  public, secret, legacy, or deferred.

### Current TempleMate native source

- native email session issuance, refresh rotation, logout, recovery, reset,
  closure revocation, scoped secure storage, and bootstrap behavior;
- current native API route exclusions and the exact additive server contract
  that would be missing for OAuth initiation/return/session exchange;
- Expo scheme, Komainu development/production identifiers, app config, EAS
  profiles, client modes, tenant binding, and local/test-only real adapter;
- signed-out UI, error model, startup/session restoration, and account-only
  navigation boundaries relevant to adding provider choices later.

### SourceGrid native/APK evidence discovery

- SourceGrid Labs and Golden Template mobile history, branches, tags,
  documentation, build/download records, and existing local artifacts;
- exact APK filename, path or historical URL, hash when locally available,
  package/version metadata, source repository, source commit, build profile,
  and intended test purpose;
- static, local-only inspection of an already present APK when needed to
  attribute its source or determine whether OAuth behavior exists; do not
  install, launch, decompile secret material into the report, or print embedded
  configuration values;
- the Expo/Rails source and tests that correspond to any verified OAuth test
  APK, including redirect construction, browser/app return, state, nonce,
  PKCE, cancellation, interrupted return, session exchange, and storage;
- a clear distinction among a real OAuth test client, an email/JWT demo APK,
  an OAuth availability stub, and an unrelated native artifact.

## Questions The Scan Must Answer

1. What exact Rails web route/controller/service sequence currently implements
   Google and Apple login for signed-out users?
2. What exact sequence implements linking and unlinking for signed-in users,
   including the last-login-method rule?
3. Which pieces are common to account/admin authentication, and where is the
   post-auth account-versus-admin scope selected?
4. Can the current centralized-auth start/exchange contract safely support a
   native return and native account token, or is an additive native server
   adapter required? Identify evidence and gaps without implementing it.
5. Which browser/app redirect, scheme, state, nonce, PKCE, cancellation,
   replay, and interrupted-return states must TempleMate represent?
6. Which Google and Apple public identifiers/config values must exist per
   Komainu development and production application, and which secret values
   must remain server-only?
7. What exact SourceGrid APK/source was used to test OAuth, and which of its
   packages, config plugins, redirect/session mechanisms, and tests are
   reusable at Expo 54/API 36? If the artifact cannot be identified, what
   evidence was exhausted and who owns the missing fact?
8. Does adding those native dependencies/config plugins require a new
   development-client binary, and what exact future EAS cloud profile would be
   appropriate? Do not run the build.
9. How should first-time OAuth users, existing email users, linked identities,
   missing provider names, closed accounts, revoked sessions, cancellation,
   denial, and provider unavailability map to existing Rails behavior?
10. What implementation phases can remain independent, where would Rails and
    Expo branches interact, and what must be integrated before device testing?
11. What automated contract, state-machine, security, account-only, and
    platform-config evidence is required before any live provider validation?
12. Which facts remain unknown because provider-console, central-auth repo, or
    protected runtime evidence was intentionally not accessed?

## Required Deliverable

Control B produces one durable Control-owned readiness report at:

`ops/docs/handoffs/2026-08-11-expo-oauth-integration-readiness-control-b.md`

The report must contain:

- a route/controller/service/model/test map for current Wenfu OAuth;
- a SourceGrid native/APK artifact-to-source mechanism/dependency/config/test
  map, or a precise not-found result with exhausted evidence;
- a TempleMate native gap matrix grouped as already present, reusable,
  additive Rails work, additive Expo work, external prerequisite, deferred, or
  unknown;
- explicit Google-versus-Apple and development-versus-production differences;
- account-only and dual-role isolation analysis;
- proposed implementation sequencing and merge gates without dispatching any
  implementation;
- exact source paths for every material fact;
- open decisions and the first actual blocker, if any.

The report is evidence for Planning. It does not modify or supersede
`EXPO_OAUTH_PHASE_PLAN.md`, accept an implementation architecture, authorize a
provider action, or begin OAuth implementation.

## Control Ownership

Control B owns one isolated `codex/`-prefixed branch/worktree from the
canonical plan commit, one immutable readiness packet, one ephemeral
Implementer, independent evidence review, acceptance, and local integration of
the report only.

The Implementer may edit only the required readiness report. Wenfu product
code, Rails, Vue, mobile source/config, tests, Planning documents, dependencies,
native generated projects, environment files, and sibling repositories are
read-only.

Control B sends no intermediate Planning traffic and does not coordinate with
Control A. It returns exactly one immutable terminal packet with the accepted
report commit, checked sources, evidence limits, final Git state, and
continuation disposition.

## Verification

Control B must record:

- exact Wenfu, SourceGrid Labs, and Golden Template HEAD/branch/status and Git
  refs used as evidence, without switching or mutating sibling worktrees;
- focused route/controller/service/model/config/test searches and the cited
  source inventory;
- proof that only the report path changed;
- a secret-pattern and prohibited-artifact scan over the report;
- `git diff --check`;
- clean isolated branch and canonical main, with staging empty;
- confirmation that no runtime, browser, provider, secret, build, device,
  network API, deployment, or external mutation occurred.

## Explicit Exclusions

- OAuth product code, routes, controllers, services, migrations, UI, tests, or
  dependencies;
- Google Cloud Console, Apple Developer, Expo/EAS, central-auth production,
  credential, callback allowlist, app-store, or provider mutation;
- reading or copying secrets, tokens, client secrets, signing material,
  production data, or private provider responses;
- downloading a missing APK or other artifact, opening a hosted APK URL,
  installing or launching an APK, or changing a sibling repository;
- treating DojoMate as OAuth implementation evidence;
- Facebook;
- admin functionality in Expo;
- payment/ECPay/Stripe;
- native build, APK/AAB, signing, Metro, device action, deployment, OTA,
  release promotion, or remote push;
- cross-repository implementation or direct coordination with another
  Planning/Control task.

## Immutable Acceptance Criteria

1. The report maps the current working Google/Apple web OAuth path from source
   and tests without treating documentation alone as implementation proof.
2. Account/admin shared authentication and post-auth authorization boundaries
   are explicit; the native target remains account-only for dual-role users.
3. Existing TempleMate email-session/storage behavior and the missing native
   OAuth adapter boundary are mapped precisely.
4. The exact SourceGrid OAuth test APK/source is attributed with evidence, or
   the report proves it was not found in the authorized local sources and names
   the next evidence owner; no unrelated app is substituted.
5. Google/Apple and development/production prerequisites are distinct, with
   public configuration separated from server-only secrets.
6. Native dependency/config/build implications are identified without adding a
   dependency or creating a binary.
7. Failure, cancellation, replay, linking, unlinking, first-login, profile,
   closure, and session-revocation states have proposed evidence requirements.
8. The gap matrix and sequencing are sufficient for Planning to create later
   bounded Rails and Expo implementation plans without inventing missing
   contracts.
9. Unknowns and external verification gates are stated honestly; no provider
   or secret access occurs.
10. Only the Control readiness report changes, checks pass, and all repository
    worktrees finish clean with staging empty.

## Current Gate

Current classification: `expo_oauth_integration_readiness_scan_authorized`.

First blocker: none. Planning must commit the paired parallel-track plans and
dispatch this readiness scan directly to Control B.
