# TempleMate Phase 3 Director Holistic UI Audit Plan

Status: Phase 3 open; blocked only on Director screen-by-screen review and
accepted visual direction

Opened: 2026-08-13

Owner: Director / Wenfu Planning

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted functional baseline: canonical `main`
`3da1500d8f91d44063879e6bc5c529eb153b6c9f`

Parent roadmap:
`ops/docs/plans/TEMPLEMATE_DEMO_READINESS_AND_BETA_DISTRIBUTION_ROADMAP.md`

## Entry Evidence

- Phase 1 web cash-only source behavior is complete at `5d50aa3`.
- Phase 2 development-client demo parity is complete at `3da1500`.
- The physical Pixel journey passed for the exact four Shengfukung `NT$50`
  offerings, self/dependent pending cash-only registration, completed-cash
  read-only fixture, absence of payment/admin action, and canonical reset.
- Functional parity has no known remaining Planning/product gap.
- The prior “final UI refinement” implementation fixed scoped feedback and
  CameraView Back behavior only. It explicitly did not perform a holistic
  layout, style, navigation, component, or visual-system redesign.

## Objective

The Director reviews every relevant TempleMate screen and state on the working
development client, records specific findings, and establishes a holistic
visual/product direction. Planning then converts only those accepted findings
into bounded UI implementation phases.

This audit is the first genuine gap after Phase 2. Controls must not invent the
visual direction, independently redesign the app, or build production artifacts
before the Director closes it.

## Review Matrix

Review at least the following surfaces in Traditional Chinese and English,
light and dark themes where materially different:

- signed-out shell, email login, signup/recovery, Google/Apple controls and
  feedback;
- home/account overview and temple connection state;
- profile view/edit;
- dependent list/create/edit/delete and confirmations;
- Discover four-offering catalog and authoritative fee presentation;
- registration preparation, self/dependent selection, create, list, edit,
  validation, pending cash-only, completed-cash read-only, and empty states;
- events, services, gallery, and certificates;
- Settings, locale/theme, assistance, contact, privacy/export/deletion, account
  closure, sign-out, and reset;
- QR camera permission/loading/denied/blocked/scanning/invalid/trusted/switch
  states without reopening accepted feature semantics; and
- global loading, empty, disabled, mutation-pending, success, error, retry,
  destructive confirmation, keyboard, safe-area, and Android Back behavior.

## Holistic Analysis Dimensions

For every screen/state, record findings against:

1. information hierarchy and whether the primary action is obvious;
2. navigation model, screen naming, grouping, and back behavior;
3. typography scale, weights, line length, bilingual fit, and density;
4. spacing rhythm, alignment, safe areas, scrolling, and keyboard avoidance;
5. color, contrast, light/dark coherence, and semantic state colors;
6. cards, lists, forms, inputs, selectors, buttons, pills, notices, and modal/
   confirmation consistency;
7. offering, fee, registrant, registration, cash-only, and read-only payment
   clarity;
8. loading/empty/error/success/disabled states and transient feedback;
9. touch targets, dynamic text, screen-reader labels/order, reduced-motion and
   other accessibility concerns;
10. Android/iOS conventions and whether a shared treatment is intentional; and
11. demo-versus-real-state clarity without making the client feel like an
    internal engineering tool.

## Finding Format

Each recorded finding should include:

- screen/state and locale/theme;
- screenshot or precise reproduction path when useful;
- observed problem;
- intended outcome or reference direction;
- severity: critical, high, medium, or polish;
- whether it is global-system, shared-component, or screen-specific; and
- any explicit non-goal.

Planning groups findings into global design-system decisions first, shared
component work second, and screen-specific exceptions last. Duplicate symptoms
must not become separate one-off fixes.

## Exit Criteria

Phase 3 audit closes only when the Director has:

1. inspected the complete matrix or explicitly marked a surface unchanged;
2. accepted the global visual direction and major layout/navigation decisions;
3. resolved contradictory findings and identified intentional platform
   differences;
4. prioritized critical/high findings required before distribution;
5. classified medium/polish items as pre-beta or deferred; and
6. authorized Planning to create the first bounded UI implementation plan.

## Current Gate

`director_ui_audit_required`

Exact blocker/owner: the Director must inspect the screens, record findings,
and decide the holistic layout/styles/UI direction. No Control packet is active.
Production EAS profiles, TestFlight/AAB artifacts, store submissions, version/
build consumption, provider work, and public release remain downstream and
unauthorized.
