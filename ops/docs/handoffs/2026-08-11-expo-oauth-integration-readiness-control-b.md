# Expo OAuth integration readiness — Control B evidence report

Date: 2026-08-11

Packet: `2026-08-11-expo-oauth-integration-readiness-control-b`, corrected
attempt 4.  Accepted plan:
`ops/docs/plans/EXPO_OAUTH_INTEGRATION_READINESS_SCAN_PLAN.md` at
`4bb6010163bbbde329e4063fb49789da962ab193`.

This is a source and documentation readiness record only.  It neither accepts
an OAuth architecture nor authorizes source, provider, secret, build, device,
or deployment work.

## Executive finding

Wenfu has working Google and Apple web OAuth authority in Rails, including its
central-auth bridge, but the existing native account API has no OAuth start,
callback, transaction, or exchange route.  The SourceGrid central-auth source
already proves a tenant-authenticated start/exchange capability: exact
tenant-owned return-URL allowlisting, state/nonce issuance and consumption,
optional S256 PKCE validation, and one-time code consumption.  Wenfu's present
browser bridge instead keeps pending context in a browser Rails session and
creates a browser account or admin cookie; it cannot by itself return safely to
TempleMate and issue the existing account-only native session.  A later
accepted tenant/native-return contract must define how Wenfu reuses those
verified central-auth capabilities through an additive account-only Rails
adapter.  That adapter must bind the native transaction before server-side
verification and issue only the existing account-scoped JWT/rotating
refresh-session contract.  This report does not choose that implementation.

Komainu/TempleMate is the first SourceGrid native OAuth pattern.  No located
SourceGrid APK, demo client, Golden Template source, or DojoMate material is a
native OAuth prerequisite or implementation reference.

## Evidence inventory and limits

All facts below are classified as **observed** local source/test/history,
**documented** current official public documentation, **configured** source
configuration, or **unknown** when it needs a provider console, the
protected runtime evidence, or deployment-specific tenant registration.  No
provider console, login, authenticated session, artifact download, secret,
build, Metro, ADB, device, or runtime action was used.

| Root | Read-only evidence identity | Classification |
| --- | --- | --- |
| Wenfu isolated worktree | `codex/expo-oauth-readiness-official`, `4bb6010163bbbde329e4063fb49789da962ab193` | observed source/test/configuration |
| SourceGrid Labs | `agent/ph-sshs-r00a-acquisition-diagnosis`, `7e8be47cda0bd90cdeb8ee55b3b89a9b45c98f67`, clean status | observed central-auth source/test plus historical/demo context |
| Golden Template | `main`, `788dc00b976eb5ed8e1c00b0d3d48563fb386a5f`, clean status | stub/template context only |

The SourceGrid Labs history commit `852531f6` is a demo Expo admin-console
change; its current `mobile/app/lib/auth/client.js` performs email/password
JWT login/refresh/logout against demo endpoints, and
`mobile/app/screens/demo/DemoConsoleScreen.js` presents demo credentials.
Commit `4b477a0f` changed the app configuration and `ops/docs/COMMANDS.md` to
record an APK download link.  Its documentation records historical DevSSD APK
paths that are absent locally; no hosted or local APK was opened, downloaded,
installed, or inspected.  These are **email/JWT demo and historical APK-link
context**, not OAuth evidence.

Golden Template `mobile/App.js` labels OAuth as an authentication placeholder,
disables its action when no provider is configured, and logs a stub action when
it is.  Its `mobile/app/lib/auth/client.js` is email/password JWT helper code;
`mobile/app.config.js` merely derives an availability list from environment
variables.  It is an **OAuth availability/stub**, not a native OAuth flow.
Neither mobile/demo artifact is a prerequisite, and neither repository was
modified.

### Observed SourceGrid central-auth contract

The mature central-auth server is source evidence, not a native implementation
reference.  `rails/config/routes.rb` exposes `POST /oauth/start` and
`POST /oauth/token/exchange` at
`rails/app/controllers/auth_service/oauth_controller.rb`.  Its `start` action
authenticates an active tenant, accepts a supported provider and required
`return_url`, rejects a tenant-slug mismatch and a return URL absent from that
tenant's exact allowlist (`rails/app/models/auth_tenant.rb`), issues a nonce,
and binds tenant, return URL, nonce, plus an optional S256 PKCE challenge into
state.  It returns an authorization URL and records an audit event.  The
provider callback controller validates that state and the same allowlist,
consumes the nonce, and redirects the verified result as a short-lived one-time
code (`rails/app/controllers/auth_service/callbacks_controller.rb`; durable
one-time/expiry/tenant/return-URL/PKCE-consumption behavior is in
`rails/app/models/auth_code.rb` and `rails/app/models/auth_nonce.rb`).

`OAuthController#exchange` requires the same authenticated tenant, the one-time
code and the exact return URL; it atomically consumes the code, validates an
optional PKCE verifier, and returns normalized identity claims plus a
short-lived central token.  `rails/spec/requests/auth_service/oauth_flow_spec.rb`
proves successful Google and Apple start/exchange response shapes and rejection
of a non-allowlisted return URL.  The accompanying callback and model specs
cover nonce replay and one-time/PKCE consumption.  This report deliberately
does not copy test fixtures, credentials, token material, or raw responses.

The client-side bridge is separately observed in
`rails/app/controllers/auth/central_oauth_controller.rb`,
`rails/app/services/auth/central_oauth_client.rb`, and
`rails/spec/requests/auth/central_oauth_spec.rb`.  It invokes those two
central endpoints with server-held tenant credentials, uses a browser callback
URL, and establishes a browser account or admin session after the exchange.
The request spec proves the account bridge and rejects a protocol-relative
error return.  Therefore the endpoint schema and its state/nonce/PKCE and
allowlist responsibilities are observed.  Unknowns are only the particular
TempleMate tenant registration, approved native return value, deployed client
credentials/provider registrations, and any additional native-specific
contract accepted later.

## Current Wenfu web OAuth map

### Entry, start, callback, and destination

1. `rails/app/helpers/oauth_helper.rb` renders Google and Apple links on both
   account and admin login screens.  When all `AUTH_BASE_URL`, `AUTH_CLIENT_ID`,
   and `AUTH_CLIENT_SECRET` are present it targets
   `GET /auth/central/:provider/start`; otherwise it uses local OmniAuth only
   when that provider's own configured ID and secret are present.  Provider
   presentation is limited to Google and Apple in
   `OAuthHelper::PROVIDER_SPECS`.
2. `rails/config/routes.rb` maps the central start and `GET|POST /auth/callback`
   callback to `Auth::CentralOAuthController`; it separately maps legacy
   OmniAuth `GET|POST /auth/:provider/callback` and `/auth/failure` to
   `Auth::OmniauthController`.
3. `rails/app/controllers/auth/central_oauth_controller.rb#start` normalizes
   Google/Apple aliases, stores `surface`, tenant/temple slug, safe relative
   origin, link intent, optional post-sign-in setting, and a random nonce in
   the Rails cookie session.  It sends provider, server callback URL, tenant,
   and context to `Auth::CentralOAuthClient#start`, then redirects to the
   returned authorization URL.  `rails/app/services/auth/central_oauth_client.rb`
   calls the central service's `/oauth/start` and `/oauth/token/exchange` using
   HTTP Basic credentials from `AUTH_*`; client secrets stay server-side.
4. In `CentralOAuthController#callback`, a provider error returns to the stored
   safe relative origin/login.  Otherwise it sends `code`, `state`, normalized
   provider, `return_url`, and query to central auth's exchange endpoint.  It
   extracts provider, provider subject, email, verification status, and name
   from the response/claims/ID-token payload, normalizes Google to
   `google_oauth2`, resolves or links the identity, applies signup/terms
   metadata, logs an audit event, and redirects to account dashboard/settings,
   account profile completion, or admin dashboard as appropriate.
5. `rails/app/controllers/auth/omniauth_controller.rb` is the legacy direct
   equivalent: it resolves the OmniAuth hash, rejects a closed account, resets
   the browser session, sets the account-session key, and redirects to the
   OmniAuth origin or account dashboard.  `rails/config/initializers/omniauth.rb`
   and `rails/app/lib/app_constants/oauth.rb` show the direct Google/Apple
   provider env-key mapping.

The following focused tests observe this bridge without treating a stubbed
central client as live-provider proof:

- `rails/test/integration/account/oauth_identity_management_test.rb` covers
  Google and Apple link redirects/callbacks, conflict, profile completion,
  stale verified Google-subject replacement, unlink, last-method protection,
  and the linking feature flag.
- `rails/test/integration/account/account_closure_test.rb` proves a closed
  account cannot complete a central Apple OAuth login.
- `rails/test/services/auth/oauth_identity_resolver_test.rb` covers identity
  resolution and transactional Google-subject replacement/audit behavior.

### Identity, linking, closure, and account/admin scope

`rails/app/models/oauth_identity.rb` uniquely binds a provider subject and one
identity per provider to a `User`.  `rails/app/services/auth/oauth_identity_resolver.rb`
first resolves an exact subject, then handles the narrow verified-email Google
subject-replacement case transactionally, otherwise links a matching email or
creates an `oauth_seeded` user.  It persists credentials/metadata as returned
by the server; a native adapter must not expose those fields.

`rails/app/services/auth/oauth_identity_linker.rb` rejects an identity linked
to another user and rejects changing an already-linked provider subject.
`rails/app/services/auth/oauth_identity_unlinker.rb` prevents an
`oauth_seeded` user from removing its sole identity.  The web management routes
are in `rails/config/routes.rb`, the account controller is
`rails/app/controllers/account/oauth_identities_controller.rb`, and linking is
feature-flagged there.

`rails/app/models/user.rb#close_account!` closes the account, revokes refresh
tokens, marks push tokens inactive, and records revocation metadata on OAuth
identities.  Both web callback controllers reject a closed account.  These are
server facts, not evidence of provider-token revocation.

The account/admin separation is explicit:

- `CentralOAuthController#establish_session_for` treats `surface=admin` as a
  separate branch, requires `user.admin_account.active?`, and writes only the
  admin session and default admin temple.  The account branch writes only the
  account session and optional account temple.
- `rails/app/controllers/admin/base_controller.rb` requires an active admin
  account and selected allowed temple.  `rails/app/controllers/api/v1/account/native_base_controller.rb`
  deliberately does not inherit browser account/admin helpers and accepts only
  JWT `scope == "account"`.
- `rails/app/serializers/account/api/native_account_serializer.rb` omits admin
  account/role/provider data.  `rails/test/integration/account/api/native_sessions_test.rb`
  proves an `admin`-scoped JWT is rejected, and
  `rails/test/integration/account/api/native_account_contract_test.rb` asserts
  native payloads omit `admin_account` and roles.  `mobile/app/account/screen_model.js`
  has no `admin` screen and its test asserts that fact.

Thus a dual-role user may authenticate to the same `User`, but the later native
server contract must ignore any client-provided admin surface and mint only the
existing `scope: "account"` session.  No admin navigation, token, role,
temple-selection authority, or API route is in Expo scope.

## Current TempleMate state and precise gap

| Group | Evidence and classification | OAuth implication |
| --- | --- | --- |
| Already present | `mobile/app/real/adapter.js` uses `/api/v1/account/native` email signup/login, refresh, logout, recovery/reset, bootstrap and closure; `NativeSessionsController` and `NativeBaseController` issue/validate account JWT plus rotating, revocable refresh records. **observed** | Reuse the server-issued account session shape only after a successful native OAuth exchange. |
| Already present | `mobile/app/lib/auth/storage.js`, `mobile/app/real/storage.js`, and `mobile/app/core/storage_scope.js` store real sessions in Expo SecureStore under environment-and-tenant scoped keys and clear on invalid/replay/revocation/closure or tenant switch. **observed** | Reuse storage and clearing behavior; do not persist provider access, refresh, ID-token, raw code, verifier, state, or identity metadata beyond an active one-time transaction. |
| Already present | `mobile/app/real/config.js` permits real mode only for explicit localhost/loopback/`.test` origin and tenant; `mobile/app.config.js` defaults to offline dummy mode. **configured** | OAuth must be separately authorized for real dev/prod; the current adapter is expressly local/test only. |
| Already present | `mobile/app.config.js` defines scheme `templemate`, adds `expo-secure-store` and `expo-dev-client`, and selects the Komainu IDs from `mobile/app/lib/app_constants/project.js`: production `com.jimmy1768.komainu`, development `com.jimmy1768.komainu.dev`, on both iOS and Android. `mobile/eas.json` has only an internal APK development-client profile. **configured** | These public identifiers/scheme are inputs for later registration; no OAuth plugin/dependency/capability is configured. |
| Missing additive Rails work | `rails/config/routes.rb` exposes only email native endpoints. `CentralOAuthController` stores pending context in a browser Rails session and writes browser cookies; it has no native transaction, native callback acknowledgement, or account-JWT issuance route. The observed central service already owns tenant authentication, exact return-URL allowlisting, state/nonce, optional PKCE, and one-time-code exchange. **observed** | A later accepted account-only Wenfu adapter/transaction must reuse the verified central service only after its tenant/native-return contract is agreed; this scan does not decide whether that requires central-service source change. |
| Missing additive Expo work | `mobile/package.json` has neither `expo-auth-session`/`expo-crypto` nor `expo-apple-authentication`; `mobile/App.js` signed-out UI has email, signup, and recovery only; `mobile/app/lib/auth/client.js` is an explicit unsupported placeholder. **observed** | Add provider-choice UI, browser/native Apple driver, redirect handling, transaction state machine, server exchange call, and tests later. |
| External prerequisite | Actual Google client registrations, redirect allowlists, consent/verification state, Apple App-ID capability/signing/profile/grouping/private key, the TempleMate central-auth tenant registration and native return allowlist values, and any EAS/build/device validation were not accessed. **unknown** | These are external gates, not inferred configuration facts. |
| Deferred | Facebook, Expo admin behavior, shared OAuth package, release/store/production deployment, and provider-token revocation policy. **deferred** | Excluded from later first implementation packets unless separately planned. |

## Official native-mechanism evidence (read 2026-08-11)

- Expo's [Authentication guide](https://docs.expo.dev/guides/authentication/)
  documents `WebBrowser.maybeCompleteAuthSession`, `makeRedirectUri`,
  `useAuthRequest`, and development builds rather than Expo Go for OAuth
  redirects.  It says the authorization-code exchange holding a client secret
  belongs on a server and describes SecureStore for native auth results.
- The [Expo AuthSession reference](https://docs.expo.dev/versions/latest/sdk/auth-session/)
  documents browser-based auth, deep-link scheme configuration, auth request
  state/PKCE primitives, and the rule that secrets do not belong in the app.
  It names `expo-crypto` as AuthSession's peer dependency.  Package versions
  shown by the current “latest” page are not an Expo SDK 54 compatibility
  claim; a later packet must select SDK-54-compatible versions.
- The [Expo SecureStore reference](https://docs.expo.dev/versions/latest/sdk/securestore/)
  documents Android encrypted SharedPreferences/Keystore and iOS Keychain,
  including iOS persistence across reinstall with the same bundle ID.  This
  reinforces server revocation and scoped-clear requirements.
- The [Expo AppleAuthentication reference](https://docs.expo.dev/versions/latest/sdk/apple-authentication/)
  limits that library to iOS/tvOS, requires `ios.usesAppleSignIn`/the config
  plugin and a new binary for build-time config, documents explicit cancellation
  handling, Apple JWT signature verification, real-device limits, and credential
  state checking.  It is not an Android Apple solution.
- Google's [OAuth 2.0 for iOS & Desktop Apps](https://developers.google.com/identity/protocols/oauth2/native-app)
  says installed apps cannot keep secrets, use the system browser, require
  credentials, use a fresh high-entropy PKCE verifier/challenge per request
  (S256 recommended), and should validate `state`.  It records that Android
  custom URI schemes are no longer supported and mobile loopback redirects are
  deprecated; a later Google design must therefore verify the exact provider
  registration/redirect model rather than assume the present `templemate://`
  scheme is accepted by Google.  It also distinguishes short-lived provider
  tokens from app sessions and says refresh tokens must be stored securely.
- Apple's [About Sign in with Apple](https://developer.apple.com/help/account/capabilities/about-sign-in-with-apple),
  [Configure Sign in with Apple support](https://developer.apple.com/documentation/xcode/configuring-sign-in-with-apple),
  [Sign in with Apple REST API](https://developer.apple.com/documentation/signinwithapplerestapi?changes=__5),
  and [Token validation](https://developer.apple.com/documentation/SigninwithAppleRESTAPI/Generate-and-validate-tokens?changes=_3&language=objc)
  establish the App-ID capability/primary-or-grouped relationship, native
  iOS Authentication Services versus web/other-platform REST handling, and
  server ownership of the signed client-secret JWT/private key for grant-code
  validation.  The two detailed Apple API pages require JavaScript in the
  read-only renderer; their search-result summaries were used only for these
  high-level documented constraints, not for an implementation recipe.

## Google/Apple and development/production configuration matrix

| Dimension | Google | Apple | TempleMate boundary |
| --- | --- | --- | --- |
| Development iOS public identity | A later provider registration must use the observed development iOS bundle ID `com.jimmy1768.komainu.dev`; actual client ID is **unknown**. | App ID/capability/signing profile for `com.jimmy1768.komainu.dev` is **unknown**. | The bundle ID is public config; registration evidence is external. |
| Production iOS public identity | Separate registration/allowlist for `com.jimmy1768.komainu`; actual client ID is **unknown**. | App ID/capability/signing profile for `com.jimmy1768.komainu` is **unknown**. Apple primary/grouping choice is external. | Do not reuse a development registration by assumption. |
| Android public identity | Separate Android client/registration must be verified for `.dev` and production package IDs. Google documents Android custom-scheme limits. | `expo-apple-authentication` is iOS-only; Android requires a separately designed provider/web/REST route and verified redirect registration. | The observed `templemate` scheme is public but does not prove provider acceptance. |
| Redirects | Exact registered native/server redirect(s), browser return, and state binding are **unknown**. | Native iOS credential versus web/Android return handling are different; exact web Service ID/domain/return URLs are **unknown**. | Permit only server-owned allowlisted redirects; never accept arbitrary callback/origin supplied by the app. |
| Public client data | Platform client ID, issuer/discovery endpoints, requested identity scopes, redirect/scheme, package/bundle IDs. | Bundle/App or Service ID and public redirect/domain information. | May appear in reviewed app config only when verified; are not credentials. |
| Server-only data | Current bridge's `AUTH_CLIENT_SECRET` and direct `OAUTH_GOOGLE_CLIENT_SECRET`; any central provider credential. | `AUTH_CLIENT_SECRET`, direct Apple client secret, Apple private signing key and generated client-secret JWT. | `rails/app/lib/app_constants/oauth.rb` and `CentralOAuthClient` demonstrate the current server-only env boundary. Never ship these in Expo `extra`, source, logs, tests, or SecureStore. |

The Director-reported existence of a Komainu Google Cloud project is not a
source-observed client/allowlist configuration.  It remains an external
verification gate.

## Proposed later contract and state evidence (not an accepted design)

The plan's required evidence points to these bounded future work items:

1. **Rails-first contract packet.** Define an account-only Wenfu-native
   transaction that accepts a fixed provider, known Komainu environment/client
   identity, tenant slug, and approved native return target.  It must bind the
   native transaction to the observed central-auth tenant/start, state/nonce,
   optional PKCE, exact allowlisted return, and one-time exchange behavior;
   do not reuse the browser cookie session as native transaction authority.
   The later packet decides the minimum additive adapter/proxy boundary after
   verifying the registered tenant/native-return values.  It must retain
   central auth as provider-secret owner, apply the current
   resolver/linker/closed-account rules, and issue the existing native account
   serializer/JWT/refresh payload only.
2. **Rails tests before client integration.** Add request/service tests for
   allowlisted redirect rejection, state/nonce/verifier mismatch, expiry,
   replay/double callback, provider mismatch, cancel/denial/unavailable,
   malformed central response, central-exchange failure, closed user,
   first login/profile-required signal, existing email subject mapping,
   explicit signed-in linking conflict/already-linked/last-method outcomes,
   session revocation, tenant isolation, and dual-role account-only token
   issuance.  Tests must prove no provider credential, token, or admin data is
   returned or logged.
3. **Expo packet after Rails contract acceptance.** Introduce an isolated
   account authentication module (provider-independent transaction/session
   boundary plus Google browser and iOS Apple driver) rather than a shared
   SourceGrid package.  It must expose pending/opened/returned/exchanging/
   authenticated/cancelled/denied/failed/replay-invalid/closed/revoked states;
   dismiss/cancel the browser correctly; validate the expected transaction;
   then store only Wenfu's account session via the existing scoped storage.
   Account UI receives Google/Apple choices only and preserves no admin path.
4. **Native-config and client tests.** Assert chosen SDK-54-compatible
   dependency versions, scheme/redirect behavior, no secrets in `extra`, both
   Komainu ID variants, Apple iOS capability/plugin, Android Apple
   unavailability/fallback, transaction cleanup on cancellation/interruption,
   race/replay handling, restore/refresh/logout/closure/tenant-switch clearing,
   account-only navigation, and provider-response redaction.
5. **Integrated pre-provider gates.** Merge only compatible Rails/Expo
   contracts and tests, then verify static app configuration and development
   client binary requirement.  Expo documents that a changed scheme/config
   plugin requires a new native binary; `mobile/eas.json` currently provides
   only the development profile, so the appropriate later EAS profile and
   actual build authorization are **unknown** and must be separately approved.
6. **External/provider and device gates.** A separately authorized owner must
   verify Google registrations/redirects/scopes/consent state, Apple App IDs,
   capability/profile/grouping/key ownership and any Service ID/domain/return
   registration, the registered TempleMate central-auth tenant and native
   return allowlist value, and real-device behavior (not simulator-only Apple
   evidence).  No such action is authorized by this report.

For a later Komainu reference, retain only attributable Wenfu-local contracts,
state-transition tests, nonsecret config matrix, redaction tests, and operating
notes.  Do not extract a shared package or copy TempleMate account/tenant
behavior into another SourceGrid application before a separately accepted plan.

## Open decisions and gates

There is no blocker to this readiness report.  The first blocker to an OAuth
implementation is an accepted Rails native-OAuth transaction/exchange contract
with central-auth ownership and trusted native-return semantics.  The
central-auth endpoint schema, state/nonce/optional-PKCE responsibilities, and
per-tenant exact allowlist mechanism are observed above; the specific
TempleMate tenant registration, approved native return value, provider client
IDs, Apple grouping/capability/key state, Google registration/consent state,
development/production EAS profiles, and device evidence are intentionally
**unknown**.  They must not be guessed from the working web flow, historical
demos, or a current Expo configuration.

## Verification record

- Focused source inventory read: Wenfu routes/controllers/services/models/
  initializers/views/tests; TempleMate app/config/adapter/storage/tests;
  SourceGrid Labs central-auth controllers/services/models/request specs and
  Golden Template current source plus the two named SourceGrid history commits.
- Official pages actually read are linked above; access date is 2026-08-11.
- No test/build/runtime command was run because the immutable packet prohibits
  product execution; report-only static evidence was the authorized work.
- Closeout result: the report is the only isolated-worktree change (untracked
  until Control accepts it), isolated staging is empty, and report-only
  `git diff --check --no-index /dev/null <report>` emitted no whitespace error
  (its exit status `1` denotes the expected new-file diff).  A focused scan
  found no PEM block or assigned API key/client-secret/access-token/refresh-
  token/password value in this report and no `*.apk`, `*.aab`, or `*.ipa`
  beneath `mobile`.
- At closeout the canonical Wenfu worktree was clean with empty staging at
  `main` `58b03c6af26a6f7ec3329372c762ccd772743fa6`; it was inspected only and
  not changed.  The isolated branch remains
  `codex/expo-oauth-readiness-official` at the required base
  `4bb6010163bbbde329e4063fb49789da962ab193`, with staging empty.
- Corrected attempt 4 repaired the report's prior SourceGrid attribution:
  `AuthService::OAuthController` and `oauth_flow_spec` now anchor the observed
  tenant-authenticated start/exchange, exact return-URL allowlist,
  state/nonce, optional PKCE, and one-time-code evidence.  No product or
  sibling-repository file changed.
