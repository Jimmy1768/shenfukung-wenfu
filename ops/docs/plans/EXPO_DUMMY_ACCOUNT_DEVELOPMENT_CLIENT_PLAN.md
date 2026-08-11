# Expo Dummy Account Development Client Plan

Status: accepted first implementation objective; documentation only;
implementation and Control dispatch are not authorized by this document

Created: 2026-08-11

Owner: Wenfu Planning

Parent roadmap: `ops/docs/plans/EXPO_ACCOUNT_APP_V1_ROADMAP.md`

## Objective

Create an installable `TempleMate (Dev)` development client from the checked-in
Expo scaffold that allows the account menus, screens, forms, and common state
transitions to be exercised with deterministic dummy data.

This is a functional UI simulator, not a backend prototype. It proves that the
native information architecture and interactions can be tested before Rails
mobile contracts, OAuth, payments, production identity, or distribution work.

## Included Surface

The dummy adapter must provide enough coherent fixture state to exercise:

- email/password sign in and sign out using clearly non-secret dummy input;
- email signup and password recovery screen behavior;
- dashboard navigation without payment widgets or actions;
- profile display and edits, including name changes;
- dependent creation, editing, updating, and deletion;
- events, services, and gallery lists/details needed by account navigation;
- registration list/show/new/create/edit/update behavior, including self and
  existing-dependent selection where the current web behavior permits it;
- certificate presentation;
- assistance and contact-temple forms;
- locale and theme changes;
- privacy request and account-closure confirmations;
- loading, empty, validation, error, retry, pending, confirmation, and signed-out
  states needed by these screens.

The dummy repository must be stateful enough for a tester to edit a name, add or
remove a dependent, create or edit a registration, and observe the updated
screen state. It must also have a deterministic reset path. Control owns the
implementation mechanism; the plan does not require a particular state library
or persistence package.

## Registration And Paid-State Simulation

- A tester may create and edit dummy registrations through the native forms.
- The dummy account cannot start checkout or submit payment.
- Registration fixtures may include unpaid, pending, cancelled, completed, and
  already-paid examples only where those states exist in Wenfu account
  behavior.
- An already-paid fixture is read-only presentation data. The app does not
  manufacture a payment transition, provider reference, receipt, callback, or
  accounting claim.
- If a dummy registration would normally require payment, the UI ends at a
  truthful payment-unavailable/deferred boundary rather than pretending that
  checkout succeeded.

## Dummy-Mode Boundary

- Dummy mode is explicit in the UI and configuration.
- It makes no Rails, account API, auth, OAuth, payment, provider, analytics, or
  external request.
- Dummy credentials are non-secret test fixtures and are never reused as real
  credentials. No real credential or provider secret appears in source,
  configuration, logs, fixtures, or screenshots.
- Dummy success is never a fallback for a failed real request.
- Reset, logout, and account closure clear or restore dummy state predictably.
- Tenant data is clearly fictional/test data. `竹南鎮聖福宮` may appear as the
  test tenant but never as the app name.

## Build And Identity Boundary

- Reuse the existing Wenfu Expo 54 scaffold.
- Launcher name is `TempleMate (Dev)` with DEV-badged app and adaptive icons.
- App version is `1.0.0`; the version synchronization/check mechanism follows
  the accepted three-component version policy.
- A local development build does not consume Android version code `1` or an iOS
  App Store Connect/TestFlight build pair.
- Generate, inspect, install, and run an Android development client proving
  compile/target SDK 36 and Android 16 behavior.
- Do not produce an AAB. EAS cloud use, signing, store actions, OTA publication,
  deployment, or release promotion are not authorized.

## Explicit Exclusions

- Rails/API integration and persisted server data;
- real email authentication, token issuance, refresh, or SecureStore sessions;
- QR camera scanning or live tenant-origin binding;
- Google/Apple OAuth or identity link/unlink;
- payments menu/history/status polling, checkout, provider return, or any
  provider action;
- admin, guest-list, staff, operations, or mode-switch behavior;
- final visual refinement or release/store assets.

## Immutable Acceptance Criteria

1. The checked-in scaffold is retained and the result is an installable
   development client, not Expo Go and not an AAB.
2. Account menus and screens cover the current non-payment, non-OAuth account
   inventory recorded by the parent roadmap.
3. Dummy email login, profile edits, dependent CRUD, and registration
   create/update work through the native UI and update visible dummy state.
4. The dummy state can be reset deterministically.
5. Paid registration fixtures can be viewed, but no payment action or mutable
   payment lifecycle exists.
6. No backend, real auth, provider, production, admin, or external request is
   made.
7. Dummy mode is unmistakable and cannot mask a real integration failure.
8. Branding, version synchronization, API 36, Android 16, and account-only
   boundaries are verified with focused evidence.
9. Functional usability is sufficient for menu/screen testing; final UI polish
   is intentionally deferred.
10. Required checks pass and the final repository state is clean and
    attributable.

## Current Gate

This is the first implementation objective. It awaits an explicit Director
instruction to dispatch through the authoritative Control. No Control packet,
build, external action, or implementation is authorized by this plan alone.
