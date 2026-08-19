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

- [ ] `/api/v1/*` namespace missing on `shengfukung.com.tw` production —
      every native-API route 404s (native OAuth start, bootstrap, login,
      temples, theme), while the older `/auth/central/*` web OAuth path
      is live and healthy. Blocks all native sign-in/login/bootstrap/
      registration on the real build. Not a code defect in this repo —
      a production deployment gap. Routing/ownership still pending
      Director decision. Full diagnosis:
      `ops/docs/handoffs/2026-08-19-production-native-api-namespace-missing-finding-control-b.md`.

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
