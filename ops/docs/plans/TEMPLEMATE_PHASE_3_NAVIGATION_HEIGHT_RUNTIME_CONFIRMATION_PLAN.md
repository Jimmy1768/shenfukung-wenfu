# TempleMate Phase 3 Navigation Height Runtime Confirmation Plan

Status: accepted for direct runtime dispatch after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted source/base: canonical `main`
`90ebd1461fe16644c54e85b73c29719585b89f93`

Source repair plan:
TEMPLEMATE_PHASE_3_SINGLE_LINE_NAVIGATION_HEIGHT_REPAIR_PLAN.md (deleted
2026-08-22 in the plans/archive cleanup; recoverable via `git log --grep`)

## Objective

Load the accepted compact-height navigation repair into the existing Pixel
development client through the established USB method and hold the session for
one Director visual confirmation. No source repair is authorized.

## Entry And Local Preparation

- Exact serial `39011FDJH00FQ8`, Pixel 8 / shiba.
- Exact installed package `com.jimmy1768.komainu.dev`, version `1.0.0`, code
  `1`, target SDK 36, existing MainActivity.
- Verify clean canonical/isolated source at `90ebd14`, exact package/lockfile
  identity, installed package, port 8081/reverse ownership, device awake and
  unlocked, and prior `stay_on_while_plugged_in` value.
- Run at most one project-local `yarn install --frozen-lockfile`; normal
  registry retrieval is authorized only for missing locked archives. Do not
  change manifests, lockfile, versions, scripts, config, or global packages.
- Confirm the focused navigation tests, full mobile suite, lint, and verify
  pass before attachment.
- Temporarily set USB-only stay-awake `2` after recording the prior value;
  restore the exact prior value on every terminal path.

## Ordered Attachment

To avoid the previously observed DevLauncher attachment race, perform once:

1. force-stop only the exact TempleMate package without clearing data/cache;
2. start exact MainActivity without a URL and verify DevLauncher visibly ready;
3. start one dummy localhost Metro service on port 8081 and verify readiness;
4. create one exact serial-fenced `tcp:8081` reverse; and
5. deliver the established local `exp+templemate` URL once.

No Metro/Expo QR, launcher scanner, Pixel native scanner, or TempleMate tenant
camera is used for attachment. No second force-stop/start/delivery/reload is
authorized.

## Visual Confirmation Matrix

Control first verifies the accepted bundle is visibly stable with no blank
surface, Render Error, fatal overlay, JavaScript exception, or native exit.
Retained app data may present the bound shell; if it presents signed-out or the
unbound gate, do not mutate account/tenant state merely to reach the menu.

When the bound shell is available, verify and present to the Director:

- Header contains Settings then Sign out and retains readable app/temple
  identity;
- business navigation contains exactly five ordered destinations on one line;
- navigation occupies only its natural compact single-row height;
- pills are vertically centered and retain readable labels, padding, and
  minimum touch height;
- active content begins immediately below the compact menu without overlap;
  and
- no second row or vertically stretched menu remains.

Send exactly `director_action_required: navigation_height_visual_confirmation`
only after this surface is ready. Hold Metro, reverse, and temporary stay-awake
state while awaiting the Director's one confirmation. Do not request any QR,
sign-in, navigation, or other Director action.

The previously observed nonfatal DevLauncher context-not-ready soft log is not
by itself a failure if `Running main` follows and the repaired TempleMate UI is
stable. A blank/fatal/repeated unusable surface remains a truthful failure.

## Cleanup And Closeout

After the Director response or a terminal failure:

- stop only packet Metro;
- remove the exact serial reverse and verify port/reverse absence;
- remove packet-created local `mobile/node_modules` and sanitized evidence;
- restore/read back the prior stay-awake value;
- preserve installed app and app data;
- verify manifests/lockfile unchanged and Git clean/staging-empty; and
- return one immutable terminal packet directly to Planning.

## Explicit Exclusions

No source/test edit, app-data/cache clear, reinstall/reboot, QR/camera, real
API/OAuth/provider/payment, dependency/lockfile/config/native/version/build
change, rebuild/EAS, Rails/Vue, production/deployment/release/push, secret, or
external mutation.

Current blocker: none if the exact Pixel remains awake, unlocked, and bound.
