# Production Native-API Namespace — Deployed And Fixed

## Identity

- Closes: `ops/docs/handoffs/2026-08-19-production-native-api-namespace-missing-finding-control-b.md`
  and `ops/docs/handoffs/2026-08-19-production-native-api-namespace-hypothesis-control-b.md`.
- Executed by: Director directly, over SSH to `jimmy1768_user@174.138.18.211`
  (per repo policy — production deployment requires the Director's own
  action, no automated pipeline exists).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`)
  advanced `release/current` to `main` beforehand (git-only, see prior
  session record) and walked the Director through the remaining steps
  live via terminal read access.

## What Was Done

1. `git fetch origin && git reset --hard origin/release/current` on the
   droplet — brought the working directory to `df171fc`, confirming
   Control B's stale-manual-deploy hypothesis.
2. `bundle install` — required despite `Gemfile.lock` being unchanged
   across the 306-commit gap; the server's locally installed gems
   weren't already present for an interactive shell context (systemd's
   `rbenv exec` path found them fine for Puma; the plain SSH shell
   needed the explicit install).
3. `RAILS_ENV=production bin/rails db:migrate`, after correctly sourcing
   `/etc/default/shengfukung-wenfu-env` (`set -a && source ... && set +a`)
   — first attempt failed on `Missing JWT_SECRET_KEY in production`
   because the interactive shell doesn't auto-load that file the way
   systemd's `EnvironmentFile=` does. Both pending migrations
   (`create_oauth_account_resolutions`,
   `add_qualifying_registration_accounting_to_platform_billing`)
   applied cleanly once sourced correctly.
4. `sudo systemctl restart shengfukung-wenfu-puma` and
   `...-sidekiq` — confirmed `active (running)` via `systemctl status`.

## Verification

`curl -I https://shengfukung.com.tw/api/v1/account/native/bootstrap`
(one of the exact paths from the original finding) now returns `422
Unprocessable Content` with real Rails headers — not `404`. `422` on a
bare unauthenticated request is the expected/correct rejection (missing
auth/session), not a route-missing error. The namespace is live.

Remaining real-world validation (not done here, next step): actual
Google/Apple sign-in on the installed TestFlight build.

## Lessons Recorded

- "`Gemfile.lock` unchanged" does not mean "gems already installed" —
  don't conflate the two when advising a deploy.
- Interactive SSH shells don't automatically replicate a systemd
  service's `EnvironmentFile=`/`rbenv exec` context — commands meant to
  mirror what a service does need to explicitly source the same env
  file and invoke the same interpreter path.

## Closeout

`ops/docs/plans/TEMPLEMATE_REFINE.md`'s Production-Side item updated to
closed. No branch, no repo code change — deployment/ops action only.
