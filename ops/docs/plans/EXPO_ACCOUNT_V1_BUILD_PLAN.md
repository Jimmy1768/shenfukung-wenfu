# Expo Account V1 Build Plan

Status: Director-authorized first broad objective accepted; dummy-data
development-client scope recorded; implementation and Control dispatch are not
authorized

Created: 2026-08-11

Owner: Wenfu Planning

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Planning base: `main` at `63a059566d66c6dda586ef7e0e9ae827ea49ff97`

First-objective update base:
`main` at `37b37a7bf6a2a4ebbac0c9248123008038c57d85`

Supporting readiness inventory:
`ops/docs/plans/EXPO_ACCOUNT_APP_READINESS_AND_PARITY_PLAN.md`

Mature read-only implementation reference:
`/Users/jimmy1768/Projects/DojoMate-Expo`

## Purpose

Organize the first Wenfu Expo build without treating every web account feature
as an automatic V1 requirement.

The readiness inventory remains useful because it records the existing Expo
scaffold, web account surfaces, API gaps, and risks. It is an upper-bound
inventory, not a command to implement full account parity.

The first broad objective is now selected: create a development client using
dummy data. This technical milestone deliberately precedes selection of the
first real account-user product journey.

Before real account behavior is implemented, V1 must still answer:

> What single job should a Wenfu account user be able to complete more usefully
> in the native app than by continuing to use the web account portal?

Until that job and its success outcome are accepted, real API integration,
authentication, broad CRUD, OAuth, payment, notification, offline, and release
work remain deferred.

## First Broad Objective — Dummy-Data Development Client

Create an installable Expo development client from the existing Wenfu scaffold
that renders an account-only native shell with deterministic dummy data.

This objective exists to prove the scaffold and native development loop, not
to approximate the final product prematurely.

### Included

- the checked-in Expo 54 scaffold and existing shared design/project assets;
- visually distinct development-client branding: launcher name
  `TempleMate (Dev)` and DEV-badged app/adaptive icons, while the production
  launcher remains `TempleMate` with unbadged artwork;
- local Metro attachment and normal development-client reload behavior;
- the minimum account-oriented shell needed to prove app startup, navigation,
  theme/tokens, locale presentation, safe areas, system bars, keyboard/insets,
  and Android back behavior where those elements are present;
- deterministic local fixtures that are visibly dummy/demo data;
- clear dummy-data mode separation so fixtures cannot silently become a
  production fallback;
- generated Android and installed development-client evidence for target SDK
  36;
- focused tests and configuration checks for the implemented shell.

### Excluded

- Rails or any other backend dependency;
- live or local API calls, native sessions, real users, or real temple data;
- signup, login, password recovery, SecureStore token use, OAuth, or identity
  linking;
- real CRUD or writes of any kind;
- payments, checkout, provider callbacks, secrets, push, camera, media, or
  background behavior;
- admin UI, role switching, admin data, or admin capabilities;
- production signing, production identifiers, AAB generation, Play upload,
  store submission, OTA publication, deployment, or release promotion.

For Android, the requested artifact is a development-client APK or equivalent
installable development artifact selected by Control under a later packet. It
is explicitly **not an AAB**. A cloud/EAS build is not implied and would require
separate external-action authority; Control may select a local mechanism when
the later packet and available tooling support it.

## Accepted Direction

These criteria are immutable for V1 planning:

1. Expo is for the account audience only. Admin remains web-only.
2. Reuse the checked-in Wenfu Expo scaffold. Do not generate a replacement app.
3. The dummy-data development client may precede product-scope selection, but
   it must remain a technical shell and must not choose real product behavior
   by implication.
4. Select one primary V1 user job before choosing real screens, endpoints,
   providers, or product dependencies.
5. Include only the minimum supporting features required to complete that job
   safely and coherently.
6. Web account behavior is authoritative for every selected feature. Match its
   fields, validation, lifecycle, permissions, tenant scope, and allowed
   operations; do not invent native-only business behavior.
7. “Parity” applies only to the selected V1 slice. It does not require all web
   features, all CRUD, all login methods, OAuth, payments, or every setting.
8. Features not explicitly accepted into V1 are deferred, not missing V1
   defects.
9. DojoMate may guide app structure, native build discipline, and verification;
   its product surface does not define Wenfu scope.
10. The Android development client must prove API 36 without producing an AAB;
    a later release artifact must prove it again under separate authority.
11. Production, providers, secrets, EAS cloud actions, store submission, and
    release promotion remain separately authorized.
12. TempleMate is one platform app. A temple name or domain is tenant context,
    not app identity.
13. The native product binds to one temple at a time. It does not copy the web
    temple-directory fallback into its normal app navigation.
14. QR/direct-link temple binding must use a validated tenant origin and must
    never carry a user identifier, credential, session, or bearer token.
15. The dummy-data development client does not add camera, network binding, or
    live domain behavior; those remain later selected product slices.
16. TempleMate Expo versioning is independent of Rails and begins at app
    version `1.0.0`. Rails changes or deployments never imply an Expo version
    change.

## Plan Relationship And Supersession

This plan is the current authority for organizing Expo V1.

`EXPO_ACCOUNT_APP_READINESS_AND_PARITY_PLAN.md` remains the source inventory of
available web behaviors and discovered gaps. Its language suggesting delivery
of the complete account feature inventory is superseded for V1. The inventory
must be consulted only after a V1 feature is selected.

`EXPO_MULTI_ROLE_MODE_SWITCH_PLAN.md` remains superseded. No admin mode, role
switch, capability UI, or admin endpoint enters V1.

The completed final-web-readiness decision permits Expo preparation. It does
not select the native product purpose or authorize implementation/release.

## Current Known Foundation

### Reuse as-is conceptually

- Expo SDK 54 project under `mobile/`;
- React Native 0.81 line and New Architecture configuration;
- shared environment and project constants;
- shared theme tokens and existing artwork pipeline;
- EAS profile file and prebuild/build wrappers;
- SecureStore dependency and preliminary auth helper;
- version metadata and application scheme.

"Reuse" does not mean every placeholder value is accepted. In particular,
`shared/app_constants/project.json` currently names the test tenant
`竹南鎮聖福宮`, and `mobile/app.config.js` incorrectly reuses that tenant name as
the launcher name. The product app is `TempleMate`; tenant identity belongs
inside the account experience. Admin-oriented demo copy, credentials,
identifiers, storage keys, nonexistent auth routes, and unresolved
config-plugin behavior remain cleanup items when an implementation slice is
authorized.

## Domain Ownership And Temporary Dual Role

The accepted domain model has two permanent roles:

| Role | Permanent owner | Intended domain | Purpose |
| --- | --- | --- | --- |
| TempleMate platform | SourceGrid | `templemate.com` or, if unavailable, `templemateapp.com` | TempleMate product site, privacy policy, help/support, app connection trust, app links, and distribution-facing URLs |
| Temple tenant | The temple client | For the pilot, `shengfukung.org.tw` | That temple's Vue site, account surface, and tenant-local API origin |

`shengfukung.com.tw` is a temporary development/staging hostname. Until the two
permanent domains exist, it stands in for both logical roles. This temporary
overloading is configuration and deployment evidence only. It must not become
TempleMate product identity, a permanent tenant domain, or a hardcoded release
assumption.

The standard ownership boundary is that each temple client purchases and owns
its own public domain. SourceGrid does not purchase the pilot's `.org.tw`
domain. SourceGrid may later purchase the separate TempleMate platform domain
when app distribution requires stable public product, privacy, help/support,
connection-trust, and store-facing URLs.

The availability of either TempleMate platform-domain candidate is not
verified by this plan, and no domain search or purchase is authorized.

The dummy-data development client does not require either purchase. Before
distribution planning can complete, the exact TempleMate platform domain must
be selected and its required public documents and connection endpoints must be
live. Exact Apple and Google submission requirements are reverified at that
later release gate rather than inferred now.

## One-Temple Native Binding Direction

TempleMate is scoped to one active temple at a time. This matches the expected
patron relationship more closely than a global in-app temple browser and keeps
rare switching explicit.

- An unbound app asks the user to connect to their temple.
- A temple site may present a QR code and an equivalent tappable connection
  link. The link is required because a user cannot scan a QR code displayed on
  the same phone.
- The QR/link payload is derived from the current tenant HTTPS origin plus a
  fixed TempleMate connection path. It contains no user-specific or secret
  value.
- The same Vue/account implementation can generate the payload from the
  current origin for every tenant; no per-temple QR database record is needed.
- TempleMate accepts a binding only after validating the origin through a
  trusted TempleMate mechanism and confirming tenant identity from the
  tenant-local `/api/v1/temple` endpoint.
- A database-free trust registry may be generated from the existing deployment
  manifest and later served from the SourceGrid-owned TempleMate platform
  domain. The exact trust document, refresh/failure behavior, and whether
  signing is required need acceptance before real authentication can use a
  scanned origin.
- Rare switching belongs in account settings. It requires a new scan/link,
  explicit confirmation, cleanup of all prior tenant-scoped session/cache
  state, and reauthentication where required.

The current web fallback remains distinct: `/account/temples` is an
unauthenticated Rails picker sourced from the checked-in deployment manifest.
Expo does not copy that directory merely because it exists on web.

Current scaffold gaps are explicit: the production mobile API origin is
currently build-time configured as `https://shengfukung.com.tw`, no runtime
validated tenant-origin store exists, and no camera/scanner dependency is
installed. None of those gaps alters the First Objective's dummy-only scope.

## Independent Expo Version Authority

TempleMate has its own tightly controlled mobile release identity. It does not
reuse, derive, or infer a version from Rails, Vue, a repository commit count,
or a tenant deployment.

- The accepted initial TempleMate app version is `1.0.0`.
- `mobile/versioning.js` is the current Expo configuration source and already
  declares app version `1.0.0`, iOS build number `1`, and Android version code
  `1`.
- `mobile/eas.json` uses `appVersionSource: local` and no build profile enables
  `autoIncrement`. That is aligned with deliberate local control and must not
  be changed to consume a number merely because EAS or a local build ran.
- Android version code starts at `1`. Local prebuilds, development clients,
  APKs, failed builds, and AABs that are never accepted into Google Play do not
  advance it. An AAB accepted into the Play release library/track system
  consumes that integer; only after the Play receipt is recorded does source
  advance to the next integer for a future upload. A consumed code is never
  reused, even if its uploaded release is later rejected, replaced, or
  abandoned. Google Play Internal App Sharing is a separate mechanism that
  officially permits reused version codes; using it does not change the
  release-track consumption ledger.
- iOS starts at version `1.0.0` build `1`. Each App Store Connect/TestFlight
  upload consumes that version/build pair. Additional uploads for `1.0.0` use
  builds `2`, `3`, and so on. When the app version advances, the iOS build
  number resets to `1`, so the first build of `1.0.1` is `1.0.1 (1)`.
- The user-visible app version, iOS build number, and Android version code are
  three distinct values. A version change requires an explicit mobile release
  decision; neither platform build number changes Rails versioning.
- `mobile/package.json` currently mirrors `1.0.0`, but no synchronization,
  mismatch guard, or consumed-number receipt exists yet. Before a distributed
  artifact, one mobile version authority and deterministic checks must cover
  Expo config, package metadata, and generated iOS/Android values.
- Rails deploys, tenant onboarding, content changes, and backend migrations do
  not bump TempleMate automatically. Conversely, an Expo version bump does not
  rename or version the Rails application.

DojoMate-Expo is evidence for the centralized version-source and native-sync
pattern, not a source for TempleMate's current number. Its
`scripts/sync-version.mjs` propagates a central version configuration into
package metadata and generated iOS/Android version fields; its profile prebuild
and EAS pre-install hooks run synchronization again. It does not store the
three version numbers in `eas.json`; that file selects local/remote authority
and build-profile behavior. Wenfu currently has no equivalent sync or verify
script. TempleMate begins at `1.0.0` even when the mature reference app has
advanced to a later release.

Official platform evidence for this policy:

- Android requires successive Play releases to use a greater `versionCode` and
  does not allow reuse of a code already used in the Play Store:
  `https://developer.android.com/studio/publish/versioning`
- Google documents Internal App Sharing as the exception where version codes
  may be reused:
  `https://support.google.com/googleplay/android-developer/answer/9844679`
- Apple documents that iOS apps may reset the build number to `1` for a new app
  version because App Store Connect identifies the unique version/build pair:
  `https://developer.apple.com/documentation/xcode/setting-the-next-build-number-for-xcode-cloud-builds`
- Expo documents local version authority and warns that app config and native
  values must stay synchronized:
  `https://docs.expo.dev/build-reference/app-versions/`

### Android API 36 disposition

Google Play requires new phone/tablet apps and app updates submitted from
2026-08-31 to target Android 16 / API level 36 or higher:

- `https://support.google.com/googleplay/android-developer/answer/11926878`

Expo documents that SDK 54 with React Native 0.81 targets Android 16 / API 36:

- `https://expo.dev/changelog/sdk-54`

Wenfu declares Expo `~54.0.25`; its lockfile resolves Expo `54.0.30` and React
Native `0.81.5`. No target-SDK override or checked-in generated Android project
was found. Therefore:

- source alignment: **API 36 capable**;
- dependency migration solely for API 36: **not currently required**;
- generated native target: **not yet observed**;
- built AAB target: **not yet proven**;
- Play compliance/release: **not yet proven or authorized**.

The First Objective must inspect the generated project and development-client
artifact for compile SDK 36 and target SDK 36, then exercise Android 16
behavior. A later AAB must prove the target again under separate release
authority. Do not upgrade packages merely to imitate DojoMate's exact patch
versions; use Expo compatibility evidence at implementation time.

## V1 Product-Scope Gate

Planning must record one accepted V1 scope card before any real product or
backend implementation packet. The dummy-data development-client milestone is
the sole accepted precursor to this gate.

### Required scope-card fields

| Field | Required decision |
| --- | --- |
| Primary user | Which ordinary account user is V1 for? |
| Trigger | What causes that user to open the app? |
| Primary job | What one task are they trying to complete? |
| Success outcome | What observable result means the task is complete? |
| Essential reads | Which existing web/public data is required? |
| Essential writes | Which existing web-authorized mutations, if any, are required? |
| Identity need | Is personalized data required? If yes, what minimum accepted login/session path supports it? |
| Temple context | How does one-temple QR/direct-link binding validate and persist the tenant origin, and how does rare switching clear prior tenant state? |
| Provider need | Does the primary job actually require OAuth, payment, camera, push, or another provider? |
| Connectivity | Is online-only acceptable for V1? What failure/retry state is required? |
| Languages | Which existing account locales must ship? |
| Completion evidence | What local tests and device behavior prove the job? |
| Explicit deferrals | Which nearby web features are intentionally excluded? |

An unanswered field is not permission to choose a conventional default. If it
changes product behavior or scope, it remains a Planning decision.

## Existing Account Surface As A Selection Menu

The following groups come only from the existing web account product. They are
possible ingredients, not an accepted V1 backlog.

| Surface group | Existing account behavior | Dependencies introduced if selected |
| --- | --- | --- |
| Temple information | Events, services, gallery, contact temple | Public/account payload review; possibly no personalized session |
| Personal overview | Dashboard, registration history, certificates, payments | Native session, account bootstrap, account-only scoping, read APIs |
| Registration action | Create/update allowed registrations; self/dependent registrants | Session, dependent selection, lifecycle/validation APIs; payment only if required by the selected journey |
| Dependent management | Create/edit/update/delete dependents | Session, complete user-scoped CRUD contract, validation and audit parity |
| Profile/settings | Profile, locale/theme, password addition, linked identities | Session plus only the selected mutation contracts; OAuth only if identity management is selected |
| Privacy/support | Assistance/contact, privacy requests, account closure | Session or attribution as applicable; high-risk confirmation and credential cleanup for closure |

Selection rules:

- Do not select a whole row merely because one field is useful.
- Do not include a write action when the primary job needs only a read.
- Do not implement dependents CRUD merely because registration can reference a
  dependent; the accepted journey must determine whether selection of existing
  dependents is enough or management is required.
- Do not include payment merely because some registrations can be paid. The
  chosen journey must state whether completion includes checkout.
- Do not include OAuth merely because web supports it. The chosen identity
  path must justify it.
- Do not add notifications, background sync, offline mutation, analytics,
  sharing, or camera without explicit V1 need.

## Authentication Decision Gate

Authentication is a dependency, not the app's purpose.

- A V1 showing only existing public temple content may not require account
  authentication; if so, calling it an account app and its navigation boundary
  must still be reviewed.
- Any personalized account data or mutation requires an authenticated native
  account contract.
- Select only the login methods necessary for the accepted V1 journey and
  target users.
- Supporting a password session does not automatically require signup,
  password reset, Google, Apple, or identity linking in the same slice.
- If V1 allows account creation or exposes a provider login, the associated
  recovery, privacy, closure, store-policy, and deep-link obligations must be
  explicitly reviewed before release.
- Tokens must remain account-only. A dual-role user must not receive admin
  data or authority in Expo.

The readiness inventory establishes that no native session/refresh contract is
currently implemented. If the selected V1 job needs authentication, the exact
minimum session contract becomes the first implementation dependency.

## CRUD Decision Gate

CRUD is selected per user job and resource, not as one platform-wide goal.

For each selected resource, the accepted scope card must state:

- required reads;
- required creates;
- required updates;
- required deletes;
- web lifecycle states in which each action is allowed;
- validation and field-error behavior;
- tenant and ownership scope;
- duplicate, retry, and concurrent-submit behavior;
- audit and user-work protection requirements.

An operation absent from the web account surface remains absent from Expo. An
operation present on web but unnecessary for the V1 job remains deferred.

## Payment And OAuth Decision Gates

Payment and OAuth are separate optional slices.

### Payment enters V1 only when

- the selected primary job cannot be truthfully completed without checkout or
  payment status;
- the exact web-equivalent state machine and return behavior are accepted;
- native browser/deep-link handling is planned;
- local/stubbed evidence is sufficient for implementation acceptance; and
- provider/live/release actions remain separately gated.

Otherwise payment is deferred. No IAP or alternative provider behavior is
invented.

### OAuth enters V1 only when

- an accepted V1 user/login need requires it;
- native start, callback, state/nonce/PKCE, failure, linking, and recovery
  boundaries are accepted;
- no client secret is embedded in Expo source or public configuration; and
- provider configuration and live validation remain separately authorized.

Otherwise OAuth and identity linking are deferred.

## V1 Work Sequence

These are Planning phases. A later Control owns implementation packet details,
paths, commands, and the one-Implementer execution mechanism.

### First Objective — Dummy-data development client

- Reconcile only the scaffold/configuration needed to create a development
  client: `TempleMate (Dev)` launcher naming, DEV-badged launcher artwork,
  EAS/local profile consistency, config-plugin source, dependency
  compatibility, and placeholder/admin/tenant-branding residue.
- Establish `mobile/versioning.js` as the single mobile version authority and
  add deterministic DojoMate-style synchronization/verification for package
  metadata and generated native values. It must validate `eas.json` local
  authority/no-auto-increment policy without writing duplicate version numbers
  into `eas.json` or incrementing any value during a build.
- Add the smallest account-only shell and deterministic dummy fixtures needed
  for development-client validation.
- Keep dummy mode explicit, local, and impossible to confuse with real API
  success.
- Generate and inspect the Android development project under a bounded packet.
- Install and launch the development client, attach it to Metro, and exercise
  the implemented shell.
- Prove target SDK 36 from generated and installed development-client evidence.
- Do not generate an AAB.

Exit: an installable account-only development client runs with dummy data and
no backend/provider dependency; API 36 is observed; no release artifact or
product-scope claim follows.

### Product Scope Gate — Accept the V1 user job

- Choose the primary user, trigger, job, success outcome, and explicit
  deferrals.
- Select only the required account surface ingredients.
- Classify authentication, CRUD, OAuth, payment, privacy, and provider needs.
- Record the minimum end-to-end journey and negative boundary.

Exit: one implementable V1 journey exists; no screen or endpoint is included
without a direct role in that journey.

### Minimum server contract

- Define and implement only the APIs required by the accepted V1 journey.
- Reuse existing Rails forms, services, policies, serializers, and public
  endpoints where they already match the selected behavior.
- If authentication is required, implement the minimum complete session
  lifecycle needed for the selected journey rather than all future identity
  features.
- Prove ordinary-user and dual-role-user account-only scoping.

Exit: fixtures/request tests give the client stable selected-slice contracts;
unselected account APIs remain deferred.

### Native foundation for the selected journey

- Replace the placeholder with the smallest navigation and state structure
  needed by V1.
- Add only the selected API, auth, preferences, localization, and error
  foundations.
- Implement loading, empty, error, retry, validation, pending, and signed-out
  states that the accepted journey actually encounters.
- Borrow structural patterns from DojoMate only where Wenfu needs them.

Exit: the shell has no admin surface and no unused product navigation.

### Primary journey implementation

- Implement the accepted end-to-end account-user job.
- Match selected web behavior and server-owned rules.
- Add only supporting screens/actions required to reach the success outcome.
- Preserve user state safely across expected interruption/retry paths.

Exit: the success outcome and explicitly accepted failure cases pass locally.

### V1 conformance and Android 16 runtime gate

- Run selected Rails and mobile checks.
- Exercise the journey on an Android 16 / API 36 emulator or device.
- Verify edge-to-edge layout, system bars/insets, keyboard behavior, back
  navigation, app resume, links, permissions, and secure storage only where
  used by V1.
- Confirm unselected admin/provider/features are absent.

Exit: local source and runtime evidence support a V1 candidate. No store or
production claim follows.

### Separate candidate and release planning

- Define exact version/build identity, signing owner, EAS profile, runtime
  tenant-origin trust, selected TempleMate platform domain, pilot client-owned
  domain, artifact inspection, public privacy/help/support URLs, store
  metadata/privacy obligations, app links, test track, monitoring, rollback,
  and submission approval.
- Prove the accepted mobile version source, package/config/native consistency,
  the Android upload-consumption receipt and next-code rule, and the iOS
  version/build pair and reset rule independently of Rails release or
  deployment state.
- Build and inspect an AAB proving target SDK 36 only under that later
  authorized release packet.

Exit: outside this plan's current authority.

## DojoMate Reuse Boundary

DojoMate evidence is valuable for:

- startup and authenticated/signed-out state separation;
- focused navigation stacks;
- centralized API and token handling when authentication is selected;
- build-profile guardrails and environment isolation;
- dependency, Expo Doctor, autolinking, test, and artifact checks;
- Android 16 device validation and built-artifact inspection.

Do not copy:

- its account-role chooser, admin/staff/operations navigation, or permissions;
- its complete dependency set;
- its OAuth, payment, push, camera, offline, or monetization systems unless the
  accepted Wenfu V1 job independently requires that capability;
- its identifiers, endpoints, native config, credentials, or product copy.

## V1 Acceptance Criteria

The following criteria apply to the First Objective:

1. The existing Wenfu scaffold is used rather than replaced.
2. The result is an installable development client, not Expo Go and not an
   AAB/store artifact.
3. Its launcher name is `TempleMate (Dev)` and it uses DEV-badged app and
   adaptive icons; `竹南鎮聖福宮` is tenant data and is not used as the app name.
4. Its resolved Expo app version is `1.0.0` and no Rails version or deployment
   state contributes to that value.
5. The mobile version authority, package metadata, resolved Expo config, and
   generated native values agree; the sync/check mechanism does not write
   version numbers into `eas.json` or auto-increment them.
6. Its local development-client build does not increment or consume the
   Android Google Play version code or an iOS App Store Connect/TestFlight
   build pair.
7. It renders only an account-oriented technical shell using deterministic,
   visibly dummy data.
8. It makes no Rails/API, authentication, CRUD, OAuth, payment, provider, or
   real-data request.
9. Dummy mode is explicit and cannot silently act as a production fallback.
10. No admin UI, mode, data, capability, or identifier is shipped in the shell.
11. No credential or provider secret appears in source, public config, logs,
   fixtures, or screenshots.
12. Generated and installed Android evidence proves target SDK 36, and the
   implemented shell is exercised on Android 16 when the packet provides an
   available emulator/device.
13. Focused checks pass with exact evidence and final Git state is clean.
14. Acceptance authorizes no AAB, EAS cloud action, Play/store action,
    deployment, provider action, production data, or release promotion.

The following product-delivery criteria become applicable only after the
Product Scope Gate records the selected scope card:

1. One named account-user job and observable success outcome define V1.
2. Every shipped real screen, endpoint, dependency, permission, and provider
   flow is necessary for that job or a required safety/release obligation.
3. Selected features match existing web account rules and operations; features
   outside the selected slice are absent or explicitly deferred.
4. Expo exposes no admin UI, data, capability, preference, route, or mode.
5. Dual-role users remain account-scoped server-side.
6. Authentication, CRUD, OAuth, and payment are implemented only to the extent
   accepted by the V1 scope card.
7. Temple context is one active validated tenant origin at a time; switching
   cannot retain or disclose the prior tenant's session or cached data.
8. No QR/direct-link payload contains a user identifier, credential, session,
   bearer token, or other secret.
9. No credentials or provider secrets appear in source, public config, logs,
   fixtures, or screenshots.
10. Required loading/error/retry/interruption states for the selected journey
   are tested.
11. Generated Android configuration and the later release artifact each prove
   target SDK 36; the V1 journey is exercised on Android 16.
12. Required checks pass with exact evidence and final Git state is clean.
13. Local acceptance does not authorize deployment, providers, EAS cloud
    actions, store submission, production data, or release promotion.

## Explicitly Deferred Until The Product Scope Gate Selects Them

- full account-site parity;
- all-resource CRUD;
- signup and password recovery;
- Google or Apple OAuth and identity linking;
- registration checkout, payment history, or provider returns;
- dependents management;
- account closure, deletion/export requests, and their store-policy effects;
- push notifications, background work, broad offline caching, analytics,
  camera, media upload, sharing, gamification, IAP, and subscriptions;
- a global in-app temple directory or casual temple switcher;
- admin/internal/operations features;
- EAS production/store builds, signing, provider configuration, store
  records/submission, OTA, deployment, and production actions. Any EAS cloud
  development-client build also requires separate explicit external-action
  authority.

Deferral here is not a decision that these features never belong in the app.
It means their need must follow from an accepted user job rather than from the
existence of web code or a mature example app.

## Current Gate And Next Action

Current classification:
`v1_dummy_data_development_client_objective_accepted_not_dispatched`.

First blocker to First Objective implementation: the Director has selected the
objective but has not explicitly instructed Planning to dispatch
implementation. The build mechanism also remains Control-owned; EAS cloud use
would require separate external-action authority.

Next owner/action: the Director may authorize implementation of the First
Objective. Planning then records its criteria as immutable and sends the
bounded dummy-data development-client phase directly to the authoritative
Wenfu Control. The real account-user job remains a later Product Scope Gate
decision. Until implementation is explicitly authorized, Planning remains
authoritative idle with no active packet, callback, approval, or Control
dispatch.
