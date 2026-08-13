# Apple OAuth User 22 Recovery Readiness Scan

Status: Planning-owned report only. No Control dispatch or production,
provider, account, release, deployment, migration, cleanup, or secret action is
authorized by this document.

Scan base: canonical `main`
`144d5f13b0526fc22de1e56a2aa38320f78572ae` on 2026-08-13.

Parent roadmap:
`ops/docs/plans/OAUTH_APPLE_USER_22_RECOVERY_ROADMAP.md`.

## Readiness Verdict

The recovery is **not ready for production execution**. Its parts have three
different readiness classifications:

- **Resolver source: ready.** The fixed unmatched-provider contract and the
  narrow consolidation service exist locally and retain passing focused
  evidence.
- **Release preparation: ready locally.** The exact accepted Candidate B inputs
  exist and can be assembled in an isolated local worktree without touching
  production.
- **Production rollout: blocked.** The production release checkout contains 86
  untracked public paths whose ownership and cleanup safety are unknown.
- **Historical remediation: blocked by design and evidence.** User 22 has not
  received the required protected eligibility inventory, the keeper's proof
  capability is unknown, and no routed fresh-Apple-proof recovery interface
  exists.

User 22 remains preserved. Deletion, unlinking, direct reassignment, closure,
or an ad hoc runner/SQL operation would violate the accepted recovery model.

## Evidence Reviewed

This scan used only current local source, Git, tests, and accepted sanitized
Control records. It performed no production/provider/account observation.

Current local evidence:

- canonical `main` was clean at scan entry and contained the parent roadmap;
- local `release/current` resolves to the accepted baseline
  `99a0a6929c5cb0eace21d5fa074cdab3950b269c`;
- all five accepted Candidate B input commits exist locally:
  `684c9ef`, `740aa39`, `7fa60f0`, `6eb57c3`, and `dcc258b`;
- the account resolution browser routes, central start/callback routes, and
  native OAuth contract are present;
- migration `20260812000000 Create OAuth account resolutions` is up in the
  local test database;
- the focused resolver/resolution/concurrency/consolidation/browser/linking/
  closure suite passed: 28 runs, 163 assertions, 0 failures, 0 errors, and 0
  skips;
- the earlier immutable Candidate B rehearsal passed the complete Rails suite:
  452 runs, 2,692 assertions, with its duplicate-index stop rehearsal;
- `git diff --check` passed.

Accepted production evidence remains limited to:

- exact target/user/path/branch/HEAD/release-ref fences passed during the last
  preflight;
- checkout cleanliness failed;
- one later read-only command identified 86 untracked paths: one under
  `rails/public` and 85 under `vue/public`;
- the paths are syntactically safe public-path names, mostly clothing, hotel,
  ramen, and restaurant media, with one archive path;
- no contents, types, sizes, links, provenance, ownership, runtime use, or
  cleanup safety were inspected;
- no production mutation occurred.

The checkout observation is point-in-time evidence from 2026-08-12. A later
packet must re-fence current state rather than assume it is unchanged.

## Source Readiness Findings

### Ready and covered

- Exact provider subject remains the primary identity authority.
- Generic signed-out cross-provider email attachment is absent.
- An unmatched account OAuth exchange creates only a short-lived pending
  resolution when the binary feature gate is enabled; it does not mint a user,
  identity, cookie, or native session.
- Existing-account resolution requires email/password proof; new-account
  resolution requires explicit name, email, password, terms acceptance, and
  confirmation.
- Admin unmatched OAuth is lookup-only.
- Pending tokens are digest-backed, purpose/surface/provider scoped, expiring,
  one-use, and lock-protected.
- The consolidation service locks the keeper, source, and identity; requires a
  freshly exchange-derived proof plus keeper password and confirmation; moves
  only one exact identity; revokes source refresh tokens; closes the source;
  and writes a redacted subject fingerprint.
- The consolidation predicate rejects source user work, admin authority,
  dependents, registrations, payments, sessions/tokens, privacy/lifecycle/
  assistance state, preferences, settings, closure state, and other enumerated
  meaningful work.
- Both `oauth_account_resolution` and `oauth_account_consolidation` default
  disabled when their system ConfigEntry is absent.

### Missing by design

- No production recovery route, controller, or UI calls
  `create_consolidation_proof_from_exchange!` or the consolidator.
- The ordinary signed-in Apple link journey cannot recover this case: because
  the Apple identity is already owned by user 22, the normal linker must report
  an ownership conflict rather than move it.
- There is no accepted recovery-specific OAuth intent that turns a freshly
  completed Apple exchange for the already-owned exact identity into a
  consolidation proof for the signed-in keeper.
- There is no accepted confirmation/reconciliation surface for the one atomic
  consolidation attempt.
- The consolidator currently accepts only keeper password proof. Whether the
  intended Google-linked keeper has a usable password is not known.
- The current empty-placeholder predicate has not been evaluated against
  production user 22. The visible `OAuth User` name and single Apple identity
  are necessary evidence, but are not sufficient eligibility proof.

These are blockers to historical remediation, not defects in the already
accepted unmatched-provider resolver.

## Phase Readiness Matrix

| Roadmap phase | Readiness | Evidence or first blocker |
| --- | --- | --- |
| Phase 0 — preserve/freeze | Ready and governing | User 22 remains unchanged; no recovery flag or mutation authority is active. |
| Phase 1A — local real Apple OAuth | Conditional | Source is ready, but Central Auth local callback allowlisting, local tenant/config presence, approved real-provider identity, and exact runtime procedure are unverified. |
| Phase 1B — production checkout | Blocked | The 86 paths are known only by normalized name. A preserve/replace decision is unsafe without bounded read-only type/provenance/runtime-use classification. |
| Phase 2 — construct Candidate B | Ready locally | Exact baseline and five commits exist; prior disposable rehearsal passed. A new immutable candidate commit has not yet been created. |
| Phase 3 — production preflight | Not ready | Requires a clean/replaced checkout and the exact newly reviewed Candidate B commit. |
| Phase 4 — deploy disabled | Not ready | Requires successful preflight, exact deployment/rollback packet, and approval. Actual schema/config/service state remains unobserved. |
| Phase 5 — activate resolution | Not ready | Requires deployed source, disabled-flag smoke acceptance, and a separate controlled unmatched-provider case. |
| Phase 6 — user 22 inventory | Sequence-blocked | Requires deployed-source validation and 24-hour review under the accepted roadmap, then protected count/Boolean-only inventory. |
| Phase 7 — recovery interface | Design-incomplete | Core service exists, but routed fresh Apple proof, keeper reauthentication decision, confirmation, and uncertain-outcome reconciliation are absent. |
| Phase 8 — recover user 22 | Not ready | Requires Phases 4–7, exact eligible source/keeper, staff availability, narrow flag window, and one-use execution authority. |
| Phase 9 — verify/monitor | Defined but unavailable | Evidence schema is known; it follows only a successful or reconciled Phase 8 transaction. |

## Gaps Requiring Decisions

### Production checkout classification

The existing safe path list is insufficient to select cleanup. The smallest
next production observation should remain read-only and return only:

- exact repeated target/ref/checkout fences;
- path kind: regular file, directory, or symlink;
- bounded size/count totals and safe MIME/file classifications;
- normalized symlink target classification, if any, without following it;
- `git check-ignore` source/rule classification where safe;
- bounded archive member-name/count inventory without extraction or contents;
- whether tracked deploy manifests or current public entrypoints refer to the
  paths, using predefined query shapes;
- start/end status equality and non-mutation proof.

It must not read arbitrary contents, expose user uploads, archive contents,
secrets, logs, or environment data, or clean/move/copy any path. Its result
supports a later Director choice among preservation, relocation, and clean
release replacement.

### Local real-provider test contract

The source is ready for a real Apple round trip, but readiness still needs:

- exact Central Auth project/tenant used by Wenfu;
- verified local callback allowlist, not the roadmap's expected value by
  assumption;
- approved local return origin and ports;
- safe environment-key presence check without values;
- a disposable/local keeper account and clean identity precondition;
- explicit provider/account authority for the staff Apple interaction;
- rollback/reset rules for the local database and Central Auth test state.

No provider-console change should be inferred. If the callback is not already
allowlisted, adding it is a separate external mutation decision.

### Keeper reauthentication

The intended keeper record is known only indirectly through the supplied Gmail
fact. Before recovery-interface design is frozen, protected evidence must
answer whether that exact account has a usable password. The choices are:

1. retain the current password proof if already available;
2. use the existing account add-password flow before recovery; or
3. accept and implement a new step-up proof tied to a recent keeper session.

The third option is a new security design and must not be silently substituted.
Planning recommends the existing password/add-password path if it is available.

### Fresh Apple proof acquisition

The recovery journey needs a distinct signed-in intent. It must:

- preserve the signed-in keeper session;
- complete Apple through Central Auth;
- resolve the exact already-owned provider subject without logging into user
  22 or invoking the normal linker;
- mint only a short-lived purpose-bound consolidation proof;
- return to an explicit keeper confirmation screen;
- consume the proof and consolidate once;
- fail closed on provider mismatch, ownership drift, replay, cancellation,
  expired state, lost keeper session, or unsupported source state.

This interface must be user-facing or a registered protected validator. A
direct operator runner carrying passwords/provider material is rejected.

## Recommended Packet Order

The scan refines the roadmap without weakening its production sequence.

1. **Candidate B construction and review — ready now, local only.** This is the
   first no-new-product-decision packet and can produce the exact commit needed
   by later preflight.
2. **Production public-asset read-only classification — requires explicit
   external read-only authority.** This is the first production blocker and
   should produce evidence for the Director's preserve/relocate/replace
   decision, not perform cleanup.
3. **Clean checkout/preservation execution — decision-dependent and separately
   destructive/mutating.** Author only after packet 2 is accepted.
4. **Local real-Apple readiness/preparation — provider/runtime authority
   required.** It may be planned while packets 1–3 proceed, but no provider
   mutation or staff login is implicit.
5. **Repeat production preflight, deploy disabled, and monitor.** Keep each as
   a separate accepted production packet.
6. **Resolution activation and controlled validation.** Keep consolidation
   disabled.
7. **Protected user 22/keeper inventory.** Stop on any meaningful source state
   or keeper Apple conflict.
8. **Recovery-interface source plan and implementation.** Freeze the keeper
   proof model before dispatch.
9. **Recovery-interface deployment, then one user 22 recovery window.** Do not
   combine deployment and historical mutation into one packet.
10. **Immediate and 24-hour verification.** Preserve closed user 22 as the
    audit source.

Only one production mutation is allowed per relevant packet boundary. An
uncertain result prevents retry until read-only reconciliation establishes the
actual state.

## Readiness Classification And Next Owner

Classification:
`apple_oauth_user_22_recovery_not_ready_source_ready_release_preparation_ready`.

No Control packet is active. Recommended next executable packet: exact local
Candidate B construction/review through Control A. Recommended next
production-facing planning packet: target-fenced read-only classification of
the 86 public paths. Neither is dispatched by this scan.

User 22 remains preserved and unchanged.
