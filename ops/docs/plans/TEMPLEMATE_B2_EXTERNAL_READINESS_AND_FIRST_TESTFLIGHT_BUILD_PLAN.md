# TempleMate B2 — External Readiness And First TestFlight Build

## Objective

Validate the EAS/Apple/TestFlight pipeline end-to-end with one real iOS
build, in parallel with Track A refinement work (independent tracks, no
coordination needed between Control A and Control B). Dev-client already
works; this validates build/signing/OTA infrastructure, not feature
completeness — known-incomplete user screens are expected and fine.

## Reference (read-only)

`/Users/jimmy1768/Projects/DojoMate-Expo` — established precedent per
`ops/docs/plans/TEMPLEMATE_PRODUCTION_RUNTIME_EAS_OTA_SOURCE_IMPLEMENTATION_PLAN.md`.
Use for eas.json profile shape, build/ota/prebuild/check script organization,
and OTA lane guardrail pattern. Do not copy DojoMate's own IDs, versions,
Apple image pin, Firebase, RevenueCat, IAP, China payment, or unrelated
flags — same rule the prior plan already established.

## Prior state (verified, not assumed)

`mobile/eas.json` already has `testflight`/`production` profiles;
`mobile/package.json` already has `build:testflight`
(`eas build --platform ios --profile testflight`) and
`ota:testflight`/`ota:production` wired to `scripts/verify-ota-lane.js`.
Frozen identity (EAS project `@jimmy1768/templemate`, bundle
`com.jimmy1768.komainu`, version `1.0.0` build `1`) confirmed against
Track B's terminal evidence.

## Scope

### Phase 1 — readiness checks (read-only, do first, in this order)

1. Exact EAS account/project/profile and current build/update/channel state
   (`eas build:list`, `eas channel:list`, etc. — read-only).
2. iOS signing readiness — check what credentials exist without exporting or
   recording private material.
3. Apple Developer / App Store Connect app-record/team/agreement readiness.
4. Required public EAS environment/configuration presence, without exposing
   values.
5. Native Google/Apple callback/return registration for
   `templemate://oauth/complete`.
6. Privacy-policy, support, and account-deletion URL readiness (App Store
   Connect requires these even for internal TestFlight testing).
7. Confirm `1.0.0` (build `1`) is the correct first-upload identity.

Each item gets a written finding (`configured`/`documented`/`observed`/
`unknown`). If Apple Developer account or App Store Connect app record
doesn't exist or isn't ready, stop and report — do not create Apple-side
account records; that's outside this packet's authority.

### Phase 2 — authorized build (same packet, only after Phase 1 passes)

Director has pre-authorized this build explicitly — do not re-ask for
build permission, but do stop and ask before anything Phase 1 flagged as
not ready.

- Run `yarn build:testflight` from `mobile/` (`eas build --platform ios
  --profile testflight`). Let EAS manage iOS signing/credentials unless
  something in Phase 1 says otherwise — standard path, avoid manual
  certificate handling.
- Goal: one real signed IPA through the full pipeline — build config,
  native OAuth entitlements, EAS Update wiring. Not a UI/feature review.
- Do **not** submit to the App Store, do not target the `production`
  profile/channel, do not publish an OTA update yet. TestFlight internal
  build only.
- If the build fails, retry within this same packet after a fix. A
  fundamentally different approach (not just a config/credential fix)
  needs a new plan, not an expanded retry.

## Boundaries (unchanged from Track B)

- No ECPay/production payment work.
- No production Rails/data changes.
- No App Store submission or `production` channel targeting.
- No secret values in logs, chat output, or committed files — public
  config only in `eas.json`/committed files; everything else stays in
  EAS's own environment store.
- Web Google/Apple OAuth was already tested; native OAuth remains
  physically untested — this build validates the pipeline, not native
  OAuth end-to-end (device testing is separate, later work).

## Branching

Any code/config changes needed to make the build pass (eas.json tweaks,
credential config, build script fixes) go on their own `claude/<slug>`
branch, test to green, merge to `main` — normal Claude Work Mode. The
`eas build` invocation itself isn't a repo mutation and doesn't need a
branch on its own.

## Track independence

Runs in parallel with Track A (Control A, Rails/account/admin refinement
of shared personal/offering-data editing). Neither track touches the
other's paths (Rails/Vue vs. mobile/EAS) — no cross-track coordination
required; escalate to Planning only for a genuinely new decision, scope
change, or a Phase 1 finding that blocks Phase 2.
