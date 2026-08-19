# Expo V1 Registration Authority Alignment Plan

Status: accepted for direct implementation dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Canonical Planning base:
`7da778288e84a6af089c6fee82c0985160e3ff1a`

Accepted runtime evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-final-ui-evidence-continuation-control-b.md`

Parallel-track boundary: Control A retains the separate Rails/web Apple OAuth
production-rollout-readiness track. This packet owns only the account
registration contract needed by TempleMate and must not edit OAuth rollout
plans or OAuth behavior.

## Objective

Replace TempleMate's freeform registration draft with the existing account
namespace authority model:

1. the temple defines offerings through its existing admin/web lifecycle;
2. the patron selects one of those offerings from the account discovery
   surface rather than authoring or relabeling an offering;
3. Rails supplies the offering identity, fee, currency, and form defaults;
4. the patron selects self or one of the signed-in account's dependents and
   edits only the account registration fields already permitted by Rails; and
5. create/update remains usable without payment, while paid fixtures and paid
   records remain read-only and expose no checkout action.

This is contract alignment and functional completion. It is not a visual
redesign, payment phase, admin-mobile phase, or new offering system.

## Parent Classification

The final UI evidence continuation is complete and accepted on canonical
`main` at `7da778288e84a6af089c6fee82c0985160e3ff1a`. Its CameraView Cancel,
dependent edit/delete, paid-read-only, reset, checks, and cleanup evidence is
accepted. The exact-value dependent-create row remains an evidence-method gap,
not a product defect.

The Expo V1 registration parent is incomplete. Runtime evidence established a
true product-contract mismatch: the mobile Add path exposes freeform
offering/registrant fields and can create or relabel a local draft without
first selecting a temple-defined offering or presenting its authoritative
fee. Draft edit was correctly stopped and remains untested.

## Existing Account Authority

The accepted behavior already exists in Rails/web and must be reused rather
than redesigned:

- account Events and Services present temple records and link to registration
  `new` with the offering slug and server-recognized `account_action`;
- `Account::RegistrationIntent` resolves that identifier only within the
  current temple and determines event/service/gathering type;
- the web `new` page presents the offering title and its formatted
  `price_cents`/`currency` as read-only details;
- the registrant picker offers only the signed-in user and that user's existing
  dependents;
- `Account::RegistrationIntakeForm` derives unit price, total, currency,
  temple, and registrable identity from the resolved offering; it does not
  accept those authorities from the patron;
- `Account::RegistrationMetadataForm` edits only permitted contact,
  registrant, quantity, logistics, and ceremony metadata under the existing
  lifecycle policy; it cannot replace the offering or its price; and
- the native account API already exposes registration `new/create/edit/update`
  and enforces temple ownership, duplicate rules, intake freeze, and lifecycle
  restrictions.

The missing native parity is bounded: discovery/preparation responses do not
yet expose enough authoritative offering/action/fee data for TempleMate, while
the current dummy repository and UI accept arbitrary offering and registrant
text.

## Frozen Product Decisions

### Offering authority

1. Temple administrators remain the sole creators/editors of events, services,
   gatherings, offering names, offering fees, currency, availability, and
   related rules. TempleMate adds no admin surface.
2. A patron cannot type an offering name, slug, action type, price, currency,
   or total. No mobile control may present those values as editable.
3. The mobile Discover surface is the entry point for a new registration,
   matching the web account flow. The Registrations surface lists existing
   registrations and may direct the patron to Discover; it must not contain a
   freeform Add-offering form.
4. Only offerings returned by the current temple's accepted account discovery
   scopes may be presented. No global, cross-tenant, stale-fixture, or
   client-invented offering is eligible.

### Fee authority

1. Rails is the final authority for `price_cents`, currency, quantity rules,
   and the persisted total.
2. The native registration preparation response must return the resolved
   offering's read-only unit fee and currency together with its identity,
   account action, and form defaults. A client-rendered total may be calculated
   only from that response and selected quantity for presentation; the server
   remains authoritative on create.
3. Create/update request bodies must never submit offering title, price,
   currency, total, payment status, provider, or checkout data. A forged money
   field must be ignored or rejected and can never alter the persisted server
   amount.
4. Zero-priced offerings remain valid if the existing Rails offering and form
   rules allow them. TempleMate must not invent a paid/free eligibility rule.

### Registrant and metadata authority

1. Registrant selection is exactly `self` or an existing dependent owned by
   the signed-in account in the current tenant. The UI may show the resolved
   name, but it must not accept an arbitrary registrant identity string.
2. The selected registrant drives the accepted Rails defaults. Contact name,
   phone, email, household notes, quantity, arrival window, and ceremony notes
   may be edited only where the existing intake/metadata forms permit them.
3. A foreign, missing, or deleted dependent fails safely. It never falls back
   to self or creates a new dependent as a side effect.
4. Existing registration edit keeps offering identity and fee read-only and
   submits only fields permitted by `RegistrationMetadataForm` and the current
   lifecycle policy.

### Payment boundary

Registration creation and permitted metadata update are part of V1 even when
the patron cannot pay in the app. This phase adds no ECPay, Stripe, provider,
checkout, payment-status polling, refund, settlement, or payment lifecycle.
The existing minimal payment status may be displayed read-only. A paid fixture
or paid server record remains non-actionable in TempleMate.

## Required Rails Native Contract Alignment

Control B may make the smallest additive native account JSON changes needed to
represent the existing browser account flow. The accepted response contract
must provide:

- for each discoverable event/service/gathering: stable ID, slug, title,
  server-recognized `account_action`, current presentation status, and
  authoritative unit fee/currency when available;
- from registration `new`: the resolved offering ID/slug/title,
  `account_action`, authoritative `price_cents` and currency, plus the existing
  intake defaults; and
- from registration `edit/show/create/update`: enough immutable offering,
  registrant, quantity, total/currency, lifecycle, and read-only payment state
  to render the accepted account surface truthfully.

Control may extend the existing native resource responses or add one narrowly
scoped registration-offering response if that is materially smaller and keeps
one authority. It must not create a second offering model, duplicate admin
rules in JavaScript, or broaden browser/API payment behavior.

Use the existing account discovery scopes, `RegistrationIntent`, intake form,
metadata form, serializer authority, tenant/user scopes, and lifecycle policy.
Do not make the client decide server eligibility from labels or guessed status
strings. If the existing browser flow has no stricter availability rejection,
this packet does not invent one.

## Required TempleMate Flow

### Dummy mode

- Replace arbitrary draft creation with a deterministic, network-free catalog
  of temple-admin-defined fixture offerings corresponding to the existing
  event/service/gathering fixture surfaces.
- Each fixture offering has an immutable ID, slug, action, title, fee, and
  currency. The dummy repository, not freeform input, owns those values.
- Selecting a Discover item opens a prepared registration state with read-only
  offering/fee presentation and account-form defaults.
- Registrant choices are the fixture account and its current dependents.
- Create/update exercises the same permitted fields and immutable boundaries
  as the real adapter. Reset restores the canonical catalog, one dependent,
  and one paid/read-only registration.
- Unknown offering IDs/actions, missing dependents, duplicate selections, and
  edits to read-only registrations fail without partial mutation.

### Real local/test mode

- Discover uses only the current native account JSON responses.
- Selecting a server offering calls registration `new` before showing the
  create form. Preparation failure, intake freeze, stale offering, or tenant
  mismatch leaves the previous UI state intact and shows a safe error.
- Create sends only the selected offering slug/action plus permitted
  registration fields. It does not fall back to dummy data or locally supplied
  money/identity authority.
- Edit loads registration `edit`, keeps offering/fee immutable, and submits
  only permitted metadata. Lifecycle rejection leaves the accepted server
  record unchanged in the UI.
- Successful create/update refreshes or deterministically reconciles the
  account registration list without duplicates.

### Presentation

Use the existing TempleMate component/style system and current zh-TW/en copy
structure. The minimum accepted presentation is:

- a visible Register action on an applicable Discover offering;
- a read-only offering title and formatted fee/currency;
- a self/dependent selector;
- the current Rails intake/edit fields needed for account parity;
- a clear create/update/cancel path; and
- existing read-only status for paid records.

Do not introduce a navigation framework, form library, new design system,
admin toggle, offering editor, or payment CTA. Final visual polish beyond
truthful hierarchy and usable controls remains outside this contract repair.

## Owned Paths

Control B may authorize one ephemeral Implementer to edit only the smallest
set within:

- `rails/app/controllers/api/v1/account/native_registrations_controller.rb`;
- `rails/app/controllers/api/v1/account/native_resources_controller.rb`;
- existing native account serializers or one small shared native offering
  presenter under `rails/app/serializers/account/api/`;
- focused native account registration/resource integration tests;
- `mobile/App.js` and focused account registration/discovery state extracted
  under `mobile/app/account/` if needed;
- existing `mobile/app/dummy/`, `mobile/app/real/`, and `mobile/app/ui/copy.js`;
- focused mobile dummy, real-adapter, registration-state, and UI tests; and
- Control-owned immutable packet/report paths under `ops/docs/handoffs/`.

No migration, schema, model, admin controller/view, browser account behavior,
OAuth, provider, payment, Vue, Expo config, dependency, lockfile, native
generated project, version, build, deployment, or release path is owned.

If implementation evidence proves a schema/model/admin/browser semantic change
is required, return `true_planning_design_gap`; do not broaden the packet.

## Required Evidence

Rails tests must prove:

- discovery and preparation return only current-temple offerings with the
  exact server action and fee/currency authority;
- registration `new` returns authoritative offering and defaults for event,
  service, and gathering paths already supported by the account namespace;
- create derives persisted unit/total/currency from the offering even when the
  request attempts to supply conflicting money fields;
- self and owned-dependent creation work; foreign/missing dependent fails;
- foreign/stale offering, intake freeze, duplicate registration, and lifecycle
  restrictions remain fail-closed;
- edit/update cannot change offering or monetary authority; and
- browser account registration and existing native session/resource tests
  remain green.

Mobile tests must prove:

- no freeform offering, slug, action, registrant identity, price, currency, or
  total entry remains in the registration flow;
- dummy Discover -> prepare -> self/dependent create -> edit transitions use
  catalog authority and do not duplicate rows;
- unknown offering/dependent, duplicate, failure, and read-only paid cases do
  not partially mutate state;
- real preparation and create/update requests match the accepted Rails shape
  and contain no client money/payment authority;
- preparation/create/update failure preserves prior state and real mode never
  falls back to dummy;
- offering and fee remain immutable during edit;
- zh-TW/en, light/dark, account-only navigation, reset, tenant scoping, and
  excluded admin/payment/OAuth surfaces remain intact.

Control independently runs:

- focused Rails native registration/resource tests plus browser account
  registration regressions;
- focused mobile registration/dummy/real/UI tests;
- full `yarn test`, `yarn lint`, and `yarn verify`;
- Ruby syntax checks for every changed Ruby source path;
- route/response and prohibited-field scans;
- `git diff --check`, staged diff check, and exact owned-path review.

Use only an already available byte-identical dependency tree through the
accepted temporary-symlink method if needed; remove it before acceptance. Do
not install or copy dependencies. Expo Doctor, prebuild, Gradle, EAS, APK/AAB,
and device evidence are not source-packet acceptance criteria because no
native dependency/configuration change is authorized.

## Acceptance Criteria

1. TempleMate patrons can create a registration only by selecting a
   current-temple, temple-defined offering presented through Discover.
2. Offering identity/action/title and fee/currency are read-only and come from
   Rails authority in real mode or deterministic catalog authority in dummy
   mode.
3. Registrant selection is restricted to self or an owned dependent; contact
   and registration metadata follow the existing Rails forms.
4. Server creation remains authoritative for persisted price, total, currency,
   temple, and registrable identity; forged client authority cannot alter it.
5. Existing draft metadata can be edited without changing offering/fee, while
   lifecycle and paid/read-only restrictions are preserved.
6. No payment, checkout, provider, admin, OAuth, cross-tenant, or dummy fallback
   behavior is added.
7. Focused Rails/mobile regressions and the full mobile checks pass.
8. TempleMate/Komainu identity, API 36, and `1.0.0 / Android 1 / iOS 1` remain
   unchanged.
9. Canonical and isolated Git states are clean with staging empty after
   accepted local integration.

## Sequencing

This source packet runs through Control B while Control A independently owns
OAuth rollout readiness. Neither Control coordinates with the other and no
path overlap is authorized.

After an accepted source integration, Planning will write one separate
installed-client runtime-validation plan. It will reuse the installed
development client and exact USB Metro method to validate:

- Discover offering selection;
- read-only authoritative fee presentation;
- self and dependent draft creation;
- draft metadata edit without offering/fee change or duplication;
- paid fixture read-only/no payment;
- reset and cleanup; and
- the remaining exact dependent-create visible evidence if still necessary.

No native rebuild is expected. This plan does not authorize Metro, ADB/device
work, EAS/build, provider/server rollout, production, deployment, release,
store/OTA, or push.

## Terminal Classifications

- `expo_v1_registration_authority_alignment_complete`;
- `true_planning_design_gap`;
- `no_evidence_backed_direct_repair_remaining`.

Current classification:
`expo_v1_registration_authority_alignment_authorized`.

First blocker: none at dispatch.
