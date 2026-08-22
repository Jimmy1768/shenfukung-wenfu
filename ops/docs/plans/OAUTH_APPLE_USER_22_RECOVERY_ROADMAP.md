# Apple OAuth User 22 Recovery Roadmap

Status: Planning-owned phased roadmap only. No phase in this document grants
production, provider, account, deployment, release, migration, or cleanup
authority.

Recorded against canonical `main` at
`6bdbc6f2294a868f7ea84a280f7c0764c47838c5` on 2026-08-13.

## Objective

Safely recover the staff member's Apple sign-in into the intended existing
account without deleting user 22, guessing account ownership, losing user work,
or widening signed-out account linking.

The desired terminal state is:

- the intended keeper account owns the exact Apple provider identity;
- Google, email/password, and Apple sign-in continue to reach that keeper under
  their existing authority rules;
- historical user 22 is closed and retained as an audited tombstone, not
  deleted;
- no second user, session, identity, registration, payment, or admin authority
  is created or silently moved;
- the fixed unmatched-provider flow is deployed and validated before the
  historical record is changed.

## Confirmed Diagnosis

The supplied production evidence establishes two different records, not a safe
automatic match:

- the staff Gmail belongs to one user and one Google identity;
- user 22 owns one Apple identity and no Google identity;
- neither user 22's user email nor its Apple identity email equals the supplied
  Gmail;
- user 22 displays the generic provisioned name `OAuth User`.

The former signed-out resolver accepted a new Apple subject, could not match it
to the existing Gmail/Google record, and provisioned a new OAuth-seeded user.
The evidence does not establish why Apple supplied no usable name, and Wenfu
must not infer common ownership from a person's name, Gmail address, Apple
relay address, or staff knowledge alone.

Deleting user 22 is not recovery. Before the fixed resolver is deployed, the
same Apple sign-in can provision another placeholder. Deletion would also
discard the identity ownership and audit trail and could destroy or detach
associated account state. User 22 therefore remains preserved until a bounded,
atomic consolidation proves both sides.

## Accepted Source And Release Baseline

The local Rails/web fix is complete. It changes unmatched provider sign-in to
a short-lived pending resolution with no user or session minted, requires
explicit existing-account or new-account resolution, makes admin OAuth
lookup-only, and removes generic signed-out cross-provider email attachment.

The Director accepted the following future production Candidate B boundary:

1. exact `release/current` baseline
   `99a0a6929c5cb0eace21d5fa074cdab3950b269c`;
2. `684c9ef` — native account API;
3. `740aa39` — native account contract evidence;
4. `7fa60f0` — native OAuth Rails contract;
5. `6eb57c3` — typed invalid-grant repair;
6. `dcc258b` — Apple account-resolution implementation.

This is a recipe for a newly reviewed release candidate. No disposable
rehearsal hash or current `main` tip is approved for production promotion.

The most recent read-only production gate stopped because the exact release
checkout contains 86 untracked public paths: one under `rails/` and 85 under
`vue/`. No contents were inspected and no cleanup was authorized. That state
must be resolved before production preflight resumes.

## Recovery Invariants

Every phase must preserve these rules:

- no deletion of user 22;
- no heuristic linking or merge by name, email, relay address, or operator
  belief;
- exact provider subject remains the provider identity authority;
- both the keeper account and the Apple identity must be freshly proven;
- no session is minted by an unmatched provider callback before resolution;
- admin OAuth remains lookup-only;
- tenant, account/admin, closure, session, privacy, payment, and user-work
  boundaries remain fail-closed;
- no direct SQL or ad hoc Rails runner may substitute for the accepted recovery
  interface;
- raw provider tokens, subjects, emails, secrets, or callback bodies do not
  enter durable plans, receipts, logs, or chat;
- an uncertain transaction outcome is reconciled before any retry.

## Phase 0 — Preserve And Freeze The Historical State

Purpose: prevent an attempted shortcut from making the incident harder to
recover.

Actions for a separately authorized packet:

- record only protected identifiers for the intended keeper and source user 22;
- leave user 22, its Apple identity, and all associated state unchanged;
- keep `oauth_account_resolution` and `oauth_account_consolidation` disabled in
  production until their respective activation phases;
- prohibit delete, unlink, relink, close, merge, session revocation, or account
  edits outside the final recovery transaction.

Exit gate: sanitized protected evidence identifies the intended keeper and
source record without changing either. This phase is preservation, not
remediation.

## Phase 1A — Validate The Fixed Flow With Real Apple OAuth Locally

Purpose: prove the actual Apple/provider round trip against the fixed local
resolver without touching production user 22.

Prerequisites:

- separately authorized read-only/provider configuration verification;
- exact Central Auth allowlisting for the local Wenfu callback, expected to be
  `http://localhost:4001/auth/callback`, verified rather than assumed;
- a disposable/local Wenfu database containing the keeper test account but no
  local Apple identity for the staff Apple subject;
- local account-resolution/linking enabled, with consolidation disabled.

Required evidence:

- the real Apple callback reaches pending account resolution and creates no
  permanent user, identity, browser cookie, or native session;
- relay/no-name presentation is safe and does not display a fabricated profile;
- incorrect keeper proof fails without mutation;
- correct keeper proof links the exact Apple identity once;
- repeated Apple sign-in resolves directly to the keeper;
- Google/email sign-in remains unchanged;
- replay, expiry, interruption, provider mismatch, and admin unmatched cases
  fail closed.

This phase may run in parallel with Phase 1B. It authorizes neither provider
console mutation nor production login.

## Phase 1B — Resolve The Dirty Production Checkout

Purpose: restore a reproducible production release target without blindly
deleting public assets.

Planning/Director must decide whether the 86 safe-listed public paths are:

- deployment-owned assets that must be preserved outside the Git checkout;
- stale files safe to replace from a clean release artifact; or
- required data whose ownership and destination must be established first.

Recommended method: preserve any required files through an explicit backup or
asset-location packet, then deploy from a clean, immutable release checkout or
artifact. Do not use an unreviewed recursive deletion or reset. The one archive
path needs explicit disposition rather than an inference from its extension.

Exit gate: exact target checkout is clean and reproducible, or deployment is
redirected to a separately verified clean release directory. A new read-only
check must confirm the result before Candidate B work continues.

## Phase 2 — Construct And Review Candidate B

Purpose: produce the exact narrow Rails release candidate already accepted by
the Director.

Required packet boundaries:

- start from exact `99a0a692...`;
- apply only the five accepted commits in the recorded order;
- produce a new reviewable release commit;
- rerun the complete Rails suite, focused OAuth/account/session tests, syntax,
  routes, migration up/down rehearsal, duplicate-index stop test, and diff
  checks;
- prove no mobile, Vue, dependency, deployment, provider, or secret change;
- do not move `release/current`, push, or deploy.

Exit gate: one immutable candidate commit and report with clean worktrees,
exact ancestry, changed-path inventory, rollback compatibility, and no
production action.

## Phase 3 — Repeat The Read-Only Production Preflight

Purpose: establish that Candidate B can be deployed safely to the exact target.

The new plan must retain the existing exact target/ref/path fences and add only
the previously prevented observations:

- clean checkout and correct release refs;
- bundle/runtime compatibility;
- required environment/configuration key presence without values;
- migration status and sanitized duplicate aggregates;
- current binary feature-flag classifications;
- service and concurrency shape;
- safe existing-account health/smoke checks;
- start/end non-mutation proof.

Stop on checkout drift, duplicate `(user_id, provider)` rows, enabled recovery
flags, missing configuration, target/ref mismatch, unexpected service state,
or any output that cannot be safely redacted.

Exit gate: a sanitized read-only report recommends or rejects deployment. It
does not authorize deployment.

## Phase 4 — Deploy Candidate B With Recovery Features Disabled

Purpose: place the safe resolver and supporting schema in production before
changing behavior or historical accounts.

This requires its own production plan with exact target, candidate commit,
backup, migration, restart, rollback, impact, verification, approval, and
monitoring boundaries. Initial production values must keep both
`oauth_account_resolution` and `oauth_account_consolidation` disabled.

Required smoke evidence:

- existing exact Google and Apple identities still sign in;
- email/password behavior remains intact;
- admin unmatched OAuth remains lookup-only;
- native and browser account session boundaries remain distinct;
- unmatched sign-in fails closed while resolution is disabled;
- no unexpected user, identity, session, or pending-resolution growth.

Monitor for 30 minutes, then complete a 24-hour review before historical
recovery advances. Rollback may revert source while retaining non-destructive
schema and audit evidence; it must not delete pending or historical records.

## Phase 5 — Activate And Validate Account Resolution

Purpose: validate the new unmatched-provider behavior independently from user
22 remediation.

In a separately approved binary activation window:

- enable only `oauth_account_resolution`;
- keep `oauth_account_consolidation` disabled;
- exercise an approved unmatched test identity or equivalent controlled case;
- prove pending/no-session behavior, explicit existing/new-account choices,
  expiry/replay protection, and exact subsequent login;
- verify no admin provisioning or broad email attachment.

The staff Apple identity cannot serve as the unmatched test while it remains
owned by user 22. Do not unlink it to manufacture this test.

Exit gate: production resolution behavior is accepted and monitored with no
historical account change.

## Phase 6 — Perform A Protected Read-Only Inventory Of User 22

Purpose: prove that user 22 qualifies for the narrow empty-placeholder
consolidation path and that the intended keeper can receive Apple safely.

Return sanitized booleans/counts only. Required proof includes:

- source metadata is OAuth-seeded, active, unclosed, named exactly
  `OAuth User`, and has no native name;
- source owns exactly one OAuth identity and it is the expected Apple subject;
- source has no admin authority, dependents, registrations, payments, refresh
  tokens, push tokens, privacy requests, lifecycle events, assistance requests,
  preferences/settings, or meaningful user work covered by the consolidator;
- keeper is active and is the intended staff account;
- keeper does not already own an Apple identity;
- no conflicting ownership, closure, session, payment, privacy, or tenant state
  exists.

Any nonzero meaningful state stops automatic consolidation and routes to a new
human adjudication plan. It is not discarded or silently reassigned.

Exit gate: exact source and keeper are eligible, or the recovery stops with the
first unsupported state.

## Phase 7 — Close The Fresh-Proof Interface Gap

Purpose: make the accepted consolidator safely invocable without direct SQL or
an ad hoc production runner.

Recommended design: a narrow signed-in account recovery journey, not an admin
merge tool. The staff member signs into the intended keeper, reauthenticates
that keeper, completes a fresh Apple authorization for the exact source
subject, reviews an explicit irreversible confirmation, and submits a
short-lived one-use proof to the existing atomic consolidator.

The current consolidator requires the keeper's password. Before implementation,
Planning must confirm whether the intended Google-linked keeper has a usable
password. If not, either use the existing safe add-password flow first or
accept a separately designed recent-session/step-up proof. Do not weaken this
precondition implicitly.

Required implementation evidence:

- purpose/surface/provider/subject binding;
- short expiry, consume-once, replay and concurrency protection;
- keeper reauthentication and fresh Apple proof;
- explicit confirmation and precise failure presentation;
- no provider token or raw subject leakage;
- atomic identity move, source-session revocation, source closure, and redacted
  audit evidence;
- failure on any source work, ownership conflict, closure, admin/payment/privacy
  state, wrong keeper, wrong provider, stale proof, replay, or partial outcome;
- no generic account merge/list/search surface.

This phase requires local tests and a separate deployment/activation plan. It
does not remediate user 22 by itself.

## Phase 8 — Execute The User 22 Recovery Window

Purpose: perform the one authorized historical consolidation after all prior
gates pass.

Required packet:

- exact target, deployed commit, source user 22, protected keeper identifier,
  feature-flag scope, operator/staff window, rollback/reconciliation rules,
  approval, verification, and monitoring;
- final pre-state drift check immediately before proof;
- keeper sign-in and accepted keeper reauthentication;
- fresh Apple authorization proving the exact identity held by user 22;
- explicit confirmation;
- one atomic consolidation attempt only.

Expected transaction:

1. consume the fresh provider proof;
2. lock keeper, source, and identity;
3. revalidate the empty-placeholder predicate;
4. move the exact Apple identity to the keeper;
5. revoke source refresh sessions;
6. close user 22 with retained audit/tombstone evidence;
7. emit only a redacted provider-subject fingerprint in audit data.

Immediately disable `oauth_account_consolidation` after the bounded window.
If the outcome is uncertain, reconcile identity ownership and transaction state
before any retry. Do not delete user 22 and do not repeat the transaction.

## Phase 9 — Verify And Monitor Recovery

Immediate acceptance evidence:

- Apple sign-in reaches the intended keeper;
- Google and email/password still reach the same keeper as applicable;
- exactly one Apple identity exists for the exact subject and it belongs to the
  keeper;
- user 22 is closed, cannot establish a session, and remains available as the
  audited historical source;
- no user work, registration, payment, admin authority, privacy state, or
  tenant data was lost or duplicated;
- feature flags have their accepted post-window values.

Monitor sanitized OAuth outcomes, pending-resolution counts, identity conflict
classifications, session errors, and account-closure audit events for 30
minutes, then conduct a 24-hour review. After activity resumes, any correction
is a forward reconciliation, not a blind database restore.

## Open Decisions Before Execution

1. Exact protected keeper account for the staff member.
2. Whether that keeper has a usable password for the current consolidator.
3. Verified Central Auth localhost callback allowlist and local real-provider
   test procedure.
4. Preserve/relocate/replace decision for the 86 untracked production public
   paths.
5. Exact newly constructed Candidate B commit after Phase 2.
6. Production deployment target/window, approver, rollback owner, and monitor.
7. Whether Phase 5 uses an approved unmatched test identity or another
   evidence method that does not disturb user 22.
8. Sanitized Phase 6 eligibility result for user 22 and the keeper.
9. Accepted keeper-proof design if the keeper has no password.
10. Exact production recovery window with the staff member available to prove
    both accounts.

## Current Classification And Next Action

Classification: `apple_oauth_user_22_recovery_roadmap_ready`.

No Control packet is active. The first executable decision is the production
checkout asset disposition in Phase 1B. Phase 1A local real-Apple validation
may be planned in parallel, but requires its own provider/runtime authority.
User 22 remains preserved and unchanged.
