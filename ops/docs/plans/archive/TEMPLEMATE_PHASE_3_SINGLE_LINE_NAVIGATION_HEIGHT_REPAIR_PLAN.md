# TempleMate Phase 3 Single-Line Navigation Height Repair Plan

Status: accepted for direct implementation dispatch after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`05d63bc3b6460eb0e62f96779950a936cad2cb74`

Parent source:
`1fdf5911ce8217587e0489d4c6a571a5e9dd2eb8`

Director visual evidence: the Pixel screenshot supplied at 2026-08-16
14:53 shows the accepted Header hierarchy and five-item single-line business
menu, but the horizontal navigation occupies several hundred vertical pixels
and stretches every pill to that height.

## Diagnosis

The Header height is visually acceptable. The regression begins below the
Header: the horizontal React Native `ScrollView` has no content-height growth
constraint, and its content row does not center children on the cross axis.
The shell therefore expands within the column layout and the navigation pills
stretch vertically. This is a direct presentation regression introduced by
the single-line navigation patch.

## Objective

Apply the smallest Expo JavaScript style/test repair so the horizontal
business navigation sizes to its content height and the existing buttons
remain centered at their intended compact height.

## Required Behavior

- Preserve the accepted Header exactly: Settings and Sign out remain adjacent
  bound-only utilities; the unbound gate still shows Sign out only.
- Preserve exactly five ordered business destinations on one non-wrapping
  horizontal line.
- Constrain the horizontal navigation shell so it does not flex-grow into the
  app's remaining vertical space.
- Center navigation children on the row's cross axis so they use the existing
  `minHeight: 40` plus the established vertical padding rather than stretching.
- Preserve existing label font size, horizontal padding, minimum touch height,
  selected styling, scrolling behavior for longer locales, and no label
  truncation.
- Do not change the Header height, content spacing, cards, notices, or any
  screen behavior.

## Owned Paths

- `mobile/App.js`
- `mobile/__tests__/ui-refinement.test.js`
- one Control record under `ops/docs/handoffs/`

No other source/test path is authorized unless Control identifies a true
Planning design gap.

## Required Evidence

1. static/style regression proof that the horizontal navigation shell cannot
   flex-grow and its content centers children on the cross axis;
2. retained proof of five business destinations, non-wrapping horizontal
   behavior, no label truncation, and unchanged minimum touch height;
3. retained bound/unbound Header utility behavior and Settings navigation;
4. focused UI/header tests and the full mobile suite pass;
5. mobile lint and verify pass;
6. `git diff --check`, staged diff check, exact owned-path review, and clean
   final canonical/isolated states; and
7. package/lockfile/config/native/identity/version/SDK/API values remain
   unchanged.

## Acceptance Criteria

- The business menu occupies only its natural single-row height.
- Pills no longer stretch vertically and are not shrunk below their existing
  readable/touchable dimensions.
- The accepted three-layer hierarchy remains Header utilities, one-line
  business navigation, then active screen content.
- No other UI or behavior changes.
- Control locally integrates only after all checks pass and returns one
  immutable terminal packet directly to Planning.

## Explicit Exclusions

No general UI redesign, Header change, button-system change, screen/copy/state/
adapter/tenant/OAuth/camera/QR/registration/payment change, dependency/lockfile/
config/native/version/build change, Metro/ADB/device/runtime action, rebuild/
EAS/install, Rails/Vue, provider/secret, production/deployment/release/push, or
external mutation.

After source acceptance, visual confirmation on the installed client remains a
separately authorized runtime packet.

Current blocker: none.
