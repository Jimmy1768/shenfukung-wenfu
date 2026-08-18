# Control A Packet — Account/Admin Offering-Data Contract, Phase A3

## Identity

- Accepted plan: `ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`,
  Phase A3 — Contract Verification (plan's existing definition, used
  unmodified).
- Control: Wenfu Control A (session `local_915b44b0-14b1-4b09-bd97-da19a1169d41`).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- Branch: (implementer branch, test-only) — merge `b67a6d3`, implementer
  commit `0882b6e`, on `main`.

## Outcome — 10 Of 12 Items Proven

Test-only diff, zero app-source changes: 438 lines, 4 new files, 12 new
test methods.

- Self/dependent prefill on account+admin surfaces — new tests.
- Account/admin creation and edit refresh symmetry — cited existing
  coverage (`registration_payment_flow_test.rb`,
  `offering_orders_registrant_flow_test.rb`).
- Explicit value overrides cached value — new tests, both surfaces.
- Blank registration value doesn't erase reusable data — cited existing
  coverage.
- Explicit clearing (admin panel + account profile/dependent editors)
  behaves as documented — cited existing coverage.
- Tenant/offering separation on a colliding offering slug — turned out
  to already be directly proven, not just structurally implied:
  `reusable_defaults_test.rb:7-19` already exercises two real `Temple`
  records sharing a slug.
- Freeform ritual/person names don't create or mutate dependents — new
  tests (account + admin, self-scoped, no dependent selected).
- Lifecycle locks / rejected updates don't mutate cache before failing —
  new test closes the one gap in existing coverage (validation-failed,
  non-locked account update).
- Audit records carry field names only, never values — new tests across
  all 4 call sites in this domain, using a real sensitive-looking string
  and asserting its absence from the persisted log row. This test is
  what surfaced Finding 1 below.
- Full regression evidence — fenced disposable Postgres DB, confirmed
  `current_database()` before writes, dropped after. 539 runs, 3379
  assertions, 0 failures/errors — independently verified pre-merge and
  post-merge on `main` (baseline was 527/3310 before this packet).

`git diff --check` clean, no schema/migration diff. Branch and worktree
cleaned up.

## Outcome — 2 Of 12 Items Failed Verification, Not Fixed (By Design)

Per the packet's own scope, a behavior fix in response to a real gap is
a Planning decision, not something a verification packet folds in.
Both confirmed by reading the actual source, not inferred.

### Finding 1 — audit metadata leak (small, likely one-line)

`Admin::PatronsController#log_patron_creation`
(`rails/app/controllers/admin/patrons_controller.rb`) embeds the
patron's actual email value in audit metadata on the `admin.patrons.create`
action: `metadata: { user_id: user.id, email: user.email }`. Every other
audit call site in this domain (`patron_metadata_values_controller`,
`offering_orders_controller`, `dependents_controller`, registration
create/update) carries only field names/counts. This is the one
outlier.

### Finding 2 — privacy data-deletion gap (real, not hypothetical)

`Privacy::UserDataDeletionFulfillment#anonymize_user!` and
`#anonymize_dependents!` both `.merge(...)` onto `metadata` instead of
clearing it. Contrast: `scrub_preferences!`/`scrub_privacy_settings!` in
the same service already reset their metadata to `{}` — the codebase
has the correct pattern, just not applied to reusable-defaults data.

Practical effect: after a fulfilled `data_deletion` privacy request, the
full `registration_reusable_defaults_v1` tree survives untouched on the
user record, and the equivalent per-dependent metadata survives on each
dependent — including free-text fields (`dedication_message`,
`ancestor_placard_name`) that can name specific people. Predates
A0–A3 — not introduced by this track's work — but this is precisely the
storage this whole track is about, and Phase A3's own item 11 ("privacy
export/deletion/closure behavior remains compatible") explicitly
required proving this, which it did not pass. Export side is fine
(`privacy_flow_test.rb` already covers it, still passing) — deletion
side is the confirmed gap.

## Track Status

Per `ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`'s
Acceptance Criteria, the track is not yet fully closeable — Finding 2
maps directly to a required A3 proof item that failed, not an
incidental side note. Sequencing (own packet vs. bundled, priority
relative to other work) is a Planning/Director decision, not made here.

## Closeout

Control A idle, standing by for direction on Findings 1 and 2.
