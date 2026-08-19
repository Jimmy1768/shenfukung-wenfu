# Control B — Export Compliance Flag (Post-B3 Follow-Up)

## Identity

- Accepted spec: follow-up offered by Control B during the first
  TestFlight build (`ops/docs/handoffs/2026-08-19-templemate-first-testflight-build-control-b.md`),
  Director-authorized directly in Control B's session.
- Control: Wenfu Control B (session `local_c98e7b6a-147e-4774-ad30-d8dcfbc3f0e0`).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- Branch: `claude/templemate-export-compliance-flag`.
- Implementer commit: `10abd91` (fix(mobile): declare no non-exempt
  encryption for App Store export compliance).
- Merge: `160ee97`, on `main`.

## Fix

Added `ios.infoPlist.ITSAppUsesNonExemptEncryption: false` to
`mobile/app.config.js`. TempleMate only uses standard HTTPS/TLS to talk
to the Rails backend, no proprietary/custom crypto — this answers App
Store Connect's export-compliance question at upload time so future
TestFlight/production builds don't need the manual "Manage" click that
build 1 (the first TestFlight upload) needed.

## Verification

Tests 63/63, lint, and `verify` all green. Expo Doctor's one failing
check (expo/expo-constants/expo-updates patch-version drift) is
pre-existing and unrelated — this diff touches only `app.config.js`.

## Process Note

This branch was worked in the shared Control A/B cwd at the same time
Planning ran an unrelated docs-only commit directly in the same working
directory without checking which branch was checked out first — a real
instance of the shared-cwd collision risk the protocol already warns
about. No harm resulted: Control B's own commit-and-merge cycle
(`10abd91` → `160ee97`) carried Planning's stray commit along cleanly
since it was docs-only and non-conflicting, and `main`'s history and the
working tree both ended up correct. Recorded as a reminder to actually
follow the "don't commit in the shared cwd without checking state
first" rule Planning itself wrote.

## Closeout

Branch and worktree cleaned up (merged, deleted). Control B idle,
standing by.
