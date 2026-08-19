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

## What's Confirmed

- `sourcegrid-labs/TENANT_OAUTH_INTEGRATION_GUIDE.md` documents the
  registration model: a tenant needs a row in `auth_tenants`, at least
  one exact URL in `auth_tenant_redirect_uris`, and machine credentials
  (`token_exchange_client_id`/secret hash). It also has its own
  "Cutover checklist (per tenant)" — including *"Return URL(s) added
  exactly to `auth_tenant_redirect_uris`"* — which already exists as a
  process, it just wasn't re-run when native support was added to an
  already-onboarded tenant.
- `sourcegrid-labs/CENTRALIZED_AUTH_SERVICE_PLAN.md` (dated March 5)
  recorded the `shengfukung` tenant's registered return URLs as only
  the two web callback URLs — no native scheme entry.
- **Confirmed live, not just from a possibly-stale doc**: a direct
  probe replicating `Auth::CentralOAuthClient`'s real production call
  (correct `tenant_slug=shengfukung`, ruling out a tenant-slug mismatch
  as a contributing cause) got `422 {"error":"invalid_return_url"}`
  straight from `auth.sourcegridlabs.com` itself. Full trace:
  `ops/docs/handoffs/2026-08-19-native-oauth-full-trace-confirmed-blocker.md`.
  This is now the **only** remaining blocker on native OAuth — every
  Wenfu-side gap (stale deploy, missing env var) is fixed and verified.

## Immediate Item — Done, 2026-08-19

Dispatched directly to Codex SourceGrid Planning (a session with actual
`sourcegrid-labs` authority — this repo never mutated that system).
Confirmed complete, independently re-verified, not just trusted:

- `templemate://oauth/complete` added as row `id=2` on the `shengfukung`
  `AuthTenant` — additive only, nothing removed or modified.
- `allowlisted_return_url?("templemate://oauth/complete")` re-queried
  and confirmed `true`.
- **Correction to this doc's own earlier claim**: live production only
  had one pre-existing web callback
  (`https://shengfukung.com.tw/auth/callback`), not the two recorded
  above from the March 5 planning doc — Codex caught this discrepancy
  against live data rather than accepting what this doc said.
- No live `/oauth/start` replay was performed (would need the tenant's
  confidential machine credential, correctly not accessed for this) —
  Codex confirmed instead, at the code level, that the `422
  invalid_return_url` branch is directly gated by the now-true allowlist
  predicate. **Final end-to-end confirmation is a real sign-in attempt
  on the TestFlight build**, not yet done.

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
