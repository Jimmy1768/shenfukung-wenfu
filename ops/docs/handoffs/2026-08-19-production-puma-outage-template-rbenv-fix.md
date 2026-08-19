# Incident — Production Puma Outage From A Broken Golden Template

## Status

Resolved. Real downtime occurred. Recording plainly, not minimizing it.

## What Happened

1. During the aborted env-file-rename attempt earlier today, `sudo bin/apply_systemd_units`
   ran. It doesn't just copy committed `.service` files — it first
   renders them fresh from `ops/systemd/template/golden-template-{puma,sidekiq}.service`
   via `bin/stage_ops_configs`, then copies the rendered output to
   `/etc/systemd/system/` and restarts. This silently overwrote the
   deployed units with a version rendered from the template, which was
   missing `/home/jimmy1768_user/.rbenv/bin/rbenv exec` in `ExecStart` —
   a gap in the template that predates today, never caught because the
   template had apparently never been used to actually render a live
   deploy before.
2. This didn't surface immediately — Puma kept running on its
   already-loaded process until the next restart.
3. When `shengfukung-wenfu-env` was later updated (adding
   `AUTH_NATIVE_RETURN_URL`) and Puma restarted, it hit the broken
   `ExecStart`: `bash: bundle: command not found` (exit 127), 5 rapid
   crash-loop attempts between 10:44:37–10:44:38, systemd's restart-rate
   limit kicked in, service ended in `Failed to start`. **Production
   was down** from 10:44:37 until the fix below landed at 10:49:51 —
   roughly 5 minutes.
4. Diagnosed via `sudo journalctl -u shengfukung-wenfu-puma -n 40 --no-pager`
   rather than trusting `systemctl status`'s summary — status alone
   showed `active (running)` with a `bash`-only process tree and 1MB
   memory right after a restart, which was ambiguous (could have been
   mid-boot or actually stuck); the full journal log made it
   unambiguous.

## Fix

- Immediate recovery: `sudo sed -i` patched the live
  `/etc/systemd/system/shengfukung-wenfu-{puma,sidekiq}.service` files
  directly, adding back the `rbenv exec` prefix — didn't depend on git
  state (`release/current` was stale on the server at the time).
- Root-cause fix, committed (`6af83fc`): `ops/systemd/template/golden-template-{puma,sidekiq}.service`
  now includes `rbenv exec`, matching the pattern the deployed files
  already had. Future `apply_systemd_units` runs — for this project or
  any other client rendered from this template — won't reintroduce the
  bug.
- Verified via full journal log (Puma actually reached "Listening on
  http://0.0.0.0:3000", both workers booted) and `curl -I
  https://shengfukung.com.tw` returning `200 OK` — not just trusting
  `systemctl status`'s "active" summary.

## Lessons

- `systemctl status`'s one-line "active (running)" is not sufficient
  verification on its own, especially right after a restart — a process
  can be alive but stuck before actually serving. Check the full
  journal log and/or an actual HTTP response when it matters.
- `bin/apply_systemd_units` re-renders from the template every time —
  it does not treat the committed/deployed `.service` files as source
  of truth. Any future hand-edit to those files (like the earlier
  env-file-rename attempt) will be silently discarded the next time
  this script runs; edits belong in the template.

## Closeout

No repo change needed beyond the already-committed template fix
(`6af83fc`). Production confirmed healthy.
