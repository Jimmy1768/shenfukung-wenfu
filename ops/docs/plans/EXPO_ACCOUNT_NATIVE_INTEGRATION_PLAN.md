# Expo Account Native Integration Plan

Status: accepted V1 integration phase; authorized for direct dispatch to
Control A after this plan is committed

Created: 2026-08-11

Owner: Wenfu Planning

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Version scope: TempleMate `1.0.0`

Accepted inputs:

- canonical `main` planning base: the commit containing this plan;
- Track A branch `codex/expo-account-json-api-track-a`, accepted tip
  `740aa39bb38806d2207636bb391167c2fee6a9b1`;
- Track A implementation parent
  `684c9efcd43127b07281fe0bf67d4932f98e0ef2`;
- Track B branch `codex/expo-native-infra-track-b`, accepted immutable tip
  `274dd7f763b7d95274a28f5241b0766cbea1d853`;
- Track B accepted source/conformance commit
  `a7d0226bbad08d79650515f7ed4f98e28320848c` and implementation parent
  `0263b0a6cd387d1e0101b76d4834a50b1f247254`.

## Objective

Combine the two accepted parallel checkpoints, connect the TempleMate Expo
account client to the accepted Rails native account JSON contract in local/test
mode, and return one coherent V1 integration checkpoint.

This is a merge and contract-fit phase. It does not redesign the working Rails
account namespace, invent new mobile product behavior, perform final UI
refinement, install a development client on a device, or begin release work.

## Authority And Sequence

Control B is finished and remains `released_terminal_idle`. It receives no
continuation and does not coordinate directly with Control A.

Control A owns this integration phase. It uses a new isolated
`codex/`-prefixed integration branch/worktree based on canonical `main` at this
accepted plan commit, then incorporates the exact accepted Track A and Track B
inputs. Control chooses the safe Git merge/cherry-pick mechanism, records exact
ancestry and conflict resolutions, and may change only evidence-backed
integration code or tests within the combined Rails/mobile scope.

Control A freezes one bounded implementation packet, delegates to one
ephemeral Implementer, independently reviews the result, runs the required
checks, and returns one immutable terminal packet to Planning. There is no
intermediate Planning traffic. Canonical `main` remains clean and unchanged
until Control has accepted the integration result; any final local merge to
`main` must be attributable, leave staging empty, and occur only as the
accepted completion of this packet. No push follows.

## Included Integration Work

### Preserve both accepted inputs

- Retain the additive `/api/v1/account/native` Rails surface and its native
  email access/refresh lifecycle.
- Retain the Expo 54 TempleMate account-only scaffold, `TempleMate (Dev)`
  identity, independent `1.0.0` version authority, build values at `1`, API 36
  configuration, and deterministic dummy mode.
- Retain Track B's navigation, stateful dummy screens, tenant-binding seams,
  storage scoping, locale/theme support, and dummy reset behavior.
- Preserve browser account behavior and all Track A account/tenant/ownership
  restrictions.

### Implement the real local/test adapter

- Implement the mobile real-adapter side of the accepted Track A request,
  response, error, and refresh-token contracts without renaming or widening
  those contracts by preference.
- Support the included account namespace operations already delivered by
  Track A: email signup/login/logout/recovery/reset, bootstrap, profile and
  password addition, dependents, registrations, certificates, events,
  services, galleries, assistance, contact, preferences, privacy, and account
  closure.
- Keep dummy and real modes explicit. A real-adapter error must surface as an
  error and must never fall back to dummy fixtures.
- Scope credentials, cached data, pending work, and adapter configuration by
  environment and bound tenant. Logout, closure, token replay/revocation, and
  tenant switching must clear the applicable local state.
- Use local/test configuration and test accounts only. Do not contact a live
  tenant, production system, provider, or external trust service.

### Prove account-only behavior

- The native app exposes no admin surface, role/mode switch, guest list, staff
  function, admin preference, or privileged dual-role response.
- Registration integration supports only the operations accepted by Track A.
  A registration may truthfully remain unpaid/pending; paid fixtures or
  returned paid state remain read-only presentation.
- No payment menu, checkout, status poller, provider reference, callback,
  refund, settlement, or accounting behavior enters this phase.
- No Google/Apple OAuth or identity-linking behavior enters this phase.

## Tenant Binding Boundary

This phase integrates against explicit local/test tenant configuration and the
accepted client interface. It may prove tenant identity, scoping, switching,
and prior-tenant cleanup with local/test fixtures or processes.

It does not invent or publish the future TempleMate domain trust registry,
contact live tenant origins, hardcode `shengfukung.com.tw` as permanent product
identity, or require a database change for QR codes. Distribution-facing
domain ownership, hosted trust documents, universal/app links, and live QR
binding remain later work.

## Physical Device And Build Boundary

Track B is complete on source, configuration, tests, Expo Doctor, prebuild,
Gradle assembly, and inspected debug-APK evidence. Physical development-client
installation, launch, Metro attachment, and Android-version-specific runtime
QA are not prerequisites for this integration phase and must not occur under
this packet.

TempleMate remains `1.0.0`. Android version code and iOS build number remain
`1`; neither is incremented. No AAB, EAS cloud build, signing, Play upload,
TestFlight/App Store action, OTA, deployment, or release promotion occurs.

## Required Evidence

Control A records exact commands and results for:

1. Git ancestry/content proving the accepted Track A and Track B inputs were
   incorporated from their exact immutable commits.
2. All Track A focused Rails request/session/contract suites, including the
   deterministic refresh-rotation contention evidence and existing browser
   account regression checks.
3. All Track B mobile unit/component/configuration checks, lint, version/API 36
   verification, and Expo Doctor.
4. Focused adapter contract tests proving the client maps every included
   request, success, validation, authorization, lifecycle, expiry, revocation,
   and not-found shape it actually consumes.
5. Local/test integration evidence for email session restoration/rotation,
   profile update, dependent CRUD, registration create/update, account reads,
   preferences/privacy, logout, and tenant/session cleanup.
6. Negative evidence that real-mode failures never fall back to dummy data and
   that admin, OAuth, payment, provider, live-domain, and release paths remain
   absent.
7. `git diff --check`, clean final source, empty staging, and exact final branch
   and canonical-main commit identities.

Control may choose the local test harness and implementation details. It must
not turn the evidence requirement into device installation, an external call,
or a production-like environment dependency.

## Immutable Acceptance Criteria

1. One coherent source tree contains both accepted checkpoints without losing
   either track's tested behavior or boundaries.
2. Expo real mode consumes the accepted Rails native account contract for the
   included non-payment, non-OAuth account surface.
3. Dummy mode remains explicit, deterministic, resettable, network-free, and
   impossible to use as fallback after real-mode failure.
4. Email authentication and refresh behavior are complete in local/test mode,
   with safe expiry, rotation, replay/revocation, logout, recovery/reset, and
   closure handling.
5. Profile name editing, dependent CRUD, registration create/update, and the
   accepted account reads/actions work through the real adapter in local/test
   evidence.
6. Tenant isolation, account ownership, dual-role account scoping, lifecycle
   restrictions, validation, and browser behavior remain server-authoritative
   and pass regression checks.
7. Expo contains no admin, OAuth, payment/provider, live-domain, production,
   or release behavior.
8. TempleMate remains version `1.0.0`; Android/iOS build values remain `1`;
   API 36 and development-client configuration checks remain green.
9. No physical device install/run occurs and its absence is not a blocker.
10. Required Rails, mobile, adapter, and local/test integration checks pass;
    final Git state is clean, attributable, and staging is empty.

## Explicit Deferrals

- final visual/UI refinement;
- physical device installation and runtime QA;
- live tenant trust registry, production TempleMate domain, and production QR
  binding;
- Google/Apple OAuth and identity linking;
- payment surface and lifecycle, including ECPay and Stripe;
- push, analytics, offline expansion, media, and unrelated native features;
- AAB, signing, EAS cloud, store records/submission, OTA, deployment,
  production data, secrets, and provider actions.

## Terminal And Next Phase

Control A returns exactly one immutable integration terminal packet with the
accepted commit(s), checks, final Git identities, residual gaps, and
continuation disposition. Planning sends the paired receipt and does not
monitor the Implementer.

If accepted, the result is the integrated TempleMate `1.0.0` source baseline.
Planning may then organize the final V1 UI-refinement phase and later separate
device, OAuth, payment, tenant-domain, and release phases. None is authorized
by this plan.

Current classification: `expo_v1_account_native_integration_authorized`.

First blocker: none. Planning must commit this accepted plan and dispatch it
directly to Control A.
