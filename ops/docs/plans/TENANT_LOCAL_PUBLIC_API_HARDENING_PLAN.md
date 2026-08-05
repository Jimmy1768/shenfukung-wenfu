# Tenant-Local Public API Hardening Plan

Status: readiness scanned; phased implementation criteria accepted; implementation not yet dispatched

Owner: Wenfu Planning

Date: 2026-08-05

## Purpose

Make the public web/API contract match TempleMate's deployment model: each
temple is an independent tenant deployment with its own repository checkout,
Vue distribution, protected environment file, domain, and Rails runtime. A
tenant deployment is not a public temple registry and must never require a
browser to name or select another temple.

This is a bounded routing and frontend-build hardening patch. It does not
change assisted onboarding, owner/admin authority, tenant records, ECPay
patron-to-temple payment semantics, TempleMate Stripe platform billing,
provider credentials, deployment authorization, or any live data.

## Evidence And Current State

The following observations establish the correction scope:

- On 2026-08-05, the public Vue bundle served at
  `https://shengfukung.com.tw/frontend/assets/index-nFdFC2uu.js` contained
  `http://localhost:3002`. The in-app browser consequently displayed
  `資料載入失敗，請稍後再試。`; its content request failed before reaching
  the public API.
- The affected bundle's filesystem timestamp on the Wenfu host was
  `2026-07-13T04:28:53Z` (12:28:53 Asia/Taipei). This is evidence of the
  served artifact, not evidence that a later backend/Stripe change caused the
  regression.
- The host's protected environment currently configures
  `VITE_API_BASE_URL=https://shengfukung.com.tw`, but Vite substitutes public
  variables at build time. Changing the environment after a build cannot
  repair an already-served static bundle.
- The current Rails public routes, Vue client, smoke script, and active
  deployment references use `/api/v1/temples/:slug`. That is incompatible with
  the intended tenant-local external contract even though the current
  `shengfukung-wenfu` record is the only configured deployment tenant.
- The observed production listener is Puma on port `3000`, with Nginx exposed
  on `80` and `443`.

## Readiness Scan — 2026-08-05

| Surface | Evidence | Readiness |
| --- | --- | --- |
| Current regression | The served bundle and a disposable build from current source have the identical SHA-256 `83b4d45df856c606fc9dcb19cf17996cee8f005af5a2c094dcd1ef22087f9a8a`. It contains `localhost:3002`. | Correction is reproducible; not a transient host failure. |
| Server routing | The public API is concentrated in `rails/config/routes.rb`; its controllers already obtain `current_temple` through `TempleContext`. The public resolver currently allows `params[:slug]` before `PROJECT_SLUG`. | Ready for a bounded route/resolver patch; no schema or data migration is needed. |
| Browser client | `vue/src/app/templeApi.js`, `theme.js`, `utils/accountLinks.js`, and the Vite proxy contain browser-visible `localhost` or tenant-selection behavior. `DemoShowcase.vue` also accepts the obsolete API-base variable. | All known client surfaces are identified and must be corrected together. |
| Port convention | Puma's current development default and several CORS/origin/docs references still use `3002` for local work. Production on the observed host is explicitly configured as `3000`. | Ready for a configuration/reference alignment; do not infer a live staging host change. |
| Test baseline | `bundle check` passed. Focused routing, public-contact, and tenant-context tests passed: 11 runs, 30 assertions, no failures/errors/skips. | Existing Rails coverage is a viable base for route-removal tests. |
| Build baseline | `npm exec vite build -- --outDir /tmp/wenfu-tenant-api-readiness-build` passed using local dependencies. | A disposable production-artifact scan can be a required deterministic check. |
| External state | No provider, credential, host, database, Nginx, or deployment mutation is needed for local implementation. | Local patch is ready; release remains separately gated. |

The only local check issue was sandbox isolation from PostgreSQL; the same
focused Rails suite passed once run against the local test database. It is not
a repository or product blocker.

## Fixed Environment-Port Convention

Use this convention consistently in configuration, development tooling, and
deployment references:

| Suffix | Environment | Application port |
| --- | --- | --- |
| `0` | live production | `3000` |
| `1` | local development | `3001` |
| `2` | live staging | `3002` |

`3002` is therefore a valid staging application port. The failure above was
the literal browser hostname `localhost`, not the number `3002`: in a visitor
browser `localhost` means that visitor's computer, not the Wenfu droplet.

Nginx is the public boundary. A browser calls its tenant's own HTTPS origin;
Nginx selects the environment-appropriate internal Puma listener. Public Vue
code must not expose an internal port or hard-code `localhost`.

## Frozen Target Contract

### Tenant-local public surface

Replace the plural, slug-addressed public contract with a singular,
tenant-local contract:

```text
/api/v1/temple
/api/v1/temple/news
/api/v1/temple/archive
/api/v1/temple/events
/api/v1/temple/events/:event_slug
/api/v1/temple/services
/api/v1/temple/services/:service_slug
/api/v1/temple/gatherings
/api/v1/temple/contact_temple_requests
```

The public controller resolves the deployed tenant from the server-side
`PROJECT_SLUG` configuration. A public URL parameter, Vue environment value,
hosted bundle, or request body must not select a temple. The internal `Temple`
record and scoped server-side account/admin controls remain necessary; this
plan changes only the public, tenant-facing route shape.

All `/api/v1/temples/:slug...` public routes are removed. They must return
`404` rather than act as compatibility aliases, so an old bundle or a future
copy cannot silently reintroduce a cross-tenant public contract.

### Vue and build behavior

- Vue public-content requests use same-origin relative paths beginning
  `/api/v1/temple`.
- Remove `VITE_API_BASE_URL` and its `localhost` fallback from the public
  content client and tenant environment template. It is not a public runtime
  setting in this architecture.
- Vite's development-server proxy is the only development-only upstream
  configuration. Its default follows the local-development convention
  (`localhost:3001`), and an explicit development override may be used when
  needed. Its value must not be compiled into a production or staging bundle.
- Tenant identity/theme environment entries needed for local presentation or
  server-side configuration may remain only where their callers do not create
  a public tenant-selection API route. Review their remaining uses explicitly
  rather than removing them blindly.

### Deployment and verification behavior

- Each tenant's Vue build is created while that tenant's own protected
  environment is loaded, then deployed to that tenant's own Vue distribution.
- Public smoke tests call `${base_url}/api/v1/temple`, never a manifest slug
  path. The manifest remains deployment metadata, not a public API registry.
- Active deployment guides and command references use the singular endpoint
  and distinguish the internal `3000/3001/3002` convention from public HTTPS
  URLs.

## Phased Implementation Plan

### Phase 1 — Server-side tenant boundary

Replace the public route family with the singular paths in this plan. Make the
public resolver select only the server-configured `PROJECT_SLUG`; public route,
query, form, or body values cannot override it. Remove every plural public
route rather than forwarding it.

Required evidence:

- singular profile/content/contact routes return the deployed tenant's data;
- public supplied slugs cannot switch the resolved tenant; and
- every former plural/slug endpoint deterministically returns `404`.

No database, tenant-record, account/admin, payment, or provider behavior is
changed in this phase.

### Phase 2 — Browser and environment hardening

Make every tenant public build call relative same-origin paths. This includes
the content API client, the theme helper, and the account-login link: account
links must not append a `temple` selector. Keep any separately authorized
account-origin integration distinct from tenant selection.

Remove `VITE_API_BASE_URL` from tenant public configuration and from the
template. Change the Vite development proxy default to `localhost:3001`, then
align the local Puma default, development CORS/origin helpers, and local
commands with the fixed port convention. A staging listener uses `3002` only
through its selected server configuration; it is never a browser URL.

Required evidence:

- an artifact built without public API-base configuration has no `localhost`,
  raw application port, plural `/temples`, or tenant slug public-content URL;
- development proxying targets `3001`; and
- production/staging browser paths remain relative and same-origin.

### Phase 3 — Operational contract and regression coverage

Update `bin/run_smoke_tests`, active deployment/command/reference documents,
and only non-historical route examples to the singular API. Retain historical
records as evidence, annotated only where necessary to avoid treating an old
endpoint as active guidance.

Add focused Rails routing/integration and frontend artifact checks. The checks
must fail if a plural public route, public tenant selector, browser-visible
`localhost`, or public raw application port returns.

### Phase 4 — Main integration and optional staging check

After Phases 1–3 pass locally, integrate their accepted commits into `main`.
This is the staging candidate branch, not the protected live release branch.
It does not by itself deploy to a droplet.

A `main` staging deployment is optional when the local Rails and production
artifact checks already provide sufficient confidence. When a droplet staging
check is desired, deploy the exact `main` commit to the staging target using
the `3002` application-port convention, then inspect the public browser and
singular endpoint. Do not bundle Nginx changes, provider actions, secrets, or
production release into this phase.

## Implementation Scope

Control owns the exact packet, paths, branch, execution mode, and checks. The
expected bounded surfaces are:

- Rails public route declarations, tenant-context behavior, and routing/
  integration tests;
- Vue public API, theme, account-link, and development-proxy configuration;
- local Puma/CORS/origin defaults and tenant environment template;
- smoke script plus active deployment/command/reference documentation; and
- focused regression tests that inspect the built frontend contract without
  exposing secrets or contacting providers.

Excluded: Stripe/ECPay providers and credentials, payment webhooks, billing
runtime, database/schema changes, account/admin authority behavior, tenant
data migration, DNS/TLS, Nginx/systemd installation, live deployment, push,
and other external actions. A later explicit release workflow is required to
build and deploy accepted code to staging or production.

## Acceptance Criteria

1. The tenant public page, contact operation, and login link use no public
   temple selector. Public content/contact operations use only the singular
   `/api/v1/temple...` contract and resolve the configured local tenant
   server-side.
2. Every former `/api/v1/temples/:slug...` public endpoint is absent with a
   deterministic `404` test; it has no compatibility redirect or alias.
3. A built Vue production artifact contains neither `localhost:3001` nor
   `localhost:3002`, a raw `3000` application port, an old plural route, nor a
   public tenant selector. No public-content request depends on
   `VITE_API_BASE_URL` or a browser-visible port.
4. The Vite development proxy and local Puma development default use
   `localhost:3001`; the `3002` staging listener is selected only through
   server configuration and is isolated from compiled staging/production
   output.
5. Focused Rails routing/integration tests prove the singular endpoint,
   tenant-local resolution, contact request behavior, and old-route rejection.
6. Focused Vue/build checks prove same-origin paths and the absence of the
   obsolete plural/slug and localhost contracts.
7. The smoke script and active operational references use the singular
   endpoint and accurately document the `3000/3001/3002` convention.
8. Existing server-side tenant isolation, owner/admin authority, records,
   assisted onboarding, ECPay patron payment behavior, Stripe platform-billing
   behavior, secret handling, and historical records remain unchanged.
9. Required focused checks and `git diff --check` pass. No provider, secret,
   deployment, host, database, or external action occurs during this patch.

## Protected Production Promotion

`release/current` is the isolated live-server branch and uses the `3000`
application-port convention. It is not a staging branch and is never changed
merely because `main` was integrated.

Only after the accepted `main` commit is confirmed to work—through a chosen
staging check or accepted local evidence—may a separate explicit production
workflow promote that exact commit to `release/current` and deploy it to the
live server. That workflow must identify the target, exact commit, rollback
point, impact, verification, approval, and monitoring boundaries before any
push or host mutation.
