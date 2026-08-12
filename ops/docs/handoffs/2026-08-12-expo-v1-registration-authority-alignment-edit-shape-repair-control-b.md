# Expo V1 registration authority alignment — dummy edit-shape repair packet

## Identity and direct mechanism

- Parent packet: `2026-08-12-expo-v1-registration-authority-alignment-control-b`, attempt 1, at plan base `65c69f12a448fe433430bb61fab7bf3a2a600b31`.
- Repair identity/attempt: `2026-08-12-expo-v1-registration-authority-alignment-edit-shape-repair-control-b`, attempt 2.
- Observed conformance defect: dummy `editRegistration` returns an internal camel-case registration record, while `preparedRegistration` expects Rails-shaped snake-case registration fields. A dependent registration can therefore be displayed/re-prepared as self, violating the frozen self-or-owned-dependent edit authority.
- Direct repair: normalize the dummy edit record to the same public registration preparation shape used by Rails, or make `preparedRegistration` safely normalize that exact dummy shape; add a focused dependent-edit preservation proof.

## Bounded authority

- Editable paths: `mobile/app/dummy/repository.js`, `mobile/app/account/registration_authority.js` only if required for the one public-shape normalization, and focused `mobile/__tests__/dummy-repository.test.js` and/or `mobile/__tests__/registration-authority.test.js`.
- Excluded: every Rails path, `mobile/App.js`, configuration/dependency/native/version/build, provider/payment/OAuth/runtime/device, and all unowned paths.
- Required checks: focused repair test, full mobile `yarn test`, `yarn lint`, `yarn verify`, `git diff --check`, and exact owned-path review.
- One fresh ephemeral Implementer: `gpt-5.6-terra/medium`; narrow local compatibility repair only. No staging, commit, merge, push, or external action.
- Planning receives no intermediate packet: Control integrates only an accepted complete source outcome or returns a terminal disposition if the defect exposes a true plan gap.
