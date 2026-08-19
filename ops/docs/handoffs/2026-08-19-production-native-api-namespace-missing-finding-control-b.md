# Finding — Native Account API Namespace Missing From Production

## Status

Unresolved. Routing decision pending Director. Not a Control B action
item — deployment/production work requires a separate explicit
production workflow per repo policy, and Control B has no deploy
access regardless.

## Identity

- Surfaced by: Wenfu Control B (session
  `local_c98e7b6a-147e-4774-ad30-d8dcfbc3f0e0`), during live Director
  device testing of the first TestFlight build.
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- No branch, no code change — this is a diagnosis of deployed
  production state, not a repo defect.

## What Was Found

Director tested Google/Apple sign-in on the real TestFlight build (v1.0.0
build 1). Both providers flash back to the sign-in screen — the system
browser never opens. Traced to `app/oauth/transaction.js#begin()`: the
browser only opens after a successful `POST` to
`/api/v1/account/native/oauth/start`; a failed call silently reaches a
`'failed'` state before ever reaching Google/Apple.

Reproduced the exact request against production directly:

```
POST https://shengfukung.com.tw/api/v1/account/native/oauth/start?temple_slug=shengfukung-wenfu
-> 404 {"status":404,"error":"Not Found"}
```

**Scope is not OAuth-specific.** Every `/api/v1/*` path 404s the same
way — `temples`, `theme`, `account/native/bootstrap`,
`account/native/login` — regardless of endpoint or `temple_slug`.
Response headers (`server: nginx/1.24.0`, `x-runtime: 0.02`,
`x-request-id`) confirm a real Rails app processed these requests and
found no matching route — not an nginx-level miss, not a frontend
catch-all (contrast: `/privacy` etc. return the SPA placeholder, a
distinctly different signature).

**Isolated further before assuming anything (Director's own request):**
`GET /auth/central/google/start` and `/auth/central/apple/start` both
correctly `302` to real, correctly-configured Google/Apple authorization
URLs via the existing central-auth broker
(`auth.sourcegridlabs.com`). Google/Apple console registration is fine;
the older web-facing OAuth path is live and healthy. This narrows the
finding specifically to the `/api/v1/account/native/*` namespace
(`config/routes.rb` lines ~22–45) not being live on whatever is
currently deployed to `shengfukung.com.tw`.

## Why It Matters

This is broader than sign-in. Native login, bootstrap, and registration
— everything the real TestFlight build depends on — go through this
same missing namespace. Practical effect: the build that just shipped
to internal testers cannot currently be used for its core purpose.
Director was not aware this was the state of the production deploy.

## Not Actioned, By Design

Control B has no deploy access, and per repo policy (`ops/protocol/shengfukung_wenfu_context.md`),
deployment/server/production-migration work requires a separate
explicit production workflow with its own target, commit, plan,
rollback, impact, verification, approval, and monitoring boundaries —
not something a Control packet does on its own authority. Routing
decision (Control A/Rails-deployment question vs. Strategy-level
cross-repo infra question vs. something the Director handles directly)
is Planning/Director's call, not decided here.

## Separate, Unrelated Finding From The Same Session

Not part of this finding, staying in Control B's own lane, no action
needed: a batch of dev/demo copy strings (sign-in headline, loading
text, QR-scan copy, account-closure text) unconditionally show even in
`isReleaseConfig()`-true production builds, despite the repo already
having the right gate for this pattern applied to behavior elsewhere,
just not to this copy. Control B is fixing this on its own branch,
no Rails/deployment overlap.
