# Expo Native Account Foundation Plan

Status: accepted sequence boundary; planned after the dummy development client;
not current implementation authority

Created: 2026-08-11

Owner: Wenfu Planning

Parent roadmap: `ops/docs/plans/EXPO_ACCOUNT_APP_V1_ROADMAP.md`

## Objective

Replace the dummy-only boundary with the minimum safe native foundation needed
for real non-production email sessions and account-only Rails API requests.
This phase does not build every account screen and does not add OAuth or
payments.

## Included Contracts

### One-temple binding

- One active temple at a time, connected by the accepted non-secret QR or
  equivalent tappable link derived from the tenant HTTPS origin and a fixed
  TempleMate connection path.
- No per-temple QR database record or new Wenfu tenant table is required.
- Validate the origin through the TempleMate trust mechanism, then confirm
  tenant identity through the tenant-local `/api/v1/temple` endpoint.
- Store the validated origin and temple identity locally with environment
  scoping.
- Switching requires explicit confirmation and clears all prior tenant session,
  cache, and pending-state data before reauthentication.
- A scanned arbitrary HTTPS origin is never trusted merely because TLS works.

The lowest-complexity accepted trust direction is a database-free registry
derived from the existing deployment manifest and served from the future
SourceGrid-owned TempleMate platform origin. The exact document format,
refresh/failure behavior, and need for signing require source-backed planning
before this phase is dispatched. The current staging hostname may stand in for
development but cannot become a permanent distribution assumption.

### Email session and API foundation

- Native email/password sign in, session bootstrap/restoration, refresh,
  sign out, expiry, revocation, and closed-account handling.
- Secure local credential storage scoped by environment and validated tenant
  origin.
- A single-flight refresh boundary and normalized machine-readable account
  errors.
- A dedicated account-only API boundary that reuses existing Rails account
  policies and services without inheriting browser redirects or admin-aware
  scope expansion.
- Ordinary users and users who also hold admin authority receive only their
  account data and capabilities.
- A client data-source boundary allows the already-built dummy UI to switch to
  real local/test adapters without dummy fallback.

## Mature Reference Boundary

DojoMate-Expo may supply patterns for token persistence ordering, refresh
recovery, single-flight handling, startup state, API errors, and tests. Wenfu
must not copy its endpoints, roles, account selection, identifiers, secrets, or
domain semantics. Wenfu Rails remains authoritative.

## Explicit Exclusions

- Broad account resource CRUD or screen completion;
- Google/Apple OAuth and identity link/unlink;
- payment history/status, checkout, callbacks, or provider actions;
- production accounts/data, provider configuration, deployment, AAB/store, or
  release work.

## Immutable Acceptance Criteria

1. A non-production email account can sign in, restore, refresh, and sign out
   through a stable native account contract.
2. Account closure/revocation leaves no usable native session.
3. Tenant switching cannot retain or disclose the prior tenant's session or
   cached data.
4. Arbitrary scanned origins are rejected; the accepted binding requires a
   trusted TempleMate decision plus tenant-local identity confirmation.
5. Dual-role users receive no admin data, capability, preference, route, or
   expanded registration scope.
6. Browser account sessions remain working and isolated from native tokens.
7. Dummy mode cannot activate after a real adapter failure.
8. No OAuth, payment, provider, production, deployment, or release behavior is
   introduced.
9. Focused Rails and mobile contract tests pass with clean final source state.

## Current Gate

This phase follows acceptance of the dummy-account development client. Its
trust-document and exact native session contracts must be recorded before
Control dispatch. It is not current implementation authority.
