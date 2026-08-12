# Expo V1 Registration Quantity Input Repair Plan

Status: accepted for direct implementation dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Canonical Planning base:
`e9bf205b875ac7240cbc2dbbeccb711f53321b0a`

Runtime evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-registration-runtime-known-contact-default-retry-control-b.md`

## Diagnosis

The runtime attempt focused a quantity field visibly showing exact `1`, sent
the authorized end/delete sequence, and still observed `1`. Source explains
the result:

```text
value={String(registration.registration.quantity || 1)}
```

`onChangeText` can set quantity to `''`, but the logical-OR fallback
immediately renders `1` again. A normal user cannot clear the controlled field
before entering a replacement value. This is a JavaScript product defect, not
an ADB, native-client, or rebuild problem.

## Objective

Make the registration quantity TextInput preserve an intentional empty string
during editing while still defaulting a missing (`null` or `undefined`)
quantity to visible `1`.

The repair must not alter registration validation, price/fee authority,
quantity persistence, offering/registrant selection, dummy/real adapters,
payments, or any other form field.

## Owned Paths

- `mobile/App.js`
- `mobile/app/account/registration_authority.js`
- `mobile/__tests__/registration-authority.test.js`
- one Control-owned immutable report/packet under `ops/docs/handoffs/`

No other path may change.

## Frozen Implementation

Add and export one pure helper in
`mobile/app/account/registration_authority.js`:

```js
function quantityInputValue(value) {
  return value === null || value === undefined ? '1' : String(value);
}
```

Import it in `mobile/App.js` and replace only the quantity FormInput's current
logical-OR expression with:

```text
value={quantityInputValue(registration.registration.quantity)}
```

Required semantics:

- `undefined` -> `'1'`
- `null` -> `'1'`
- `''` -> `''`
- `1` -> `'1'`
- `'1'` -> `'1'`
- `2` -> `'2'`
- `'2'` -> `'2'`
- `0` -> `'0'` (presentation must not silently replace invalid input;
  existing validation remains authoritative)

Do not use another truthiness fallback, mutate state inside the helper, add
input normalization, change `validQuantity`, or special-case ADB/runtime test
values.

## Tests And Checks

Extend `mobile/__tests__/registration-authority.test.js` with direct helper
assertions for every required semantic above. Preserve all existing authority
tests.

Control independently requires:

- focused registration-authority test passes;
- full `yarn test` passes;
- `yarn lint` passes;
- `yarn verify` passes with TempleMate/Komainu identity, API 36, version
  `1.0.0`, Android build `1`, and iOS build `1` unchanged;
- source scan finds no remaining
  `String(registration.registration.quantity || 1)` in `mobile/App.js`;
- the helper is the only quantity presentation change;
- `git diff --check` and exact owned-path review pass; and
- canonical/isolated worktrees finish clean with staging empty.

No Expo Doctor is required because this changes no manifest, dependency,
config, or native closure. No Metro/device runtime action belongs to this
source packet.

## Acceptance

Accept only if:

1. missing quantity still displays `1`;
2. an empty editing value stays visibly empty;
3. nonempty and invalid-present values are represented truthfully;
4. all existing registration authority behavior/tests remain green; and
5. no unrelated product or native surface changes.

Completion classification:
`expo_v1_registration_quantity_input_repair_complete`.

After acceptance, Planning may separately dispatch Control B to repeat only
the remaining installed-client registration runtime evidence. Runtime
validation is not part of this source packet.

## Explicit Exclusions

- no runtime/Metro/ADB/device action or Director input;
- no dependency/lockfile/config/native/prebuild/build/EAS/APK/AAB/version/
  build-number change;
- no Rails/Vue/database/schema/migration change;
- no registration fee/offering/registrant/payment/provider/OAuth/admin logic
  change;
- no production/deployment/release/push/secret/external action.

Current classification:
`expo_v1_registration_quantity_input_repair_authorized`.

First blocker: none at dispatch.
