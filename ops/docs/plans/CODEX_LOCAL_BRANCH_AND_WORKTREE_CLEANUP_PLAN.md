# Codex Local Branch And Worktree Cleanup Plan

Status: accepted for direct cleanup dispatch after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted inventory baseline: canonical `main`
`2242d85c5b8deb5fbb20d5062745bdb7d658a48d`

Director authority: the Director approved Planning's recommended local branch
and worktree cleanup after the read-only inventory reported 78 local branches,
70 merged cleanup candidates, 69 registered `/private/tmp` worktrees, 12
prunable registrations, one dirty superseded packet worktree, and about 12.84
GiB under the matching temporary-directory prefix.

## Objective

Preserve the remaining historical Control records that currently exist only on
unmerged or untracked local state, then remove obsolete local temporary
worktrees and branch refs while retaining canonical history, the inactive OAuth
Candidate B, release authority, and every Codex-managed workspace.

This is repository-local housekeeping. It authorizes no product/runtime,
remote Git, deployment, provider, account, device, or external action.

## Immutable Keep Set

The following must remain byte- and ref-identical except that canonical `main`
may advance through the accepted preservation/report commits:

- canonical branch `main` and worktree
  `/Users/jimmy1768/Projects/shengfukung-wenfu`;
- local release ref `release/current` at its observed value;
- inactive OAuth release candidate branch
  `codex/oauth-account-resolution-candidate-b` at
  `96baa5306e209364b04d0f5d77fb49b75f943019` and its worktree
  `/private/tmp/shengfukung-wenfu-oauth-account-resolution-candidate-b`;
- current detached Codex worktree
  `/Users/jimmy1768/.codex/worktrees/a56a/shengfukung-wenfu`;
- Codex-managed branch/worktree
  `codex/expo-account-json-api-track-a` /
  `/Users/jimmy1768/.codex/worktrees/wenfu-expo-account-json-api-track-a`;
- Codex-managed branch/worktree
  `codex/expo-account-native-integration` /
  `/Users/jimmy1768/.codex/worktrees/wenfu-expo-account-native-integration`;
- all remote refs, including `origin/*`; and
- all repository files except the exact historical records and Control report
  authorized below.

No path under `/Users/jimmy1768/.codex/worktrees`, no remote ref, and no
Candidate B path/ref may be removed, pruned, rewritten, or force-updated.

## Phase 1 — Preserve Historical Records

No branch/worktree deletion may begin until this preservation phase is
committed and integrated on canonical `main`.

### Five unmerged documentation-only branches

Extract the exact committed blobs from these exact tips and add them to the
same repository-relative paths on the current canonical lineage. Do not edit,
normalize, summarize, or rewrite their contents.

1. `codex/expo-eas-android-dev-client-download-install` at
   `4b1fd08fa2e9e02085d32ed1ddec4e80a8a85704`:
   - `ops/docs/handoffs/2026-08-12-expo-eas-android-development-client-download-install-control-b-packet.md`
   - `ops/docs/handoffs/2026-08-12-expo-eas-android-development-client-download-install-control-b.md`
2. `codex/expo-eas-android-dev-client-download-install-2` at
   `95a851807270dc4896dc1637d20cc653646c2c0f`:
   - `ops/docs/handoffs/2026-08-12-expo-eas-android-development-client-download-install-continuation-control-b-packet.md`
   - `ops/docs/handoffs/2026-08-12-expo-eas-android-development-client-download-install-continuation-control-b.md`
3. `codex/expo-v1-dummy-device-camera-validation` at
   `adec69ea8015169992099a19d8598b237f881368`:
   - `ops/docs/handoffs/2026-08-12-expo-v1-dummy-device-camera-validation-control-b.md`
4. `codex/expo-v1-final-ui-runtime-validation` at
   `30b593cfcebcd217bc08f14d92ceefd20e1cfd6d`:
   - `ops/docs/handoffs/2026-08-12-expo-v1-final-ui-refinement-runtime-validation-control-b.md`
5. `codex/expo-v1-final-ui-runtime-validation-2` at
   `396aee203b0d8d13f3e12f0fd8fa7b740ab525fa`:
   - `ops/docs/handoffs/2026-08-12-expo-v1-final-ui-refinement-runtime-validation-renewal-control-b.md`

Control verifies each canonical blob is byte-identical to its named source-tip
blob before any source branch is deleted. These are historical failure/partial
evidence records; adding them to canonical history does not reactivate or
change their outcome.

### One untracked superseded packet

The only accepted dirty-state exception is:

- worktree:
  `/private/tmp/shengfukung-wenfu-expo-v1-registration-runtime-director-setup-callback`
- branch: `codex/expo-v1-registration-runtime-director-setup-callback` at
  `920bccec3b2494e16d13f7f214da749929e4d059`
- sole untracked path:
  `ops/docs/handoffs/2026-08-12-expo-v1-registration-runtime-director-setup-callback-control-b.md`
- observed SHA-256:
  `9a5de46581e939ea6096216a504285bdf61e266eeb7b0e2e8d35fc0c268885c0`

Add that exact byte sequence to the same canonical repository path. It remains
an immutable superseded, nonterminal packet whose pending matrix is historical;
it is not accepted runtime evidence. If the worktree contains any other change
or the hash differs, stop before cleanup.

### Preservation acceptance

Before deletion, Control must prove:

- all eight paths were absent from the accepted inventory baseline;
- all eight canonical copies now match their exact sources byte-for-byte;
- the preservation commit changes only those eight paths plus the Control
  packet/report record;
- canonical integration is complete and clean;
- every source tip remains reachable until all comparisons finish; and
- `git diff --check` passes.

## Phase 2 — Remove Obsolete Temporary Worktrees

Resolve targets from the accepted inventory baseline and record the complete
path/branch manifest in the immutable Control packet before the first removal.

Authorized target class:

- registered worktree path begins exactly
  `/private/tmp/shengfukung-wenfu-`;
- it is not the retained Candidate B worktree;
- it existed in the accepted baseline inventory; and
- its branch is either already merged into accepted canonical history or is one
  of the five exact documentation-only branches whose records passed Phase 1.

The special dirty callback worktree becomes removable only after its exact
untracked packet passed Phase 1 preservation. Every other target must be clean
with empty staging before removal. Any new, different, or additional dirty
state is an immediate stop for that target and must not be discarded.

Prefer `git worktree remove` for valid registered worktrees. For an exact
baseline entry whose administrative gitdir is already prunable, first verify
the directory is the expected non-symlinked `/private/tmp` target and contains
no unpreserved change, then remove only that exact directory and prune only its
stale registration. Never use a variable that can resolve to an empty, root,
home, repository-root, parent, wildcard, or unresolved path.

The Control cleanup worktree itself is excluded while active. After its
accepted documentation/report commit is integrated, Control may operate from
the canonical repository path to remove its own clean temporary worktree and
branch before the terminal inventory.

## Phase 3 — Delete Obsolete Local Branch Refs

After associated worktrees are absent and Phase 1 evidence is canonical:

- delete local branch refs associated with the removed authorized temporary
  worktrees;
- use ordinary merged-branch deletion wherever ancestry permits;
- the five named documentation-only branches may be force-deleted only after
  their exact record blobs are proven canonical;
- delete these five already-merged branch refs that have no registered
  worktree:
  - `codex/templemate-phase3-tenant-gate-back-dismissal-retry`
  - `codex/templemate-phase3-tenant-gate-home-foreground-retry-reuse`
  - `codex/templemate-phase3-tenant-gate-shade-swipe-retry`
  - `codex/templemate-phase3-tenant-gate-shade-swipe-retry-reuse`
  - `codex/templemate-pixel-foreground-diagnosis-reuse`;
- remove the cleanup branch itself only after its accepted commit is integrated;
  and
- run local worktree metadata pruning only after target removal.

Do not delete or alter any ref in the immutable keep set. Do not delete a
branch whose tip or worktree state differs from the accepted manifest.

## Expected Final Inventory

If and only if the accepted baseline remains unchanged, the final local branch
set should be exactly:

- `main`;
- `release/current`;
- `codex/oauth-account-resolution-candidate-b`;
- `codex/expo-account-json-api-track-a`; and
- `codex/expo-account-native-integration`.

The final registered worktree set should be exactly the canonical worktree,
the current detached Codex worktree, the two protected Codex-managed
branch worktrees, and the retained Candidate B worktree. No prunable worktree
registration or removed `/private/tmp` target may remain.

If a new branch/worktree appears after the accepted inventory baseline, do not
infer cleanup authority for it; preserve it and report the final difference.

## Required Evidence

Control records and independently verifies:

1. exact canonical base, plan ancestry, clean status, empty staging, local
   branch inventory, worktree inventory, prunable markers, and disk-use count;
2. the immutable keep set and full cleanup manifest before deletion;
3. eight-path preservation with exact blob/hash equality and docs-only
   canonical integration before branch removal;
4. per-target clean/dirty classification and the one exact accepted dirty
   exception;
5. worktree removal and branch deletion results with no remote operation;
6. final exact branch/worktree inventory or a truthful stopped-target list;
7. retained Candidate B tip/worktree cleanliness and unchanged release/current,
   protected Codex worktrees, remote refs, and canonical product tree;
8. reclaimed local disk space measured from the exact temporary-prefix set;
9. `git diff --check`, canonical plan/report ancestry, clean canonical status,
   empty staging, and no unexpected changed paths; and
10. one immutable terminal report integrated on canonical `main` before the
    cleanup branch removes itself.

No product test suite is required because no product/source/configuration path
may change. A normal report-only Implementer may prepare the preservation and
terminal record; Control owns every destructive Git/filesystem action and must
review the exact resolved target before execution.

## Recovery And Stop Conditions

- Before deletion, every accepted source commit remains referenced and every
  untracked byte is copied into canonical history.
- Merged product history remains recoverable from canonical `main`.
- The five force-deleted branch tips remain recoverable through the preserved
  exact documentation records, but their divergent commit objects are not
  claimed as durable product history.
- Any hash mismatch, new dirty state, missing source tip, unexpected branch,
  keep-set mismatch, canonical drift, symlinked/broad target, failed
  preservation integration, or uncertain removal result stops the affected
  cleanup before a retry.
- No `git reset`, checkout-based discard, broad `git clean`, wildcard removal,
  remote deletion, push, or history rewrite is authorized.

## Explicit Exclusions

No product/source/test/config/dependency/native/version/build edit; no archive
or deletion of Codex tasks; no Control thread lifecycle change; no remote ref,
fetch, pull, push, or GitHub action; no provider, account, secret, device,
runtime, build, deployment, release, production, payment, or external action.

Current blocker: none if the exact accepted inventory and hashes still match.
On terminal acceptance, the parent cleanup is complete and both Controls remain
available for the later separately authorized product phases.
