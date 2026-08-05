# Tenant-Local Public API Hardening Plan

Status: accepted planning criteria; implementation not yet dispatched

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

## Implementation Scope

Control owns the exact packet, paths, branch, execution mode, and checks. The
expected bounded surfaces are:

- Rails public route declarations and API controllers/tenant-context tests;
- Vue public API client and Vite development proxy configuration;
- public-content and contact-request tests;
- smoke script and active deployment/command/reference documentation; and
- focused regression tests that inspect the built frontend contract without
  exposing secrets or contacting providers.

Excluded: Stripe/ECPay providers and credentials, payment webhooks, billing
runtime, database/schema changes, account/admin authority behavior, tenant
data migration, DNS/TLS, Nginx/systemd installation, live deployment, push,
and other external actions. A later explicit release workflow is required to
build and deploy accepted code to staging or production.

## Acceptance Criteria

1. The tenant public page and all its content/contact operations use only the
   singular `/api/v1/temple...` contract and resolve the configured local
   tenant server-side.
2. Every former `/api/v1/temples/:slug...` public endpoint is absent with a
   deterministic `404` test; it has no compatibility redirect or alias.
3. A built Vue production artifact contains neither `localhost:3001` nor
   `localhost:3002`, and no public-content request depends on
   `VITE_API_BASE_URL` or a browser-visible port.
4. The Vite development proxy defaults to `localhost:3001`; this is isolated
   from compiled staging/production output.
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

## Release Gate After Local Acceptance

After Control accepts and integrates the local patch, a separate explicit
release workflow must build the tenant Vue distribution, deploy it to the
intended tenant host, and verify:

1. the public site fetches the singular endpoint successfully;
2. the old plural endpoint returns `404`;
3. no browser request targets `localhost` or a raw application port; and
4. the selected Nginx upstream matches the environment's `3000`, `3001`, or
   `3002` convention.
