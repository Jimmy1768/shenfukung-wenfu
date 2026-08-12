# Expo V1 registration authority alignment — dummy offering/action repair packet

## Identity and direct mechanism

- Parent accepted-plan packet: `2026-08-12-expo-v1-registration-authority-alignment-control-b`, attempt 1.
- Prior bounded repair: `2026-08-12-expo-v1-registration-authority-alignment-edit-shape-repair-control-b`, attempt 2.
- Repair identity/attempt: `2026-08-12-expo-v1-registration-authority-alignment-offering-action-repair-control-b`, attempt 3.
- Observed conformance defect: the dummy catalog lookup accepts a matching stable offering ID without also requiring its authoritative `account_action`. A forged/mismatched action can therefore select a known offering in dummy mode while Rails rejects it.
- Direct repair: require the same stable offering identity **and** exact catalog action for all dummy selection shapes; add focused proof that a known ID/slug with a wrong action fails without state mutation.

## Bounded authority

- Editable paths: `mobile/app/dummy/repository.js` and focused `mobile/__tests__/dummy-repository.test.js` only.
- Required checks: focused repair test, full `yarn test`, `yarn lint`, `yarn verify`, `git diff --check`, and exact owned-path review.
- Explicit exclusions: Rails, App/UI/config/dependencies/native/version/build/runtime/device/external/provider/payment/OAuth paths.
- One fresh ephemeral Implementer: `gpt-5.6-terra/medium`; no staging, commit, merge, push, or external action.
