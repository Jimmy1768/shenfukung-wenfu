# Admin Permissions UI And Navigation Alignment Plan

Status: implemented, Control B accepted, and locally integrated

Product authority: Director

Control owner: Wenfu Control B

Date: 2026-08-08

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Observed base: `3898b0967581df79223d4a22e4d634eb9e434458`

## Authority And Phase

This document captures the read-only UI review and the Director-confirmed
readiness corrections as frozen local product criteria. The Director explicitly
requested direct Control B execution without a Control A or Planning relay.
That instruction is a recorded exception for this one local UI track; it does
not change the repository's ordinary Codex Work Mode routing.

This is a local Rails admin UX and navigation-clarity track. It does not change
temple membership, owner/admin authority, capability persistence, tenant
isolation, payments, providers, deployment, secrets, production data, or the
assisted-onboarding operating model.

## Purpose

Make the admin permissions page readable, accessible, and internally coherent:

- each administrator reads as one bounded unit;
- each capability reads as one selectable row;
- each Save action clearly belongs to its administrator;
- permission copy accurately describes sidebar visibility and action gates;
- existing authorization behavior remains unchanged unless this plan
  explicitly says otherwise.

## Evidence Baseline

Observed source evidence:

- `rails/app/views/admin/permissions/index.html.erb` contains dedicated
  permission grid, card, form, checklist, checkbox, and action classes.
- Those permission-specific classes have no rules in the admin SCSS or checked
  compiled admin CSS, so browser layout falls back to an ungrouped document
  flow.
- `rails/app/models/admin_permission.rb` defines ten capability flags.
- `rails/app/helpers/admin/navigation_helper.rb` maps sidebar visibility to
  capabilities, with Gatherings and Offerings intentionally visible without a
  capability gate.
- `rails/app/controllers/admin/gatherings_controller.rb` and
  `rails/app/controllers/admin/offerings_controller.rb` permit list access
  without `manage_offerings` while gating create/edit/archive actions.
- `rails/app/views/admin/shared/_nav.html.erb` currently renders only the item
  label and provides no read-only state.
- Existing permission integration tests cover updates, audit logging,
  authorization, and temple isolation, but no focused navigation-semantics or
  permission-page layout contract exists.

The supplied screenshots are review evidence only. Personal values from them
must not be copied into source, fixtures, logs, or durable records.

## Confirmed Issues

### 1. Administrator boundaries are missing

The page has one outer card, but individual administrators have no visible
border, background, padding, or inter-card gap. A reader cannot quickly see
where one person's permissions end and the next person's begin.

### 2. Save actions collide with the following administrator

The action container has no divider, reserved area, or top/bottom spacing. On
narrow layouts the next administrator heading starts immediately after the
preceding Save button.

### 3. Permission rows are visually and interactively weak

The native checkbox is detached from its label and hint. Capability rows lack
alignment, separators, a full-row hit area, checked-state treatment, keyboard
focus treatment, and a consistent minimum touch target.

### 4. Information hierarchy is unclear

Administrator identity, role badge, permission list, validation errors, and
the per-person action do not read as parts of one unit.

### 5. Capability-to-navigation meaning is under-explained

The following menu gates match directly:

| Capability | Sidebar or UI result |
| --- | --- |
| `manage_profile` | Temple Profile |
| `manage_news` | News |
| `manage_gallery` | Gallery / Event Recaps |
| `manage_registrations` | Registrations and Orders |
| `view_financials` | Payments |
| `manage_permissions` | Permissions |

The following are intentional shared or action-only relationships:

- Patrons is visible with either `manage_permissions` or
  `manage_registrations`.
- Archives is visible with either `view_financials` or `export_financials`;
  CSV export remains independently gated.
- `record_cash_payments` gates an action within the order/payment workflow and
  has no standalone menu item.
- `view_guest_lists` gates the guest-list/API surface and has no standalone
  menu item.

The confirmed mismatch is explanatory rather than an authorization bypass:
`manage_offerings` gates authoring and editing but not the Gatherings or
Offerings list entries. An administrator without it can still browse the
read-only lists.

### 6. Page-level permission copy is stale

The page says only temple owners can change permission flags, while the current
controller authorizes any current-temple administrator with
`manage_permissions`. Its empty state also points to a "Users" screen even
though the current admin-promotion surface is Patrons.

### 7. The role badge is not temple-scoped

The card renders the reusable `AdminAccount.role`, but Wenfu's current role
authority is carried by `AdminTempleMembership` for the selected temple. A
multi-temple administrator can therefore receive a badge that does not describe
their role in the temple whose permissions are being edited.

## Frozen Product Direction

Preserve read-only visibility for Gatherings and Offerings when
`manage_offerings` is disabled. Hiding those menu items would reduce
discoverability while leaving the same list routes reachable directly and
would not strengthen authorization.

Make the behavior explicit instead:

- describe `manage_offerings` as an authoring capability, not a menu-visibility
  switch;
- state that Gatherings and Offerings remain browseable in read-only mode;
- show a clear read-only state in the sidebar for users without the capability;
- continue to hide or reject create, edit, archive, upload, and setup-draft
  actions through the existing server-side authorization boundaries.

No capability column, role default, permission inheritance rule, controller
authorization rule, or tenant boundary should change in this track.

## Phased Work

Execute the phases in order as one bounded UI track. Control owns the exact
implementation packet and required paths.

### Phase 1 — Permission semantics and copy

Goal: make every checkbox explain what it grants.

- Refine the `manage_offerings` label and hint in English and Traditional
  Chinese to distinguish read access from authoring access.
- Refine `record_cash_payments` and `view_guest_lists` hints to identify their
  in-workflow or API/list surfaces rather than implying standalone menu items.
- Preserve and, where useful, explain the shared Patrons and Archives gates.
- Correct the page body so it names `manage_permissions` authority rather than
  claiming the screen is owner-only.
- Point the empty state to the current Patrons-based promotion workflow rather
  than a nonexistent Users screen.
- Keep capability keys and persisted permission behavior unchanged.

Pass condition:

- a permission manager can predict both sidebar visibility and permitted
  actions from the checkbox copy without learning internal capability names.

### Phase 2 — Administrator card structure and responsive spacing

Goal: make each administrator a visually complete unit.

- Add an explicit grid/list gap between administrator cards.
- Give each card its own border, background, radius, and responsive padding.
- Align administrator identity and role badge while allowing long names and
  addresses to wrap without horizontal overflow.
- Resolve the badge from the administrator's membership in the selected temple
  and use localized owner/admin labels; do not render the reusable account role
  as temple authority.
- Ensure validation feedback remains inside the affected administrator card.

Pass condition:

- at desktop and narrow widths, adjacent administrators remain clearly
  separated and no identity, badge, or form content overlaps or overflows.

### Phase 3 — Capability rows and per-card action area

Goal: make selection and saving obvious and accessible.

- Render every capability as a full-width aligned row with the control, title,
  and hint treated as one label target.
- Add row separation and clear hover, checked, and `:focus-visible` treatment.
- Preserve native checkbox semantics and keyboard operation.
- Provide an adequate touch target without hiding the real control from
  assistive technology.
- Add a dedicated action area with a top divider and sufficient padding above
  and below the Save button.
- Keep one form and one Save action per administrator.

Pass condition:

- the Save action cannot visually touch the next administrator, and each
  checkbox can be identified, focused, toggled, and confirmed independently.

### Phase 4 — Read-only navigation communication

Goal: align Gatherings and Offerings navigation with the chosen permission
semantics.

- Keep Gatherings and Offerings visible to authenticated administrators who
  lack `manage_offerings`.
- Mark their state as read-only in the sidebar in a compact, localized,
  accessible way.
- Ensure users with `manage_offerings` do not receive a misleading read-only
  marker.
- Preserve all other existing sidebar gates, including the dual Patrons and
  Archives routes.
- Preserve server-side action authorization; navigation presentation must not
  become the enforcement boundary.

Pass condition:

- users can distinguish browse access from authoring access before selecting
  the menu item, and existing authorization outcomes remain unchanged.

### Phase 5 — Regression and visual acceptance

Goal: prove the layout and semantic changes without widening product scope.

- Add focused assertions for permission-page structure and source/compiled CSS
  presence.
- Add focused navigation coverage for direct, shared, action-only, and
  read-only capability relationships.
- Preserve the existing permission update, audit, unauthorized-access, and
  cross-temple isolation coverage.
- Rebuild checked-in Rails CSS from the repository root.
- Review the page with at least two administrator cards at desktop and narrow
  widths, including keyboard focus and checked states.
- Use the isolated local admin review database and provision a second
  disposable administrator for multi-card evidence; do not use production or
  customer data.
- Exercise representative light, dark, and high-contrast themes.
- Run final diff, status, and staging checks.

Pass condition:

- focused tests and CSS build pass;
- visual evidence shows bounded cards, separated actions, readable permission
  rows, and no narrow-width collision;
- Git state is clean and attributable after accepted local integration.

## Frozen Acceptance Criteria

1. Every administrator is enclosed by a distinct card with visible spacing
   before the next administrator.
2. Every Save action is separated from its checklist and the next card by a
   divider and adequate spacing at all supported widths.
3. Every capability is a full-row label target with aligned copy, native
   checkbox semantics, a visible checked state, and a visible keyboard focus
   state.
4. Long identity text and localized capability copy wrap without horizontal
   overflow or detached controls.
5. Page-level copy accurately names `manage_permissions` authority and the
   Patrons-based promotion workflow.
6. Every role badge reflects the administrator's membership role for the
   selected temple and is localized.
7. `manage_offerings` is presented as create/edit/archive authority while
   Gatherings and Offerings remain explicitly read-only when it is disabled.
8. Patrons and Archives retain their existing multi-capability visibility.
9. `record_cash_payments` and `view_guest_lists` remain action/surface gates
   and are described accurately without invented sidebar entries.
10. Permission persistence, audit logging, tenant isolation, owner/admin
   authority, and all server-side authorization outcomes remain unchanged.
11. Focused permission/navigation tests, repository-root `bin/build_rails_css`,
   and `git diff --check` pass.
12. No deployment, provider call, secret access, production-data action, push,
    or external mutation occurs.

## Proposed Verification

The authoritative Control selects the final commands and paths in its frozen
packet. The minimum expected local evidence is:

```text
bin/build_rails_css
cd rails && bin/rails test test/integration/admin/permissions_management_test.rb
cd rails && bin/rails test test/integration/admin/layout_css_test.rb
cd rails && bin/rails test <focused navigation coverage selected by Control>
git diff --check
git status --short --branch
git diff --cached --name-status
```

Visual review should exercise desktop and narrow viewports, at least two
administrator cards, unchecked and checked rows, keyboard focus, validation
errors, long English and Traditional Chinese text, and representative light,
dark, and high-contrast themes.

## Explicit Exclusions

- No database migration or capability-key change.
- No role-default or owner/admin inheritance change.
- No relaxation of controller authorization.
- No payment, accounting, provider, credential, or webhook change.
- No temple onboarding, membership, account, or tenant-isolation change.
- No Vue, Expo, deployment, server, DNS, TLS, or production work.
- No rewriting of historical review, acceptance, return, or execution records.

## Implementation Closeout

All five phases and all twelve frozen acceptance criteria were completed on
2026-08-08 under the recorded direct-Control exception.

- Permission authority, empty-state guidance, capability hints, and both
  supported locales now describe the actual permission and navigation
  behavior.
- Administrator cards use selected-temple membership roles, bounded card
  styling, full-row native checkbox labels, visible checked and keyboard-focus
  states, and separated per-card action areas.
- Gatherings and Offerings remain browseable without `manage_offerings` and
  show localized read-only sidebar markers; authoring controls remain governed
  by the existing server-side capability checks.
- Focused navigation coverage proves every direct gate, both halves of the
  Patrons and Archives shared gates, the two action-only capabilities, and both
  read-only and authoring states.
- `bin/build_rails_css` passed. The complete packet test set passed with 33
  runs, 253 assertions, 0 failures, 0 errors, and 0 skips. `git diff --check`
  passed.
- Isolated local browser review used two disposable administrator cards and
  verified desktop and narrow layouts, long identity wrapping, checked rows,
  keyboard focus, separated desktop action/card boundaries, both locales,
  both selectable display modes, and the read-only sidebar markers.

The admin display-mode selector exposes Standard and Dark only. The repository
also defines an `ops-high-contrast` token palette, and the new styles consume
those shared tokens, but there is no supported UI route for selecting that
palette. Control therefore verified the high-contrast compatibility from
source rather than mutating hidden browser state. This is a visual-evidence
limitation, not an unfinished product change or a reason to add a new display
mode outside the frozen scope.

No push, deploy, provider call, secret access, production-data action, or
external mutation occurred.

Accepted local implementation commit:
`dbc248efce9b92f082bbabeeb004b24eebe1ae4a`.

## Direct Authorization Record

On 2026-08-08, after reviewing the five-phase readiness scan and its discovered
copy, role-scope, navigation-marker, and visual-fixture corrections, the
Director confirmed the result was correct and instructed Wenfu Control B to
complete every phase until finished or until a concrete gap prevents truthful
completion. The Director also instructed that this track not be sent to Control
A or Planning.

Control B may therefore freeze one bounded implementation packet, dispatch one
ephemeral Implementer, review conformance, and locally integrate accepted work.
This authorization does not include push, deploy, publication, secrets,
providers, production data, external mutation, or any product/runtime change
outside this plan.
