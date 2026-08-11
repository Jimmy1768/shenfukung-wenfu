# Expo V1 Functional Stabilization — Control A Implementation Packet

## Identity

- Accepted plan and immutable criteria:
  `/Users/jimmy1768/Projects/shengfukung-wenfu/ops/docs/plans/EXPO_V1_FUNCTIONAL_STABILIZATION_PLAN.md`, all eight confirmed findings and its proposed acceptance criteria.
- Control task and authority state: Wenfu Control A
  `019fc08d-676b-7ca2-be32-3efe42fa2fca`, active and authoritative.
- Repository, worktree, branch, and base HEAD:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`;
  `/private/tmp/shengfukung-wenfu-expo-v1-functional-stabilization`;
  `codex/expo-v1-functional-stabilization`;
  `d77233fb8d492aec7551a8793996b2add4cab405`.
- Packet status and date: recorded immutable Control packet, 2026-08-11.
- Immutable packet identity and implementation attempt:
  `wenfu-control-a-expo-v1-functional-stabilization-attempt-1`.

## Scope

- Objective: Correct the eight accepted Expo V1 functional findings only: success-only mutation transitions; real local/test session restoration and collection loading; preference persistence; dummy-only fixture binding with awaited cleanup; truthful real registration workflow; dummy signup credentials; and data-driven/safe account presentation.
- Exact owned editable paths:
  - `mobile/App.js`
  - `mobile/app/account/screen_model.js`
  - `mobile/app/dummy/adapter.js`, `mobile/app/dummy/fixtures.js`, and `mobile/app/dummy/repository.js`
  - `mobile/app/real/adapter.js`, `mobile/app/real/response.js`, and `mobile/app/real/storage.js`
  - `mobile/app/lib/auth/storage.js`, `mobile/app/lib/theme/resolver.js`, and `mobile/app/lib/theme/storage.js`
  - `mobile/app/tenant/binding.js`
  - `mobile/app/ui/copy.js`
  - `mobile/__tests__/account-surface.test.js`, `mobile/__tests__/dummy-repository.test.js`, `mobile/__tests__/real-adapter.test.js`, `mobile/__tests__/tenant-binding.test.js`, and new focused tests under `mobile/__tests__/` whose names start with `functional-stabilization-`.
- Explicitly excluded paths and systems: Rails, Vue, Planning documents, native generated projects, package/dependency/lockfile/build configuration, prebuild, Gradle, Expo run, EAS, Metro, ADB/device action, OAuth, payments/providers, secrets, production, deployment, push, and all external state.
- Required checks and expected evidence:
  - interaction and adapter tests for every accepted finding, including failure/pending behavior and account-safe failure states;
  - `cd mobile && yarn test`, `yarn lint`, and `yarn verify`;
  - cached local Expo Doctor with `EXPO_OFFLINE=1 CI=1` and no download;
  - both public configuration modes and rejected-identifier/boundary scans already enforced by the mobile checks;
  - `git diff --check`.
- Evidence sources and status: accepted plan is documented; canonical base, clean status, and exact worktree are observed; Rails contract remains read-only authority; no blocker observed.
- First blocked surface, if known: none.

## Incident-Correction Placement

- Is this an incident correction? No. It is the accepted bounded Expo stabilization phase.
- Selected surface: existing Expo JavaScript/state/adapter/test paths only.
- `AGENTS.md` excluded: no Director authorization and no governance change.

## Repair And Terminal Boundary

- Is this a bounded nonterminal repair within unchanged immutable criteria? No.
- Planning packet prohibited until a terminal disposition: yes.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no.
- Eligibility confirmed before selecting a model: yes; this is one bounded ordinary implementation packet.
- Luna disqualifiers checked: availability, cost, mechanical simplicity, and rejection do not qualify for a persistent Handoff.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra/medium`.
- Selection reason and lowest-sufficient configuration: normal bounded Expo JavaScript/state and focused-test work; no transactional persistence, schema, or provider mutation.
- Ephemeral allocation: `gpt-5.6-terra/medium`; Luna is never ephemeral.
- One ephemeral Implementer task: `/root/expo_v1_functional_stabilization`.
- Return destination: this Control directly.
- Implementer boundaries: owned paths only; no acceptance, staging, commit, merge, push, deploy, approval handling, secret access, external mutation, or scope expansion.

## Control Review And Closeout

- Conformance review: against the eight accepted findings, all acceptance criteria, and the explicit exclusions.
- Acceptance/integration: Control independently reruns required checks, stages, commits, and locally integrates only an accepted result into clean canonical `main`.
- Terminal: one immutable direct packet to Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6`, followed by its paired `released_terminal_idle` receipt.
- Authority confirmation: Planning reported accepted local criteria; Strategy owns any cross-repository policy; no such question is present.
