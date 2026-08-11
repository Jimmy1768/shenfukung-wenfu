# Expo Account JSON API Track Plan

Status: completed and accepted immutable Track A checkpoint; Control A is
`released_terminal_idle` pending the separate integration dispatch

Created: 2026-08-11

Owner: Wenfu Planning

Parallel counterpart:
`ops/docs/plans/EXPO_NATIVE_CLIENT_INFRA_TRACK_PLAN.md`

Supporting inventory:
`ops/docs/plans/EXPO_ACCOUNT_APP_READINESS_AND_PARITY_PLAN.md`

## Objective

Create the account-only JSON and native email-session equivalent of the working
Rails account namespace, excluding OAuth and the entire payment
surface/lifecycle.

The HTML account namespace already defines the product. This track adapts its
current routes, forms, services, policies, validations, tenant rules, lifecycle
rules, throttles, audits, and allowed operations into stable account-safe JSON.
It does not redesign the account console and does not edit Expo code.

## Parallel Ownership

Control A owns the Rails-side track. Its implementation packets may own the
bounded Rails routes, account API controllers, session/auth services,
serializers, and Rails tests selected by Control A. Exact paths remain
Control-owned packet details.

Control A does not edit:

- `mobile/` or Expo configuration;
- Expo build/version scripts or native client tests;
- Vue/account presentation unless a later accepted plan identifies a shared
  web defect;
- payment, OAuth, provider, deployment, or production surfaces;
- Planning documents.

Control B does not need to wait for this track to build the dummy client and
native infrastructure. Neither parallel track integrates the other. The later
merging phase waits for both accepted terminal checkpoints and is coordinated
by Planning through Control A.

## Account-Only Contract Boundary

Every native endpoint must always operate as the signed-in account user under
the validated tenant context. A user who also holds admin authority receives no
admin-owned registration scope, guest list, capability, preference, temple
management data, or other expanded access.

Existing browser account sessions must keep working. Native sessions are a
separate API authentication mechanism and cannot silently inherit HTML redirect
or cookie assumptions.

## Included Work

### Contract inventory

Record stable request, success, validation-error, authorization-error,
lifecycle-denial, and not-found behavior for the current non-payment,
non-OAuth account surface:

- email/password sign in and sign out;
- email signup, forgot/reset password, and the existing password-addition rule;
- session bootstrap/restoration, refresh, expiry, revocation, and account
  closure;
- dashboard/account bootstrap without payment widgets or payment actions;
- profile read/update;
- dependent new/create/edit/update/destroy;
- events, services, and gallery account reads;
- registration index/show/new/create/edit/update, with no invented delete;
- certificate presentation data matching current account behavior;
- assistance and contact-temple submission;
- locale and theme preferences without `admin_display_mode`;
- privacy request actions and account closure.

### Native email session

- Implement the minimum complete access/refresh/session lifecycle required by
  the email account surface.
- Define rotation, replay, expiry, revocation, logout, account-closure, and
  per-device behavior before protected endpoints rely on it.
- Return machine-readable safe error codes without leaking whether an account
  exists.
- Preserve browser session behavior and prove separation in request tests.

Mature sibling code is implementation evidence, not Wenfu authority. The
checked-in Wenfu refresh-token sketch must not be treated as already working,
and DojoMate endpoint names or payloads are not copied without matching Wenfu
semantics.

### Account resource adapters

- Reuse existing Rails forms, services, policies, and serializers wherever
  their account semantics already match.
- Add JSON adapters only where the current account behavior lacks a safe native
  boundary.
- Keep field validation, ownership, tenant isolation, lifecycle restrictions,
  audit behavior, throttles, duplicate handling, and user-work protections on
  the server.
- Provide stable accepted response examples or equivalent machine-readable
  contract evidence that the mobile adapter can consume after Track A
  acceptance.

### Registration state without payments

- Registration creation/update follows the existing non-payment account rules.
- A registration that requires payment may stop at its truthful unpaid or
  pending boundary.
- Existing paid registrations may expose only the minimal high-level state
  required for account presentation.
- No payment history endpoint, checkout, status poller, provider reference,
  callback, reconciliation, or mutable payment transition enters this track.

## Required Evidence

Focused Rails request/contract evidence must cover, where applicable:

- successful request and exact response shape;
- field validation and stable error codes;
- signed-out, expired, revoked, and closed-account sessions;
- refresh rotation, replay, and concurrent refresh;
- wrong-tenant, cross-tenant, and ownership denial;
- an account user who also holds admin authority remaining account-scoped;
- permitted registration operations and lifecycle denial;
- duplicate/retry/concurrent mutation behavior where the existing action makes
  it material;
- browser account behavior remaining intact;
- absence of unnecessary provider, admin, or secret fields.

## Explicit Exclusions

- all Expo/mobile files, screens, navigation, storage, and build work;
- Google/Apple OAuth, identity link/unlink, or provider callbacks;
- payment menu/history/status polling, checkout, provider return, callbacks,
  ECPay/Stripe actions, refunds, settlement, or accounting;
- admin/guest-list/staff/operations APIs for Expo;
- production accounts/data, deployment, secrets, external services, AAB/store,
  or release work.

## Immutable Acceptance Criteria

1. The current non-payment, non-OAuth account namespace has stable account-safe
   JSON equivalents for the operations listed in this plan.
2. Native email signup/login/session/refresh/logout/recovery/closure behavior is
   complete enough for the included account surface and preserves browser
   sessions.
3. Every mutation reuses the current server-authoritative Wenfu business rule
   rather than reimplementing it in a controller or client contract.
4. Dual-role users remain strictly account-scoped in every response and
   mutation.
5. Registration JSON preserves current create/update/lifecycle behavior with no
   invented delete and no payment lifecycle.
6. Accepted response/error examples are stable enough for the parallel Expo
   adapter to integrate without guessing.
7. No OAuth, payment, provider, Expo, production, deployment, or release work
   occurs.
8. Required Rails checks pass with exact evidence and final source state is
   clean and attributable.

## Terminal Checkpoint, Later Merge, And Current Gate

On accepted completion, Control A sends its terminal packet only to Planning.
Planning records the paired receipt and holds Control A's accepted Rails commit
and contract evidence as one input to a later merging phase. Control A performs
no Expo integration under this parallel-track plan.

After both Control A and Control B have delivered accepted terminal checkpoints
and received `released_terminal_idle`, Planning may write and accept a separate
merging/integration plan and send it to Control A. That later plan—not this
parallel track—owns bringing the two accepted commits together, implementing or
adapting the real mobile wire integration, resolving evidence-backed contract
fit, and running end-to-end local/test checks. Control B remains idle unless a
later Planning decision explicitly gives it new work. The Controls do not
coordinate directly.

Accepted checkpoint:

- branch: `codex/expo-account-json-api-track-a`;
- implementation: `684c9efcd43127b07281fe0bf67d4932f98e0ef2`;
- accepted contract/concurrency evidence and branch tip:
  `740aa39bb38806d2207636bb391167c2fee6a9b1`;
- classification: `accepted_frozen_outcome` / `released_terminal_idle`.

Integration result: this checkpoint is incorporated into canonical integration
commit `6cab3f1b52ebaeaf68667f19a3c804f8d9c43079` under
`EXPO_ACCOUNT_NATIVE_INTEGRATION_PLAN.md`. No provider, production, external,
or release action is authorized by this completed track.
