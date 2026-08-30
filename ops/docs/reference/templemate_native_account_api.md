# TempleMate native account API: what exists

## The one fact this doc exists to prevent getting wrong

**The native account API is built.** As of 2026-08-31 there are 43 routes under
`/api/v1/account/native/*` covering sessions, OAuth, profile, dependents,
registrations, resources, preferences, privacy, and assistance — and
`mobile/app/real/adapter.js` consumes nearly all of them.

This doc exists because the planning record said the opposite for a long time
and was widely cited. `EXPO_ACCOUNT_APP_READINESS_AND_PARITY_PLAN.md` asserted
"native authentication is not implemented", "JSON parity is mostly absent", and
six blocking contract gaps (B-01..B-06). All six are resolved. A session that
reads that plan without checking the routes will re-plan work that already
shipped, or re-build endpoints that already answer.

**Check `bin/rails routes | grep native` before believing any claim that a
native endpoint is missing.**

## Authority boundary (why this API is separate)

`Api::V1::Account::NativeBaseController` deliberately does **not** inherit
`Account::BaseController`. That controller is a browser-cookie surface with
admin-aware scope helpers: for a user who also holds admin authority,
registration scope can widen to owned admin temples, and preferences accept an
admin display mode. An account-only app must never receive or mutate that.

The native base instead enforces, on every request:

- `temple_slug` present and resolvable, else `tenant_required` /
  `tenant_not_found`
- a bearer JWT whose `scope` claim is exactly `"account"`, else
  `session_invalid`
- a live refresh-session (`session&.active?`), else `session_revoked`
- a non-closed user, else `account_closed`

`Api::BaseController` itself provides no authentication on purpose — nine
public tenant endpoints (temples, events, gatherings, services, news,
galleries, contact requests) inherit it directly, so a base-level
authenticate filter would be wrong there, not merely missing.

Session lifecycle is `Auth::RefreshToken` — `issue!`, `rotate!`, `revoke!`,
`revoke_all!` are all implemented.

## Three layers, three different completion states

Do not collapse these. "The app can't do X" is usually a *screen* gap, not an
API gap.

| Layer | State |
| --- | --- |
| Rails native API | Essentially complete (see absences below) |
| `mobile/app/real/adapter.js` | 37 methods; covers the API except contact + payment |
| Expo account screens | **Thin.** `mobile/app/account/` holds only `registration_authority.js`, `screen_model.js`, `registration_demo_presentation.js` |

There are no profile or dependents *screens*, even though the adapter has full
`updateProfile`, `addPassword`, and dependent CRUD, and the API answers all of
them. That gap is UI work, not contract work.

## Endpoint surface

| Group | Routes |
| --- | --- |
| Session | `POST login`, `DELETE logout`, `POST refresh`, `POST signup`, `GET bootstrap` |
| Password | `POST password/recovery`, `POST password/reset`, `POST profile/password` |
| OAuth | `POST oauth/start`, `POST oauth/exchange`, `GET oauth/resolution`, `POST oauth/resolution/new`, `POST oauth/resolution/existing` |
| Profile | `GET profile`, `PATCH profile` |
| Dependents | `GET`, `POST`, `GET/:id`, `PATCH/:id`, `DELETE/:id` |
| Registrations | `GET`, `POST`, `GET/:id`, `GET/new`, `GET/:id/edit`, `PATCH/:id` |
| Resources | `GET events`, `GET services`, `GET galleries`, `GET galleries/:id`, `GET certificates` |
| Preferences | `GET preferences`, `PATCH preferences` |
| Privacy | `GET privacy`, `POST privacy/:request_type`, `POST privacy/close` |
| Support | `POST assistance`, `POST contact` |

Native registration create/update posts a fixed field set, independent of any
temple's offering YAML: `quantity`, `registrant_scope`, `dependent_id`,
`contact_name`, `contact_phone`, `contact_email`, `household_notes`,
`arrival_window`, `ceremony_notes`. This is why the Expo app does **not**
depend on per-temple offering configuration — it consumes a stable contract.

## What is genuinely absent

- **Native checkout / payment handoff.** No native endpoint starts a checkout
  or handles browser return; `Account::RegistrationsController#start_checkout`
  and `#checkout_return` are HTML-only. The adapter has no payment method
  either. Absent on both ends.
- **Account payments history.** Only `GET /api/v1/account/payment_statuses/:reference`
  exists, which is per-registration, not a history list.
- **Linked-identity management.** OAuth resolution handles signup-time
  conflicts; there is no native list/link/unlink surface, and the server's
  last-login-method protection must be preserved if one is added.
- **Contact temple from the client.** `POST native/contact` exists; the
  adapter does not call it.

## Source

- `app/controllers/api/v1/account/native_base_controller.rb` — the authority
  boundary above.
- `app/controllers/api/v1/account/native_*_controller.rb` — the endpoints.
- `app/services/auth/refresh_token.rb`, `app/services/auth/jwt_service.rb` —
  session lifecycle.
- `mobile/app/real/adapter.js` — the client surface, with `/api/v1/account/native`
  as its base path.
- `ops/docs/reference/templemate_native_oauth.md` — the OAuth transaction in
  detail (start/exchange, `templemate://oauth/complete`).
- `ops/docs/plans/EXPO_ACCOUNT_APP_READINESS_AND_PARITY_PLAN.md` — still live
  for its product decisions, non-scope, and remaining payment/shell work; its
  gap register is superseded by this doc.
