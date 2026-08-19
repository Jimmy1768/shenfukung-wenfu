# Native OAuth — Full Trace, Wenfu Side Confirmed Clean

## Status

Wenfu side fully diagnosed and fixed. One confirmed remaining blocker,
outside this repo's authority — `sourcegrid-labs`'s own tenant
registration.

## Chain Of Findings, In Order

1. **Production namespace stale** (fixed 2026-08-19 earlier today) —
   `/api/v1/*` 404s from a stale manual deploy. See
   `ops/docs/handoffs/2026-08-19-production-native-api-namespace-deploy-fix.md`.
2. **`AUTH_NATIVE_RETURN_URL` missing from production env** (fixed
   today) — native OAuth failed at the very first step with `503
   native_oauth_unavailable`. See
   `ops/docs/plans/TEMPLEMATE_REFINE.md`'s Production-Side section.
3. **Tenant slug mismatch — hypothesized, then ruled out.** Suspected
   `central_tenant_slug` might fall back to the local temple slug
   (`shengfukung-wenfu`) instead of the registered central-auth tenant
   (`shengfukung`). Confirmed false: `AUTH_TENANT_SLUG=shengfukung` is
   correctly set in production. Verified with a direct probe script
   (`Auth::CentralOAuthClient`'s own logic replicated, run via `bin/rails
   runner` on the droplet using the real loaded env) that bypassed the
   client's own error-swallowing (`Auth::CentralOAuthClient#parse_response!`
   discards the real HTTP status/body into a generic `RequestError` with
   no detail — the API's `502 oauth_start_failed` alone couldn't have
   confirmed or ruled this out).
4. **Confirmed live: `invalid_return_url`.** The direct probe, using
   the real production credentials/tenant slug, got a definitive answer
   from `auth.sourcegridlabs.com` itself:
   ```
   tenant_slug sent: shengfukung
   HTTP status: 422
   Body: {"error":"invalid_return_url"}
   ```
   This matches `CENTRALIZED_AUTH_SERVICE_PLAN.md`'s recorded
   registration for the `shengfukung` tenant — only the two web
   callback URLs, no native scheme. `templemate://oauth/complete` is
   not an allowed return URL for this tenant.

## What's Left

Exactly `CENTRAL_AUTH_TENANT_REGISTRATION_PLAN.md`'s immediate item:
register `templemate://oauth/complete` in `auth_tenant_redirect_uris`
for the `shengfukung` tenant. That's `sourcegrid-labs`'s own system —
not a Wenfu repo change, not something Control A/B or this session can
execute. Still needs the Director's decision on how that gets done
(direct action there, or a governance structure set up in that repo).

## Cleanup

Diagnostic probe script (`/tmp/oauth_probe.rb` on the droplet) is
scratch, not part of the app — safe to leave (server-local tmp file,
not committed anywhere) or remove, Director's call, not urgent.

## Closeout

No further Wenfu-side action until the central-auth registration is
resolved. Once it is, the very next sign-in attempt should be the real
test of whether the full chain — app → Rails → central-auth → back to
app — completes end to end for the first time.
