# Central Auth Tenant Registration Plan

## Objective

Two distinct things, don't conflate them:

1. **Immediate, narrow, Wenfu's own requirement**: register
   `templemate://oauth/complete` as an allowed return URL for the
   `shengfukung` tenant in `auth.sourcegridlabs.com`'s
   `auth_tenant_redirect_uris`, so native OAuth can actually reach the
   central client instead of failing at Wenfu's own missing env var
   (already being fixed separately —
   `ops/docs/plans/PLATFORM_ENV_FILE_REORGANIZATION_PLAN.md`).
2. **Broader, later, not Wenfu's to execute**: cleaner/more robust
   tenant organization in the central auth service itself, since the
   Director plans many more apps to register there over time. This is
   `sourcegrid-labs`'s own system — out of this repo's authority to
   change directly.

## What's Confirmed (read-only, from `sourcegrid-labs`, not acted on)

- `sourcegrid-labs/TENANT_OAUTH_INTEGRATION_GUIDE.md` documents the
  registration model: a tenant needs a row in `auth_tenants`, at least
  one exact URL in `auth_tenant_redirect_uris`, and machine credentials
  (`token_exchange_client_id`/secret hash). It also has its own
  "Cutover checklist (per tenant)" — including *"Return URL(s) added
  exactly to `auth_tenant_redirect_uris`"* — which already exists as a
  process, it just wasn't re-run when native support was added to an
  already-onboarded tenant.
- `sourcegrid-labs/CENTRALIZED_AUTH_SERVICE_PLAN.md` (dated March 5,
  possibly stale) records the `shengfukung` tenant's registered return
  URLs as only the two web callback URLs — no native scheme entry.

## Immediate Item — Blocked On Cross-Repo Authority, Not Wenfu Work

Adding `templemate://oauth/complete` to `shengfukung`'s allowed return
URLs is a mutation in `sourcegrid-labs`'s own database/system, not a
Wenfu repo change. This plan does not authorize making that change from
here. Options, Director's call:

- Director does it directly in that system (console, rake task,
  whatever the actual mechanism is — not yet identified from here).
- A session with actual `sourcegrid-labs` authority (its own
  Planning/Control, if one gets set up, or Strategy given cross-repo
  coordination is its stated role) does it as a proper packet there.

## Broader Item — Explicitly Deferred, Needs Its Own Decision

"More robust/clean organization of tenants" in the central auth service
is real scope, not something to bolt onto the narrow immediate need.
Needs its own plan, owned and executed inside `sourcegrid-labs` (or by
whichever governance structure the Director sets up there), once that's
decided. Not scoped further here — this doc's job is just to not lose
the requirement, not to design the solution for a system this repo
doesn't own.

## Next Owner/Action

Planning holds this until the Director decides how cross-repo
`sourcegrid-labs` work gets organized (own Work Mode setup, Strategy-routed,
or Director-direct) — same open question raised earlier, still
unanswered. No dispatch from Wenfu Control A/B either way; neither owns
another repo's production auth system.
