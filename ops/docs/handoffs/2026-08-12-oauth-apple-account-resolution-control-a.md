# Control implementation packet — Apple OAuth account resolution (Rails/web)

## Authority and immutable input

- Planning: Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Accepted plan: `ops/docs/plans/OAUTH_APPLE_ACCOUNT_RESOLUTION_READINESS_AND_IMPLEMENTATION_PLAN.md`.
- Exact base: `bb4099bb03df62bd8287bcd7f26b039872b9c7bf`.
- Diagnosis predecessor: `653aa0631b884209fee37869e1d7c7fc271006be`.
- Execution branch/worktree: `codex/oauth-apple-account-resolution` at
  `/private/tmp/shengfukung-wenfu-oauth-apple-account-resolution`.

## Bounded outcome

Implement only the accepted local Rails/web/shared OAuth account-resolution
contract: exact-subject sign-in, signed-in explicit linking, server-held
pending resolution, proof-gated existing-account linking or new-account
creation, lookup-only admin behavior, and the narrow accepted empty
OAuth-placeholder consolidation. Remove generic signed-out email attachment
without changing the accepted Google subject-compatibility repair.

## Ownership and allowed paths

The Implementer may change only Rails OAuth-resolution implementation,
migration/schema, browser account views/controllers/routes, Rails constants,
and their focused Rails tests. Expected implementation surfaces include:

- `rails/app/services/auth/{oauth_identity_resolver,oauth_exchange_identity,oauth_identity_linker,native_oauth_flow}.rb`
- new narrowly scoped OAuth account-resolution/consolidation services
- `rails/app/controllers/auth/{central_oauth,omniauth}_controller.rb`
- `rails/app/controllers/account/oauth_identities_controller.rb`, new
  account-resolution controller/views only where required
- `rails/app/controllers/api/v1/account/native_oauth_controller.rb`
- `rails/app/controllers/admin/sessions_controller.rb` only if required for
  lookup-only Central OAuth gating
- `rails/app/models/oauth_identity.rb`, new pending-resolution/audit models,
  `rails/app/lib/app_constants/oauth.rb`, `rails/config/routes.rb`
- one narrowly confined `rails/db/migrate/*oauth*resolution*.rb` migration and
  its exact `rails/db/schema.rb` consequence
- focused tests under `rails/test/{models,services/auth,integration/account,integration/admin,integration}/` that exercise only this contract.

No mobile/Expo/Vue/Planning docs, unrelated Rails code, provider settings,
secrets, external calls, production data, deployment, push, or historical
account remediation are owned.

## Required invariants and evidence

1. Existing identities resolve only by exact provider subject; signed-out
   generic cross-provider email attachment is removed. Preserve the existing
   verified-email, exactly-one-user, exactly-one-Google-identity compatibility
   repair and its audit redaction.
2. New signed-out provider subjects create a short-lived, one-use,
   server-held pending resolution with no account/admin browser session and no
   native session. It must support only accepted named outcomes: exact login,
   signed-in explicit link, existing-account proof/link, new-account proof,
   and lookup-only admin rejection.
3. Pending records must be database-backed; their tokens/audits must not leak
   raw provider subjects, emails, tokens, code, credentials, or upstream
   payloads. Prove expiry, replay, tampering, provider mismatch, concurrent
   consumption, and no session issuance before resolution.
4. Existing-account linking and supported empty OAuth-seeded placeholder
   consolidation require the accepted dual proof, are atomic and auditable,
   preserve or fail closed for tenant/user-work/admin/payment/privacy/closure
   state, and cannot touch unsupported records. A separate unique
   `oauth_identities(user_id, provider)` database constraint is required.
5. Browser account UX, legacy callback behavior, Central callback, and native
   response contract must agree. Unmatched admin OAuth is lookup-only and must
   not provision or elevate an account. Closure, authority, unlinking,
   browser/email sign-in, privacy, payment, and historical records retain
   their current protections.
6. Include feature gates and safe rollback behavior exactly as specified in
   the accepted plan: disabling unmatched-provider resolution prevents the new
   pending path while exact existing identities and existing linked behavior
   remain safe.

## Execution allocation

Use one ephemeral `gpt-5.6-terra/high` Implementer. This is the
lowest sufficient approved allocation because the packet combines transactional
pending persistence, database integrity, multi-relation identity ownership,
one-use/replay/concurrent consumption, atomic retained-state consolidation,
and rollback gating. The Implementer must not stage, commit, merge, push,
deploy, access providers/secrets/production, or mutate external state; it
returns directly to Control.

## Required checks

- focused model/service/controller/integration tests covering every accepted
  resolution and fail-closed case, plus retained browser/email/OAuth and
  account/admin/closure/privacy/payment regressions named by the plan;
- migration status and schema check proving only the pending-resolution and
  `oauth_identities(user_id, provider)` integrity changes;
- Ruby syntax checks for all modified/new Ruby paths;
- route and redaction scans; focused source scans for removed generic
  signed-out email attachment and retained Google repair;
- `git diff --check`, changed-path review, canonical integration ancestry,
  clean worktree, and empty staging.

## Exclusions and terminal disposition

No production investigation or remediation is authorized. Control reviews,
commits accepted work on this branch, locally integrates it into clean
canonical `main`, and sends Wenfu Planning one immutable terminal packet with
commits, paths, exact checks, state, blockers, and preserved-boundary
confirmation. Control remains visible and idle after Planning's receipt.
