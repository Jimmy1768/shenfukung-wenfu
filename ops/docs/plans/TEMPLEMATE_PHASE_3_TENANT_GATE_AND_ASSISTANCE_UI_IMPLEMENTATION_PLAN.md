# TempleMate Phase 3 Tenant Gate And Assistance UI Implementation Plan

Status: accepted for direct implementation dispatch after commit

Accepted: 2026-08-14

Owner: Wenfu Planning / Director

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`c969f39851dffb207952e8d19f40780e975678fc`

Parent audit:
TEMPLEMATE_PHASE_3_DIRECTOR_HOLISTIC_UI_AUDIT_PLAN.md (deleted 2026-08-22 in
the plans/archive cleanup; recoverable via `git log --grep`)

Accepted findings:
TEMPLEMATE_PHASE_3_UI_AUDIT_FINDINGS.md (deleted 2026-08-22 in the
plans/archive cleanup; recoverable via `git log --grep`)

Accepted readiness evidence:
`ops/docs/handoffs/2026-08-14-templemate-phase-3-tenant-and-support-ui-readiness-control-a.md`

Parallel runtime packet: Control B owned the (now-completed) dummy
development-client audit session under TEMPLEMATE_PHASE_3_UI_AUDIT_RUNTIME_SESSION_PLAN.md
(deleted 2026-08-22 in the plans/archive cleanup; recoverable via
`git log --grep`). This source packet was not to stop, reload, attach to,
automate, or otherwise interfere with that session.

## Accepted Director Decisions

1. When authenticated without a selected temple, TempleMate is a QR-first
   setup gate rather than an ordinary account shell. The only product action is
   TempleMate's in-app temple QR scan; sign-out remains available as the safe
   escape. Normal account navigation and temple-scoped content are hidden.
2. Once bound, the temple is stable context. Ordinary switching is removed
   from Home and placed at the bottom of Settings as its least-prominent
   action. Existing explicit confirmation and confirmation-only cleanup remain
   unchanged.
3. Expo V1 retains only the admin-visible Assistance action. Contact Temple is
   removed from the Expo V1 Settings and rendered screen surface. The existing
   Rails/web email-contact behavior is not removed, converted, or redesigned.
4. The retained Assistance form submits the existing Rails-native profile
   channel contract and presents truthful dummy versus real outcomes.

## Objective

Implement the accepted tenant-binding hierarchy and retained Assistance UI as
one bounded Expo JavaScript patch. The work is combined because the decisions
share the authenticated shell, Settings, copy, feedback, and account-screen
tests; it must still preserve the two semantic boundaries and avoid a broader
visual redesign.

No native capability, dependency, configuration, Rails product behavior, or
production service changes are required.

## Required Behavior

### Authenticated unbound gate

- If `signedIn` is true but there is no active presentation tenant, do not
  render the normal six-tab Navigation or any ordinary AccountSurface screen.
- Render a dedicated, accessible setup surface with:
  - TempleMate identity and unbound status;
  - clear Traditional Chinese and English copy equivalent to “Scan your temple
    QR code to finish setup” (do not describe QR binding as authentication);
  - one visible primary action that opens TempleMate's existing in-app
    `TempleQrCamera`;
  - existing camera permission loading/denied/blocked/retry/cancel/invalid
    states; and
  - the existing Header sign-out action as the safe escape.
- Do not render the fixture connection-link input or connect-with-link button
  in the user-facing gate. Preserve the deterministic fixture parser/helper
  seam for tests and trusted fixture evidence.
- A valid dummy fixture scan binds the trusted temple and enters the bound Home
  shell. Invalid/untrusted/cancelled scans remain gated without changing the
  tenant or account data.
- Do not invent executable real QR binding. If a deliberate local/test real
  session ever reaches unbound state, fail closed with truthful unavailable
  presentation and sign-out rather than dummy fallback or a false scan claim.
- Reset, sign-out, feedback ownership, app resume, Android Back, camera Back,
  and account data must remain deterministic. The gate must not expose
  profile, dependent, registration, Discover, Settings, privacy, closure, or
  support actions before binding.

### Bound Home and low-priority Settings switching

- Bound Home may show the current temple as stable context but contains no
  switch control, candidate, link input, or switch confirmation.
- At the bottom of Settings, after ordinary account/privacy/demo actions,
  render a low-priority temple-connection section showing the retained active
  temple and, only where the existing dummy fixture switch is executable, a
  secondary switch action.
- The existing state machine remains authoritative:
  - request stores the candidate without presenting it as active;
  - prior temple remains visible until confirmation;
  - confirmation clears the prior tenant's OAuth/session/cache/pending scope;
  - `confirmSwitch` succeeds only with the matching cleanup receipt; and
  - failures preserve the prior active tenant and account presentation.
- Keep switch confirmation within Settings. Do not add an automatic switch,
  remove confirmation, move cleanup earlier, or enable a real-mode dummy
  fallback.

### Assistance-only Expo V1 support

- Settings contains one clearly named Assistance action with concise copy that
  explains its real destination: a request for temple staff in the admin
  assistance queue. Remove the Contact Temple button from Expo V1.
- Remove the rendered Contact Temple screen from the Expo account screen model
  and safe navigation surface. Do not remove or change Rails/web Contact Temple
  routes, form, email delivery, audit behavior, or tests. A non-rendered mobile
  adapter seam may remain only if its continued presence is intentional and
  boundary-tested; it must not be advertised as an available V1 screen.
- Assistance renders one message field with validation consistent with the
  retained Rails profile assistance use: a clear required/optional decision,
  maximum 280 characters, and the exact payload
  `{ assistance: { channel: "profile", message } }` through the real adapter.
  Do not add a patron-selectable channel control for this Settings entry.
- Dummy mode must explicitly identify submission as local fixture behavior and
  must retain the submitted channel/message deterministically without implying
  that an administrator received it.
- Real local/test mode must:
  - submit `channel: "profile"`;
  - preserve the current account snapshot rather than replacing it with the
    assistance response envelope;
  - distinguish a newly created request from an already-open duplicate when
    the returned contract permits it;
  - show a scoped, truthful success/error outcome; and
  - never claim email delivery or an admin inbox message.
- Navigation away, reset, sign-out, locale change, and app resume must clear or
  correctly scope transient Assistance feedback under the existing feedback
  ownership rules.

## Likely Owned Paths

Control may narrow this inventory but may not widen outside the accepted Expo
JavaScript/test and Control-record boundary without returning a true Planning
design gap:

- `mobile/App.js`
- `mobile/app/account/screen_model.js`
- `mobile/app/tenant/binding.js` or one new narrowly scoped tenant-presentation
  helper under `mobile/app/tenant/`
- one new narrowly scoped Assistance form/presentation helper under
  `mobile/app/account/`, if useful
- `mobile/app/dummy/repository.js`
- `mobile/app/dummy/adapter.js`, only if required by the exact retained payload
- `mobile/app/real/adapter.js`, only if required to preserve snapshot and
  expose the accepted response semantic
- `mobile/app/ui/copy.js`
- focused tests under `mobile/__tests__/`, including account surface, tenant
  binding/gate, UI refinement, dummy repository, and real adapter contracts
- the Control implementation record under `ops/docs/handoffs/`

Rails source, routes, forms, models, services, views, locales, schema, and
migrations are excluded. Focused Rails tests may be run read-only against a
properly fenced test database, but no Rails test file change is required or
authorized by this plan.

## Required Evidence

Control independently verifies at least:

1. deterministic pure/helper evidence for bound, unbound, binding-failed, and
   switching presentation/navigation authority;
2. static/rendered-source evidence that unbound hides Navigation and all
   temple-scoped account screens, exposes only in-app QR plus sign-out, and has
   no user-facing connection-link control;
3. valid/invalid/cancel camera result behavior and retained trusted fixture
   parser tests;
4. Home contains no switch action; Settings contains the sole low-priority
   bound switch action and the sole confirmation-only cleanup call;
5. candidate/prior presentation and cleanup receipt invariants remain green;
6. Expo account screens and Settings expose Assistance but not Contact Temple;
7. rendered Assistance produces `channel: "profile"`, maximum-280 message
   behavior, exact real request body, dummy fixture-only state, new/duplicate
   outcome mapping, snapshot preservation, and scoped feedback;
8. no Contact Temple Rails/web source or behavior change;
9. full `mobile` tests, lint, verify, and project-local offline Doctor;
10. focused existing Rails native assistance/admin assistance regression tests,
    only with explicit `RAILS_ENV=test` and an exact safe test-database fence;
11. `git diff --check`, exact changed-path review, rejected identifier/provider/
    checkout/admin-native/live-origin scans as applicable, and clean/staging-
    empty isolated and canonical final state; and
12. TempleMate/Komainu identities, Expo `1.0.0`, Android code `1`, iOS build
    `1`, SDK/API 36, dependencies, lockfile, and native configuration unchanged.

## Acceptance Criteria

The source packet is accepted only if all Required Behavior and Required
Evidence pass. In particular:

- the unbound shell cannot reach normal account screens by visible navigation,
  safe-screen fallback, or Android Back;
- a trusted dummy QR is the only product path from unbound to bound;
- bound switching is absent from Home and remains confirmed/cleanup-safe at
  the bottom of Settings;
- Expo V1 exposes only Assistance, with the exact Rails profile-channel
  payload and truthful destination semantics;
- account state survives Assistance response handling;
- Rails/web Contact Temple and admin Assistance behavior remain unchanged;
- no native rebuild, version/build increment, dependency/configuration change,
  device action, or external action occurs; and
- Control locally integrates the accepted source only after full conformance
  review, then sends one immutable terminal packet directly to Planning.

## Explicit Exclusions

No holistic visual-system redesign, new navigation framework, real tenant QR
protocol, Rails/Vue product/source edit, Contact Temple email redesign,
provider/email credential or delivery action, OAuth/payment/admin-native
surface, dependency/lockfile/config/native change, build/prebuild/EAS/install,
version/build increment, Metro/ADB/device or active Control B session action,
production data, deployment, release, push, secret, or external mutation.

## Post-Implementation Sequence

This source patch does not complete Phase 3. After acceptance, Planning will
separately sequence installed-client runtime validation on the compatible
development client. The broader Director holistic UI audit remains open for
additional findings and final visual direction.

Current blocker: none.
