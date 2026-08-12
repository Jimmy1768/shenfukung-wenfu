# Expo V1 registration quantity input repair — Control packet

## Immutable identity

- Plan/base: `ops/docs/plans/EXPO_V1_REGISTRATION_QUANTITY_INPUT_REPAIR_PLAN.md` at `b576752aa5c300c2990fba0655d87e8231373f2d`.
- Runtime evidence: `ops/docs/handoffs/2026-08-12-expo-v1-registration-runtime-known-contact-default-retry-control-b.md`.
- Control B `019fe020-e92e-7770-984f-b59acd547ab0` to Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Worktree/branch: `/private/tmp/shengfukung-wenfu-expo-v1-registration-quantity-input-repair`; `codex/expo-v1-registration-quantity-input-repair`.
- Packet/attempt: `2026-08-12-expo-v1-registration-quantity-input-repair-control-b`, attempt 18.

## Frozen scope

- Control uses `gpt-5.6-terra/high`; the one Implementer uses `gpt-5.6-terra/medium`, sufficient for the pure bounded helper, one import/use-site, and direct tests.
- Owned product paths: `mobile/App.js`, `mobile/app/account/registration_authority.js`, and `mobile/__tests__/registration-authority.test.js`; this packet is the only documentation path.
- Add/export only `quantityInputValue(value)`, returning `'1'` only for null or undefined and `String(value)` otherwise. Use it only at RegistrationForm's quantity input.
- Required direct semantics: missing -> `'1'`; empty string -> empty; 1/'1'/2/'2'/0 -> truthful strings. No truthiness fallback, validation/state/normalization/authority/payment/adapter change.
- Required checks: focused helper test, full yarn test, lint, verify, rejected-expression scan, owned-path review, diff and clean state. No device/Metro, dependency/config/native/Rails/Vue/provider/payment/OAuth/build/deployment/push/external work.

## Result matrix

| Evidence | Status | Safe result |
| --- | --- | --- |
| Pure helper semantics and RegistrationForm use site | passed | Exported `quantityInputValue` returns `'1'` only for null/undefined and otherwise stringifies faithfully. Direct assertions cover undefined, null, empty string, numeric/string 1 and 2, and 0. RegistrationForm uses it only for the quantity FormInput. |
| Focused/full tests, lint, verify, scans | passed | Focused registration-authority test passed 2/2; full mobile test suite passed 52/52; lint and native-client verification passed. The rejected `String(registration.registration.quantity || 1)` expression is absent from `mobile/App.js`. |
| Exact paths, diff, integration, cleanup | passed | Only the three frozen mobile paths and this packet changed. A temporary byte-identical dependency symlink was used solely to run the checks and was removed before commit. Diff check and exact-path review passed; no config, dependency, native, runtime, provider, or external change occurred. |

## Terminal closeout

- Classification: `expo_v1_registration_quantity_input_repair_complete`.
- Continuation disposition: `accepted_frozen_outcome`.
- Accepted commit and canonical integration: pending Control commit/review at packet creation; completed in terminal evidence.
- Boundary confirmation: no Metro, ADB/device, Director action, dependency/lockfile/config/native/Rails/Vue, fee/offering/registrant/payment/provider/OAuth/admin, production/deployment/release/push/secret, or external action occurred.
