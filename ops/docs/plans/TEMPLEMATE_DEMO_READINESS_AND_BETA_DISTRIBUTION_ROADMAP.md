# TempleMate Demo Readiness And Beta Distribution Roadmap

Status: accepted sequencing roadmap; no implementation or external action is
authorized by this document

Accepted: 2026-08-13

Owner: Wenfu Planning

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted planning baseline: canonical `main`
`1b2d7320a00351810cdfe1f5b2951543776c60b4`

## Objective

Prepare TempleMate for credible client demonstrations and staff beta testing
without requiring live Stripe platform billing or a live ECPay merchant
account. Stabilize the web demo first, reproduce that accepted behavior in the
development client, perform a deliberate visual UI refinement pass, and only
then create production-signed Apple and Google artifacts.

The demo must show a coherent assisted-onboarding product:

1. client prospects can use the account and admin web surfaces for the
   Shengfukung test tenant at `shengfukung.com.tw`;
2. staff can use a sideloaded Android build or TestFlight build of TempleMate;
3. a patron can select a temple-defined offering and create a registration;
4. when online payment is not configured, the registration remains pending and
   the product truthfully directs the patron to cash payment instead of showing
   a fake or broken checkout;
5. a web admin can record cash completion, settle the registration, and cause
   it to enter the accepted qualifying-registration accounting flow; and
6. no real money, provider credential, or merchant account is required for the
   demonstration.

## Recency And Evidence Discipline

This roadmap reconciles the complete accepted history rather than treating the
latest store discussion or an older plan title as the whole product state.

- Canonical source and accepted completion evidence outrank earlier roadmap
  projections and chat summaries.
- The local payment program through Phases 1–4 is complete at `33e59f7`; do not
  reopen qualifying-registration accounting, tenant provider isolation, the
  four-offering catalog, or simulated ECPay amount/callback behavior without
  changed evidence.
- The Expo account client already contains account-only navigation, email
  flows, Google/Apple native OAuth infrastructure, tenant QR camera support,
  dummy and local/test-real adapters, account CRUD, registration authority,
  and accepted physical-device functional evidence. This is not a greenfield
  app.
- The earlier plan named “Final UI Refinement” repaired transient-feedback and
  CameraView Back behavior. It explicitly did not redesign layouts, navigation,
  visual hierarchy, copy, or component styling. It is not evidence that the
  current vibe-coded layout has received the Director's intended visual pass.
- The installed `TempleMate (Dev)` APK and EAS development-client build are
  development artifacts. They are not production-signed App Store or Play
  artifacts and still depend on the accepted development-client runtime path.
- External store rules are temporally unstable. The policy facts recorded
  below were checked against official Apple and Google documentation on
  2026-08-13 and must be reverified immediately before the affected submission.

## Fixed Product Boundaries

### Tenant and product identity

- The app is **TempleMate**, not the name of one tenant.
- Internal project name: `komainu`.
- Production iOS bundle ID and Android package:
  `com.jimmy1768.komainu`.
- Development iOS bundle ID and Android package:
  `com.jimmy1768.komainu.dev`.
- `TempleMate (Dev)` remains visually distinguishable from `TempleMate`.
- `shengfukung.com.tw` is the permanent demo/sales-sandbox tenant hostname
  (decided 2026-08-28, see
  `ops/docs/reference/templemate_product_positioning.md`), not a stand-in
  for a future product origin. It is not the permanent client domain either.
  The actual temple expects to use its own client-owned `shengfukung.org.tw`
  after onboarding.
- No SourceGrid-owned TempleMate product domain will be purchased. Stable
  privacy, help, support, trust, and store-facing URLs live at
  `sourcegridlabs.com/templemate` instead.

### Web and native authority

- Rails remains authoritative for tenant, account, offering, registration,
  payment-state, cash-completion, and accounting semantics.
- Expo is account-only. Admin creation of offerings, cash settlement, payment
  administration, and all other admin functions remain web-only. No role
  switch or admin mode is added to TempleMate.
- Patrons select existing Temple-admin-defined offerings. Patrons cannot
  author, relabel, or price an offering.
- The Shengfukung demo catalog contains exactly four enabled offerings at
  `TWD 50`: `incense-donation`, `lamp-service`, `ghost-festival-table`, and
  `liberation-ritual`.
- The ambiguous fifth source row remains a Planning marker:
  **DISABLED — awaiting an updated temple DOCX**. This marker is not a runtime
  field, schema feature, or instruction to infer the missing temple decision.

### Payments

- Stripe platform billing is the temple paying SourceGrid. Its sandbox and live
  validation are deferred until the first real client.
- ECPay is the patron paying the temple. Live ECPay validation is deferred until
  a real client supplies a legally usable merchant account and authorizes the
  provider workflow.
- The fake provider remains local/test infrastructure. A client-facing demo
  must not claim that fake checkout is ECPay, show a fake provider action, or
  imply money moved.
- The accepted demo behavior is payment pending plus a truthful online-payment-
  unavailable/cash-payment path. Exact product copy is refined later; the
  semantic state is fixed here.
- Admin-recorded cash completion is real application state in the test tenant,
  but it is a demonstration record rather than evidence of money movement,
  settlement, tax, invoice, or regulatory finality.

### Version and build authority

- TempleMate marketing version remains `1.0.0` through this roadmap unless a
  separately accepted release decision changes it.
- Android version code remains `1` until the first AAB is uploaded to a Google
  Play release-library/track surface that consumes that code. After that
  successful upload, the next Android AAB must use `2`; do not increment merely
  for local development, an EAS build, or planning.
- The first TestFlight upload is `1.0.0 (1)`. Each later TestFlight upload for
  `1.0.0` uses the next build number. When the marketing version changes, the
  iOS build resets to `1`.
- Android and iOS build ledgers are independent. Rails releases never advance
  either mobile ledger.

## Phase Map

| Phase | Outcome | Dependency | Current state |
| --- | --- | --- | --- |
| 0 | Accepted local/web/native/payment foundations | Existing accepted work | Complete |
| 1 | Web demo flow is truthful and repeatable | Phase 0 | Complete |
| 2 | Development client matches the accepted web demo flow | Phase 1 | Complete |
| 3 | Director-led visual UI refinement on the development client | Phase 2 | Complete and sufficient for V1 |
| 4 | Real Google/Apple native OAuth readiness and runtime validation | Phase 3 | Next phase |
| 5 | Store, policy, signing, runtime, and artifact readiness | Phase 4 | Planned |
| 6 | Separately authorized production-identity beta artifacts and staff distribution | Phase 5 | Planned |
| 7 | Repeatable client-meeting demo and beta observation/acceptance | Phase 6 | Planned |
| Deferred | First-client Stripe/ECPay activation | Signed real client and provider prerequisites | Not a demo blocker |

## Phase 0 — Accepted Foundation

Phase 0 records what is already complete and must not be rebuilt because it is
near the latest discussion.

- Web account and admin namespaces exist and have accepted functional history.
- Native Rails account JSON/email/OAuth contracts and the Expo account-only
  client are integrated.
- Expo SDK 54, Android compile/target API 36, camera, OAuth, secure storage,
  EAS project linkage, Komainu identifiers, and the development-client build are
  present.
- Dummy device validation covers account navigation, profile/dependent work,
  four-offering registration selection and mutation, read-only paid state,
  tenant QR binding/switching, Google/Apple dummy OAuth, locale/theme, privacy,
  assistance/contact, and cleanup.
- The four Shengfukung offerings are controlled at `TWD 50` each.
- Local payment Phases 1–4 cover qualifying accounting, tenant-scoped provider
  selection, fake-provider state transitions, simulated ECPay amount/signature
  boundaries, cash completion, failure/cancellation, refund rejection and full
  correction, callback/webhook idempotency, and tenant isolation.

Exit: already accepted. Phase 0 grants no production, provider, store, or
deployment authority.

## Phase 1 — Web Demo Flow

Make `shengfukung.com.tw` a truthful, repeatable meeting environment before
changing the native presentation.

Required behavior:

1. Account and admin authentication paths required for the meeting are working
   on the exact deployed demo target. Apple account-resolution rollout remains
   its own critical web track and must be truthfully classified before Apple is
   offered in a demonstration.
2. The account surface lists only the four accepted temple-defined offerings
   with authoritative `NT$50` prices.
3. A patron can create a registration for self or an owned dependent without
   entering offering identity or price authority.
4. With no live ECPay configuration, the registration becomes payment pending,
   shows that online payment is not currently available, offers cash/payment-
   at-temple guidance, and exposes no active checkout/retry control.
5. The client-visible experience must not say or imply that the fake adapter is
   ECPay or a live payment service.
6. An authorized web admin can record cash completion exactly once. The
   registration and payment presentation update consistently, and the accepted
   qualifying-registration accounting includes it using the existing
   Asia/Taipei qualification semantics.
7. Failure, duplicate action, refresh, and navigation do not create duplicate
   payments, registrations, audit rows, or accounting usage.
8. A documented meeting reset/setup method returns the test tenant to an
   attributable demonstration baseline without deleting unrelated user work.

Implementation planning must resolve the current source mismatch in which the
Shengfukung configuration selects the fake patron provider and the pending web
view normally renders checkout. The accepted semantic result is cash-only/
online-unavailable presentation; the later Control owns the narrow mechanism
and regression evidence.

Exit evidence:

- exact local request/service tests for unavailable-online-payment and cash
  completion/accounting;
- account/admin browser evidence on an accepted target under a separate
  deployment/runtime packet;
- no provider call or credential access;
- clean, attributable source and test/demo data state.

## Phase 2 — Development-Client Demo Parity

This is the newly explicit phase. Do not begin holistic UI styling immediately
after the web fix. First make the existing development client reproduce the
accepted Phase 1 product behavior.

Required behavior:

1. The account-only Discover/registration journey presents the same four
   temple-defined offerings and authoritative `NT$50` prices.
2. Self and owned-dependent registrations work through the accepted offering
   selection and metadata boundaries.
3. A payment-required registration stops at a clear pending/cash-only state.
   There is no checkout, provider browser, status poller, retry button, ECPay
   claim, or payment mutation.
4. A paid/cash-settled registration may be shown read-only. In deterministic
   dummy mode this is explicitly fixture data; it is not provider or settlement
   evidence.
5. No admin action is added. Cash settlement continues to be demonstrated on
   web; TempleMate only presents the account-owned result.
6. Existing account CRUD, email/OAuth, tenant QR binding, locale/theme,
   assistance/contact, privacy/closure, and cleanup behavior remain functional.
7. Dummy mode remains visibly network-free and identified as demo data. Real
   mode never falls back to dummy after an API error.

The minimum beta-demo boundary is a self-contained, clearly labeled dummy
journey plus the separate persisted web demonstration. It does not claim that a
dummy mobile registration appears in web admin. Connecting a distribution
build to the deployed test tenant is a later explicit runtime decision and
requires a trusted production origin, deployed API/OAuth readiness, and safe
configuration; it is not silently inferred from the existence of the real
local/test adapter.

Exit evidence:

- deterministic mobile tests and source guardrails;
- physical development-client validation using the accepted USB/Metro method;
- the complete four-offering, pending/cash-only, and settled-read-only journey;
- no native rebuild unless Phase 2 actually changes native dependencies or
  configuration.

## Phase 3 — True Visual UI Refinement

After functional parity is stable, perform the Director-led design pass on the
development client. This is the first phase that treats the current layout as
vibe-coded and intentionally refines it as a product surface.

Scope:

- information architecture and screen hierarchy within the existing
  account-only feature inventory;
- typography, spacing, color, cards, forms, buttons, navigation, feedback,
  loading, empty, error, confirmation, and read-only payment states;
- consistent temple/offering/registration presentation across Traditional
  Chinese and English, light and dark modes;
- keyboard behavior, safe areas, touch targets, dynamic text, contrast,
  screen-reader labeling, camera surface, and Android/iOS platform conventions;
- visual distinction between demo data and real persisted state; and
- Director review on physical devices at representative screen sizes.

Explicit exclusions:

- no new product feature, admin mode, offering authority, provider checkout,
  analytics, push notification, gamification, or broad offline system;
- no premature screenshot generation from layouts that have not been accepted;
- no version or build-number increment merely for iterative UI work.

Exit: the Director accepts the visual system and the complete meeting journey
on the development client. Remaining issues are recorded by screen/state and
severity; there is no unresolved critical render, navigation, data-authority,
or accessibility failure.

## Phase 4 — Real Google/Apple Native OAuth Readiness And Runtime Validation

Phase 4 begins with a read-only readiness scan, followed only by separately
accepted provider, deployment, and device-validation packets. Current evidence
proves the Rails/native OAuth source contracts, provider-independent transaction
handling, deterministic dummy Google/Apple behavior, and a local/test-only real
adapter. It does not prove real mobile Google or Apple provider behavior,
production account resolution, or production distribution configuration.

The readiness scan must establish rather than infer the exact Rails/Central Auth
deployment and account-resolution state; production and development identifiers,
native scheme/return URL, API/trust origin, runtime mode, EAS profile, and
provider-registration state; which console or deployment actions need separate
authority; and a sanitized physical-device matrix for success, cancellation or
denial, browser interruption/return, repeat sign-in, session restoration, and
safe unmatched-account/account-resolution behavior. It must also freeze cleanup,
privacy, account, stop, and production-data boundaries.

Web OAuth and dummy OAuth are not evidence of real native OAuth. This phase
does not delete, merge, relink, or otherwise remediate user 22; the accepted
Apple account-resolution rollout and historical recovery remain separate
Control A work.

Exit: the real Google/Apple native readiness and device-validation gate is
accepted. It does not authorize an artifact, upload, or public release.

## Phase 5 — Distribution Readiness

Only after Phase 4 acceptance, prepare the release surfaces. This phase may
create plans and configuration but does not itself authorize artifact upload or
public release.

Required closure:

1. Select and purchase the stable TempleMate product domain when needed, then
   publish stable privacy, help/support, account-deletion, and store-facing
   URLs. Do not use the future client-owned `shengfukung.org.tw` as the
   TempleMate product origin.
2. Prepare store descriptions, category, keywords, localized metadata,
   screenshots from the accepted UI, support contact, review notes, tester
   instructions, and a truthful explanation of demo/cash-only behavior.
3. Complete Apple App Privacy and Google Play Data safety declarations from an
   exact source/data-flow inventory, including account data, OAuth, camera QR
   access, diagnostics if any, deletion, and absence of payment-card handling.
4. Create/verify the Apple App Store Connect record and Google Play app for
   `com.jimmy1768.komainu`, without changing the accepted public product name.
5. Define production EAS profiles for iOS App Store/TestFlight and Android AAB.
   The current `eas.json` contains only the internal development APK profile,
   and the current verification guard intentionally rejects release profiles;
   both require a reviewed release-phase correction rather than an ad hoc build
   command.
6. Verify signing ownership, export compliance, camera permission copy, OAuth
   callback/configuration, runtime mode, API/trust origin, environment
   isolation, exclusion of the development launcher/debug surface from release
   artifacts, and absence of secrets in public Expo config or artifacts.
7. Decide and record the exact beta runtime: clearly labeled self-contained
   demo mode, or an explicitly validated test-tenant connection. No production
   artifact may accidentally inherit a localhost origin or development-only
   contract.
8. Add deterministic version/build synchronization and a two-platform upload
   ledger without automatic increments.
9. Reverify current official Apple and Google submission/testing rules at the
   time of execution.

Exit: source is release-configured and verified, store records and stable
public documentation exist, exact build/upload plans are accepted, and no
artifact has yet consumed Android or iOS build `1`.

## Phase 6 — Production-Identity Artifacts And Staff Beta

“Production artifact” here means a production-identity, production-signed iOS
archive or Android AAB. It does not mean public production release, live
provider activation, or a claim that the beta is ready for general customers.

### Apple

- Build and upload TempleMate `1.0.0 (1)` to App Store Connect/TestFlight under
  `com.jimmy1768.komainu`.
- Staff who are not App Store Connect users are external testers. External
  testing requires TestFlight test information and the first external build is
  subject to TestFlight App Review. Official reference:
  <https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview>.
- Later uploads within `1.0.0` increment only the iOS build number: `(2)`,
  `(3)`, and so on.

### Google Play AAB

- Build and upload TempleMate `1.0.0`, Android version code `1`, as an AAB to
  the selected closed-testing track under `com.jimmy1768.komainu`.
- Once that AAB is accepted into the Play upload surface, code `1` is consumed;
  the next AAB uses code `2`.
- The selected closed-testing track, tester requirements, eligibility, and
  submission rules are temporally unstable. Reverify them from current official
  Apple and Google sources and the applicable console at execution time; do not
  promote historical tester counts, durations, or chat guidance into authority.

### Optional Android APK

- An Android APK variant is a distinct future packet, not a fallback implicit in
  the Play AAB. Its packet must state the intended channel, runtime and
  provider/network constraints, signing owner, update path, and separation from
  the Play artifact.

### Shared upload boundary

- Each build and upload requires a separate exact Control packet naming source
  commit, platform, profile, identifier, version/build, artifact handling,
  signing owner, rollback/stop conditions, and sanitized external receipt.
- Do not upload both platforms merely because one succeeded.
- Failed/rejected uploads are reconciled before retry; build numbers are not
  blindly advanced.
- No public App Store release, Google production-track release, staged rollout,
  OTA update, or provider activation is authorized by beta acceptance.

Exit: staff can install the production-identity beta through TestFlight and/or
Google closed testing, the build ledgers match actual upload receipts, and
critical beta issues have an attributable correction path.

## Phase 7 — Repeatable Client-Meeting Demo And Beta Acceptance

Prove the complete sales demonstration as an operating procedure rather than a
collection of individually working screens.

Meeting journey:

1. show the public test-temple page and account sign-in;
2. show the four offerings and create a patron registration;
3. show payment pending with truthful online-payment-unavailable/cash guidance;
4. switch to web admin and record cash completion;
5. show the settled registration and its accepted accounting inclusion;
6. show TempleMate account features on the staff beta, including temple
   binding, account CRUD, offering selection, registration, pending/cash-only
   presentation, and read-only settled example; and
7. restore the demo baseline without deleting unrelated user or admin work.

Exit: the journey is rehearsed on the exact meeting targets, has an owner and
reset procedure, and contains no fake provider claim, secret, live charge, or
manual database repair.

## Deferred First-Client Activation

The following work begins only after a real client agrees to onboard and the
app/demo evidence is sufficient for that engagement:

- Stripe platform-billing sandbox setup and test lifecycle, followed by a
  separately authorized live billing rollout;
- client-owned ECPay merchant onboarding, credential injection, callback and
  refund validation, low-value live test, monitoring, and rollback;
- client-owned domain, production tenant deployment, production data, and
  live provider operations; and
- any native payment checkout/return/status surface required after the live
  web provider contract is accepted.

These are not blockers to Phases 1–7. Local fake/simulated evidence remains
engineering evidence only and is never reclassified as provider validation.

## Sequencing And Control Ownership

- Phases 1–3 are complete historical gates; their accepted evidence is retained.
- Phase 4 is next and must close real Google/Apple native OAuth readiness and
  device validation before distribution readiness is claimed.
- Phase 5 decides and verifies release configuration; it does not build or
  upload.
- Phase 6 keeps TestFlight IPA, Play AAB, and optional Android APK authorities
  separate. A successful build is not an upload and a beta upload is not a
  public release.
- Phase 7 consumes accepted beta artifacts and does not authorize public release.
- Each implementation, deployment, provider, store-record, build, upload, and
  runtime-validation action requires its own committed accepted plan and direct
  Planning-to-Control dispatch.

## Current Gate

Phases 1–3 are complete. Current next action: Planning authors the separate
Phase 4 real Google/Apple native OAuth read-only readiness-scan plan through
Control B, sequenced with the separate Control A Apple account-resolution
rollout state. It does not authorize provider, account, deployment, build,
artifact, upload, or release action.
