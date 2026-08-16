# Control packet — TempleMate production runtime, EAS, and OTA source

## Identity

- **Accepted plan:** `ops/docs/plans/TEMPLEMATE_PRODUCTION_RUNTIME_EAS_OTA_SOURCE_IMPLEMENTATION_PLAN.md` at `41a92ee090717650a081da16d201362add9a180a`.
- **Control / Planning:** Control B `019fe020-e92e-7770-984f-b59acd547ab0` -> Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- **Repository / worktree / branch:** `/Users/jimmy1768/Projects/shengfukung-wenfu`; `/private/tmp/shengfukung-wenfu-templemate-production-runtime-eas-ota-source`; `codex/templemate-production-runtime-eas-ota-source`.
- **Base:** `41a92ee090717650a081da16d201362add9a180a`, clean with staging empty before this packet.
- **Immutable packet identity / attempt:** `2026-08-17-templemate-production-runtime-eas-ota-source-control-b`, attempt 1.

## Scope and evidence

- **Objective:** Phase B1 source-only production/TestFlight real-runtime, trusted demo-temple QR, EAS Update/runtime/profile, guarded build/OTA interfaces, and truthful initial ledgers.
- **Owned paths:** the plan's listed Mobile config, EAS, lock closure, version/verifier, narrow scripts, real adapter/config/transport/storage and tenant binding/scanner seams, focused tests, TempleMate EAS/OTA/version/build/update reference/ledger docs, and this packet. The Implementer must name every changed path in its return.
- **Excluded:** generated native trees; Rails/Vue; provider/Apple/EAS/device/build/publish actions; credentials/secrets; production/deployment/release/push; Android release profiles; payment/OAuth architecture changes.
- **Configured source facts:** `mobile/eas.json` currently has only development; `mobile/app/real/config.js` permits explicit local/test real origins only; `mobile/app/tenant/scanner.js` defers real binding. These are source gaps to implement, not authority for external action.
- **Required checks:** pre/post package and lock hashes; one project-local compatible dependency materialization; focused and full mobile tests; lint; verifier; Expo Doctor; resolved config matrices; OTA guardrail static/dry tests with child-process stubs; source/secret/localhost/dummy/path/lock scans; diff and clean-state checks.
- **First blocked surface:** none at dispatch. Future B2 EAS/Apple/provider/device/build/publish actions remain outside this packet.

## Boundaries

- **Incident correction:** no. This is accepted additive Phase B1 source authority.
- **Repair:** no. A conformance defect under unchanged criteria will receive a new bounded repair attempt; Planning receives no intermediate packet.
- **Persistent handoff:** no.

## Implementer dispatch

- **Allocation:** `gpt-5.6-terra/medium`, the lowest sufficient normal ephemeral allocation. This is bounded client configuration, adapter/parser/guardrail, test, and documentation work without schema, retained shared-state migration, or external mutation.
- **Task:** one ephemeral Implementer edits owned paths only, runs required source-local checks, and returns directly to this Control.
- **Implementer prohibitions:** no acceptance, stage, commit, merge, push, provider/EAS/Apple access, external mutation, secret access, or scope expansion.

## Control closeout

- Control independently reviews frozen-plan conformance and integrates only an accepted result locally.
- Terminal delivery names attempt, commits, paths, checks, first blocker/disposition, and next owner; Planning's paired receipt is `released_terminal_idle`.
- Planning owns any B2 external authorization. Control B does not coordinate with Control A.
