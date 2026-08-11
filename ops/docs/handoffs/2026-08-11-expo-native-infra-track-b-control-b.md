# Expo Native Infrastructure Track B — Control B Packet

## Identity

- Accepted-plan path and immutable criteria:
  `ops/docs/plans/EXPO_NATIVE_CLIENT_INFRA_TRACK_PLAN.md`, Planning direct
  dispatch dated 2026-08-11. Criteria 1–12 in that dispatch are immutable.
- Control task and authority state: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0`; direct Planning owner
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6`; ordinary reversible local Track B
  work authorized by the Director and Planning.
- Repository, worktree, branch, and base HEAD:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`,
  `/private/tmp/shengfukung-wenfu-expo-native-track-b`,
  `codex/expo-native-infra-track-b`,
  `9d9037aa038e131063dbeaaf8d9ed8b1fa5ffc71`.
- Packet status and date: recorded immutable before dispatch, 2026-08-11.
- Immutable packet identity and implementation attempt:
  `2026-08-11-expo-native-infra-track-b-control-b`; attempt 1.

## Scope

- Objective: turn the checked-in Expo 54 scaffold into a locally installable,
  account-only `TempleMate (Dev)` Android development client using deterministic
  dummy data, and stop at the committed pre-integration checkpoint.
- Exact owned editable paths:
  - `mobile/App.js`, `mobile/index.js`, `mobile/app.config.js`,
    `mobile/eas.json`, `mobile/versioning.js`, `mobile/package.json`,
    `mobile/yarn.lock`, `mobile/metro.config.js`, and any new
    `mobile/babel.config.js`, `mobile/jest.config.js`, or package-local test
    configuration required by the accepted scaffold;
  - existing and new paths below `mobile/app/`, `mobile/theme/`,
    `mobile/locales/`, `mobile/assets/`, and `mobile/__tests__/`;
  - `bin/expo_prebuild`, `bin/expo_build`, and new Expo-only scripts below
    `mobile/scripts/` or `bin/` that make the Track B checks deterministic;
  - this Control packet only, at
    `ops/docs/handoffs/2026-08-11-expo-native-infra-track-b-control-b.md`.
- Explicitly excluded paths and systems: all `rails/`, `vue/`, account web
  code, admin/guest/staff/operations code, every `ops/docs/plans/` file,
  payment/OAuth/provider code, secrets/env files, deployment/EAS/cloud/OTA,
  AAB/store/release surfaces, external services, production data, and the
  read-only `/Users/jimmy1768/Projects/DojoMate-Expo` reference. Do not create
  a real Rails adapter or change canonical `main`.
- Required behavior:
  - Product name is `TempleMate`; development launcher is `TempleMate (Dev)`;
    DEV-badged app/adaptive artwork is selected in development. The string
    `竹南鎮聖福宮` is fixture-only tenant content.
  - Preserve independent app version `1.0.0`, three-component validation, and
    untouched iOS/Android build values `1`; add deterministic verify/sync
    guardrails that never bump them or duplicate app version in `eas.json`.
  - The dummy-only account app has explicit startup/signed-out/authenticated
    states, account-only navigation, zh-TW/en and theme preferences,
    safe-area/system-bar/keyboard/back/resume handling, normalized errors and
    pending guards, and environment- plus tenant-scoped storage interfaces.
  - Dummy login, profile-name edit, dependent create/edit/delete, and
    registration create/update must alter visible state and reset visibly and
    deterministically. Paid fixture state is read-only. There is no payment
    UI, provider reference, callback, polling, or mutable payment lifecycle.
  - Tenant binding implements unbound/bound/binding-failed/switching states,
    deterministic connection-link/QR parsing, trust and identity fixtures,
    confirmation and prior-tenant cleanup interfaces. It makes neither a live
    request nor a permanent identity out of the staging hostname.
- Required checks and expected evidence:
  1. deterministic mobile unit/component/config/guardrail suite covering the
     dummy interactions, reset, account-only navigation, locale/theme,
     storage isolation, tenant parsing/trust/switch cleanup, no-network dummy
     behavior, version/config/profile rules, and no payment/admin residue;
  2. package lint/static checks and `expo-doctor` compatibility evidence;
  3. development configuration inspection that proves `TempleMate (Dev)`,
     development-client profile, SDK 36 compile/target configuration, SDK 36
     Android 16 intent, `1.0.0`, and preserved build numbers;
  4. local Android development-client prebuild/compile/install/run evidence
     when the local Android toolchain/device permits it. It must be a debug
     development client/APK only, never EAS/cloud/Expo Go/AAB. If a required
     device/install action is impossible, preserve exact command/output and
     report the first unmet local prerequisite to Control; do not substitute a
     cloud or release build.
  5. `git diff --check`, review of changed paths against this packet, and clean
     implementation worktree before return.
- Evidence sources and status:
  - documented: accepted Track B plan and readiness inventory;
  - observed: clean canonical main at the exact base, Expo 54 scaffold,
    current dev-client mismatch and placeholder residue;
  - unknown: local Android SDK/device availability until checks run.
- First blocked surface, if known: none; Android installation/run may reveal a
  local-toolchain prerequisite, which is not authority to use external EAS.

## Incident-Correction Placement

- Is this an incident correction? no.
- Selected surface: native/mobile source, package configuration, and mobile
  verification hooks only.
- `AGENTS.md` excluded unless explicit Director authorization is recorded: yes.

## Repair And Terminal Boundary

- Is this a bounded nonterminal repair within unchanged immutable criteria: no.
- Failed attempt identity and evidence: none.
- Immutable repair packet direct mechanism, owned paths, and checks: n/a.
- True Planning design gap, Director authority decision, or no evidence-backed
  direct repair remaining: none known.
- Planning packet prohibited until a terminal disposition: yes.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no.
- Eligibility confirmed before selecting a model: yes; no durable continuity
  condition applies.
- Luna disqualifiers checked: availability, cost, mechanical simplicity, and
  rejection do not qualify.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra/high`.
- Selection reason and lowest-sufficient configuration: the packet spans a
  new Expo 54 client architecture, deterministic stateful dummy repository,
  native config/version/build guards, tenant-bound storage and parsing, and
  Android SDK evidence. These coupled, stateful boundaries justify the deeper
  bounded Terra/high allocation; Sol is not needed.
- Ephemeral allocation: `gpt-5.6-terra/high` with the preceding explicit
  immutable-packet complexity rationale; Luna is never ephemeral.
- One ephemeral Implementer task: implement only this packet in the isolated
  worktree and return direct evidence to Control B.
- Return destination: this Control directly.
- Implementer boundaries: owned paths only; no acceptance, staging, commit,
  merge, push, deploy, approval handling, secret access, external mutation,
  scope expansion, Planning-document edit, Control-A coordination, or real
  Rails adapter.

## Control Review And Closeout

- Conformance review against immutable criteria: pending implementer return.
- Acceptance decision and rationale: pending.
- Integration, staging, and commit evidence when accepted: Control-only,
  isolated branch only; no merge to canonical main.
- Immutable terminal packet direct delivery, source Control, target Planning,
  implementation attempt, and continuation disposition: pending; terminal is
  `accepted_frozen_outcome` only after evidence is accepted.
- Paired Planning receipt: `released_terminal_idle` required.
- Parent classification, continuation disposition, and next owner/action:
  Planning retains both parallel checkpoints for a later separate integration
  plan through Control A; Control B stops after the paired receipt.
- `active_packet: none` only with the exact missing decision and owner: n/a
  while this packet is active.
- Residual risk, production gap, and next owner: live Rails adapter,
  trusted-origin document/hosting, provider/OAuth/payment flows, release
  signing/distribution, and final integration remain Planning-owned deferred
  work.
- Authority confirmation: Planning reported evidence and immutable criteria;
  Strategy owns cross-repository policy and the Director accepts it.
