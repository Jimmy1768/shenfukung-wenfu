# TempleMate Phase 3 UI Audit Runtime Session Plan

Status: accepted for direct runtime-session dispatch to Control B after commit

Accepted: 2026-08-14

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`e5575245103b428aa46c0d9f22a0cd6ecd4157c0`

Parent audit:
`ops/docs/plans/TEMPLEMATE_PHASE_3_DIRECTOR_HOLISTIC_UI_AUDIT_PLAN.md`

## Objective

Start and retain one local dummy TempleMate development-client session so the
Director can manually inspect every Phase 3 screen/state and report holistic
UI findings. This packet provides runtime access only; it does not implement,
repair, or infer any visual decision.

## Directly Observed Entry Fence

Planning observed on 2026-08-14:

- exact USB serial `39011FDJH00FQ8` in ADB `device` state;
- Pixel 8 / `shiba`;
- installed package `com.jimmy1768.komainu.dev`;
- version `1.0.0`, Android code `1`, target SDK 36; and
- canonical `main` clean/staging empty at the accepted baseline.

## Authorized Runtime Session

1. Reverify the exact source, device, package, port, reverse, and dependency-
   equivalence fences.
2. Use only the accepted local method: source-identical temporary dependency
   access, explicit dummy/development mode, localhost dev-client Metro on port
   8081, exact serial `adb reverse tcp:8081 tcp:8081`, and the local
   `exp+templemate` attachment for `com.jimmy1768.komainu.dev`.
3. Foreground TempleMate at the signed-out or canonical reset entry surface.
   Do not use a Metro QR, Expo launcher scanner, Pixel native scanner, or
   provider browser.
4. Return the callback
   `director_action_required: phase3_ui_audit_session_ready` only after the
   bundle renders and the app is visibly usable.
5. Leave the packet-owned Metro process and exact serial reverse running while
   the Director manually reviews the app. Control B remains the runtime owner;
   Planning records findings. No Director input automation is required or
   permitted during review.
6. Do not interpret comments as source-edit authority. Planning will later
   consolidate findings and commit separate accepted UI implementation plans.
7. On explicit Director/Planning completion, device disconnect, unrecoverable
   render failure, or session supersession, stop only the packet Metro process,
   remove only the exact reverse/temp dependency/evidence state, and return one
   immutable terminal report.

## Session Boundaries

- Manual Director navigation, form entry, reset, locale/theme switching, and
  camera permission/view inspection inside deterministic dummy mode are
  permitted for UI review. No real QR payload, provider, API, payment, or
  account is used.
- Screenshots supplied by the Director are review evidence. Control must not
  retain private notification, provider, credential, or unrelated device
  content.
- The session may reveal functional defects, but Control records them without
  source repair. This phase is visual audit, not implementation acceptance.
- The installed development client is retained at cleanup.

## Explicit Exclusions

No source/test/config/dependency edit, build/prebuild/EAS/install/artifact,
version/build increment, Rails/Vue/server/deployment, live API/OAuth/provider,
QR payload, payment, production data, store/release/push, secret, or external
mutation. No holistic UI decision is delegated to Control.

## Acceptance And Callback

- Session ready means exact dummy bundle visibly rendered on the fenced Pixel
  with Metro/reverse owned and running.
- The packet remains active after the ready callback so the Director can review.
- Phase 3 remains blocked on Director findings and visual decisions, not on
  Control implementation.
- Final terminal disposition occurs only after explicit cleanup authority or a
  truthful runtime blocker.

Current blocker: none.
