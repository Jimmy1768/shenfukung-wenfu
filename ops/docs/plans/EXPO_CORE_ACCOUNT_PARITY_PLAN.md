# Expo Core Account Parity Plan

Status: superseded as standalone sequencing authority; Rails JSON parity is now
owned by `EXPO_ACCOUNT_JSON_API_TRACK_PLAN.md` and mobile integration by
`EXPO_NATIVE_CLIENT_INFRA_TRACK_PLAN.md`; retained as prior evidence

Created: 2026-08-11

Owner: Wenfu Planning

Prior parent roadmap: `ops/docs/plans/EXPO_ACCOUNT_APP_V1_ROADMAP.md`

## Objective

Connect the proven native screens to local/test Rails data so the current
non-payment, non-OAuth account namespace works in TempleMate. This phase ports
existing behavior; it does not redesign the account product.

## Source Of Truth

For every resource and action:

- the checked-in account route/controller is the operation inventory;
- existing account forms, services, policies, validations, lifecycle rules,
  throttles, and audits remain server-authoritative;
- Expo receives account-safe request/response/error adapters;
- public JSON may be reused only after its fields, ordering, tenant scope, and
  error behavior match the account use;
- no native-only operation or broadened field set is added.

## Included Functional Surface

### Email identity

- email/password sign in and sign out through the native foundation;
- email signup using existing account registration rules;
- forgot/reset password through a safe native/browser return where required;
- the existing password-addition behavior for an account without a password;
- no Google/Apple buttons, link, unlink, or OAuth callback in this phase.

### Account reads and writes

- dashboard/account overview with payment widgets and payment actions removed;
- profile read/update, including the existing name requirement and current
  phone, city, and notes fields;
- dependent new/create/edit/update/destroy with current user scoping and audit
  behavior;
- event, service, and gallery account presentation using reviewed existing
  data contracts;
- registration index/show/new/create/edit/update, with the existing self versus
  dependent behavior and lifecycle restrictions and with no invented delete;
- certificate presentation matching the current web behavior;
- assistance and contact-temple submissions with current field, error, and
  throttle behavior;
- locale and theme preferences, excluding `admin_display_mode` or any other
  admin preference;
- data export/deletion requests and account closure with confirmation, session
  revocation, and local-data cleanup matching existing account authority.

### Registration state without payments

- A test account can create and edit registrations using local/test Rails data.
- Registrations that do not require payment can reach their normal
  non-payment completion state.
- A payment-required registration stops at the truthful unpaid/pending boundary
  with no checkout action.
- Local/test fixtures may include already-paid registrations so the account
  registration screens can display an existing paid state.
- The client cannot create, alter, poll, or reconcile a payment and receives no
  unnecessary provider reference.

## Required Contract Evidence

Each included adapter must have focused Rails request evidence for:

- success and field validation;
- signed-out and expired-session behavior;
- wrong-tenant and cross-tenant denial;
- a user who also has admin authority remaining account-scoped;
- web lifecycle denial and ownership denial;
- duplicate, retry, or concurrent-submit behavior where the existing mutation
  makes those cases material;
- account closure and prior-tenant local-state cleanup where applicable.

Mobile evidence must cover loading, empty, retry, validation, pending,
confirmation, logout, and interruption states actually used by the included
surface.

## Explicit Exclusions

- payment menu/history, payment-status polling, checkout, provider return,
  callback, refund, settlement, or provider credentials/actions;
- Google/Apple OAuth, provider login, or identity link/unlink;
- admin, guest-list, staff, operations, or role/mode behavior;
- push, analytics, background sync, broad offline mutation, IAP,
  subscriptions, or new sharing/media features;
- production data, deployment, EAS cloud action, AAB/store action, or release
  promotion;
- final visual refinement beyond functional, accessible-enough implementation
  needed to test the flows.

## Immutable Acceptance Criteria

1. The included account screens work against local/test Rails data rather than
   dummy state.
2. Email signup/login/recovery and session behavior match existing account
   authority without OAuth.
3. Profile edits, including name, persist and return current web validation
   behavior.
4. Dependent CRUD persists with correct ownership, validation, and audit
   behavior.
5. Registration create/update persists with existing lifecycle, registrant,
   validation, duplicate, and tenant rules; no delete is invented.
6. A payment-required registration cannot pay, while a seeded already-paid
   registration can be presented without exposing a payment lifecycle.
7. Assistance/contact, preferences, privacy requests, and closure preserve the
   existing account behavior and safety boundary.
8. Dual-role users receive account-only behavior and no admin surface or data.
9. No OAuth or payment implementation, provider action, production action, or
   release claim occurs.
10. Focused Rails/mobile checks pass and final source state is clean and
    attributable.

## Current Gate

This phase follows acceptance of the native account foundation. Before its
Control dispatch, Planning must map each included native adapter to the exact
existing Rails form/service/policy and response contract. It is not current
implementation authority.
