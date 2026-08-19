# Control B — First TempleMate iOS TestFlight Build (B3)

## Identity

- Accepted plan: `ops/docs/plans/TEMPLEMATE_B2_EXTERNAL_READINESS_AND_FIRST_TESTFLIGHT_BUILD_PLAN.md`,
  Phase 2 (`testflight` profile only, per prior scope narrowing —
  `production` deferred, still in scope for later).
- Control: Wenfu Control B (session `local_c98e7b6a-147e-4774-ad30-d8dcfbc3f0e0`).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- No branch, no worktree, no repo changes — build/submit/credentials/App
  Store Connect record creation are external-tool/account actions
  outside repo state.

## What Happened

- Director completed `eas credentials --platform ios` interactively
  (production profile, shared Distribution Cert + new Provisioning
  Profile for `com.jimmy1768.komainu`) once physically back with the
  iPhone needed for Apple 2FA.
- Control B ran `yarn build:testflight --non-interactive` — succeeded
  clean.
  - Build log: `https://expo.dev/accounts/jimmy1768/projects/templemate/builds/53c2b1ec-3509-40b8-ac16-06c674dcc451`
  - IPA: `https://expo.dev/artifacts/eas/-rcLJxVyLOA4le_FS_Fip0IA5Cnca_hX93cB63MyVYc.ipa`
- Director created the App Store Connect app record (TempleMate,
  `com.jimmy1768.komainu`) themselves, then chose Transporter over
  `eas submit` for this first upload — a deliberate choice (clearer
  first-submission error output than CLI text), Control B laid out the
  tradeoff, Director decided. Control B never touched Apple
  auth/submission at any point.
- Cleared the expected `ITSAppUsesNonExemptEncryption` compliance
  prompt (standard HTTPS-only exemption, correct for this app's actual
  transport).

## Current State

Version `1.0.0` build `1` is live under TempleMate → TestFlight,
internal-testing groups already available, no App Review needed for
internal testers. The Director's actual goal — QA and sales reps
installing via TestFlight — is achievable now.

`production` profile build was not run this session — explicitly scoped
to `testflight`-only, confirmed multiple times by the Director. Still
in scope per the plan whenever it's wanted, not run today.

## Open, Not Yet Actioned

Control B offered to add `ios.infoPlist.ITSAppUsesNonExemptEncryption:
false` to `app.config.js` so future builds skip the manual compliance
prompt — a small source change, would need its own branch per Claude
Work Mode. Awaiting the Director's answer directly in Control B's
session; not decided here.

## Closeout

No blockers. No repo changes to clean up. Control B idle, standing by.
