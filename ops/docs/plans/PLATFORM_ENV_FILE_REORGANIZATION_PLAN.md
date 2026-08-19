# Platform Env File Reorganization Plan

## Objective

The Rails backend's production env file is named `shengfukung-wenfu-env`
— scoped to look like it belongs to one temple tenant, when it's
actually the centralized platform config serving every temple through
this backend (per `ops/protocol/shengfukung_wenfu_context.md`'s
"Domain And Tenancy Architecture" section). Rename it to reflect the
platform, not one tenant. No real clients exist yet, so this is
in-scope to do cleanly now rather than as a careful zero-downtime
migration later.

## Scope

- Rails/backend env file only. Vue's existing per-client-domain env
  file pattern (`bin/deploy_vue <client-slug>` →
  `/var/www/<client-slug>`, each with its own `.env.production`) is
  already correctly structured — not touched by this plan.
- Rename `/etc/default/shengfukung-wenfu-env` →
  `/etc/default/templemate-env`, matching the platform's own future
  identity (`templemate.com`) rather than the demo temple's domain.
- Fold in the still-pending `AUTH_NATIVE_RETURN_URL=templemate://oauth/complete`
  addition (from the native-OAuth trace) as part of the new file's
  initial contents, rather than adding it twice.
- Update the systemd unit source-of-truth in this repo
  (`ops/systemd/shengfukung-wenfu-puma.service`,
  `ops/systemd/shengfukung-wenfu-sidekiq.service`) — change
  `EnvironmentFile=` to point at the new path.
- **Explicitly not in scope**: renaming the systemd service/unit files
  themselves (`shengfukung-wenfu-puma.service` → e.g.
  `templemate-puma.service`), or the nginx config file name. Those are
  a bigger, separate rename (service names, log paths, existing
  `systemctl` muscle memory) — noted here so it isn't lost, not done in
  this pass unless explicitly asked.

## Sequence

1. On the droplet: copy the existing env file to the new name, add
   `AUTH_NATIVE_RETURN_URL` to it.
2. Update `EnvironmentFile=` in both `.service` files in this repo,
   commit.
3. Get the updated unit files onto the droplet (matches the existing
   `bin/apply_systemd_units` pattern from `deployment_notes.md`, or a
   direct copy given no automated pipeline exists).
4. `systemctl daemon-reload`, restart both services.
5. Verify both services `active (running)` and the native OAuth env var
   is actually loaded (confirm via the same live-request method used
   for the namespace fix, not just trusting the restart).
6. Remove the old `shengfukung-wenfu-env` file once confirmed working —
   don't leave a stale duplicate that could get edited by mistake later.

## Owner

No Control fits this cleanly (platform infrastructure, not Rails
product work or TempleMate mobile work) — Director executes directly,
same pattern as today's other production fixes, Planning provides exact
commands and records evidence after.

## Acceptance

- New env file exists, correctly named, contains everything the old one
  had plus the native return URL.
- Old env file removed, no stale duplicate.
- Systemd unit files in the repo match what's actually deployed.
- Both services confirmed running on the new file.
- Native OAuth env var confirmed actually loaded (not just present in
  the file).
