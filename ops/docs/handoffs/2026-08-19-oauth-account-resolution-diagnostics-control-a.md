# Control A — OAuth Account Resolution, Diagnostics

## Identity

- Dispatch: diagnostics-only, per `ops/docs/plans/TEMPLEMATE_REFINE.md`'s
  account-resolution finding.
- Control: Wenfu Control A (session `local_915b44b0-14b1-4b09-bd97-da19a1169d41`).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- No code changes — read-only diagnostics plus one local (non-production)
  runtime proof.

## Findings

1. **Why `oauth_account_resolution` is off**: confirmed via
   `FeatureFlags::Evaluator`'s `default: false` behavior (no `ConfigEntry`
   row exists for this key anywhere) and `git log -S"oauth_account_resolution"`
   across full history — only the single feature-adding commit
   (`dcc258b`, 2026-08-12, "feat: add proof-gated OAuth account
   resolution") touches this string. **Never turned on, not disabled
   after an incident.** Plausible (not proven) context: `dcc258b`'s
   "proof-gated" framing and
   `ops/docs/plans/OAUTH_APPLE_USER_22_RECOVERY_ROADMAP.md`'s account of
   the prior unsafe auto-provisioning resolver suggest this was built as
   the deliberate safe replacement, likely never activated because doing
   so without a complete resolution UX on every client (native never had
   one) would recreate today's exact symptom. Explicitly flagged as
   inference, not a confirmed reason.
2. **No native resolution-consuming endpoint exists** — confirmed from
   both sides: `config/routes.rb`'s native scope lists every native
   route explicitly, no `oauth/resolution*` among them; the three
   resolution routes that do exist are registered under the plain web
   `account` scope. `NativeOAuthController#exchange` already correctly
   detects and surfaces the case (`409`,
   `{code: "account_resolution_required", oauth: {resolution_token}}`)
   — the gap is specifically the two consuming endpoints downstream,
   not the detection.
3. **Contract scoped for Control B** (not built): three new routes
   mirroring `Account::OAuthResolutionsController` against the already
   surface-agnostic `Auth::OAuthAccountResolution` service:
   - `GET oauth/resolution` — `{temple_slug, token, provider}` →
     `{resolution: {provider, expires_at}}`.
   - `POST oauth/resolution/existing` — `{temple_slug, oauth: {token,
     provider}, account: {email, password}}` → same session-issuing
     shape as `NativeSessionsController#login`.
   - `POST oauth/resolution/new` — `{temple_slug, oauth: {token,
     provider}, account: {email, password, name, terms_accepted}}` →
     same shape, `:created`.
   All follow existing `NativeOAuthController`/`NativeSessionsController`
   conventions exactly. `surface` value resolved separately (see
   Planning note below) — not left open.
4. **Native email/password signup — real runtime proof, not production
   contact.** Correctly declined to test against actual production
   (creating a real account is an unconditional prohibited action,
   independent of dispatch wording) and substituted a genuinely
   equivalent local proof instead of silently skipping it: booted a real
   `rails server` (Puma, full middleware stack) against a fenced
   disposable Postgres database loaded from the exact schema currently
   on `main`/production, issued a real `POST /api/v1/account/native/signup`,
   got `201` with a real `User` row and working session, then confirmed
   the issued access token actually authenticates via a follow-up
   `GET /api/v1/account/native/profile` (`200`, correct user). Server
   killed, database dropped after. Confirms the code path works
   end-to-end on the exact code now in production; does not confirm
   production's live infrastructure itself.

## Planning Note — `surface` Question Resolved, Not Left Open

Control A flagged whether `consume_existing!`/`consume_new!` should use
`surface: "native"` (a new value) or reuse web's `surface: "account"`,
to prevent cross-surface token consumption, correctly treating it as an
implementation decision rather than chasing it during diagnostics.
Already answered by the model itself:
`OAuthAccountResolution`'s own validation is
`validates :surface, inclusion: { in: %w[account native] }` —
`"native"` is already an accepted value, present for exactly this
purpose. Use it.

## Closeout

No branch, no code changes. Control A idle, standing by for the actual
build dispatch (Rails-side endpoints, per the contract above).
