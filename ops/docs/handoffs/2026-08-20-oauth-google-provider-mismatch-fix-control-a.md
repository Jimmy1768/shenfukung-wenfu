# Control A — Google OAuth Provider-Mismatch Fix

## Identity

- Fixes: the bug found in `ops/docs/handoffs/2026-08-20-native-oauth-account-resolution-endpoints-control-a.md`.
- Control: Wenfu Control A (session `local_915b44b0-14b1-4b09-bd97-da19a1169d41`).
- Planning: Wenfu Planning (session `local_1b819a1b-17d1-4571-b571-f930dece9da9`).
- Implementer commit: `9b90db1` (fix: canonicalize both sides of
  OAuthAccountResolution provider comparison).
- Merge: `bcf8131`, on `main`.

## Fix

Control A's own initial recommendation (canonicalize only the stored
value) turned out to be half-right — the implementer found a real gap
before building anything: a third caller,
`consume_consolidation_proof!`, intentionally passes identity-form
provider strings (it looks up `OAuthIdentity` rows directly, which are
always identity-form). A one-sided fix would have repaired web/native
while silently breaking Google consolidation the same way — Apple/
Facebook would have masked it again, same as the original bug.

Actual fix: canonicalize **both sides** of `validate_record!`'s
comparison via a small helper reusing the existing
`IDENTITY_TO_CANONICAL_PROVIDER` map (pass-through fallback for values
not present in it) — correct regardless of which convention a given
caller uses. Storage itself is untouched, still identity-form, so
`OAuthIdentityLinker` keeps creating `OAuthIdentity` rows consistent
with every other one in the system.

## Verification

- New regression tests use Google specifically (confirmed this is
  exactly why the original round-trip tests didn't catch it — Apple's
  identity-form and canonical strings are identical). Cover both
  new-account and existing-account-linking paths, drive a real `409`
  through the actual exchange endpoint, consume it with the exact
  canonical value the client receives, and explicitly assert the
  resulting `OAuthIdentity` is stored identity-form and **not**
  canonical — proving the fix didn't leak canonical form into identity
  storage while fixing the comparison.
- `git diff --check` clean, no schema/migration diff — touches exactly
  the service file and the test file.
- Branch and worktree cleaned up.

## Incident Found Along The Way — Shared Test DB Contention, Not This Packet's Fault

Independently re-verifying the suite against the shared default test
database, Control A hit 15 `MissingAttributeError`/`UnknownAttributeError`
errors for columns present in current `schema.rb` but missing from the
live shared database. Traced precisely, not guessed: `pg_stat_activity`
showed two other live connections to `golden_template_test` at the
time, and `db:test:prepare` itself failed with `PG::ObjectInUse` —
confirmed concurrent contention from some other session mutating the
shared DB against an older schema between the implementer's clean run
and Control A's own re-verification.

Control A did not touch the shared DB — re-verified against a fenced
disposable database instead (pre- and post-merge), confirmed clean both
times: 544 runs, 3449 assertions, 0 failures/errors. The fix itself is
solid; the errors were environmental noise, not a defect in this
packet.

**Root cause, confirmed separately by Planning**: `rails/config/database.yml`
defaults `PGDATABASE_TEST` to the literal, unparameterized
`golden_template_test` — every project cloned from Golden Template
shares this exact default unless overridden. Same unrendered-template-
default pattern already found in the env file
(`shengfukung-wenfu-env`) and the systemd `ExecStart` rbenv gap earlier
today — very likely another local project's test run colliding on the
same shared Postgres database name, not another Wenfu session. Not
fixed here — deferred, same as the env-file rename, not urgent since
fenced disposable databases already avoid the actual risk.

## Closeout

Branch and worktree cleaned up. Control A idle, standing by.
