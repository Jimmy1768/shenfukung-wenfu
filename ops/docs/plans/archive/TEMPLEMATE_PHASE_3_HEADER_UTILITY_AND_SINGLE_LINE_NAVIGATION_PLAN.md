# TempleMate Phase 3 Header Utility And Single-Line Navigation Plan

Status: accepted for direct implementation dispatch after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`e0dcd0b078e10510c3d87c4981d664912e008c02`

Parent Phase 3 source:
`ops/docs/plans/TEMPLEMATE_PHASE_3_TENANT_GATE_AND_ASSISTANCE_UI_IMPLEMENTATION_PLAN.md`

Accepted runtime evidence:
`ops/docs/handoffs/2026-08-16-templemate-phase3-online-locked-materialization-runtime-control-b.md`

Director visual evidence: two Pixel screenshots supplied on 2026-08-16 show
the accepted bound TempleMate shell and Settings content. The first five
business destinations occupy the first navigation row; Settings alone wraps
onto a second row. The Settings screen retains Assistance, privacy/account
actions, reset, and the low-priority temple switch.

## Accepted Director Decision

The bound application shell has three visual layers:

1. header identity and utilities: Settings and Sign out;
2. a single-line main navigation containing temple/account business
   destinations only; and
3. the active screen content.

Do not shrink button labels or touch targets merely to fit Settings into the
business navigation. Settings is a utility destination and moves beside Sign
out. The existing authenticated-unbound QR-first gate remains unchanged and
must not expose Settings.

## Objective

Implement one bounded Expo JavaScript presentation patch that moves Settings
from the main navigation into the bound Header utility group and makes the
remaining business navigation a single non-wrapping line.

This is navigation ownership and layout work only. It does not redesign
Settings, alter any screen behavior, or add a new navigation framework.

## Required Behavior

### Bound header utilities

- When a tenant is actively presented, the Header renders Settings and Sign
  out as adjacent utility actions on the right of the existing TempleMate and
  connected-temple identity.
- Settings navigates to the existing `settings` screen using the same
  navigation/feedback ownership path as other destinations.
- Sign out retains its existing behavior and relative destructive/safe-escape
  semantics.
- The utility group must remain readable, accessible, and within the header;
  do not overlap, truncate, or displace the app/tenant identity beyond the
  existing one-line connected-temple constraint.
- The authenticated-unbound QR-first Header exposes Sign out only. It must not
  render Settings or provide any route around the setup gate.

### Business navigation

- The main navigation contains exactly `home`, `profile`, `dependents`,
  `registrations`, and `discover`, in the existing order.
- Settings is absent from the tablist/business menu but remains an accepted
  account screen and the return destination for Assistance, privacy, closure,
  reset, and temple-switch flows.
- The business navigation is one horizontal line and never wraps into a second
  row. Preserve readable labels and accessible touch targets rather than
  globally shrinking the buttons.
- At the Director-observed Pixel width, all five Traditional Chinese business
  destinations must remain visible on the single row. Longer locale/device
  conditions must remain one-line and must not silently truncate destination
  labels; bounded horizontal overflow is acceptable only when required to
  preserve label readability and touch targets.
- Existing selected-tab presentation and navigation feedback behavior remain
  unchanged for the five business destinations. Opening Settings from the
  Header must not falsely mark a business destination selected.

### Screen and state preservation

- Settings content and order remain unchanged: preferences, Assistance,
  privacy/account actions, dummy reset, and the low-priority temple connection
  and switch controls.
- Home, profile, dependents, registrations, Discover, Assistance, privacy,
  closure, tenant switching, QR binding, reset, Back, and sign-out behavior
  remain unchanged.
- Bound/unbound safety and `safeBoundScreen` behavior remain unchanged.
- Both Traditional Chinese and English copy dictionaries remain unchanged
  unless a test-only reference requires no rendered copy change.

## Likely Owned Paths

Control may narrow this inventory but may not widen beyond the accepted Expo
JavaScript/test and Control-record boundary without returning a true Planning
design gap:

- `mobile/App.js`
- `mobile/app/account/screen_model.js`, only if the pure menu model is aligned
  to the five business destinations
- `mobile/__tests__/account-surface.test.js`
- `mobile/__tests__/ui-refinement.test.js`
- one additional existing focused mobile presentation test only if necessary
- the Control implementation record under `ops/docs/handoffs/`

`mobile/app/ui/copy.js`, adapters, repositories, tenant binding, OAuth,
camera/QR, registration/payment, Rails, Vue, configuration, dependency,
lockfile, and native paths are excluded.

## Required Evidence

Control independently verifies at least:

1. a pure/static menu assertion that the business menu is exactly the five
   accepted destinations and Settings remains a valid account screen;
2. rendered-source evidence that bound Header owns Settings and Sign out,
   while the unbound gate Header exposes Sign out only;
3. rendered-source/style evidence that the business tablist cannot wrap and
   does not truncate labels; if bounded horizontal overflow is used, it must
   have accessible one-line behavior and no visible second row;
4. Settings navigation uses the existing navigation/feedback path and does not
   change Settings content or subordinate return destinations;
5. existing unbound gate, tenant switch, Assistance, privacy, closure, reset,
   Back, and sign-out regressions remain green;
6. focused account-surface/UI tests and the full mobile test suite pass;
7. mobile lint and verify pass;
8. `git diff --check`, exact changed-path review, and clean/staging-empty
   isolated and canonical final state pass; and
9. TempleMate/Komainu identities, Expo `1.0.0`, Android code `1`, iOS build
   `1`, SDK/API 36, dependency manifests, lockfile, and native configuration
   remain unchanged.

## Acceptance Criteria

The patch is accepted only if:

- the observed six-item two-row menu no longer exists;
- Settings is a bound-only Header utility immediately associated with Sign
  out;
- the five business destinations remain in order on one non-wrapping line,
  with no label/touch-target downsizing used as the solution;
- Settings and every existing subordinate action remain reachable and
  behaviorally unchanged after binding;
- the unbound QR-first gate cannot reach Settings or ordinary navigation;
- all required checks pass; and
- Control locally integrates the accepted source and returns one immutable
  terminal packet directly to Planning.

## Explicit Exclusions

No screen-content redesign, button-system redesign, copy rewrite, new
navigation dependency/framework, adapter/repository/tenant/OAuth/camera/QR/
registration/payment behavior, Rails/Vue source, dependency/lockfile/config/
native change, version/build increment, Metro/ADB/device action, rebuild/EAS/
install, provider/secret, production/deployment/release/push, or external
mutation.

## Post-Implementation Sequence

After source acceptance, Planning may separately authorize reuse of the
installed development client and the accepted USB Metro method for a visual
confirmation of the Header utilities and one-line business navigation. That
runtime evidence is not part of this source packet and requires no native
rebuild.

Current blocker: none.
