# TempleMate Development-Client Cash-Only Demo Parity Plan

Status: accepted for direct implementation dispatch to Control B after commit

Accepted: 2026-08-13

Owner: Wenfu Planning

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`5d50aa309ad1740e46796c927733febc77b6f9aa`

Parent roadmap:
`ops/docs/plans/TEMPLEMATE_DEMO_READINESS_AND_BETA_DISTRIBUTION_ROADMAP.md`

Phase 1 source contract:
`ops/docs/plans/SHENGFUKUNG_WEB_DEMO_CASH_ONLY_FLOW_PLAN.md`

## Objective

Bring the existing TempleMate development client to functional demo parity
with the accepted Shengfukung web cash-only flow before the Director performs
the holistic Phase 3 UI review.

This is not a new product-design phase and has no known Planning gap. It is a
bounded Expo JavaScript/dummy-data presentation and validation phase. Preserve
the existing account-only app, native OAuth, QR camera, tenant binding, account
CRUD, registration authority, locale/theme, privacy/support, and reset behavior.

## Accepted Demo Contract

1. Dummy mode remains explicitly network-free, resettable, and visibly demo
   data. It does not claim synchronization with web admin or a provider.
2. The bound Shengfukung fixture exposes exactly the four accepted temple-
   defined offerings: `incense-donation`, `lamp-service`,
   `ghost-festival-table`, and `liberation-ritual`.
3. Every offering has authoritative `TWD 5000` internal price data and renders
   as `NT$50`. The patron cannot edit offering identity, label, unit price, or
   currency.
4. The ambiguous fifth source entry and its two inferred halves are absent from
   the catalog and registration journey. Do not add a runtime disabled feature.
5. Self and owned-dependent registration creation/edit behavior remains the
   accepted metadata-only flow. A newly created payment-required registration
   visibly remains pending.
6. Pending registration presentation truthfully says online payment is not
   available and cash payment should be arranged with the temple. Exact copy is
   functional Phase 2 copy and may be visually refined in Phase 3.
7. No checkout, retry, payment-provider browser, payment status mutation,
   provider reference, fake/ECPay claim, or payment action is visible or
   reachable.
8. One canonical completed-cash fixture is read-only and visibly identified as
   demo data. It proves only presentation, not cash receipt, provider,
   settlement, accounting, or synchronization.
9. Admin cash completion remains web-only. No admin route, role switch,
   settlement button, offering creation, or accounting UI is added to Expo.
10. The deterministic reset returns exactly one fixture dependent, one
    completed-cash read-only registration, the four offerings, default locale/
    theme, and the accepted unbound tenant state.
11. Real local/test adapter behavior remains fail-closed with no dummy fallback.
    This phase does not deploy or connect a production artifact to the live
    tenant.

## Required Implementation And Evidence

- Align dummy fixtures/repository/account presentation with the exact four-
  offering and cash-only contract.
- Add localized Traditional Chinese and English functional copy for pending
  cash arrangement and completed-cash display-only state.
- Use one pure presentation/state classifier for registration payment/demo
  state rather than scattering string checks across the UI.
- Preserve offering-derived totals when quantity changes and preserve the
  accepted empty-input quantity behavior.
- Add focused tests proving catalog exactness, `NT$50`/TWD values, absence of
  the ambiguous offerings, pending/cash-only state, completed-cash read-only
  state, no payment action, self/dependent mutation, atomic rejection, and
  canonical reset.
- Run the full mobile test suite, lint, verification guard, and Expo Doctor
  using the accepted source-identical local dependency method without changing
  dependencies or lockfiles.
- Verify `TempleMate (Dev)`, Komainu development identifiers, Expo SDK 54,
  Android API 36, camera/OAuth native closure, and `1.0.0 / Android 1 / iOS 1`
  remain unchanged.
- Run physical Pixel development-client validation using only the previously
  accepted USB reverse/local Metro/local TempleMate attachment method if the
  exact target and installed package pass preflight. Control performs bounded
  device interaction; no Director manual input is required.
- Physical evidence must cover the four-offering list/fees, self and dependent
  registration, pending cash-only presentation, completed-cash read-only state,
  absence of payment/admin actions, and reset. A functional defect is reported
  truthfully and repaired only within the unchanged accepted criteria.
- No native rebuild is required or authorized because this phase changes no
  native dependency or configuration.
- Cleanup removes only packet-owned Metro/reverse/temp dependency/evidence
  state and preserves the installed development client.

## Explicit Exclusions

- No holistic layout, styling, component-system, information-architecture, or
  visual redesign. Those decisions belong to the Director's Phase 3 review.
- No Rails/Vue/admin source, server deployment, production/test-tenant data,
  live API, real OAuth/provider browser, provider credential, Stripe/ECPay,
  money, cash recording, accounting mutation, or external action.
- No QR payload presentation/scan or tenant-switch revalidation unless needed
  only to restore the already accepted unbound dummy baseline; do not reopen
  accepted camera/tenant evidence.
- No dependency/lockfile/config/native/prebuild/build/EAS/artifact/install,
  version/build increment, TestFlight, AAB, store, OTA, push, or release action.
- No payment history screen, checkout/return/status lifecycle, admin mode,
  analytics, push notification, or new account feature.

## Immutable Acceptance Criteria

1. Dummy mode exposes exactly four accepted `NT$50` Shengfukung offerings and
   no ambiguous fifth/inferred half.
2. Self and dependent registrations remain offering-authoritative and can be
   created/edited through the existing accepted operation set.
3. New payment-required registrations visibly stop at pending cash-only/
   online-unavailable with no payment/provider/admin action.
4. The completed-cash fixture is read-only and explicitly demo presentation.
5. Reset restores the exact canonical demo state without duplicate or residue.
6. Existing account/OAuth/QR/tenant/locale/theme/privacy/support behavior and
   real-mode no-fallback boundaries remain green.
7. Mobile checks and physical development-client evidence pass; identity,
   version, builds, SDK/API, dependencies, native config, and installed package
   remain unchanged.
8. Final canonical and isolated worktrees are clean with staging empty and no
   excluded action occurs.

## Sequencing And Terminal Boundary

- Planning commits this accepted plan and sends it directly to Control B.
- Control B records one immutable implementation packet, dispatches one
  ephemeral Implementer, owns bounded repairs and local integration, and sends
  one immutable terminal packet directly to Planning.
- Acceptance completes Phase 2 functional parity. It does not claim holistic
  visual quality or production-artifact readiness.
- Planning then stops at Phase 3. The first genuine open gap is Director-owned:
  inspect every screen/state, record findings, and perform a holistic layout,
  styles, interaction, accessibility, and UI analysis before any visual
  implementation plan or production artifact.

## Current Gate

Accepted for Control B implementation after commit. First blocker: none.
