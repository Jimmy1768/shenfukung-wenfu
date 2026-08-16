# Control repair packet — production OAuth trusted-origin proof

## Identity

- **Parent:** `2026-08-17-templemate-production-runtime-eas-ota-source-control-b`, accepted plan at `41a92ee090717650a081da16d201362add9a180a`.
- **Repair attempt:** 3, following binding-persistence repair attempt 2; Control B -> Wenfu Planning.

## Observed conformance defect

The candidate config resolves TestFlight/production to the exact public origin, and the real adapter uses that config for Rails-native OAuth start/exchange. However, the required test evidence does not explicitly instantiate the release configuration and prove those OAuth calls use only `https://shengfukung.com.tw`, never Google, Apple, or Central Auth directly. The frozen plan explicitly requires that proof.

## Direct mechanism and scope

- Add only focused real-adapter/OAuth test evidence (and production-config test evidence only if necessary) that captures the configured start/exchange requests from a TestFlight/production real adapter and asserts the exact trusted Rails origin and existing scheme/PKCE envelopes.
- Do not alter source behavior, dependencies/lockfile/EAS/version/docs, or any external system. Do not materialize dependencies again.
- Run the focused dependency-free tests and static/diff checks. Reuse the recorded successful full-suite and unchanged-config check evidence.

## Boundaries

- Fresh ephemeral Implementer: `gpt-5.6-terra/medium`; normal narrow test-conformance repair.
- No staging, commit, EAS/Apple/provider/device/build/publish, secret, or external action by the Implementer.
- Control reviews exact test scope and all accumulated packet evidence before terminal acceptance.
