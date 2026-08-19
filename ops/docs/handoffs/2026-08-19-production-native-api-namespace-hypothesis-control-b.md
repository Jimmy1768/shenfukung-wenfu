# Finding — Production Native-API Namespace Gap, Root-Cause Hypothesis

## Status

Read-only investigation complete. No production access used, nothing
touched, no branch opened. Hypothesis established; actual production
action is a separate Director decision, not made here.

## Identity

- Follow-up to: `ops/docs/handoffs/2026-08-19-production-native-api-namespace-missing-finding-control-b.md`.
- Investigated by: Wenfu Control B (session `local_c98e7b6a-147e-4774-ad30-d8dcfbc3f0e0`),
  dispatched read-only per Director's routing decision (stays with
  Control B, not Control A or Strategy).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).

## Hypothesis: Stale Manual Deploy, Not A Config Defect

Production's checked-out Rails code predates the native API routes —
this is an ordinary manual-deploy gap, not a bug in this repo's
committed configuration.

### Evidence

1. **nginx is correctly configured, and confirmed proxying correctly on
   the live server** — not a proxy issue. `ops/nginx/shengfukung-wenfu.conf`
   has `location ^~ /api { proxy_pass http://rails_puma; ... }`.
   Confirmed *behaviorally*, not just by reading the file: the earlier
   404 for `/api/v1/*` carried genuine Rails response headers
   (`x-runtime`, `x-request-id`), not a raw nginx/static-file 404 or the
   SPA catch-all that `/privacy` etc. return instead. That signature
   only occurs if nginx successfully proxied the request to Rails and
   Rails itself found no matching route.
2. **No automated Rails deploy pipeline exists anywhere in this repo.**
   Checked every relevant `bin/` script (`deploy_vue`, `deploy_vue_all`,
   `apply_nginx_config`, `apply_systemd_units`, `doctor_deploy`,
   `setup_backend_once`, `reset_backend`, etc.) — none contain a
   `git pull`/`fetch`/`checkout`/`reset` step. The Rails systemd unit
   (`ops/systemd/shengfukung-wenfu-puma.service`) runs `bundle exec puma`
   from a fixed `WorkingDirectory` — it serves whatever code is already
   checked out there, it does not update it. No `.github/workflows` or
   any CI/CD config exists. Getting new Rails code live requires someone
   to manually SSH in, `git pull`, and restart — and nothing in the repo
   records when that last happened.
3. **Timing lines up.** The missing routes (`config/routes.rb`'s
   `account/native` namespace, including `oauth/start`) were added in
   commit `7fa60f0` ("feat: add native OAuth Rails contract"),
   2026-08-11 21:00:22 +0800. 16 more commits have touched `rails/`
   since then, through today.

### Honest Uncertainty

Cannot directly confirm the server's actual checked-out SHA without
production access (by design — none used). A less likely alternative
(a `routes.rb` load error silently dropping just this namespace on
whatever commit *is* live) can't be fully ruled out with certainty —
but every piece of repo evidence points at stale manual deploy, and
there's no evidence for anything else.

## Next Step — Director Decision, Not Actioned Here

The likely fix (get current `main` onto the server, restart Puma) is
well-understood, but the actual deploy remains outside this
investigation's authority — per repo policy, production/deployment
action requires a separate explicit production workflow with its own
target, commit, plan, rollback, impact, verification, approval, and
monitoring boundaries. Whether the Director does this directly (no
automated pipeline exists, so it may need to be them regardless, same
as the EAS credentials/2FA step) or authorizes a scoped packet is not
decided here.

## Closeout

No code changes, no branch. Control B idle, standing by.
