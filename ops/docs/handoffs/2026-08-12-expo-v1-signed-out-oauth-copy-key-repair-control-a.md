# Expo V1 Signed-Out OAuth Copy-Key Repair — Control A Packet

Status: immutable before Implementer dispatch

Date: 2026-08-12

## Identity

- Accepted plan: `ops/docs/plans/EXPO_V1_SIGNED_OUT_OAUTH_COPY_KEY_REPAIR_PLAN.md`
  at `2e739627c70c3e013d195762a7e8b5bc8289bdc7`.
- Control: Wenfu Control A `019fc08d-676b-7ca2-be32-3efe42fa2fca`,
  `gpt-5.6-terra/high`.
- Repository/worktree/branch: `/Users/jimmy1768/Projects/shengfukung-wenfu` /
  `/private/tmp/shengfukung-wenfu-expo-v1-signed-out-oauth-copy-key-repair` /
  `codex/expo-v1-signed-out-oauth-copy-key-repair`.
- Runtime evidence baseline: `6445945248c4d51f7e48382d7f61f901506174cb`.
- Plan/base HEAD: `2e739627c70c3e013d195762a7e8b5bc8289bdc7`.
- Packet identity and attempt: `wenfu-control-a-expo-v1-signed-out-oauth-copy-key-repair-attempt-1`.

## Scope

- Objective: repair the signed-out OAuth phase label lookup that references the
  nonexistent `t.oauthState` dictionary and add only its static regression
  proof.
- Implementer-owned paths: `mobile/App.js` and
  `mobile/__tests__/ui-refinement.test.js` only.
- Control-owned paths: this immutable packet and a final safe receipt under
  `ops/docs/handoffs/` only.
- Exact change: the signed-out lookup must be
  `t.oauthOutcome[oauthState.phase] || t.oauthOutcome.idle`; no dictionary
  rename, alias, copy, refactor, JSX/UI, adapter, OAuth-behavior, locale, or
  other cleanup is permitted.
- Tests: focused UI-refinement test, full `yarn test`, `yarn lint`,
  `yarn verify`, `git diff --check`, staged diff check, focused path/diff
  review, and final clean/staging-empty review. A temporary byte-identical
  existing `node_modules` symlink is permitted only for checks and must be
  removed.
- Explicit exclusions: package install, manifest/lockfile/config/version/native
  changes; Rails/Vue/Planning edits; Metro, ADB/device, camera/QR, OAuth/API
  runtime, EAS/build, provider, deployment, release, payment, production, and
  push.
- Evidence: the plan documents the rendered failure and source mismatch;
  current source observes `t.oauthState` only in the signed-out render and
  existing `oauthOutcome` dictionaries in both locales. First blocker: none.

## Incident-Correction Placement

- Incident correction: yes; it is a one-line source/test correction and creates
  no persistent governance, copy-system, or product-runtime change.
- Selected surfaces: existing mobile render source and its existing focused
  regression test. `AGENTS.md` is excluded.

## Repair And Terminal Boundary

- Bounded nonterminal repair within unchanged criteria: no; this is attempt 1.
- Any failed required check or observed direct conformance defect is a new
  Control-owned repair packet; Planning receives no intermediate packet.
- Terminal target: Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6` with
  one immutable direct terminal after accepted integration or true terminal
  disposition only.

## Handoff Eligibility And Implementer Dispatch

- Persistent Handoff requested: no. Eligibility was assessed before selection;
  this normal, deterministic correction needs one ephemeral Implementer.
- Selected Implementer: `gpt-5.6-terra/medium`, the lowest sufficient model
  for a two-file static lookup/test repair; no transactional, retained-state,
  concurrency, migration, or destructive complexity exists.
- Implementer task: edit only the two owned mobile paths, run required local
  checks, remove any temporary symlink, and return direct evidence to Control.
- Implementer may not stage, commit, merge, push, deploy, approve, access
  secrets/providers, mutate external state, or expand scope.

## Control Review And Closeout

- Control independently verifies exact diff, lookup/dictionary residue,
  required checks, boundaries, staging, and clean status before committing and
  fast-forward integrating accepted work to canonical `main`.
- Continuation after acceptance: Planning separately owns renewed device/Metro
  validation through Control B; no device action follows from this packet.
- Authority confirmation: Planning supplied only the accepted local plan; no
  external, provider, secret, product-runtime, or deployment authority is used.
