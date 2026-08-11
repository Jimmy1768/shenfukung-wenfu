# Expo Account App Readiness And Parity Plan

Status: completed initial readiness inventory; retained as supporting evidence
for `EXPO_ACCOUNT_V1_BUILD_PLAN.md`; implementation and Control dispatch not
authorized by this document

Created: 2026-08-11

Owner: Wenfu Planning

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Scanned base: `main` at `43c252692d415f1c66d72ef41b6d356222db1721`

Mature read-only reference: `/Users/jimmy1768/Projects/DojoMate-Expo`
`main` at `0a35b4ca9af78a69917d80ea17471a676c36760f`

## Outcome

Current disposition: the Director clarified on 2026-08-11 that V1 scope must
follow the app's selected purpose. The complete feature/parity language below
is an upper-bound inventory, not a V1 delivery requirement. Current V1
selection, sequencing, and acceptance authority lives in
`EXPO_ACCOUNT_V1_BUILD_PLAN.md`.

Wenfu is ready for detailed Expo planning, but it is not ready for account-app
screen implementation against a stable mobile contract.

This is not a greenfield app. The repository already contains an Expo 54
project, EAS profiles, per-environment URL/config helpers, shared project and
design tokens, generated native artwork, SecureStore helpers, build wrappers,
and version metadata. That scaffold should be retained and corrected.

The first implementation blocker is server-side: there is no implemented
native account authentication/session contract, and the current account JSON
controllers inherit browser-cookie authentication. Most web account reads and
writes also have no JSON equivalents. Building screens first would force the
mobile client to guess contracts and would violate the parity-only direction.

This scan intentionally leaves many gaps open. It does not authorize code,
schema, dependency, native-project, provider, runtime, build, or release work.

## Binding Product Direction

The following criteria are frozen for any later implementation packet:

1. The Expo app is an **account-namespace app only**.
2. Admin remains web-only. Expo has no admin navigation, admin endpoints,
   admin capability payload, admin theme preference, role/mode switch, or
   patron/admin toggle.
3. The account web product is the feature and behavior authority. Expo
   duplicates the same login methods, account features, CRUD operations,
   validation rules, lifecycle restrictions, tenant scoping, and payment
   states in native presentation.
4. “Parity” does not authorize a new operation. If web account supports create
   and update but not delete, Expo does the same.
5. Existing Rails domain services and policies remain authoritative. Mobile
   endpoints adapt them; they do not fork business logic into JavaScript.
6. The existing Wenfu `mobile/` scaffold is the starting point. Do not replace
   it with a newly generated app or copy DojoMate wholesale.
7. DojoMate-Expo is read-only evidence for mature client structure, session
   recovery, navigation, forms, testing, and build guardrails. Its domain,
   versions, admin/operations modes, academy selection, monetization, push,
   and caching behavior are not Wenfu requirements.
8. No production/provider action, secret access, EAS build, app-store action,
   deployment, database mutation, real payment, or real OAuth configuration is
   authorized by this plan.

## Prior Expo Plan Disposition

`ops/docs/plans/EXPO_MULTI_ROLE_MODE_SWITCH_PLAN.md` records an older direction
for one patron/admin app with a mode switch. The Director's 2026-08-11
account-only instruction supersedes that direction for Wenfu. The old document
remains intact as historical decision evidence, but none of its admin mode,
capability, temple-admin selector, or mode-persistence criteria may enter a
future Expo packet.

The archived final-web-readiness decision remains valid: web readiness permits
Expo preparation to begin, but it did not prove or implement the mobile API.

## Evidence Boundaries

This is a source scan, not runtime acceptance. It inspected repository files
and Git state without starting Rails, Metro, a simulator, a device, a database,
an OAuth flow, a payment flow, EAS, or an external service.

Evidence was classified as:

- **implemented**: source and existing tests show a concrete behavior;
- **scaffolded**: a reusable shell/helper/config exists but is not a complete
  product path;
- **placeholder**: source explicitly defers or stubs the behavior;
- **unverified**: configuration or code exists but this planning scan did not
  execute it;
- **missing**: no corresponding source contract was found.

## Existing Wenfu Expo Scaffold

### Reusable foundation

| Area | Evidence | Readiness |
| --- | --- | --- |
| Expo runtime | `mobile/package.json` uses Expo `~54.0.25`, React Native `0.81.5`, React `19.1.0` | Implemented dependency scaffold; execution unverified |
| App/config entry | `mobile/App.js`, `mobile/index.js`, `mobile/app.config.js`, `mobile/metro.config.js` | Scaffolded |
| Environment mapping | `shared/app_constants/env.json` and `mobile/app/lib/app_constants/env.js` | Scaffolded; URLs not probed |
| Project identity | `shared/app_constants/project.json` and mobile project helper | Scaffolded; native identifiers need correction/review |
| Design system | shared themes plus `mobile/theme/tokens.js` and login styles | Reusable, not account-screen complete |
| Artwork | app, adaptive, development, splash, favicon assets | Present; store suitability unverified |
| Secure storage | `expo-secure-store` and auth storage helper | Scaffolded; key names are unsafe residue |
| HTTP auth helper | login, refresh, logout request helper | Scaffolded against nonexistent routes |
| EAS/build | `mobile/eas.json`, `bin/expo_prebuild`, `bin/expo_build` | Present; profile/config defects found; no build run |
| Versioning | `mobile/versioning.js` | Present at initial `1.0.0` / build `1` values |

### Placeholder and template residue that must not ship

- `mobile/App.js` is an explicit “Expo starter” screen, not an account app.
- It displays seeded admin credentials, offers an admin quick action, and only
  logs an OAuth stub.
- `mobile/app.config.js` names login/refresh settings as admin settings and
  defaults to `/api/v1/mobile/sessions*`, which Rails does not route.
- Demo credentials, including a password, are placed in public Expo `extra`
  configuration. Account production code must not embed credentials.
- Native identifiers default to an `.admin` suffix.
- SecureStore keys use `golden-template.admin.*`, creating wrong-surface and
  possible cross-app collision semantics.
- Mobile translations live under `demo_admin`; they are not account copy.
- Mobile advertises Japanese while the web account locale selector currently
  offers only Traditional Chinese and English.
- `bin/expo_build dev-client` selects `development-client`, but `eas.json`
  defines `development` instead.
- `app.config.js` expects a Komainu/local config plugin, while no matching
  `mobile/plugins-local` package was found in Wenfu.
- There is no navigation package, form/validation stack, account provider,
  screen hierarchy, test runner, lint command, locale guard, error boundary,
  or account API module beyond the auth placeholder.

These are planning findings, not authorization to rename, remove, install, or
regenerate anything now.

## Web Account Parity Manifest

The following web surface is the scope authority. “API now” describes what was
found at the scanned base, not what a future endpoint must be named.

| Account behavior | Web account evidence | Account JSON API now | Expo readiness / gap |
| --- | --- | --- | --- |
| Choose temple context | `/account/temples`; session-held active temple slug | No native bootstrap/selection contract | Missing. The mobile contract must preserve server-validated temple scope without inventing an admin temple selector. |
| Email/password sign in and sign out | `Account::SessionsController`, login form, account session key | No mobile session endpoint | Blocker. Placeholder client routes do not exist. |
| Google/Apple sign in where configured | Central OAuth browser flow and account login/signup links | No native start/callback/session exchange contract | Missing. Exact native browser/deep-link contract requires an explicit decision. |
| Email signup | `Account::SignupsController` and `Account::RegistrationForm` | No JSON endpoint | Missing, including duplicate-provider guidance, minimum password, terms metadata, errors, and post-sign-in intent. |
| Forgot/reset password | shared password routes linked from account login/settings | No native contract | Missing; parity path and secure return behavior need definition. |
| Session restoration and logout | browser cookie session | No token issuance/rotation/revocation implementation | Blocker. JWT helper exists; refresh-token service raises `NotImplementedError`. |
| Dashboard | recent registrations, certificates, payments, quick actions | Registrations/certificates are separate summary APIs; no dashboard/bootstrap payload | Partial reads only. Loading/error/empty state and refresh consistency are undefined. |
| Profile read/update | name, phone, city, notes; at least one name | No JSON endpoint | Missing read/update contract and field-error mapping. |
| Password settings | add a password only when the OAuth account lacks one; reset link otherwise | No JSON endpoint | Missing. Expo must not turn this into arbitrary password-change CRUD. |
| Linked identities | list, link, unlink with last-login-method protection | No JSON/native flow | Missing. Server guard and browser/deep-link return must be preserved. |
| Dependents | new/create/edit/update/destroy; user-scoped fields and audit | No JSON endpoint | Missing complete web-authorized CRUD and validation contract. |
| Events | account event list | Public temple event index/show JSON exists | Payload suitability and account navigation intent unverified. No account-specific adapter is defined. |
| Services | account service list | Public temple service index/show JSON exists | Payload suitability and registration entry intent unverified. |
| Gallery | account gallery index/show | Public temple archive JSON exists | Mapping, pagination/media behavior, and account presentation contract unverified. |
| Registrations | index/show/new/create/edit/update; no delete; self/dependent registrant; lifecycle gates | Account API exposes index summaries only | Major gap. Missing detail, create, update, validation, permitted-field, lifecycle, duplicate, and idempotency contracts. |
| Registration payment | payment page, checkout start, browser return, status polling | Payment-status show exists; checkout start/return are HTML account routes | Major gap. Native handoff/return must reuse current payment semantics without inventing IAP or provider behavior. |
| Payments | account payment history | Payment-status is per registration; no account payments index JSON | Missing history contract; exposure of provider references must be reviewed. |
| Certificates | dashboard/list data | Account certificates index JSON exists | Partial. Native display/download/share needs an explicit parity decision based on actual web behavior. |
| Assistance request | account create action | No account JSON endpoint | Missing request/error/throttle contract. |
| Contact temple | account modal/create action; public JSON create route also exists | Public create endpoint exists | Candidate reuse, but authenticated attribution, fields, errors, and throttle parity are unverified. |
| Locale | account selector persists session/cookie/user preference; `zh-TW` and `en` | Preferences JSON includes locale | Partial. Expo locale list/copy does not match web. |
| Theme | account light/dark preference | Preferences JSON exists | Partial. Current API also accepts `admin_display_mode`; account Expo must never expose or mutate it. |
| Privacy requests | request deletion and export | No account JSON endpoint | Missing visible native actions and request-state/error contract. |
| Close account | immediate web closure and session destruction | No account JSON endpoint | Missing high-risk confirmation, token revocation, retry/result, and signed-out terminal-state contract. |

## API And Authority Findings

### Native authentication is not implemented

- `Api::BaseController` describes JWT/session authentication as future work.
- `Auth::JwtService` exists, but no scanned controller uses it for mobile
  authentication.
- `Auth::RefreshToken` is an explicit sketch whose issue, rotate, and revoke
  methods raise `NotImplementedError`, even though a `RefreshToken` model/table
  exists.
- The Expo auth helper therefore represents intended shape, not a working
  server contract.

### Existing account JSON is browser-session JSON

`Api::V1::Account::BaseController` inherits `Account::BaseController`, including
the browser account session, tenant context, and authentication behavior. Its
integration tests sign in through the browser session helper. It is not
evidence that bearer-token Expo requests work.

### Existing account JSON is not safe to adopt blindly for account-only Expo

The current API base includes admin-aware scope helpers. For a user with an
active admin account, registration scope can expand to owned admin temples,
and a guest-list endpoint is present. Preferences also accept an admin display
mode. Those behaviors conflict with the account-only app boundary.

A future mobile account contract must always return the signed-in user's
account data under the selected account temple context, even when that same
user also has web-admin authority. It must not disclose or mutate admin data,
capabilities, preferences, guest lists, or temple-admin context.

### JSON parity is mostly absent

The current account API provides only registration summaries, one registration
payment status, certificates, guest lists, and preferences. Profile,
dependents, registration detail/mutations, payments history, privacy, account
closure, assistance, signup, sessions, password settings, and OAuth identity
management remain HTML-only or absent.

## DojoMate-Expo Reference Findings

DojoMate-Expo is mature evidence, not a copy source for Wenfu product rules. It
uses Expo 53 / React Native 0.79, while Wenfu already uses Expo 54 / React
Native 0.81. Package versions and generated native configuration must follow
Wenfu compatibility, not be downgraded to match the example.

### Transferable patterns to evaluate during implementation

- an explicit startup state machine for secure-token load, refresh recovery,
  current-user bootstrap, loading, authenticated, and signed-out states;
- a centralized API client with bearer attachment, one refresh path,
  structured 401 handling, bounded retry, and complete auth cleanup;
- origin/app-scoped SecureStore keys and single-flight token refresh;
- focused provider composition for auth, preferences, localization, and app
  data rather than one monolithic screen;
- separate auth and signed-in navigation stacks;
- Formik/Yup-style field and server-error handling, if the future Control
  selects compatible dependencies;
- keyboard, safe-area, loading, error, empty, retry, and mutation-pending UX;
- user-scoped cache cleanup at logout/account closure;
- Jest and source-contract checks for auth, storage keys, locale parity,
  navigation boundaries, API mutations, payment returns, and build profiles;
- profile-aware build/prebuild commands with explicit guardrails.

### Patterns explicitly excluded from Wenfu parity

- role/account-selection screens and patron/admin/operations switching;
- admin, staff, operations, permission, or academy-management navigation;
- multi-academy selection as a substitute for Wenfu account temple context;
- DojoMate domain payloads, endpoint names, access rules, and visual copy;
- IAP/RevenueCat, subscription upsells, push notifications, gamification,
  advanced offline caches, and OTA/release lanes unless separately authorized;
- copying its app config, secrets, identifiers, native folders, or dependency
  versions.

## Gap Register

### Blocking contract gaps

| ID | Gap | Why it blocks implementation readiness | Required planning evidence before dispatch |
| --- | --- | --- | --- |
| B-01 | No native session contract | Expo cannot authenticate or restore the same account safely | Accepted request/response/error/expiry contract for sign in, refresh, sign out, bootstrap, and closed accounts |
| B-02 | Refresh lifecycle is a sketch | Secure persistent login cannot be claimed | Rotation, replay, expiry, revocation, per-device, logout, close-account, and audit criteria |
| B-03 | Browser account API base is not native auth | Existing JSON success tests rely on cookies | A dedicated authenticated account API boundary that reuses account policies without inheriting HTML redirect/session assumptions |
| B-04 | Admin-aware API leakage conflicts with scope | Dual-role users could receive admin-owned data in an account-only app | Frozen account-only scoping tests, including a dual-role user negative case |
| B-05 | No stable account bootstrap | App cannot resolve user, selected temple, locale/theme, and initial navigation coherently | Minimal bootstrap fields, temple-context behavior, versioning, and cacheability criteria |
| B-06 | Most parity mutations are absent | UI work would invent payloads and error behavior | Accepted endpoint/resource contract inventory mapped to existing forms/services/policies |

### Authentication and identity gaps

- The exact mobile token type, lifetime, refresh rotation, reuse detection,
  device/session list, and revocation semantics are undecided.
- Account closure must terminate mobile credentials; current web session
  destruction alone is insufficient for a token client.
- Password login error and throttle responses need stable machine-readable
  codes without exposing account existence.
- Email signup needs JSON validation, terms/version recording, existing OAuth
  account guidance, and post-auth temple/registration intent parity.
- Forgot/reset password deep-link behavior is undefined.
- Native Google/Apple initiation, callback ownership, state/nonce/PKCE rules,
  provider availability, account-link mode, and failure return are undefined.
- Expo public config currently treats provider client secrets as an enablement
  input. Client secrets must never be embedded in a native bundle.
- Linking/unlinking must preserve the server's last-login-method protection.

### Account data and CRUD gaps

- No JSON profile read/update contract or field-level validation format.
- No dependent list/create/read/edit/update/destroy contract.
- No registration detail/create/update contract, permitted-field map, or
  lifecycle-state mutation result.
- No mobile contract for self versus dependent registrants, dependent metadata
  synchronization, quantities, arrival windows, household notes, ceremony
  notes, duplicate prevention, or concurrent edits.
- No account payments history payload.
- No single dashboard/bootstrap aggregation decision; using many calls versus
  one payload remains an implementation choice after contracts are known.
- Public temple events/services/gallery payloads have not been checked against
  every field and ordering assumption in account views.
- Pagination, refresh, stale-data, and retry behavior are undefined. Offline
  mutation support is not implied by parity and should default out of scope.

### Payment and return-flow gaps

- The web checkout is HTML/provider-redirect based. The approved native
  handoff mechanism—system browser or another reviewed method—is undecided.
- The app scheme exists, but no checkout return/deep-link route matrix,
  correlation rule, cancel path, or interrupted-return recovery is defined.
- Payment-status polling exists for a registration but its native authorization,
  terminal-state timing, retry/backoff, and error contract need acceptance.
- Current serializers may expose external references. Mobile-minimal exposure
  must be reviewed rather than copied automatically.
- Native IAP is not account-web parity and is excluded.
- No real ECPay credential, merchant, payment, refund, callback, or production
  action is part of this work.

### Privacy, support, and compliance-surface gaps

- Close-account confirmation, in-flight request behavior, credential
  revocation, local-data clearing, and final signed-out UX are undefined.
- Deletion/export request submission and existing-request visibility need a
  mobile contract.
- Completed export delivery is not currently a mobile behavior; parity must be
  decided from the web product instead of assuming native download/share.
- Assistance and contact-temple field/error/throttle contracts are incomplete.
- App-store privacy/support metadata, policies, and review evidence are later
  release-gate work, not proven by the existence of web privacy pages.

### Client architecture and quality gaps

- No account navigation map or deep-link allowlist exists.
- No startup/auth recovery state machine exists in Wenfu.
- No account API client, normalized error model, refresh single-flight, or
  mutation guard exists.
- SecureStore key names are template/admin-specific and not scoped by app/API
  origin or environment.
- No declared local-data inventory or logout/closure cleanup matrix exists.
- No form library or native validation strategy is installed.
- No mobile test, lint, type/static, translation-key, config, or dependency
  compatibility checks are defined.
- No accessibility, dynamic text, reduced-motion, keyboard, screen-reader,
  touch-target, low-connectivity, or older-device acceptance matrix exists.
- Shared theme tokens exist, but account component primitives and visual parity
  criteria do not.
- No crash/error reporting or privacy-safe diagnostic policy is selected; no
  external telemetry is authorized.

### Build and distribution gaps

- The dev-client build wrapper references a nonexistent EAS profile.
- Config-plugin resolution is incomplete in this repository.
- Native identifiers retain admin/template semantics and need an explicit
  development/production isolation matrix.
- EAS project ID is configured in shared source, but ownership, access, and
  correspondence to the intended app were not externally verified.
- No prebuild/build was run, so native generation, iOS pods, Android Gradle,
  signing, and current Expo Doctor compatibility are unverified.
- Version/build-number ownership and bump rules are not accepted.
- Deep-link association files, universal/app links, store records, signing,
  privacy manifests, screenshots, review credentials, and release rollback are
  unplanned or unverified.
- Builds, provider setup, OTA publishing, store submission, and release remain
  separately authorized work.

## Required Future Work Packages

These are sequencing and acceptance boundaries, not implementation packets.
Planning must accept the applicable detailed contract before any Control
dispatch. Control later owns bounded packet construction and implementation
mechanism.

### EA-0 — Freeze parity contracts

- Turn the manifest above into exact request, response, validation-error,
  authorization, tenant, lifecycle, and negative-case contracts.
- Identify the existing Rails form/service/policy each mutation must call.
- Freeze account-only behavior for ordinary users and dual-role users.
- Decide native OAuth, password-reset, checkout return, and temple-context
  flows without expanding features.

Exit: no screen must guess a server payload or business rule.

### EA-1 — Native account session foundation

- Implement and test native sign in, refresh, bootstrap, sign out, expiry,
  revocation, closed-account handling, throttling, and audit behavior.
- Keep browser account sessions working and isolated.
- Prove tokens do not grant admin namespace access and dual-role users receive
  account-only data.

Exit: a minimal diagnostic client can authenticate, restore, refresh, and sign
out locally without an Expo product screen.

### EA-2 — Account read parity

- Add stable current-user/temple context and dashboard data.
- Add profile, dependents, events, services, gallery, registrations, payments,
  certificates, preferences, linked identities, and privacy-request reads only
  where the web surface has corresponding behavior.
- Reuse suitable public serializers only after field/scoping review.

Exit: read payload fixtures and Rails request tests cover every account-only
surface and negative tenant/admin cases.

### EA-3 — Account mutation parity

- Add signup, profile update, password addition, dependent CRUD, registration
  create/update, preferences, assistance, contact, OAuth identity management,
  privacy requests, and account closure in bounded slices.
- Preserve web validations, allowed operations, audits, throttles, tenant
  isolation, lifecycle gates, and idempotency/concurrency protections.

Exit: each mutation has success, validation, unauthorized, wrong-tenant,
duplicate/concurrent, and lifecycle-denied evidence as applicable.

### EA-4 — Payment and browser-return parity

- Implement only the accepted native handoff/return mechanism around the
  existing registration checkout and payment status model.
- Prove pending/completed/failed/cancelled behavior, interrupted returns,
  duplicate callbacks/status checks, and safe app resume.

Exit: local/stubbed contract evidence matches web payment semantics. No live
provider evidence is required or authorized.

### EA-5 — Account-only Expo shell

- Replace the placeholder with startup/auth/account navigation.
- Add the shared API/auth/preferences/localization foundations and correct
  account-scoped secure storage/config.
- Remove all shipped admin credentials, copy, routes, modes, toggles, and
  identifiers from the account app.
- Build screens from the frozen parity manifest, including loading, empty,
  error, retry, validation, mutation-pending, and confirmation states.

Exit: the app contains account navigation only and every visible action maps to
an accepted web-authorized contract.

### EA-6 — Local conformance and build readiness

- Add focused mobile unit/component/contract tests and Rails request tests.
- Add lint/static, locale-key, config, storage-key, account-only navigation,
  and build-profile guardrails.
- Verify Expo dependency compatibility before adding packages.
- Run approved local Expo/React Native checks, then device/simulator and native
  prebuild checks only under a later implementation packet.

Exit: local evidence is reproducible, Git is clean, and remaining release or
external gaps are explicitly classified.

### EA-7 — Separate release gate

- Treat signing, EAS credentials/builds, provider configuration, universal
  links, store assets/metadata/review, privacy declarations, deployment/API
  origin, monitoring, rollback, and staged rollout as a new exact plan.

Exit: not defined by this readiness scan. EA-0 through EA-6 do not authorize
EA-7.

## Immutable Acceptance Criteria For Future Expo Delivery

1. Expo starts from the checked-in Wenfu scaffold and preserves compatible
   project/design/environment assets.
2. Signed-out users can use the same account authentication methods supported
   by web for the target environment, with truthful unavailable states.
3. Session restoration, refresh rotation, logout, password reset, and account
   closure fail safely and clear all account-scoped local data as applicable.
4. The signed-in navigation contains only account features. No admin or
   operations UI, capability payload, guest list, mode switch, or admin
   preference is reachable or shipped.
5. A user who also has admin authority sees only their account-owned data in
   Expo; server tests prove the boundary.
6. Expo matches the web account feature inventory and operation set, including
   profile, password addition, linked identities, dependents, temple content,
   registrations, payments, certificates, assistance/contact, preferences,
   privacy requests, and closure.
7. Field validations, tenant isolation, registration lifecycle rules, payment
   states, OAuth safeguards, throttles, audit behavior, and user-work
   protections remain server-authoritative and match web.
8. No native-only product feature is added under “parity.”
9. Credentials and provider secrets are absent from source, public Expo config,
   logs, fixtures, screenshots, and returned errors.
10. Traditional Chinese and English account copy are complete and checked;
    additional locales are not advertised until their account parity exists.
11. Required Rails and mobile checks pass with exact command/count evidence,
    and the final source state is clean and attributable.
12. Local acceptance makes no claim about production, live providers, app
    stores, legal/accounting finality, or release readiness.

## Future Verification Matrix

At minimum, later packets must define and return evidence for:

- Rails request/contract tests for every mobile auth and account endpoint;
- ordinary-user, dual-role-user, signed-out, closed-account, wrong-temple, and
  cross-tenant negative cases;
- refresh rotation/replay/revocation and concurrent refresh behavior;
- signup, reset, OAuth sign-in/link/unlink, and interrupted deep-link returns;
- every web-authorized dependent and registration mutation plus denied edits;
- payment return/status terminal states using local/stubbed provider evidence;
- privacy request and account-closure credential/local-data cleanup;
- client startup, navigation, forms, errors, empty/loading/retry states, locale,
  theme, storage keys, and logout cleanup;
- configuration/profile checks that fail on admin residue, embedded
  credentials, nonexistent EAS profiles, or unintended origins;
- approved Expo Doctor, bundling, prebuild, simulator/device, and platform
  build checks when their respective packets authorize them.

Exact commands and tools remain Control-owned implementation-packet details.

## Explicit Non-Scope

- Admin, internal, marketing-admin, staff, support, operations, guest-list, or
  temple-management features in Expo.
- Any role/mode toggle or conditional admin shell.
- New account features or CRUD operations absent from web.
- Changes to existing web product behavior except the minimum shared API/auth
  adaptation accepted in a later plan.
- Push notifications, gamification, background sync, broad offline mutation,
  analytics, IAP, subscriptions, or monetization.
- Real provider credentials/actions, money movement, refunds, merchant setup,
  production data, deployment, EAS cloud builds, OTA publish, store submission,
  or release promotion.
- Changes to DojoMate-Expo.

## Open Decisions That Must Not Be Guessed

1. The exact native access/refresh/session contract and its compatibility with
   browser account sessions.
2. Whether the minimal bootstrap is one resource or composed requests.
3. How account temple selection and registration entry intent are represented
   without importing admin multi-temple behavior.
4. The native OAuth and password-reset browser/deep-link return contract.
5. The registration checkout browser/deep-link return contract.
6. Whether certificates and completed privacy exports need native
   download/share, based strictly on accepted web parity.
7. The minimal account-safe fields for payment status/history serializers.
8. The supported device/OS/accessibility matrix and later release targets.

These decisions are not blockers to accepting this readiness scan. They are
blockers to dispatching the affected implementation slices.

## Implementation Start Gate

No Control or Implementer should receive Expo product work from this scan
alone. Planning must first accept EA-0 with exact mobile authentication and
account resource contracts. The earliest bounded implementation should prove
the native session/account-only authority boundary before any broad screen
build.

Current next action: remain Planning-authoritative idle until the Director
authorizes contract planning or another exact Expo phase. No active packet,
callback, approval, or Control dispatch is created by this document.

## Readiness Decision

Decision: `planning_ready_with_blocking_contract_gaps`

- Existing scaffold reuse: **yes**.
- Greenfield regeneration: **no**.
- Account-only scope: **accepted and frozen**.
- Admin/mode-switch scope: **superseded and excluded**.
- Web account feature inventory: **identified**.
- Mature example patterns: **identified read-only**.
- Stable native auth/account API: **no**.
- Expo account implementation dispatch: **not authorized**.
- First blocker: **EA-0 native session and account-only API contract**.
