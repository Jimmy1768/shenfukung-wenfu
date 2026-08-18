# Admin Patron Profile And Dependents CRUD

## Objective

Admin can currently `create` a brand-new patron but has no way to edit an
existing patron's profile, and a patron's dependents (where overlapping
fields like a dependent's name live) are read-only display in the admin
patron list — no admin create/update/destroy path exists at all. Extend
admin with real edit capability for both, reusing the exact same forms
the patron already uses on themselves — not a parallel admin-specific
implementation. Same low-friction model as the just-shipped
reusable-defaults packet: both parties write through identical logic,
last write wins, no new ACL.

## Prior state (verified, not assumed)

- Patron self-service is fully built: `Account::ProfileController` /
  `Account::ProfileForm` (`english_name`, `native_name`, `phone`, `city`,
  `notes`) and `Account::DependentsController` / `Account::DependentForm`
  (full CRUD: `english_name`, `native_name`, `relationship_label`,
  `birthdate`, `phone`, `email`, `notes`). Both forms take `user:` as a
  plain argument — nothing ties them to `current_user` specifically.
- `Admin::PatronsController` has `create` (gated by `can_manage_admins?`,
  i.e. the `manage_permissions` capability — stricter than the rest of
  Track A) but no `edit`/`update`. `patron_payload` shows dependent
  name/phone/email/notes/relationship read-only; no admin dependent CRUD
  exists.

## Scope

1. Add `edit`/`update` to `Admin::PatronsController` for an existing
   patron's core profile — reuse `Account::ProfileForm` directly
   (`Account::ProfileForm.new(user: @patron, params: ...)`), do not
   reimplement it.
2. Add dependent create/update/destroy on the admin side, reusing
   `Account::DependentForm` directly the same way
   (`user: @patron`) — same reasoning, same form, different actor.
3. Capability gate: use `manage_registrations`, matching the precedent
   the just-shipped reusable-defaults packet already established — not
   the stricter `manage_permissions`/`can_manage_admins?` currently on
   `create`. Defaulting to this rather than asking; flag it in the
   terminal report if it turns out wrong, don't block on confirming it
   up front.
4. No new permission/ACL design. Both patron and admin write through the
   same forms; last write wins, as already established for the
   reusable-defaults work.
5. UI: embed into the existing admin patron view (index/show), mirroring
   the patron-facing profile/dependents forms' field set and labels —
   same "reuse the patron-facing shape" pattern as the offering-orders
   reusable-defaults packet.
6. Rails/Vue only.

## Required checks

- Full Rails suite green.
- End-to-end tests proving the actual round trip both directions: admin
  edits a patron's profile field → patron sees it updated on their own
  profile page; admin edits/creates a dependent → patron sees it on
  their own dependents list; and the reverse (patron edits their own
  dependent → shows correctly in admin's patron view). Controller-level
  assertions alone aren't enough, same bar as the last packet.
- No migration/schema change expected — flag and stop if one turns out
  to be needed rather than adding one silently.

## Branching

`claude/admin-patron-profile-dependents-crud` — test to green, merge to
`main` per Claude Work Mode.

## Track independence

Runs on Control A (Rails/account/admin), independent of Track B.
