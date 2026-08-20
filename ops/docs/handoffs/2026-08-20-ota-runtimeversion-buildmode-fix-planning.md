# Planning — OTA runtimeVersion/BUILD_MODE Fix, Direct

## Identity

- Follows: the same session's production deploy of the native OAuth
  account-resolution work (`ead42e2`, `2290df3`, `bcf8131`), same day.
- Planning: Wenfu Planning, working directly (small/urgent, no packet
  handed to Control) — this went outside the normal packet-and-review
  flow because it was diagnosed and fixed live, mid-incident, not
  planned in advance. Recorded here for the same reason any Control
  packet gets a handoff: so a cold session can pick up the state without
  re-deriving it.
- No branch/worktree — commits landed straight on `main`, matching the
  existing convention for small, self-contained fixes.

## What Happened

While shipping the native OAuth account-resolution work to production,
Planning also ran the mobile side's first-ever real OTA publish
(`yarn ota:testflight`). Two real bugs surfaced, both root-caused to the
same thing: `mobile/`'s Expo/EAS config had silently diverged from
`~/Projects/DojoMate-Expo` — the Director's mature, proven reference for
this exact stack — instead of following it.

### Bug 1 — `runtimeVersion` nested one level too deep

`app.config.js` had `runtimeVersion: { policy: 'appVersion' }` sitting
inside the `updates` object instead of as a sibling of it. Schema-valid
placement, but the real EAS build pipeline reads `expo.runtimeVersion`
at the top level only — it silently found nothing there and never wrote
an `EXUpdatesRuntimeVersion` key into the compiled app at all.

Confirmed directly, not inferred: downloaded the actual installed
TestFlight `.ipa` (build `53c2b1ec`, commit `9f36c64`, 2026-08-19) and
inspected its embedded `Expo.plist` — no `EXUpdatesRuntimeVersion` key
present. The embedded `app.config` inside that same binary had the
identical misplaced shape, confirming the bug was live at build time,
not just today. That build is structurally unable to ever receive an
OTA update, regardless of what gets published to any branch/channel.

Fixed by pinning `runtimeVersion` to the literal `versioning.appVersion`
string at the top level of `expo`, matching DojoMate-Expo's
`config/base.cjs` exactly (`runtimeVersion: APP_VERSION`) instead of the
object-policy form.

### Bug 2 — OTA publish script didn't set `BUILD_MODE`

`scripts/verify-ota-lane.js` only ever set
`TEMPLEMATE_CLIENT_ENVIRONMENT` before invoking `eas update`. It never
set `BUILD_MODE`/`EAS_BUILD_PROFILE`, so the first real publish run
(without those set in the calling shell either) evaluated
`app.config.js` with `isDevelopmentClient()` defaulting to `true` —
published a dev-identity bundle (`TempleMate (Dev)`,
`com.jimmy1768.komainu.dev`, dev icon) under the `testflight` channel.
Confirmed by pulling the published manifest via `eas channel:view
testflight --json` and reading `extra.expoClient`.

Fixed by having the script inject each lane's env explicitly —
`{ BUILD_MODE, EAS_BUILD_PROFILE, TEMPLEMATE_CLIENT_ENVIRONMENT }` per
lane — mirroring DojoMate-Expo's `scripts/publish-ota.mjs`
`LANE_CONFIG.env` pattern, rather than trusting the caller's shell.
Republished correctly afterward; verified via the same `channel:view`
check that the manifest now carries the real production identity.

### Bug 3 — `isDevelopmentClient()` failed unsafe on unset env, found by `eas submit`

Same class of bug, a third call site: `isDevelopmentClient()` defaulted
the *unset* case (neither `BUILD_MODE` nor `EAS_BUILD_PROFILE` present)
to `'development'`. `eas build`/`eas update` always set `BUILD_MODE`
explicitly, so this never surfaced through them. `eas submit` resolves
the project's bundle identifier by evaluating `app.config.js` in a bare
process with neither var set, independent of the `--profile` flag on
its own command line — it silently pointed App Store Connect credential
lookup at `com.jimmy1768.komainu.dev` for a `--profile testflight`
submit. Caught live, mid-submission, from the Director's own terminal
output (not something this session's tooling surfaced on its own).

Root-caused and fixed at the shared resolution logic itself rather than
patching `eas submit` as a new special case, since three separate call
sites hit the same defect in one day: `isDevelopmentClient()` (and the
adjacent `buildMode` fallback in the same function) now return
"unknown, not dev" when the env is genuinely unset, mirroring
DojoMate-Expo's actual proven form (`isDev = BUILD === 'development'`
— strict equality against `undefined` is `false`) instead of asserting
a specific default for an ambiguous context. Verified directly: ran
`app.config.js` with all three relevant env vars deleted and confirmed
`ios.bundleIdentifier` resolves to `com.jimmy1768.komainu`, not `.dev`.

Also added `mobile/eas.json`'s `submit.testflight` profile (`ascAppId`
only) — actual Apple API-key/auth setup is the Director's own
interactive action, per the same "not self-authorized" rule as the
build itself; this session does not perform it.

## Hardening

Both bugs shipped invisibly — nothing in the existing test/verify
tooling caught either, and in one case a test actively asserted the
buggy shape as correct:

- `scripts/verify-native-client.js` now asserts, for every buildMode
  (`development`/`production`/`testflight`): `runtimeVersion` is a
  top-level literal string equal to `versioning.appVersion` (catches
  bug 1's exact shape), and `verify-ota-lane.js`'s `LANE_ENV.<lane>.
  BUILD_MODE` stays in lockstep with `eas.json`'s own
  `build.<lane>.env.BUILD_MODE` (catches bug 2's exact shape).
- `__tests__/native-config.test.js` previously asserted
  `config.updates.runtimeVersion` (the wrong, nested location) equal to
  `{ policy: 'appVersion' }` — this was locking bug 1 in as correct, not
  catching it. Corrected to assert the real top-level location.
- Added a "Mobile/Expo Reference Pattern" section to
  `ops/protocol/shengfukung_wenfu_context.md` pointing at
  `~/Projects/DojoMate-Expo` as the pattern to check before touching
  `app.config.js`/`eas.json`/OTA scripts here, instead of re-deriving
  Expo/EAS config from the docs each time.

69/69 tests, lint, verify all green. Committed directly to `main`:
`ead42e2` (runtimeVersion fix, mid-incident), `3febcb3` (hardening for
bugs 1 and 2), `5e1e3cd` (iOS build number bumped to 2, Director
instruction), `6fe68fe` (bug 3 fix and regression test).

## Resolved Since

Director authorized and a new TestFlight build (build `2a7dee90`, iOS
build number 2, version 1.0.0 unchanged) was produced and verified
directly — downloaded the real `.ipa` and confirmed
`EXUpdatesRuntimeVersion => "1.0.0"` is now actually embedded, unlike
build 1. `eas submit --non-interactive` hit bug 3 (above) mid-attempt;
fixed, and submission proceeds via the Director's own interactive
`eas submit` run (Apple API-key setup cannot be non-interactive or
performed by this session).

## Closeout

No branch/worktree to clean up (direct-to-main). Planning standing by
once the Director's interactive submit completes, to confirm the build
lands correctly under TestFlight processing.
