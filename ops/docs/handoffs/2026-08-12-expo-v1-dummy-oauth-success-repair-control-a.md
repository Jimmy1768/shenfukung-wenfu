# Expo V1 Dummy OAuth Success Repair — Control A Packet

Status: immutable before Implementer dispatch

Date: 2026-08-12

## Identity

- Accepted plan: `ops/docs/plans/EXPO_V1_DUMMY_OAUTH_SUCCESS_REPAIR_PLAN.md`
  at `bd0b8e0149bce1b4f2aad9e235ca70053d583ceb`.
- Control: Wenfu Control A `019fc08d-676b-7ca2-be32-3efe42fa2fca`,
  `gpt-5.6-terra/high`.
- Repository/worktree/branch: `/Users/jimmy1768/Projects/shengfukung-wenfu` /
  `/private/tmp/shengfukung-wenfu-expo-v1-dummy-oauth-success-repair` /
  `codex/expo-v1-dummy-oauth-success-repair`.
- Accepted runtime-report baseline: `11511d35d4fd807e4bd68c7c757c7fa206ff4529`.
- Packet identity and attempt:
  `wenfu-control-a-expo-v1-dummy-oauth-success-repair-attempt-1`.

## Scope

- Objective: repair the provider-independent dummy success path at the actual
  Expo PKCE runtime boundary so Google and Apple reach the existing
  authenticated account-only state, with no browser, provider, or network use.
- Direct diagnosis: `mobile/app/oauth/runtime.js` requests
  `Crypto.CryptoEncoding.BASE64URL`; the installed accepted Expo SDK 54
  `expo-crypto` type/module surface exposes only `HEX` and `BASE64`. Its own
  encoding assertion rejects the unsupported value before dummy OAuth start,
  producing the generic signed-out failure for both providers.
- Implementer-owned paths, minimum necessary subset only:
  `mobile/app/oauth/runtime.js`, `mobile/app/oauth/pkce.js`,
  `mobile/__tests__/dummy-oauth.test.js`,
  `mobile/__tests__/oauth-transaction.test.js`, and one new focused
  runtime-boundary mobile test if needed. `mobile/App.js` and
  `mobile/app/dummy/adapter.js` are read-only unless direct evidence proves
  their edit essential; any other path is excluded.
- Control-owned paths: this packet and final safe receipt under
  `ops/docs/handoffs/` only.
- Exact mechanism: use the supported Expo SDK 54 Base64 digest encoding and
  deterministically translate only its standard Base64 alphabet/padding to the
  existing Base64URL S256 contract. Keep SHA-256, 32 random bytes, entropy,
  verifier rules, expected return URL, transaction record, and controller
  semantics unchanged.
- Required proof: runtime-boundary test must exercise the same Expo runtime
  inputs used by `App.js` (including rejected unsupported encoding and accepted
  Base64-to-Base64URL conversion), prove valid verifier/challenge properties,
  and carry both dummy provider successes through the same controller to an
  authenticated existing snapshot. Retain cancellation, denial, failure,
  interruption, profile-required, replay, expiry, correlation, cleanup, real
  adapter/controller, account-only, network-disabled, and no-provider-browser
  evidence.
- Required checks: focused dummy OAuth, OAuth transaction, and new runtime
  boundary test; full `yarn test`, `yarn lint`, `yarn verify`; diff/staged-diff
  checks; focused owned-path and rejected dependency/config/identifier/version/
  provider-SDK/live-origin/network-fallback scans. Only a byte-identical
  temporary existing `node_modules` symlink may be used, then removed.
- Explicit exclusions: package manager/install, manifest/lockfile/config/
  native/Rails/Vue/camera/QR/version/build change; Metro, ADB/device, EAS,
  provider/API/secret, deployment/release/payment/production/push, or scope
  expansion.
- First blocker: none; the direct source-controlled mechanism is within the
  plan-owned Expo OAuth/PKCE/test paths.

## Incident-Correction Placement

- Incident correction: yes; a minimum mobile runtime/PKCE source and test-hook
  correction, not an `AGENTS.md`, governance, or product semantic change.
- `AGENTS.md` is excluded; no persistent governance change is introduced.

## Repair And Terminal Boundary

- Bounded nonterminal repair within unchanged criteria: no; attempt 1.
- Any failed required evidence or in-scope defect receives a new Control repair
  packet; Planning receives no intermediate status.
- One immutable terminal goes directly to Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6` only after accepted integration or
  a truthful terminal disposition.

## Handoff Eligibility And Implementer Dispatch

- Persistent Handoff requested: no; a single ephemeral Implementer is
  sufficient. Luna eligibility is not present.
- Selected Implementer: `gpt-5.6-terra/medium`. The direct mechanism is
  diagnosed and the bounded JavaScript/test work has no persistence, migration,
  concurrency, or destructive cleanup; medium is sufficient.
- Implementer edits only the packet-owned mobile OAuth/PKCE/test subset; it
  must not stage, commit, merge, push, deploy, access secrets/providers,
  perform external action, or broaden scope. It returns directly to Control.

## Control Review And Closeout

- Control independently verifies the SDK 54 encoding surface, rejected and
  accepted runtime path, exact diff, safety/real-mode residue, full required
  checks, staging, and clean states before commit and local main integration.
- Next owner after accepted integration: Planning may separately dispatch
  Control B for renewed device validation. No device activity follows here.
- Authority confirmation: only local JavaScript/test work is authorized; no
  external, provider, secret, product-runtime, deployment, or release action
  is used.
