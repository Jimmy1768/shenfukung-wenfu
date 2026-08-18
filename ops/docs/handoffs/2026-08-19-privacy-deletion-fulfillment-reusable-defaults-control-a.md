# Control A Packet — Privacy Deletion Fulfillment, Reusable-Defaults Clear

## Identity

- Accepted spec: Finding 2 of
  `ops/docs/handoffs/2026-08-18-account-admin-offering-data-contract-phase-a3-control-a.md`
  (Phase A3 item 11 gap), dispatched directly — no separate plan doc,
  closes an existing Acceptance Criteria item in
  `ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`.
- Control: Wenfu Control A (session `local_915b44b0-14b1-4b09-bd97-da19a1169d41`).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- Branch: `claude/privacy-deletion-fulfillment-reusable-defaults`.
- Implementer commit: `a0be1ad` (fix(privacy): clear metadata on
  anonymize instead of merging).
- Merge: `0fa4d6f`, on `main`.

## Fix

`Privacy::UserDataDeletionFulfillment#anonymize_user!` and
`#anonymize_dependents!` now set `metadata` to just the tombstone keys
instead of merging tombstone keys onto existing metadata — the same
clear-not-merge pattern `scrub_preferences!`/`scrub_privacy_settings!`
already used in the same file, applied consistently rather than
reinvented.

## Verification

- Shared-dependent branch (`link.destroy!`, for a dependent linked to
  another user too) confirmed untouched by the fix — it never touched
  metadata before and still doesn't; only the branch that actually
  anonymizes was changed.
- Confirmed no downstream code in `fulfill!` reads `@user.metadata` or
  `dependent.metadata` after these methods run.
- New test (`test/integration/internal/privacy_requests_test.rb`) writes
  real distinguishable values through the actual production write paths
  — `Registrations::ReusableDefaults#write!` for the user's
  `dedication_message`, `Registrations::DependentContactSync.call!` for
  the dependent's notes/phone — sanity-checks they landed, runs
  fulfillment, reloads both records from Postgres, and asserts the
  namespace key and literal strings are gone and `metadata.keys` is
  exactly the tombstone set. Proves persisted DB state, not that a
  method merely ran.
- Export-side coverage (`privacy_flow_test.rb`) confirmed unaffected —
  untouched, still passing.
- Full Rails suite independently re-run pre-merge and post-merge on
  `main`: 540 runs, 3391 assertions, 0 failures/errors (baseline was
  539/3379 before this packet). `git diff --check` clean, no
  schema/migration diff — pure Ruby logic change.

## New Finding, Reported Only, Not Fixed

Broader grep for the same merge-instead-of-clear shape found one more
instance: `User#close_account!` merges `revoked_at`/`revoked_reason`
onto each `oauth_identity.metadata` rather than clearing it. Judged a
different bug, not the same one: `close_account!` doesn't anonymize
personal fields (email/names untouched — it's a status change, not a
deletion/anonymization action), and it targets a different record type
(OAuth identity linkage metadata, not the user/dependent record). Not
fixed here; flagged for a future look, not judged urgent.

## Track Status

With this fix, Phase A3 item 11 (privacy export/deletion/closure
compatibility) is resolved. **Finding 1 (audit email leak in
`Admin::PatronsController#log_patron_creation`) remains open** — the
track's Acceptance Criteria isn't fully closed until it's addressed too,
even though it's small.

## Closeout

Branch and worktree cleaned up (merged, deleted). Control A idle,
standing by for the next packet.
