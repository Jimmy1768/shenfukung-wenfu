# Expo Native Client Infrastructure Track Plan

Status: accepted parallel Track B boundary; intended for Control B;
implementation and Control dispatch are not authorized by this document alone

Created: 2026-08-11

Owner: Wenfu Planning

Parallel counterpart:
`ops/docs/plans/EXPO_ACCOUNT_JSON_API_TRACK_PLAN.md`

Mature read-only reference:
`/Users/jimmy1768/Projects/DojoMate-Expo`

## Objective

Build the TempleMate-specific Expo infrastructure and functional account client
from the checked-in scaffold while Control A independently builds Rails JSON
parity.

This track begins with deterministic dummy adapters, so navigation, menus,
screens, forms, state transitions, build configuration, and device behavior do
not depend on unfinished Rails endpoints. After Track A is accepted, this track
maps the real JSON contract behind the same client boundary and performs local/
test integration. Final UI refinement remains the last slice of this track.

## Parallel Ownership

Control B owns the Expo/native track. Its implementation packets may own the
bounded `mobile/` source, mobile tests/configuration, Expo build/version hooks,
and Expo-specific repository scripts selected by Control B. Exact paths remain
Control-owned packet details.

Control B does not edit:

- Rails routes, controllers, models, services, serializers, or Rails tests;
- Vue account behavior;
- payment, OAuth, provider, deployment, production, or store surfaces;
- Planning documents.

During the parallel wave, Control B uses dummy adapters and internal client
models. It does not guess or impose the final Rails wire format. After Planning
provides Track A's accepted contract, Control B adds the mobile wire adapter
without asking Control A to coordinate directly.

## Parallel Wave — Expo Infrastructure And Dummy Account Client

### Development-client foundation

- Reuse the checked-in Expo 54 scaffold rather than generating a new app.
- Use launcher name `TempleMate (Dev)` with DEV-badged app and adaptive icons;
  `竹南鎮聖福宮` is test tenant data, never the app name.
- Keep TempleMate app version independent of Rails, use the three-component
  `major.minor.patch` pattern, and begin at `1.0.0`.
- Add deterministic DojoMate-style version synchronization/verification without
  automatic increments or duplicate version values in `eas.json`.
- Reconcile local development-client profiles, config plugins, dependency
  compatibility, environment isolation, placeholder residue, and account-only
  identifiers.
- Generate, inspect, install, and run an Android development client proving
  compile/target SDK 36 and Android 16 behavior.
- Do not produce an AAB or consume Android version code `1` or an iOS App Store
  Connect/TestFlight build pair.

### Native application infrastructure

- startup and dummy/authenticated/signed-out state separation;
- account-only navigation and deep-link allowlist;
- data-source interfaces separating dummy and real adapters;
- deterministic dummy repository with reset behavior;
- form state, validation presentation, pending guards, normalized errors, and
  retry handling;
- locale/theme/preferences foundations for Traditional Chinese and English;
- safe-area, system-bar, keyboard, Android back, app-resume, and interruption
  behavior;
- secure-storage and session interfaces scoped by environment and tenant, with
  no real credentials used during the dummy wave;
- focused mobile unit/component/configuration tests and account-only guardrails.

DojoMate supplies mature structural evidence for these mechanisms. TempleMate
does not copy DojoMate roles, academy selection, endpoints, identifiers,
secrets, product copy, payment, OAuth, push, or monetization behavior.

### Interactive dummy account surface

The dummy client covers the current non-payment, non-OAuth account surface:

- dummy email/password sign in/out, signup, and password-recovery screens;
- dashboard without payments;
- profile display/edit, including name;
- dependent create/edit/update/delete;
- events, services, and gallery presentation;
- registration index/show/new/create/edit/update, including self/dependent
  selection where current account behavior permits it;
- certificate presentation;
- assistance and contact-temple forms;
- locale/theme preferences;
- privacy request and account-closure confirmations;
- loading, empty, validation, error, retry, pending, success, confirmation, and
  signed-out states used by those screens.

Dummy state must be interactive enough to edit a name, add/remove dependents,
and create/edit registrations. A dummy account cannot pay. Fixtures may include
already-paid registrations solely to test read-only paid-state presentation.
No checkout, payment history, status poller, provider reference, callback, or
mutable payment transition exists.

Dummy mode is explicit, makes no network request, cannot become a fallback for
real integration failure, and has a deterministic reset path. Dummy credentials
are non-secret test input and are never reused as real credentials.

## Tenant-Binding Infrastructure

Control B owns the native side of the accepted one-temple model:

- unbound, bound, binding-failed, and switching states;
- QR scanning and equivalent tappable connection link;
- parsing a non-secret tenant HTTPS origin plus fixed TempleMate connection
  path;
- trusted-origin validation followed by tenant identity confirmation through
  `/api/v1/temple`;
- environment-scoped local persistence;
- explicit switching confirmation and complete prior-tenant session/cache/
  pending-state cleanup.

The native app never trusts an arbitrary scanned HTTPS origin. The accepted
database-free direction is a trust registry derived from the deployment
manifest and served from the TempleMate platform origin. The exact trust
document and any external hosting remain separately planned; local development
may use deterministic trust fixtures and must not hardcode the staging hostname
as permanent product identity.

## Convergence Wave — Real Account Adapter

This wave starts only after Planning provides Control A's accepted Rails commit
and contract evidence.

- Implement the mobile wire adapter against the accepted JSON contract.
- Replace dummy email session behavior with local/test Rails email sessions,
  secure persistence, refresh, sign out, expiry, revocation, and closure.
- Connect the existing screens to local/test Rails reads and mutations without
  changing internal product behavior to fit the transport.
- Keep dummy mode available only as an explicit development/test mode; it never
  handles a failed real request.
- Prove profile edits, dependent CRUD, registration create/update, preferences,
  assistance/contact, privacy actions, and closure against local/test data.
- Prove dual-role users receive only account data and no admin navigation or
  capability.
- A payment-required registration stops truthfully before checkout; existing
  paid state may be displayed only through the accepted minimal field.

If the accepted server contract and client need genuinely conflict, Control B
reports the exact planning design gap to Planning. It does not coordinate a
contract change directly with Control A.

## Final V1 Refinement

After functional local/test integration is accepted, refine the existing V1
surface without adding scope:

- coherent navigation, typography, spacing, icons, and component primitives;
- complete Traditional Chinese/English copy;
- loading/error/empty/pending/confirmation consistency;
- keyboard, focus, touch targets, screen reader, dynamic text, reduced motion,
  contrast, Android 16 edge-to-edge/back/resume, and available iOS checks;
- removal of placeholder, template, dummy-only, and admin residue from the real
  client mode.

Refinement adds no route, resource, CRUD operation, provider, permission, or
business rule.

## Explicit Exclusions

- Rails implementation or Rails test changes;
- Google/Apple OAuth or identity link/unlink;
- payment menu/history/status polling, checkout, return, callbacks, providers,
  refunds, settlement, or accounting;
- admin, guest-list, staff, operations, or mode switching;
- EAS cloud action without separate authority, AAB/store submission, signing,
  production data, deployment, OTA, or release promotion.

## Immutable Acceptance Criteria

### Parallel-wave criteria

1. The existing scaffold produces an installable `TempleMate (Dev)` development
   client, not Expo Go and not an AAB.
2. Version, dev branding, profile/config, dependency, and API 36 checks are
   deterministic and no build number is consumed.
3. The current non-payment, non-OAuth account menus/screens are testable using
   explicit interactive dummy data.
4. Dummy email login, profile edits, dependent CRUD, and registration
   create/update alter visible dummy state and can be reset deterministically.
5. Paid fixtures are read-only presentation; no payment lifecycle exists.
6. The client architecture has a strict dummy/real adapter seam and does not
   invent the future Rails wire contract.
7. No admin, backend, provider, production, external, or release behavior is
   present in the dummy wave.

### Convergence and refinement criteria

8. The real adapter conforms to Control A's accepted JSON contract without
   changing Rails-owned semantics.
9. Local/test email sessions and included account reads/mutations work through
   the same screens previously exercised with dummy data.
10. Tenant switching clears all prior tenant-scoped session and cached state;
    arbitrary scanned origins are rejected.
11. Dual-role users see and receive only account behavior.
12. Final refinement improves presentation/accessibility/device behavior but
    adds no product scope.
13. No OAuth, payment, provider, production, deployment, AAB/store, or release
    work occurs.
14. Required mobile and local integration checks pass with exact evidence and
    final source state is clean and attributable.

## Convergence And Current Gate

Control B may complete the parallel dummy/infrastructure wave independently.
Its real-adapter continuation requires Planning's receipt of Control A's
accepted terminal contract. Planning sends that continuation directly to
Control B; the Controls do not coordinate directly.

Current classification:
`parallel_track_b_accepted_not_dispatched`.

First blocker: no explicit Director instruction has authorized Track B
implementation dispatch. EAS cloud use and every other external action remain
separately unauthorized.
