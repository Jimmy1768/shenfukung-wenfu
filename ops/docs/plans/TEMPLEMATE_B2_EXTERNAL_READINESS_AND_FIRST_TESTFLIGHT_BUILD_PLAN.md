# TempleMate B2 — External Readiness And First TestFlight Build

## Objective

Validate the EAS/Apple/TestFlight and EAS/Apple/production-channel
pipelines end-to-end with real iOS builds, in parallel with Track A
refinement work (independent tracks, no coordination needed between
Control A and Control B).

**Corrected assumption, previous version of this plan had it wrong:**
Android dev-client already works and is the primary iteration loop
(~95% of development). iOS dev-client does not work — the Director tried
and gave up on the ad-hoc-provisioning path, and there's no plan to
revisit it. This packet does not depend on iOS dev-client at all. The
actual intended iOS workflow is: build directly to two separate
**production-configured** profiles instead of a dev-client step —
`testflight` (tester QA loop, refined afterward via OTA — slower than
dev-client, "enough for final touch-ups, usually CSS issues, not code
logic") and `production` (kept on its own channel specifically so
testers can keep iterating in TestFlight without affecting whatever is
live in App Store distribution). Building the `production` profile here
means producing that signed artifact, not submitting it — see Boundaries.

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

### Phase 2 — build (same packet, only after Phase 1 passes)

**Authorization for this phase must come from the Director directly, in
this Control B session — not from Planning's relay of the Director's
words, however explicit that relay was.** This is a real EAS build spend
and real Apple/App Store Connect account contact; per
`claude_work_mode.md`'s direct-authorization rule, confirm with the
Director here before running anything below, even though Planning
already has the Director's go-ahead in its own transcript.

- Run `yarn build:testflight` (`eas build --platform ios --profile
  testflight`) and, once that succeeds, `yarn build:production`
  (`eas build --platform ios --profile production`) from `mobile/`. Let
  EAS manage iOS signing/credentials unless Phase 1 found a reason not
  to — standard path, avoid manual certificate handling.
- Goal: one real signed IPA on each channel through the full pipeline —
  build config, native OAuth entitlements, EAS Update wiring. Not a
  UI/feature review; known-incomplete screens are expected and fine.
- Building the `production` profile produces a signed artifact only —
  it does **not** submit anything to App Store review. Do not run
  `eas submit`, do not open App Store Connect's release flow, do not
  publish an OTA update yet. That's separate, later, separately-gated
  work.
- If a build fails, retry within this same packet after a fix. A
  fundamentally different approach (not just a config/credential fix)
  needs a new plan, not an expanded retry.

## Boundaries (unchanged from Track B)

- No ECPay/production payment work.
- No production Rails/data changes.
- No App Store submission (`eas submit` or App Store Connect release
  flow) — building the `production` profile is in scope, submitting it
  for review is not.
- No secret values in logs, chat output, or committed files — public
  config only in `eas.json`/committed files; everything else stays in
  EAS's own environment store.
- Web Google/Apple OAuth was already tested; native OAuth remains
  physically untested — this build validates the pipeline, not native
  OAuth end-to-end (device testing is separate, later work).

## Confirmed blocker (Phase 1 finding, 2026-08-18)

`https://shengfukung.com.tw/privacy`, `/terms`, and `/support` all
return the same byte-identical 852-byte placeholder page (Golden
Template Marketing default) — confirmed by direct fetch, not inferred.
There is no real privacy policy, terms, or support/account-deletion
content behind any of them; the router falls through to a marketing SPA
catch-all. Apple requires a working privacy-policy URL and
account-deletion path for TestFlight, internal testing included — this
blocks Phase 2 regardless of build authorization, until real content
exists at those URLs. This is website content work, not mobile work —
routing it is a Planning decision, not Control B's to solve.

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
