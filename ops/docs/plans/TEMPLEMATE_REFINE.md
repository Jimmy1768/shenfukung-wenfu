# TEMPLEMATE REFINE LEDGER

## Purpose

- Running ledger for TempleMate (mobile) refinements discovered during
  real-device/TestFlight QA.
- Keep this file focused on the mobile app and its production
  dependencies, not Rails/Vue web work (that's `ACCOUNT_PORTAL_REFINE.md`
  / `ADMIN_PORTAL_REFINE.md`).

## Workflow

Two categories, fixed differently — iOS has no dev-client, so this
distinction matters:

- **Local-fixable**: application-code bugs, testable against a local/dev
  backend via Android dev-client (the real 95% iteration loop) before
  ever spending a TestFlight build.
- **Production-side**: bugs that live in production environment/
  deployment state itself, not in this repo's application code. Can't be
  reproduced via dev-client (which talks to local/dev, not production) —
  can only be validated by pushing an actual signed build to TestFlight
  and testing against the real deployed backend.

Build numbering: version stays `1.0.0`, build number increments per
TestFlight upload without touching the marketing version — next build
is **build 2**.

## Active Items

### Production-Side

- [x] `/api/v1/*` namespace missing on `shengfukung.com.tw` production —
      every native-API route 404s (native OAuth start, bootstrap, login,
      temples, theme), while the older `/auth/central/*` web OAuth path
      is live and healthy. Blocks all native sign-in/login/bootstrap/
      registration on the real build. Not a code defect in this repo —
      a production deployment gap. Full diagnosis:
      `ops/docs/handoffs/2026-08-19-production-native-api-namespace-missing-finding-control-b.md`.
      **Root-cause hypothesis (read-only investigation, no production
      access): production's Rails checkout is simply stale**, predating
      the native OAuth routes commit (`7fa60f0`, 2026-08-11) — no
      automated deploy pipeline exists anywhere in the repo, so this is
      an ordinary manual-deploy gap, not a config/proxy defect. nginx
      confirmed correctly proxying `/api` behaviorally. Full evidence:
      `ops/docs/handoffs/2026-08-19-production-native-api-namespace-hypothesis-control-b.md`.
      Actual deploy action still needs its own separately authorized
      production workflow — pending Director decision on whether they
      do it directly (no pipeline exists, may need to be them regardless)
      or authorize a scoped packet.
      **Fixed 2026-08-19**: Director deployed directly (`release/current`
      advanced to `main`, `bundle install`, both pending migrations run,
      services restarted). Verified via `curl` — the namespace now
      returns `422` (real auth rejection) instead of `404` (route
      missing). Full record:
      `ops/docs/handoffs/2026-08-19-production-native-api-namespace-deploy-fix.md`.
      Remaining validation: real Google/Apple sign-in on the installed
      TestFlight build.

- [ ] **New, precise finding (2026-08-19), traced after the namespace fix
      above:** real Google/Apple sign-in still fails — screen flashes
      back to idle before the system browser opens, same symptom as
      before the namespace was live. Root cause identified directly, not
      hypothesized: `POST /api/v1/account/native/oauth/start` now returns
      `503 {"error":"native_oauth_unavailable"}` for both providers, with
      a real, correctly-shaped PKCE challenge (confirmed via a live
      request built the same way the client does —
      `rails/app/services/auth/native_oauth_flow.rb`'s
      `configured_return_url!` raises `ConfigurationError` — caught and
      rendered as this exact 503 — whenever
      `AppConstants::OAuth.native_return_url` (`rails/app/lib/app_constants/oauth.rb`)
      is blank, i.e. whenever `ENV["AUTH_NATIVE_RETURN_URL"]` is unset.
      `AUTH_BASE_URL`/`AUTH_CLIENT_ID`/`AUTH_CLIENT_SECRET` are confirmed
      present in production (the web `/auth/central/*` flow, which shares
      the same `Auth::CentralOAuthClient`, works) — this is specifically
      the native-only env key. Not a new discovery either: an already-
      archived plan (`ops/docs/plans/archive/OAUTH_ACCOUNT_RESOLUTION_PRODUCTION_READ_ONLY_PREFLIGHT_PLAN.md`)
      flagged this exact variable as a known potential gap back on
      2026-08-12 and explicitly did not authorize fixing it in that
      packet. Expected value, per that same plan and
      `mobile/app/oauth/config.js`'s fixed return URL:
      `AUTH_NATIVE_RETURN_URL=templemate://oauth/complete`. Fix is a
      one-line addition to production's env file
      (`/etc/default/shengfukung-wenfu-env` per
      `ops/systemd/shengfukung-wenfu-puma.service`) plus a Puma restart —
      same production-deploy-authority boundary as the namespace fix
      above, not something Control B can do. **Open after this fix**:
      whether the central-auth service (`auth.sourcegridlabs.com`) itself
      accepts `templemate://oauth/complete` as an allowed return
      destination is still unverified and was the original Phase 1
      "unknown/deferred" flag — can't be tested until the env var exists,
      since `start!` fails before ever reaching the central client.

### Local-Fixable

- [x] Dev/demo copy strings (sign-in headline, loading text, QR-scan
      copy, account-closure text) unconditionally showing even in
      `isReleaseConfig()`-true production builds, despite the repo
      already having the right gate for this pattern applied to
      behavior elsewhere. Control B fixing independently, own branch,
      no Rails/deployment overlap — found and handled same session as
      the production-API finding above.

## QA Checklist

- [ ] Google sign-in succeeds on a real TestFlight build against
      production.
- [ ] Apple sign-in succeeds on a real TestFlight build against
      production.
- [ ] No dev/demo copy visible in a release-config build.
