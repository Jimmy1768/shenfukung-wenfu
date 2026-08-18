# Control A Packet — Account/Admin Offering-Data Contract, Phase A2

## Identity

- Accepted plan: `ops/docs/plans/ACCOUNT_ADMIN_PERSONAL_AND_OFFERING_DATA_CONTRACT_PLAN.md`,
  Phase A2 — Rails Surface Alignment (plan's existing definition, used
  unmodified).
- Control: Wenfu Control A (session `local_915b44b0-14b1-4b09-bd97-da19a1169d41`).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- Pure verification. No branch, no worktree, no code changes.

## Scope

Confirm the plan's stated UX invariants still hold on current code
(post-A1), rather than assume the phase implies new build work.

## Findings — Each Verified First-Hand

1. **Prefill only fields present in schema** — confirmed.
   `Registrations::ReusableDefaults#eligible_fields` is strictly
   schema-derived; `write!` filters through `eligible_field?` before
   storing anything; both prefill call sites read through the same
   service scoped to the exact offering. No cross-schema leakage
   possible.
2. **Patrons and authorized admins can overwrite editable values** —
   confirmed, unchanged since A0/A1. Both sides gate through
   `Registrations::LifecyclePolicy`, symmetric.
3. **Missing optional fields do not block registration** — confirmed.
   Form-level validation requires only `quantity`, `contact_name` (when
   contact-editable), and registrant scope/dependent selection.
   Model-level validation touches nothing on logistics/ritual_metadata/
   contact fields.
4. **Paid/lifecycle-locked snapshots remain protected** — confirmed,
   untouched by A1; `LifecyclePolicy`,
   `policy_filtered_update_attributes`, `redirect_gathering_edits!`, and
   `reusable_write_allowed?` intact exactly as A0 traced them.
5. **Profile/dependent editors remain the explicit way to clear reusable
   data** — confirmed. `ProfileForm`/`DependentForm` use `.compact`
   (strips nil only), so an explicit blank submission writes through as
   a real clear. Separately, `ReusableDefaults#write!` always ignores
   blank values, so a blank field on a *registration* submission can
   never implicitly clear a reusable default. No implicit-clear path
   exists anywhere.
6. **No new admin hierarchy/approval flow** — confirmed, nothing of the
   sort introduced anywhere in this track.
7. **Native JSON controllers inherit service behavior, no mobile
   expansion** — confirmed. `Api::V1::Account::NativeRegistrationsController`
   calls the same `RegistrationIntakeForm`/`RegistrationMetadataForm`
   classes A1 touched, so the A1 consolidation already flows through
   natively with zero native-specific change. No native/mobile change
   made.

## Two Observations — Noted, Not Actioned (Correctly Out Of Scope)

- The account-facing registration form
  (`_form.html.erb`/`_existing_form.html.erb`) doesn't use
  `schema.include_field?` to show/hide fields per-offering the way the
  admin form does — it always renders contact/arrival_window/
  ceremony_notes fields, gated only by gathering-vs-not. No
  prefill-safety or data-integrity consequence (`ReusableDefaults`
  independently enforces eligibility on write regardless of what the
  form renders) — a UI-consistency gap between the two surfaces, not a
  contract violation. Building account-side schema-driven field
  visibility would be new scope beyond "keep the existing simple UX."
- Neither registration order form (account or admin, as distinct from
  the standalone admin reusable-defaults panel) can render a genuinely
  novel field name outside `FormSchema::DEFAULT_SECTIONS`' fixed
  ~14-field vocabulary — schema customization in existing tests only
  reorders/subsets/toggles multi-value on those existing names.
  Pre-existing platform characteristic, not something A1 touched or A2
  asked about.

## Closeout

Pure verification, nothing to build. All seven stated invariants hold.
Control A idle, standing by for Phase A3.
