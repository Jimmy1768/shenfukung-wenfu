# Expo Account App V1 Roadmap

Status: superseded as current sequencing authority by the two parallel-track
plans; retained as prior roadmap evidence

Disposition: parallel Rails JSON work is now organized in
`EXPO_ACCOUNT_JSON_API_TRACK_PLAN.md` for Control A, and pre-integration
Expo-native infrastructure/dummy-client work in
`EXPO_NATIVE_CLIENT_INFRA_TRACK_PLAN.md` for Control B. Both stop at terminal
checkpoints. Planning later coordinates a separate merging/integration phase
through Control A; final refinement follows functional integration. OAuth and
payments remain separate deferred phases. No implementation or Control dispatch
is authorized by this disposition.

Created: 2026-08-11

Owner: Wenfu Planning

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Supporting inventory:
`ops/docs/plans/EXPO_ACCOUNT_APP_READINESS_AND_PARITY_PLAN.md`

Superseded sequencing plan:
`ops/docs/plans/EXPO_ACCOUNT_V1_BUILD_PLAN.md`

Mature read-only implementation reference:
`/Users/jimmy1768/Projects/DojoMate-Expo`

## Product Authority

TempleMate V1 is the native account app for the existing Wenfu account
namespace. The existing Rails account controllers, forms, services, policies,
validations, lifecycle rules, and Vue/HTML presentation are the product source.
Expo adapts them to native presentation; it does not select a smaller invented
purpose or create new business behavior.

The following direction is accepted:

1. TempleMate contains account behavior only. Admin remains web-only, with no
   role switch, mode toggle, admin payload, or admin navigation in Expo.
2. V1 covers the current non-payment, non-OAuth account surface. Existing
   web-authorized operations remain the operation boundary: no native delete is
   added where web has no delete, and no web operation is removed merely to
   simplify Expo.
3. The first implementation objective is an installable development client
   that simulates the account menus, screens, email login, and user actions with
   deterministic dummy data.
4. Dummy registration creation is interactive. A dummy account cannot perform
   checkout, but fixtures may include already-paid registrations so paid-state
   presentation can be tested without a provider or payment lifecycle.
5. Real non-production email authentication and persisted core account behavior
   follow in separate native-foundation and parity phases.
6. OAuth is a separate later phase. Its absence does not block core V1 email
   login and account testing.
7. The entire payment surface and lifecycle is a separate later phase. No
   checkout, payment history, payment status polling, provider return, or
   provider action is required for core V1.
8. Functional UI is built during dummy and parity work. Final visual,
   accessibility, interaction, and device refinement occurs only after the
   functional V1 surface works.
9. Mature sibling repositories supply proven client, auth, navigation, form,
   test, and build patterns. Wenfu Rails remains authoritative for Wenfu data,
   authorization, tenant, and lifecycle semantics.
10. The existing Wenfu Expo scaffold is reused. TempleMate versioning remains
    independent of Rails, uses `major.minor.patch`, and starts at `1.0.0`.

## Phase Map

| Sequence | Plan | Outcome | Current disposition |
| --- | --- | --- | --- |
| 1 | `EXPO_DUMMY_ACCOUNT_DEVELOPMENT_CLIENT_PLAN.md` | Installable API 36 development client with interactive dummy account screens | First implementation objective; not dispatched |
| 2 | `EXPO_NATIVE_ACCOUNT_FOUNDATION_PLAN.md` | Trusted one-temple binding, native email session, account-only API client, and safe local state | Planned after Phase 1 |
| 3 | `EXPO_CORE_ACCOUNT_PARITY_PLAN.md` | Existing non-payment, non-OAuth account behavior works against local/test Rails data | Planned after Phase 2 |
| 4 | `EXPO_V1_UI_REFINEMENT_PLAN.md` | Functional V1 receives final native visual, accessibility, interaction, and device refinement | Planned last within core V1 |
| Deferred | `EXPO_OAUTH_PHASE_PLAN.md` | Existing Google/Apple account login and identity behavior receives a native contract | Separate phase; not a core V1 blocker |
| Deferred | `EXPO_PAYMENT_PHASE_PLAN.md` | Account payment surface and provider lifecycle receive their own exact plan | Separate phase; not a core V1 blocker |

Distribution, AAB/store submission, signing, production domains, public privacy
and support URLs, provider credentials, deployment, and release promotion remain
outside every phase above until separately authorized.

## Current Account Surface Boundary

Core V1 takes its inventory from the checked-in account namespace and excludes
only the separately planned OAuth and payment surfaces. The functional inventory
is:

- email/password sign in, sign out, signup, password recovery, and the existing
  password-addition rule;
- dashboard/account overview without payment widgets or actions;
- profile read/update;
- dependent create/edit/update/delete;
- event, service, and gallery browsing;
- registration index/show/new/create/edit/update, with no invented delete;
- certificate presentation matching the current account behavior;
- assistance and contact-temple submission;
- locale and theme preferences, excluding admin display preferences;
- privacy request actions and account closure;
- one active, validated temple context at a time.

Paid registration fixtures may appear as registration state. They do not add a
payments menu, provider reference, checkout action, or mutable payment state.

## Supersession

This roadmap supersedes the purpose-first selection gate, selective-CRUD gate,
and the idea that the dummy development client must be only a minimal technical
shell in `EXPO_ACCOUNT_V1_BUILD_PLAN.md`. The prior document remains evidence
for scaffold, domain, tenant-binding, API 36, branding, and version decisions.

The readiness inventory remains the gap register. Its broad implementation
packages and open-decision list are not one combined delivery plan; the phase
documents above now own sequencing and scope.

## Current Gate

Current classification:
`v1_phase_roadmap_accepted_first_phase_not_dispatched`.

First blocker: no explicit instruction has authorized implementation dispatch
of the dummy-account development-client phase. Planning remains authoritative
idle with no active packet, callback, approval, provider action, or Control
dispatch.
