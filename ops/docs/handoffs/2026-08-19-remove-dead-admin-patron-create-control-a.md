# Control A Packet — Remove Dead Admin::PatronsController#create

## Identity

- Accepted spec: Finding 1 investigation (dispatched directly, no
  separate plan doc) — closes Phase A3 item 9's remaining outlier in
  `ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`.
- Control: Wenfu Control A (session `local_915b44b0-14b1-4b09-bd97-da19a1169d41`).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- Branch: `claude/remove-dead-admin-patron-create`.
- Implementer commit: `e82e6fb` (chore(admin): delete dead
  Admin::PatronsController#create).
- Merge: `ce0022c`, on `main`.

## Background

Investigation while explaining Finding 1 (audit log embedding a
patron's real email value) surfaced that the action containing the leak
— `Admin::PatronsController#create` — was never reachable in the real
product: git history confirms it existed since the controller's very
first commit (`e7c080b`, 2026-01-06), and no view, JS, or live route
ever called it (only the search/patron-picker `#index` path is real).
Director's call: delete the dead code rather than patch a log line in
an action that shouldn't exist.

## Outcome

- `app/forms/admin/patron_form.rb` deleted entirely.
- `PatronsController#create`, `#patron_params`, `#log_patron_creation`
  removed (all three only used by the deleted action).
- `create` dropped from
  `before_action :require_manage_permissions!, only: %i[promote revoke create oauth_duplicates]`.
- `routes.rb`: `resources :patrons, only: %i[index create]` →
  `only: %i[index]`.
- `patron_payload` left untouched — still used by `#index`'s JSON
  response for the patron picker.
- One dead test (`patron_picker_test.rb`, "create makes a new patron
  profile") removed alongside — it was the only test exercising
  `#create`.

Diff exactly as scoped: 4 files, 2 insertions, 104 deletions.

## Verification

- Independently re-grepped `app/`, `test/`, `config/`, `lib/` before
  merging — confirmed no other callers of `Admin::PatronForm`,
  `patron_params`, or `log_patron_creation`, and confirmed the removed
  test was the only one hitting `#create`.
- Full Rails suite re-run pre-merge and post-merge on `main`: 539 runs,
  3385 assertions, 0 failures/errors — down from 540/3391 by exactly the
  one removed test, reconciling cleanly.
- `git diff --check` clean, no schema/migration diff.

## Track Status — Both A3 Findings Now Closed

Finding 2 (privacy deletion not clearing reusable-defaults) fixed
2026-08-19 (`0fa4d6f`). Finding 1 (audit email leak) resolved by
deletion rather than patch, this packet. All 12 Phase A3 verification
items now hold.
`ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`'s Acceptance
Criteria is fully met.

## Closeout

Branch and worktree cleaned up (merged, deleted). Control A idle,
standing by for the next packet.
