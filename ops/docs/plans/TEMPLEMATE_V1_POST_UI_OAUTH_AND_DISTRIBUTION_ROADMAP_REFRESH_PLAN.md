# TempleMate V1 Post-UI OAuth And Distribution Roadmap Refresh Plan

Status: accepted for direct documentation-only dispatch after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted base: canonical `main`
`1b1cb69e74dad282793fb4ccdfe196dc48dbda76`

Accepted Phase 3 runtime evidence:
`ops/docs/handoffs/2026-08-16-templemate-phase3-navigation-height-bound-visual-continuation-control-b.md`

Parent roadmap:
`ops/docs/plans/TEMPLEMATE_DEMO_READINESS_AND_BETA_DISTRIBUTION_ROADMAP.md`

## Director Decision

The bound TempleMate development-client layout is correct and sufficient for
V1. Phase 3 visual refinement is accepted. Real Google and Apple OAuth have
not yet been validated on the mobile app. Production-identity artifacts may be
prepared only after that distinct OAuth readiness/runtime gate is accepted.

The intended later artifact families are:

- iOS App Store/TestFlight IPA through the production TempleMate identity;
- Android Google Play AAB; and
- an optional separately configured Android APK distribution variant, informed
  by the established DojoMate-Expo operating pattern but never copying its
  identifiers, credentials, signing material, or unreviewed commands.

This decision authorizes documentation reconciliation only. It authorizes no
source/configuration edit, provider action, build, upload, or release.

## Objective

Update the durable TempleMate roadmap and coordination records so they reflect
the full accepted history without recency bias:

1. Phase 1 web cash-only demo behavior is complete.
2. Phase 2 development-client cash-only parity is complete.
3. Phase 3 Director-led UI audit and refinement is complete and accepted for
   V1 at the exact runtime report above.
4. The next product gate is a distinct real Google/Apple native OAuth
   readiness and physical-device validation phase.
5. Distribution readiness follows OAuth acceptance and precedes any artifact.
6. Production-identity TestFlight IPA, Play AAB, and optional Android APK are
   separate later artifact authorities, not one implied release action.
7. First-client Stripe and live ECPay activation remain deferred and are not
   reintroduced as demo or beta blockers.

## Required Roadmap Corrections

### Phase status

Update the roadmap's phase map, phase descriptions, sequencing, and current
gate. Preserve earlier accepted product decisions and historical evidence.
Do not rewrite completed phases as if they were newly decided.

The post-refresh sequence is:

- Phase 0: accepted foundation — complete.
- Phase 1: web cash-only demo flow — complete.
- Phase 2: development-client cash-only demo parity — complete.
- Phase 3: Director UI audit/refinement — complete and sufficient for V1.
- Phase 4: real Google/Apple native OAuth readiness and runtime validation —
  next phase.
- Phase 5: store, policy, signing, runtime-mode, and artifact readiness.
- Phase 6: separately authorized production-identity beta artifacts and
  staff distribution.
- Phase 7: repeatable client-meeting demo and beta observation/acceptance.
- Deferred: first-client Stripe platform billing and live ECPay activation.

### Phase 4 real OAuth gate

Document that current evidence proves OAuth source contracts, provider-
independent transaction handling, dummy Google/Apple behavior, and a local/
test-only real adapter. It does not prove real mobile Google or Apple provider
behavior or production distribution configuration.

Phase 4 must begin with a read-only readiness scan. It must establish, rather
than infer:

- the exact accepted Rails/Central Auth deployment and account-resolution
  state needed for mobile validation;
- the production and development app identifiers, native scheme/return URL,
  API/trust origin, runtime mode, EAS profile, and provider-registration state;
- which provider-console or deployment actions remain separately authorized;
- a sanitized device matrix for Google and Apple success, cancellation/denial,
  browser interruption/return, repeat sign-in, session restoration, and safe
  unmatched-account/account-resolution behavior; and
- cleanup, stop, privacy, account, and production-data boundaries.

Do not claim that web OAuth, dummy OAuth, or the earlier source phase proves
real native OAuth. Do not delete, merge, relink, or otherwise remediate user 22
as part of mobile OAuth validation. The accepted Apple account-resolution and
historical recovery tracks remain separate Control A work.

### Phase 5 distribution readiness

Preserve the existing release-readiness requirements and add the explicit
dependency on Phase 4. This phase decides and verifies release configuration;
it does not build or upload.

It must keep these artifact paths distinct:

- iOS App Store/TestFlight production identity and production runtime;
- Android Google Play AAB and selected closed-testing track; and
- optional Android APK variant, including its intended channel, runtime,
  provider/network constraints, signing, update path, and separation from the
  Play AAB.

DojoMate-Expo may be inspected later as an operational reference for profiles,
commands, ledgers, artifact handling, and TestFlight/Android variants. It is
not OAuth evidence and its app-specific identifiers, secrets, signing state,
versions, and commands are never inherited without a Wenfu-specific review.

Stable public URLs, store records, privacy/data-safety declarations, signing,
release runtime configuration, development-launcher exclusion, and current
official Apple/Google rules remain readiness gates. Temporally unstable tester
counts, durations, and submission rules must be reverified from official
sources at execution time rather than copied from old chat.

### Phase 6 artifact authority

Retain `1.0.0`, Android code `1`, and iOS build `1` now. Documentation work,
OAuth testing, development-client Metro work, or readiness scans do not
increment them.

Each build and each upload requires its own exact accepted packet with source
commit, platform/profile, runtime mode, identifier, version/build, signing
owner, artifact handling, upload target, rollback/stop conditions, and
sanitized receipt. A successful build is not an upload; a beta upload is not a
public release. TestFlight production identity means a production-signed beta,
not App Store public release.

### Phase 7 meeting acceptance

Preserve the existing cash-only demo journey. It may use the accepted web test
tenant and an accepted staff beta artifact, but it does not activate live
Stripe/ECPay or grant public release authority.

## Phase 3 Findings Closeout

Update the rolling Phase 3 findings record without rewriting the original
observations:

- mark Director review complete for V1;
- map Findings 001–003 to the accepted tenant gate/Assistance implementation
  and its device evidence;
- record the accepted Header utility, five-item single-line business menu, and
  compact-height repairs and final runtime confirmation;
- state that the Director judged the resulting bound UI sufficient for V1;
  and
- retain any noncritical/deferred observations as future evidence rather than
  inventing a new source defect.

## Future Work And Current Coordination

Add a concise post-UI V1 sequence to `future_work.md` and a current TempleMate
gate section to `codex_work_mode_current.md`. The snapshot must identify Phase
4 real OAuth readiness/validation as the next owner action and state that no
Control packet is active after this documentation phase unless Planning
dispatches it separately.

Do not remove historical pointers merely because the new roadmap is more
current. Prefer current-status additions and pointer consolidation over
rewriting historical records.

## Exact Editable Paths

- `ops/docs/plans/TEMPLEMATE_DEMO_READINESS_AND_BETA_DISTRIBUTION_ROADMAP.md`
- `ops/docs/plans/TEMPLEMATE_PHASE_3_UI_AUDIT_FINDINGS.md`
- `ops/docs/reference/future_work.md`
- `ops/docs/handoffs/codex_work_mode_current.md`
- Control-owned immutable packet/report records under `ops/docs/handoffs/`

This accepted plan itself is Planning-owned and already committed before
dispatch. Control may not edit it.

## Required Evidence

Control verifies:

1. exact ancestry from `1b1cb69` and clean canonical/isolated states;
2. the four durable records agree on the completed Phases 1–3, next Phase 4,
   and later Phase 5–7 ordering;
3. real native OAuth remains explicitly untested and is not conflated with
   web or dummy OAuth;
4. the Apple account-resolution rollout/recovery track remains separate and no
   user/account action is implied;
5. TestFlight IPA, Play AAB, and optional APK are distinct, separately gated
   future artifacts;
6. `1.0.0 / Android 1 / iOS 1` remains unchanged and no automatic increment is
   introduced;
7. Stripe platform billing and live ECPay remain deferred until the first real
   client;
8. current external store rules are marked for future official revalidation,
   with no stale tester rule elevated to current authority;
9. no obsolete “Phase 1 next” or “Phase 3 open” current-gate statement remains
   in the four edited durable records;
10. Markdown links and headings are coherent, `git diff --check` passes, and
    exact changed-path review finds documentation paths only; and
11. canonical and isolated worktrees finish clean with staging empty.

No product tests are required because no product/source/configuration path may
change. Control performs direct evidence review and may use one normal
report-only ephemeral Implementer.

## Explicit Exclusions

No Expo/Rails/Vue source or test edit; no EAS/app/store/provider/account/
deployment/production inspection or mutation; no secret or credential access;
no Google/Apple login; no user 22 remediation; no dependency, native config,
identifier, runtime mode, version/build, profile, signing, artifact, upload,
release, push, or external action.

Current blocker: none for documentation reconciliation. After acceptance, the
next owner/action is Planning's separately committed Phase 4 real Google/Apple
native OAuth readiness-scan plan through Control B, sequenced with the separate
Control A Apple account-resolution rollout state.
