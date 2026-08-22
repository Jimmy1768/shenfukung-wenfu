# Expo V1 Functional Stabilization Plan

Status: accepted for direct implementation dispatch to Control A after this
plan and the parallel OAuth-readiness plan are committed

Created: 2026-08-11

Owner: Wenfu Planning

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Observed canonical baseline:
`4aef52bc21f66886257f67bf0b11cac35baac252`

Predecessor:
EXPO_V1_DEV_CLIENT_UI_REFINEMENT_PLAN.md (deleted 2026-08-22 in the
plans/archive cleanup; recoverable via `git log --grep`)

Mature read-only reference:
`/Users/jimmy1768/Projects/DojoMate-Expo`

## Purpose

Perform one bounded Expo functional-stabilization pass before further visual
UI refinement.

The accepted Pixel smoke test proves that the development client starts,
loads its JavaScript bundle, and supports selected successful dummy-mode
interactions without a fatal JavaScript error. It does not prove failure-state
transitions, session restoration, complete real-adapter data loading, persisted
preferences, or real registration workflow conformance.

The existing visual baseline remains useful and accepted. This plan does not
discard it or redesign the app. It records concrete state-management and
adapter-wiring defects that should be corrected before additional visual
polish makes those behaviors harder to isolate.

## Evidence Already Passing

- TempleMate starts in the installed Expo development client and connects to
  Metro in explicit dummy mode.
- The observed dummy journey covered sign-in, account home, profile,
  dependent management, registration presentation, paid read-only fixture,
  tenant switch, English, and dark mode.
- App-scoped logs showed the main JavaScript entry running with no fatal
  JavaScript error.
- The merged mobile suite passes 19 tests, source lint, version/API verification,
  both Komainu configuration modes, and the accepted candidate's offline Expo
  Doctor check.
- The native Rails API and adapter contract tests pass independently. No Rails
  defect is established by the findings below.

## Confirmed Functional Findings

### 1. Failed mutations execute success-only UI transitions

`mobile/App.js` uses a shared `run` function that catches an action failure,
sets an error, and then resolves normally. Several callers attach `.then(...)`
for UI work that is valid only after success.

Observed consequences:

- invalid dependent create/update/delete can clear the edit form;
- invalid registration create/update can clear the form;
- failed assistance/contact submission can navigate back to Settings;
- failed account closure, including an invalid dummy confirmation, can still
  run the sign-out transition.

The stabilization must make success, validation failure, request failure, and
pending re-entry explicit. Success-only state changes must never run after a
failed operation.

### 2. Stored real sessions are not restored by the application

The real adapter implements `restoreSession`, including fail-closed cleanup,
but the app always initializes `signedIn` as false and never invokes the
restore path.

Required outcome:

- startup attempts restoration only in deliberate real local/test mode;
- a valid stored session loads the account bootstrap and enters the signed-in
  account surface;
- missing or rejected sessions remain signed out;
- invalid, replayed, revoked, expired, or closed-account state clears the
  scoped session and never falls back to dummy data.

### 3. Real account collections are not fully loaded

Rails native bootstrap currently returns user, temple, preferences, recent
registrations, and certificates. Dependents, events, services, and galleries
have separate accepted endpoints. The real adapter exposes those methods, but
the UI never calls them.

Consequences in real mode:

- existing dependents can appear absent after login;
- Events, Services, and Gallery can appear empty despite server data;
- the UI cannot truthfully distinguish loading, empty, and failed collection
  states.

The stabilization must load each account collection from its existing native
endpoint at a deterministic point, preserve tenant/user scope, and expose
truthful loading, empty, and error states. It must not broaden Rails bootstrap
or invent a new aggregate endpoint merely for convenience.

### 4. Locale and theme preferences are not wired to accepted storage/API

The current controls modify React state only. They do not initialize from the
accepted preference state, persist dummy/local preference state, or call the
real adapter's preferences update.

Required outcome:

- dummy mode persists the selected locale/theme within its resettable,
  environment-and-tenant scope;
- real local/test mode initializes from account preferences and writes through
  the existing account preference contract;
- a failed preference update does not falsely present saved state;
- `admin_display_mode` remains absent.

### 5. Fixture tenant controls leak into real mode

The home screen renders fixture link, fixture QR, and alternate-fixture switch
behavior from shared UI branches. A signed-in real adapter can therefore enter
dummy tenant-switch behavior. The current switch handler also starts
`clearTenantState` without awaiting its result and immediately confirms the
new binding.

Required outcome:

- fixture link/QR/switch behavior is dummy-only;
- real local/test mode displays only its explicit configured tenant binding;
- any future real tenant switch remains deferred to the accepted live trust
  and binding phase;
- dummy switch confirmation awaits successful prior-tenant cleanup before
  binding the alternate fixture and exposes cleanup failure safely.

### 6. Real registration UI bypasses the accepted form workflow

The current shared form treats `offering` as free text and defaults to a
display label. The real API expects the accepted offering slug/account action
and supplies defaults through registration `new`; edit data comes through
registration `edit`. Existing updates accept registration metadata rather than
changing the offering itself.

Consequences in real mode:

- create can send a display label where the server expects an offering
  identifier;
- the UI presents the offering as editable during update even though that
  change is not submitted;
- new/edit defaults and lifecycle restrictions are not represented
  truthfully.

The stabilization must adapt the existing Rails new/create/edit/update
contract without adding registration delete, payment, checkout, or provider
behavior. Paid dummy fixtures remain read-only presentation.

### 7. Dummy signup credentials cannot be used for a later login

Dummy signup changes the fixture profile email but dummy sign-in remains
hardcoded to the original seed email and password. Signup appears successful,
but after sign-out the created credentials cannot sign in.

Required outcome:

- a successfully created dummy account can sign out and sign back in with its
  created email/password during the same resettable fixture lifecycle;
- reset restores the original deterministic fixture credentials;
- failed signup does not authenticate or mutate the account.

### 8. Some declared account presentation paths are not data-driven

- The home certificate content is hardcoded instead of rendering the accepted
  certificate data.
- `connection` is declared as an account screen but has no explicit render
  branch; an unexpected selection falls through to the account-closure screen.
- The application lacks an explicit unknown-screen guard.

The stabilization must render certificate data truthfully, make every declared
screen exhaustive, and fail safely to an account home/not-found state rather
than a destructive screen.

## Scope Boundary

This is an Expo JavaScript/state/adapter-wiring and test phase. Expected owned
areas are:

- `mobile/App.js` and focused account screen/action modules extracted from it;
- existing `mobile/app/account/`, `mobile/app/dummy/`, `mobile/app/real/`,
  `mobile/app/tenant/`, preference/storage, UI copy, and focused test paths;
- only development scripts needed to enforce the existing source boundaries.

Rails is read-only contract authority for this phase. If direct evidence shows
that an existing account operation cannot be represented through the accepted
native API, that is a Planning gap and not implied Rails edit permission.

No new runtime UI/navigation/form dependency is authorized by this findings
document. A dependency request must identify the exact missing capability and
why the current React Native/Expo surface cannot provide it.

## Control Ownership

Control A owns one isolated `codex/`-prefixed branch/worktree from the
canonical commit containing this accepted plan, one immutable implementation
packet, one ephemeral Implementer, independent conformance review, acceptance,
and local integration.

Control A may edit only the bounded Expo JavaScript/state/adapter/test paths it
records from the scope above plus its own immutable Control handoff. Rails,
Vue, Planning documents, native generated projects, dependencies, build
profiles, provider configuration, deployment, and release paths remain
excluded.

Control A sends no intermediate Planning traffic. It returns exactly one
immutable terminal packet after an accepted outcome, a true Planning gap, a
Director authority decision, or no evidence-backed direct repair remains.
Control A does not coordinate with the independent OAuth-readiness track.

## Proposed Verification

An accepted implementation plan should require:

- interaction-level tests proving success-only transitions do not execute on
  validation or request failure;
- dummy signup -> sign-out -> sign-in and reset lifecycle tests;
- real restore-session success, absent-session, and fail-closed cases;
- explicit real loader request/state tests for dependents, registrations,
  certificates, events, services, and galleries;
- preference initialization, persistence/update, rollback, locale, theme, and
  admin-exclusion tests;
- dummy-only tenant fixture controls and awaited cleanup failure/success tests;
- real registration new/create/edit/update mapping and lifecycle/read-only
  tests against the accepted serializer shapes;
- exhaustive declared-screen rendering and certificate data tests;
- regression coverage for profile, dependent CRUD, assistance, contact,
  privacy, closure, dummy no-network, real no-fallback, account-only scope,
  Komainu identifiers, version `1.0.0`, build values `1`, and API 36;
- mobile test, lint, verify, offline project-local Doctor, both public Expo
  configuration modes, rejected-identifier scan, and `git diff --check`.

## Runtime And Build Boundary

The identified repairs are JavaScript and local/test adapter work. They do not
require a native rebuild.

- Do not run Expo prebuild, Gradle, `expo run:android`, or EAS merely to perform
  the stabilization.
- Do not create an APK/AAB, increment a build number, access Google Cloud or
  provider configuration, or install/replace the Pixel package.
- After source and automated checks pass, any later device verification should
  reuse the installed development client through Metro under separately
  accepted device authority.
- EAS cloud remains the default only when a genuinely changed native binary is
  required. Local native builds retain the separate explicit-reason rule.

## Explicit Exclusions

- additional visual redesign, final component styling, animation, or new
  navigation architecture;
- Rails/Vue feature changes or a broadened account API;
- live tenant QR/camera/trust registry, universal/app links, or production
  tenant switching;
- OAuth or identity linking;
- payment, checkout, ECPay, Stripe, provider references, refunds, settlement,
  or accounting;
- push, analytics, media upload, broad offline synchronization, deployment,
  secrets, production data, store submission, OTA, or remote push.

## Proposed Acceptance Criteria

1. Every mutation performs success-only follow-up state changes only after the
   adapter operation succeeds; failure retains the relevant form/screen and
   shows an attributable error.
2. Real local/test startup restores a valid scoped session and fails closed for
   absent or rejected sessions without dummy fallback.
3. Existing dependents, registrations, certificates, events, services, and
   galleries load from their accepted real endpoints with truthful loading,
   empty, and error states.
4. Locale and theme initialize and persist through the correct dummy or real
   preference mechanism without exposing admin preferences.
5. Fixture binding and switching remain dummy-only, and tenant cleanup is
   awaited before a switch commits.
6. Registration new/create/edit/update follows the existing Rails contract;
   offering identity, defaults, editability, and read-only states are truthful.
7. Dummy-created credentials support a later dummy login until reset.
8. Certificates are data-driven and every declared/unknown screen resolves to
   a safe, non-destructive presentation.
9. Existing happy-path account operations and all account/admin/payment/OAuth
   boundaries remain intact.
10. Required automated checks pass without a native build, external action, or
    device mutation, and final Git state is clean with staging empty.

## Current Gate

Current classification: `expo_v1_functional_stabilization_authorized`.

First blocker: none. Planning must commit the paired parallel-track plans and
dispatch this plan directly to Control A.
