# Control A Packet — Account/Admin Offering-Data Contract, Phase A1

## Identity

- Accepted plan: `ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`,
  Phase A1 — Contract And Storage Alignment, narrowed per Phase A0's
  findings (`ops/docs/handoffs/2026-08-18-account-admin-offering-data-contract-phase-a0-control-a.md`).
- Control: Wenfu Control A (session `local_915b44b0-14b1-4b09-bd97-da19a1169d41`).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- Branch: `claude/account-admin-offering-data-contract-a1`.
- Implementer commit: `29dddd2` (refactor: consolidate dependent
  contact-sync into shared service).
- Merge: `8845c0d`, on `main`.

## Scope

Behavior-preserving consolidation only, per A0's finding that the
assumed asymmetry didn't exist — the real issue was four separate
reimplementations of the same write-back logic. No tenant/storage-key
work (A0 confirmed that's already safe). No admin UI/surface work
(Phase A2 territory). Capability-gate inconsistency
(`manage_permissions` on `PatronsController#create`) explicitly left
untouched, as instructed.

## Outcome

- New `Registrations::DependentContactSync.call!(dependent:, phone:,
  email:, notes:)` — the single merge-and-persist implementation, in the
  `Registrations::` namespace next to `UserMetadataUpdater`.
- All four call sites (`RegistrationIntakeForm`,
  `RegistrationMetadataForm`, `Payments::TempleRegistrationBuilder`,
  `Admin::OfferingOrdersController#sync_dependent_profile_after_update`)
  now delegate to it. Each site still sources its own raw phone/email/
  notes values (form attributes vs. persisted registration payload —
  legitimately different per site, not part of the duplication); only
  the merge/persist step moved.
- One behavioral wrinkle checked, not just carried over: an
  equality-guard before `update!` existed on only one of the four
  original sites. Confirmed `Dependent` has no callbacks and Rails'
  dirty-tracking already no-ops an unchanged-value `update!`, so folding
  that guard into all four sites changes no observable behavior.

## Verification

- Full Rails suite independently re-run, pre-merge (implementer's
  worktree) and post-merge on `main`: baseline 511/3244 (clean `main`
  before this packet) → 527/3310 after, 0 failures/errors both times.
- Consolidation is proven, not just outcome-tested: spy tests per call
  site assert the shared service is invoked with the right args, plus a
  static-source guard test asserting none of the four files contains a
  local merge-into-metadata pattern and that all four reference the
  shared service — catches a duplicate implementation reappearing
  alongside the shared call, which behavioral tests alone would miss.
- `git diff --check` clean; no schema/migration diff (confirmed against
  `db/`).

## Closeout

Branch and worktree cleaned up (merged, deleted). Control A idle,
standing by for Phase A2.
