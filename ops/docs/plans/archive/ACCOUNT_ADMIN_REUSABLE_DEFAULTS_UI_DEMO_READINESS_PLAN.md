# Account/Admin Reusable-Defaults UI — Demo Readiness

## Objective

Sales needs a working prototype to demo. The backend already supports
low-friction shared editing (patron self-service and admin, both able to
overwrite the same reusable per-offering data, gated only by the existing
`manage_registrations` capability — no fine-grained ACL). The gap is
specifically that admin's write path
(`Admin::PatronMetadataValuesController#create`/`#destroy`) is a raw JSON
API with no view — give it a real form, mirroring what a patron already
sees in their own registration form. This is UI completion, not new
authorization design.

## Prior state (verified, not assumed)

- `app/services/registrations/reusable_defaults.rb` — the shared storage
  boundary both paths already write through.
- `app/controllers/admin/patron_metadata_values_controller.rb` —
  `create`/`destroy` JSON actions exist, capability-gated
  (`require_manage_registrations!`), audit-logged. No corresponding view.
- `app/controllers/admin/offering_orders_controller.rb` — already has full
  `new`/`edit`/`update` actions for admin to create/edit a registration on
  a patron's behalf; views exist at `app/views/admin/offering_orders/`.
- `app/views/account/registrations/_form.html.erb` /
  `_existing_form.html.erb` — the patron-facing reference for what fields
  exist and how they're presented (`contact_name`, `contact_phone`,
  `contact_email`, `household_notes`, `arrival_window`, `ceremony_notes`,
  plus offering-schema-driven reusable fields).

## Scope

1. Build a real admin view for the reusable-defaults data, embedded in the
   existing admin offering-orders screens (not a new standalone page) —
   admin can see, add, edit, and clear the same per-offering fields a
   patron's own form would draw defaults from and write back to. Mirror
   the patron-facing field presentation; don't invent a different shape
   for admin.
2. Confirm the existing admin `new`/`edit` registration screens
   (`offering_orders`) actually render and submit cleanly end-to-end —
   this is what sales will click through live, so it needs to work, not
   just exist in the controller.
3. **Do not touch** `Registrations::LifecyclePolicy` (`core_fields_editable?`
   / `contact_fields_editable?`) — that's state-based (payment/fulfillment
   status), not an authorization question, and out of scope here.
4. **Do not** design new permission/ACL logic — the existing
   `manage_registrations` capability gate already matches "no convoluted
   matrix, no bad actors." Reuse it as-is.
5. Form/view duplication (`RegistrationIntakeForm` vs
   `RegistrationMetadataForm`, `_form.html.erb` vs `_existing_form.html.erb`)
   — opportunistic cleanup only if directly in the way of this work, not a
   mandated refactor. Demo-ready beats pristine right now.
6. Rails/Vue only. No mobile/Expo work — independent of Track B.

## Required checks

- Full Rails suite green.
- Manual-equivalent coverage: a request/system test that actually drives
  the new admin view end-to-end (add a reusable field value as admin,
  confirm it appears as a default in a subsequent patron registration
  form) — not just controller-level JSON assertions, since the whole
  point is the UI existing and working.
- `git diff --check`; no migration/schema change expected — flag and stop
  if one turns out to be needed rather than adding one silently.

## Branching

`claude/account-admin-reusable-defaults-ui` — test to green, merge to
`main` per Claude Work Mode.

## Track independence

Runs in parallel with Track B (Control B, TempleMate/EAS, currently
holding for direct Director authorization). No coordination needed
between them.
