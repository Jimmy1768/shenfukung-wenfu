# Expo V1 Signed-Out OAuth Copy-Key Repair Plan

Status: accepted for direct implementation dispatch to Control A after commit

Created: 2026-08-12

Owner: Wenfu Planning

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`6445945248c4d51f7e48382d7f61f901506174cb`

Runtime evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-dummy-device-camera-usb-validation-control-b.md`

## Objective

Repair the single observed JavaScript render failure that prevents TempleMate's
signed-out dummy screen from rendering, add focused regression proof, and
integrate the bounded source correction without rebuilding or touching a
device.

## Confirmed Defect

The installed development client successfully loaded the current Metro bundle
and showed:

- `Render Error`;
- `Cannot convert undefined value to object`;
- `App.js (99:1264)`;
- component stack `SignedOut` -> `App`.

Direct source evidence confirms the mismatch:

- `mobile/App.js` renders the OAuth status from
  `t.oauthState[oauthState.phase] || t.oauthState.idle`;
- both `zh-TW` and `en` dictionaries in `mobile/app/ui/copy.js` define
  `oauthOutcome`, not `oauthState`;
- another accepted path in `mobile/App.js` already uses
  `t.oauthOutcome[next.phase] || t.oauthOutcome.failed`.

The frozen correction is to use the existing `oauthOutcome` dictionary for the
signed-out OAuth phase label. Do not rename the dictionaries or introduce an
alias/new copy authority.

## Owned Paths

Control A may authorize one ephemeral Implementer to edit only:

- `mobile/App.js`;
- `mobile/__tests__/ui-refinement.test.js`.

Control-owned immutable packet/report paths under `ops/docs/handoffs/` are also
allowed. No other product, configuration, dependency, lockfile, version, native,
Rails, Vue, or Planning path is owned.

## Required Implementation

1. Replace only the erroneous signed-out OAuth phase lookup so it reads
   `t.oauthOutcome[oauthState.phase] || t.oauthOutcome.idle`.
2. Preserve the existing OAuth controller, dummy/real adapter behavior, phase
   names, Google/Apple buttons, locale copy, account scope, and UI structure.
3. Extend the existing UI-refinement test with focused static regression proof
   that:
   - the signed-out render lookup uses `oauthOutcome` for the current phase and
     idle fallback;
   - `App.js` contains no `t.oauthState` lookup;
   - both locale dictionaries expose `oauthOutcome` and do not introduce an
     `oauthState` dictionary.

Do not broaden this into a copy-system refactor, locale parity framework, JSX
reformat, component extraction, UI refinement, or unrelated defect cleanup.

## Checks

Control independently runs from the accepted isolated source:

- the focused UI-refinement test;
- `yarn test`;
- `yarn lint`;
- `yarn verify`;
- `git diff --check` and staged diff check;
- a focused diff/path review proving only the exact lookup, regression proof,
  and Control packet/report changed.

Use only an already available byte-identical dependency tree through the
existing safe temporary-symlink method if the isolated worktree lacks
`node_modules`; remove it before acceptance. Do not run a package manager or
install/copy dependencies.

Expo Doctor, export, native prebuild, Gradle, EAS, and physical device evidence
are not acceptance criteria for this one-line JavaScript correction. The next
separately authorized Metro validation will provide runtime proof.

## Acceptance Criteria

1. The exact observed undefined-key render path is corrected to the existing
   `oauthOutcome` authority.
2. Focused regression proof fails for the rejected `t.oauthState` form and
   passes for the accepted lookup in both locales.
3. Existing mobile tests, lint, and native config/version guard pass.
4. No behavior, copy, route, adapter, native dependency/configuration, or
   version/build value changes.
5. Canonical and isolated Git states are clean with staging empty after Control
   integration.

## Explicit Exclusions

- Metro, ADB, Pixel/device interaction, app reload/launch, screenshot, camera,
  QR, OAuth runtime, or real API action;
- dependency/manifest/lockfile/config/version/build/native changes;
- EAS/local build, prebuild, APK/AAB, signing, provider, deployment, release,
  OTA, store, payment, production, or push;
- repair of any issue not directly evidenced by this render failure.

## Sequencing

On accepted integration, Planning will separately dispatch renewed dummy device
validation through Control B using the exact USB/ADB TempleMate Metro method.
The existing installed development client is reused; no native rebuild is
expected.

Current classification:
`expo_v1_signed_out_oauth_copy_key_repair_authorized`.

First blocker: none.
