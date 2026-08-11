# Expo V1 Development-Client UI Refinement Plan

Status: Director-amended TempleMate `1.0.0` UI-refinement phase; Control B
candidate complete, direct terminal delivery and Planning acceptance pending

Created: 2026-08-11

Owner: Wenfu Planning

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Canonical input: integrated `main` at the commit containing this plan, with
account-native integration baseline
`6cab3f1b52ebaeaf68667f19a3c804f8d9c43079`

Mature read-only reference:
`/Users/jimmy1768/Projects/DojoMate-Expo`

## Objective

Refine the integrated account-only TempleMate UI while running the already
installed Expo development client on an attached Android device, using
deterministic dummy data for safe and repeatable visual interaction.

Track B and the integration phase proved source, build, and contract behavior;
this phase uses the native runtime to expose layout, insets, keyboard,
back-navigation, theme, localization, and interaction defects that static
checks cannot show. UI iteration runs JavaScript through Metro against the
compatible installed client. It does not imply a fresh native build.

The phase refines the accepted screens and flows. It does not choose new
features, redesign Rails behavior, add admin functions, or begin release work.

## Current Evidence

- Canonical `main` is clean and contains the accepted Track A, Track B, and
  real-adapter integration ancestry.
- The current account client is functional, but its presentation is still
  concentrated in `mobile/App.js`, uses mixed hard-coded and localized copy,
  applies dark colors incompletely, and exposes a horizontally scrolling
  account menu.
- Generated TempleMate theme authority already exists in
  `mobile/theme/tokens.js`; account display-mode and mobile-theme contracts
  already exist in Rails and the native adapter.
- DojoMate supplies mature structural evidence for native screen boundaries,
  stack behavior, shared form primitives, safe areas, loading surfaces, and
  device-oriented review. Its roles, product copy, dependencies, colors,
  OAuth, payments, push, and admin/operations surfaces are not TempleMate
  authority.
- Pixel 8 serial `39011FDJH00FQ8` has the earlier
  `tw.com.templemate.dev` development client, version `1.0.0`, version code
  `1`, target SDK 36 installed. The Director rejected that Taiwan-prefixed
  identifier because TempleMate is a SourceGrid product and SourceGrid is a
  Singapore company. The installed binary may remain as historical UI-runtime
  evidence, but its identifier is not accepted product or future-build
  authority.
- Control B's isolated candidate branch
  `codex/expo-v1-dev-client-ui-refinement` contains the UI refinement and
  pinned project-local `expo-doctor@1.20.1`; its direct immutable terminal
  delivery to Planning is still pending.
- The Director rejected routine local native builds for this workflow because
  they consume substantial local disk and the compatible client is already
  installed. Planning permanently removed the two confirmed disposable local
  Android build trees after verifying the installed package. No branch source
  or installed device package was removed.

## Native Build And Artifact Policy — Director Amendment

The original plan's permission to create a local debug rebuild without a
specific reason is superseded.

DojoMate's mature policy is the reference: its ordinary build scripts invoke
EAS cloud, its local variants are explicitly named `build:local:*`, and
`docs/commands.md`, `docs/reference/ota-channel-workflow.md`, and
`docs/operator/README.md` reserve local builds for an explicit Director/owner
request or local native-build debugging.

TempleMate adopts the same boundary:

- reuse a compatible installed development client for normal UI work and load
  JavaScript from Metro;
- do not run Expo prebuild, Gradle assembly, `expo run:android`, or another
  local native artifact path merely to start or re-verify UI work;
- when a native dependency or native configuration change genuinely requires
  a new binary, EAS cloud is the default build mechanism;
- an EAS build remains an external action and requires a separately accepted
  packet for the exact profile and artifact; this amendment does not launch
  one;
- a local native build requires either an explicit Director request or a
  recorded, evidence-backed local native-build debugging reason accepted
  before the build starts; low-disk preflight and exact cleanup ownership are
  required;
- after installation, any local APK and generated native build directory are
  deleted unless the Director explicitly requests retention.

## Native Application Identifier Authority — Director Amendment

SourceGrid's existing mobile project authority uses the owned
`sourcegridlabs.com` reverse-domain prefix `com.sourcegridlabs`. TempleMate
therefore uses product-owned identifiers, independent of any temple tenant or
tenant country:

- production iOS bundle identifier and Android application ID:
  `com.sourcegridlabs.templemate`;
- development-client iOS bundle identifier and Android application ID:
  `com.sourcegridlabs.templemate.dev`.

No `tw.*`, `shengfukung.*`, temple-domain, or tenant-name identifier is
accepted. The application config and its source/config tests must express the
development/production split deterministically. This source correction does
not authorize building, installing, or replacing a native binary during this
plans/roadmap run. The currently installed legacy-ID development client is not
release evidence.

## Control Ownership

Control B owns one isolated `codex/`-prefixed branch/worktree from the
canonical plan commit, one immutable implementation packet, one ephemeral
Implementer, independent device/conformance review, acceptance, and local
integration.

Control B may edit the bounded `mobile/` presentation, component, theme,
localization, test, package, and development-script paths selected in its
packet. Rails, Vue, deployment, provider, production, release, and Planning
paths are excluded from Implementer ownership.

Control sends Planning no intermediate status. It returns exactly one terminal
packet after an accepted outcome, a true planning gap, a Director authority
decision, or no evidence-backed direct repair remains.

## Reproducible Expo Doctor Installation

Install `expo-doctor` as a pinned project-local development dependency at
version `1.20.1`, the exact cached version that passed 18/18 checks against the
integrated Expo 54 project and whose Node engine accepts the observed Node
`20.20.2` runtime.

Required result:

- `mobile/package.json` records `expo-doctor` in `devDependencies`, not runtime
  `dependencies`;
- `mobile/yarn.lock` records the exact resolved package and integrity;
- a stable `yarn doctor` script invokes the project-local binary without
  `npx`, global installation, or an implicit download;
- a clean/frozen install makes the command available in every worktree;
- `EXPO_OFFLINE=1 CI=1 yarn doctor` passes against the final candidate.

DojoMate currently configures Doctor checks but invokes the tool through
`npx`; it does not pin the CLI. TempleMate intentionally differs here because
the missing per-worktree executable blocked the preceding integration review.
Do not copy DojoMate Doctor exclusions unless a current TempleMate failure
provides direct evidence and the exclusion preserves truthful coverage.

The Director explicitly authorizes fetching only `expo-doctor@1.20.1` from the
package registry if the existing local cache cannot complete the pinned
development-dependency installation. This authority covers the package and
normal registry metadata/integrity resolution only. It does not authorize
broad dependency upgrades, Expo SDK changes, unrelated packages, global
installation, telemetry, EAS/cloud action, or provider access.

## UI Refinement Boundary

### Preserve product behavior

- Keep every integrated non-payment, non-OAuth account screen and operation.
- Keep dummy mode as the explicit device-refinement mode: deterministic,
  resettable, visibly non-production, and network-free.
- Keep the real adapter and its contract tests intact; real-mode failures never
  fall back to dummy data.
- Keep TempleMate account-only. No admin navigation, role/mode switch, guest
  list, staff surface, or privileged dual-role presentation may appear.
- Paid dummy registrations remain read-only presentation. No payment action or
  lifecycle is added.

### Refine native presentation

- Separate reusable native primitives and screen presentation where that
  improves clarity and testability; do not preserve the monolithic file shape
  merely because it was sufficient for the scaffold.
- Use the generated TempleMate tokens and accepted account/mobile preference
  contracts as color/theme authority. Light and dark account modes must apply
  coherently to backgrounds, raised surfaces, cards, inputs, text, borders,
  notices, errors, and system bars.
- Use existing TempleMate assets and identity. Do not name the app or chrome
  after the test tenant, and do not invent a new logo, icon system, illustration
  library, or tenant brand.
- Apply one consistent typography, spacing, radius, card, form, button, status,
  header, and navigation hierarchy across signed-out and signed-in screens.
- Replace mixed hard-coded bilingual labels with complete `zh-TW` and English
  copy drawn from the accepted account concepts. Dummy-mode disclosure and
  fixture credentials remain visibly test-only.
- Keep all current account destinations reachable with clear active state and
  predictable native back behavior. The exact navigation presentation is a
  Control-owned implementation detail; it must remain account-only and usable
  without a horizontally clipped primary action.
- Refine loading, empty, validation, pending, success, error/retry,
  confirmation, read-only-paid, binding-failed, and tenant-switch states that
  already exist.
- Ensure fields, buttons, destructive confirmations, lists, and cards remain
  usable with the Android keyboard, font scaling, safe areas, edge-to-edge
  system bars, and ordinary portrait viewport.
- Preserve reasonable accessibility labels/roles, visible focus/state cues,
  contrast, and touch targets for the refined controls.

No new runtime UI/navigation dependency is authorized by default. Control may
reuse DojoMate's structural patterns with React Native and the dependencies
already present. If a new runtime package becomes genuinely necessary, that is
a planning gap rather than implied permission.

## Development-Client Device Authority

Control B was authorized to perform the following local device actions only on
the exact attached Android target that passed its recorded preflight:

- inspect serial, model, OS/API, authorization state, storage availability, and
  current legacy development-client package state;
- verify the installed legacy package only when attributing the completed UI
  runtime evidence; a corrected-ID binary build or installation requires the
  separate build authority above;
- create only the ADB reverse mappings required for the local Metro development
  session;
- start local Metro in explicit dummy/development mode, launch TempleMate
  `(Dev)`, reload it during refinement, and inspect app-scoped logs;
- capture non-secret dummy-mode screenshots needed for visual review;
- leave the development client installed for continued local V1 work.

Android 17/API 37 on the observed Pixel is compatible runtime evidence for an
app targeting API 36. The device does not need to run API 36. Target SDK 36
remains a build/configuration criterion.

Do not inspect unrelated device data, uninstall or alter unrelated packages,
use real credentials, contact a live API, or broaden device mutation. A changed
serial or ambiguous target requires Control to stop before installation and
return the exact evidence.

## Required Device Journey

Using dummy mode on the installed development client, Control exercises and
visually reviews at minimum:

1. startup and signed-out login, signup, and recovery states;
2. dummy sign-in and account home/temple connection presentation;
3. profile name edit;
4. dependent create, edit, and delete;
5. registration create/edit plus read-only paid fixture presentation;
6. events, services, gallery, and certificate presentation;
7. assistance, contact, preferences, privacy, closure confirmation, and dummy
   reset;
8. tenant binding failure and confirmed switch cleanup;
9. Traditional Chinese and English;
10. light and dark account modes;
11. keyboard open/dismiss, Android back, app background/resume, and a relaunch
    while Metro is connected.

Representative screenshots must make the major visual states reviewable, but
must contain only deterministic dummy data. Control owns their local evidence
location and does not add screenshots to product assets unless the plan's UI
implementation itself requires an existing approved asset.

## Required Checks

Control records exact commands and results for:

- clean/frozen dependency installation and the pinned project-local Doctor
  executable;
- `EXPO_OFFLINE=1 CI=1 yarn doctor`;
- all mobile tests, source lint, version/API 36 verification, and any focused
  presentation/state tests added by this phase;
- current public Expo development config confirming `TempleMate (Dev)`, Expo
  54, version `1.0.0`, Android/iOS build values `1`, development-client plugin,
  target/compile SDK 36, and development identifier
  `com.sourcegridlabs.templemate.dev`;
- current public Expo production config confirming product identifier
  `com.sourcegridlabs.templemate`, without building a production artifact;
- installed package identity/version and exact ADB launch target; no native
  build evidence is required when the compatible installed client is reused;
- Metro connection plus completion of the required dummy journey;
- app-scoped crash/error review and representative dummy screenshots;
- regression proof that the real adapter contract, dummy no-network boundary,
  account-only exclusions, and version/build rules remain intact;
- `git diff --check`, clean final branch/canonical state, empty staging, and
  exact commit ancestry.

Control may run the focused Rails native-account regression suite if mobile
changes touch shared contract expectations. It may not change Rails under this
phase.

## Immutable Acceptance Criteria

1. The installed real TempleMate development client is launched on the exact
   preflighted Android device and connects to local Metro in explicit dummy
   mode without an unnecessary native rebuild.
2. The required dummy account journey is usable and visually reviewed on the
   device; no major screen is clipped, unreachable, obscured by keyboard/system
   UI, or dependent on a live service.
3. Signed-out and signed-in surfaces share a coherent TempleMate visual system
   derived from existing repository tokens and assets.
4. Traditional Chinese and English are complete for the refined surface, with
   no accidental mixed-language controls or truncated primary actions.
5. Light and dark account modes apply coherently to every refined surface and
   system-bar treatment.
6. Loading, empty, validation, pending, success, error/retry, confirmation,
   paid-read-only, and tenant-binding/switch states are clearly distinguishable
   and preserve their accepted behavior.
7. Profile editing, dependent CRUD, registration create/edit, privacy/support,
   preferences, closure, and dummy reset retain functional test coverage.
8. The app remains account-only; no admin, OAuth, payment/provider, live
   tenant, production, or release behavior is introduced.
9. `expo-doctor@1.20.1` is a pinned project-local development dependency,
   `yarn doctor` requires no `npx` or global tool, and the final offline Doctor
   run passes.
10. TempleMate remains `1.0.0`; Android version code and iOS build number remain
    `1`; no AAB/store build number is consumed; API 36 checks remain green.
11. Development and production config use
    `com.sourcegridlabs.templemate.dev` and
    `com.sourcegridlabs.templemate`, respectively; no tenant or country prefix
    remains in active mobile source.
12. Required automated and device checks pass with attributable evidence, and
    final Git state is clean with staging empty.

## Explicit Exclusions

- Rails or Vue behavior changes;
- real/live tenant QR scanning, camera permission, hosted trust registry,
  universal/app links, or production domain work;
- Google/Apple OAuth or identity linking;
- payment menus, checkout, provider state, ECPay, Stripe, refunds, settlement,
  or accounting;
- push, analytics, broad offline behavior, media upload, or unrelated native
  features;
- iOS device/TestFlight runtime acceptance;
- any new native build in this UI-refinement packet, including EAS cloud or a
  local build; AAB, signing, Play/App Store action, OTA, deployment, production
  data, secret access, release promotion, or remote Git push.

## Terminal And Next Gate

Control B returns exactly one immutable terminal packet directly to Planning
with its accepted commit, installed package/device evidence, screenshots or
equivalent visual review inventory, automated checks, final Git identities,
residual gaps, and continuation disposition. A final displayed only in the
Control task is not direct terminal delivery. Planning sends the paired receipt
and does not monitor the Implementer.

On acceptance, TempleMate remains version `1.0.0` and has an Android
development-client UI baseline suitable for the next separately planned V1
candidate-readiness decision. Device installation does not authorize live API,
tenant-domain, OAuth, payment, release, or store work.

Current classification: `expo_v1_dev_client_ui_refinement_terminal_pending`.

First blocker: Control B must apply the source-only identifier correction
without a native build, then deliver its immutable terminal packet directly to
Planning under the amended build policy.
