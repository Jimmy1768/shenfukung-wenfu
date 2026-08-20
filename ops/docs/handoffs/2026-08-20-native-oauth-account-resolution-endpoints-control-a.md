# Control A — Native OAuth Account-Resolution Endpoints

## Identity

- Accepted contract: Control A's own scoping in
  `ops/docs/handoffs/2026-08-19-oauth-account-resolution-diagnostics-control-a.md`.
- Control: Wenfu Control A (session `local_915b44b0-14b1-4b09-bd97-da19a1169d41`).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- Branch: `claude/oauth-account-resolution-native` (isolated cleanly in
  Control A's own worktree throughout, despite the earlier shared-name
  mistake with Control B — never actually touched, single Rails-only
  commit on the correct base).
- Implementer commit: `5899db4` (feat: add native OAuth account-
  resolution consuming endpoints).
- Merge: `2290df3`, on `main`.

## Outcome

New `Api::V1::Account::NativeOAuthResolutionsController`, three routes
exactly per the scoped contract, `surface: "native"`:

- `GET oauth/resolution`
- `POST oauth/resolution/existing`
- `POST oauth/resolution/new`

Mirrors existing native controller conventions exactly — one rescue per
`Auth::OAuthAccountResolution` exception class, `render_error`/
`issue_session_payload`/`native_context` reused, not reimplemented.

## Verification

- Round-trip tests drive a **real** `409` through the actual
  `native_oauth#exchange` endpoint (reusing the existing
  `FakeCentralOAuthClient` stub, not a hand-built resolution record),
  consume it through both new endpoints, assert real DB state
  (`OAuthIdentity` created, `OAuthAccountResolution` consumed), and use
  the genuine returned `access_token` on a follow-up authenticated
  request. Control A read the test file itself to confirm this, not
  just trusted the implementer's summary.
- Full Rails suite independently re-run pre-merge and post-merge: 542
  runs, 3421 assertions, 0 failures/errors. `git diff --check` clean, no
  schema/migration diff, confirmed all changes under `rails/`.
- Branch collision from the earlier shared-name mistake never actually
  materialized — Control A checked the shared cwd before acting, found
  Control B's work and Planning's correction docs already resolved onto
  `main`, confirmed its own branch had sat cleanly isolated the whole
  time (one commit on the unmodified base), merged with zero conflicts.

## Real Finding — Google Provider-Mismatch Bug, Not Fixed Here

Independently traced (not relayed): for Google specifically, account
resolution is broken end-to-end, both web and native, unrelated to
today's other fixes.

- `Auth::OAuthExchangeIdentity#pending_result` creates the
  `OAuthAccountResolution` record with `provider:` set to the
  identity-form string — `"google_oauth2"` for Google, from
  `PROVIDER_TO_IDENTITY`.
- Both `Auth::CentralOauthController#callback` (web) and
  `Auth::NativeOAuthFlow#exchange!` (native) hand the client back
  `canonical_provider` — `"google"`.
- `validate_record!`'s `secure_equal?(record.provider, provider)` then
  always compares `"google_oauth2"` against `"google"` — always fails,
  always raises `ProviderMismatch`, regardless of what the client does.
- Apple/Facebook unaffected — their identity-form and canonical strings
  are identical (`"apple"→"apple"`, `"facebook"→"facebook"`). This is
  exactly why the round-trip tests use Apple, not Google — Google would
  fail at this exact step, itself further confirmation.

Not live-impacting today (`oauth_account_resolution` is off in
production), but the flag is a single global toggle across all
providers — turning it on for Apple testing turns it on for Google too,
and any Google user hitting an unmatched identity would hit this wall
immediately. Deliberately left unfixed, out of this packet's scope —
Control A explicitly asked Planning for a sequencing call rather than
expanding scope unilaterally.

One more note from Control A worth preserving: its ephemeral
Implementer apparently also tried filing this finding through some
other background-task channel. Control A explicitly declined to vouch
for that channel and treated its own direct trace in this report as the
authoritative record — the right call, since this handoff is what
Planning and the Director actually see.

## Closeout

Branch and worktree cleaned up. Control A idle, standing by. Google
provider-mismatch fix sequenced separately (see next dispatch).
