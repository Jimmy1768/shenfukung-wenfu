# Expo V1 Registration Authority Runtime Validation Plan

Status: accepted for direct runtime dispatch to Control B after commit

Created: 2026-08-12

Owner: Wenfu Planning

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Canonical Planning base and accepted source baseline:
`92f00fd78869dfe1b2ee7d1207052bc861778a52`

Accepted source plan:
`ops/docs/plans/EXPO_V1_REGISTRATION_AUTHORITY_ALIGNMENT_PLAN.md`

Accepted source report:
`ops/docs/handoffs/2026-08-12-expo-v1-registration-authority-alignment-control-b.md`

Parallel-track boundary: OAuth production rollout remains paused pending the
Director's separate Candidate B/read-only-preflight decision. This Expo packet
must not contact production, edit OAuth, or coordinate with Control A.

## Objective

Use the already installed TempleMate development client and the accepted USB
Metro method to obtain visible dummy-mode evidence that the registration flow
now follows the account authority contract:

1. new registration begins only from a temple-defined Discover offering;
2. offering identity and fee/currency are visible and not editable;
3. self and an existing dependent can each be selected as registrant;
4. draft create and metadata edit preserve offering/fee authority and do not
   duplicate rows;
5. the paid fixture remains read-only with no payment/checkout action;
6. the remaining exact dependent-create transition is visibly proven; and
7. reset restores the canonical fixture state and exact runtime cleanup.

This is observation-only. Do not repair source during the packet. The accepted
changes are JavaScript/Rails source and require no new native binary.

## Accepted Source Preconditions

Control independently proves before runtime:

- canonical source contains accepted implementation commit
  `693e6dcbaa8525e05fea2b133dbed956d86d6537` and the current committed
  Planning plan;
- canonical and isolated Git states are clean with staging empty;
- full mobile tests remain 51/51, followed by `yarn lint` and `yarn verify`;
- the installed dependency tree is byte-identical to current
  `mobile/package.json` and `mobile/yarn.lock`, using the accepted temporary
  symlink method only if necessary and removing it at terminal;
- exact Pixel serial `39011FDJH00FQ8` is connected as `device` and identifies
  as Pixel 8 / `shiba`;
- installed package is exactly `com.jimmy1768.komainu.dev`, launcher
  `.MainActivity`, version `1.0.0`, Android code `1`, and target SDK 36;
- TCP 8081 has no unrelated listener and the exact serial has no pre-existing
  `tcp:8081` reverse mapping; and
- no other TempleMate runtime-validation packet is active.

An Android 17/API 37 Pixel is acceptable runtime evidence for the installed
target-SDK-36 development client. Do not reinterpret this as a native
compatibility certification or require an Android 16 device.

## Exact Runtime Method

Use only the previously accepted target-fenced USB method:

    adb -s 39011FDJH00FQ8 reverse tcp:8081 tcp:8081
    TEMPLEMATE_CLIENT_MODE=dummy BUILD_MODE=development npx expo start --dev-client --localhost --port 8081

Open only Metro's emitted local `exp+templemate` URL through target-fenced ADB.
Do not ask the Director to scan a Metro/Expo QR code. Do not use TempleMate's
in-app scanner, the Expo development launcher scanner, or the Pixel native
camera/scanner in this packet.

Dismiss only the expected development overlay if it blocks the app. Do not
clear app storage, reinstall, rebuild, change permissions, or mutate the
package.

## Packet-Local Test Data

Use only the deterministic dummy fixture account and these temporary values:

- dependent name: `Runtime Dependent`;
- retain the prefilled relationship value; do not replace it;
- self-registration editable contact name: `Runtime Contact`;
- self-registration quantity after edit: `2`.

No personal data is permitted. Before typing into an existing field, visibly
clear that exact field and verify focus. If target-fenced input cannot produce
the exact temporary value before any committed mutation, record that row as
`untested` and do not classify a product defect. Do not concatenate values or
accept an approximate row as evidence.

## Runtime Sequence

### 1. Canonical entry

1. Reach the signed-out TempleMate dummy disclosure.
2. Sign in with the existing fixture credentials.
3. Use visible dummy reset once if needed to establish canonical state:
   one fixture dependent, one paid/read-only registration, and the deterministic
   event/service/gathering catalog.
4. Require account-only navigation and no render error.

### 2. Exact dependent-create evidence

1. Open Dependents.
2. Clear the name field, enter exactly `Runtime Dependent`, and retain the
   prefilled relationship value.
3. Press Add once.
4. Require exactly one new `Runtime Dependent` row, no concatenated name, no
   duplicate, and preservation of the fixture dependent.
5. Keep this temporary dependent until both registration subslices complete.

This closes only the previously untested dependent-create row. Repeating the
already accepted dependent edit/delete evidence is unnecessary except for the
final cleanup/reset proof.

### 3. Discover and immutable preparation

1. Open Registrations and confirm the existing paid fixture is visibly
   read-only and has no payment or checkout action.
2. Confirm the only new-registration action directs to Discover; no freeform
   offering Add form is present.
3. Open Discover and require the deterministic temple offerings and their
   read-only fees:
   - `平安祈福` — `TWD 1,200`;
   - `線上祈福服務` — `TWD 600`;
   - `社群聚會` — `TWD 0`.
4. Require each offering to expose a Register action and no editable offering,
   slug, action, price, currency, or total control.
5. Select `線上祈福服務`. Require the prepared registration form to show the
   same title and `TWD 600`, self and both dependent choices, permitted
   metadata fields, Create, and Cancel.
6. Press Cancel once. Require return to Registrations with no new row and no
   mutation of the paid fixture.

### 4. Self draft create and metadata edit

1. Return to Discover and select `線上祈福服務` again.
2. Keep the fixture account selected as registrant and create once with
   quantity `1`.
3. Require exactly one new draft row for `線上祈福服務` and the fixture account,
   with the original paid fixture preserved and no duplicate.
4. Open that draft. Require offering title and `TWD 600` to remain read-only.
5. Change only quantity to `2` and contact name to exactly `Runtime Contact`,
   then update once.
6. Require one updated draft row without duplication. Reopen it and require
   quantity `2`, contact name `Runtime Contact`, and unchanged
   `線上祈福服務` / `TWD 600`.

The UI need not expose a payment action or claim payment success. If it shows a
derived total, it must be consistent with the immutable unit fee and quantity;
absence of a separate total display is not a defect for this packet.

### 5. Dependent draft create

1. Return to Discover and select `平安祈福`.
2. Select exactly `Runtime Dependent` as registrant.
3. Create once with quantity `1` and otherwise accepted defaults.
4. Require exactly one new draft row for `平安祈福` and
   `Runtime Dependent`, without altering the paid self-registration for the
   same offering and without duplicating either draft.
5. Reopen the dependent draft and require the dependent selection plus
   immutable `平安祈福` / `TWD 1,200`; do not edit it further.

### 6. Final authority and reset proof

1. Require the paid fixture still read-only and no registration surface to
   expose payment, checkout, provider, offering-title edit, or fee edit.
2. Use visible dummy reset once.
3. Require removal of `Runtime Dependent` and both temporary drafts and exact
   restoration of one fixture dependent, one paid/read-only registration, and
   the canonical offering catalog.

## Evidence Matrix

The immutable runtime report records `passed`, `untested`, or `defect` for:

- exact dependent create without concatenation or duplication;
- Registrations-to-Discover-only entry;
- all three offering/fee displays and absence of editable authority;
- preparation and Cancel without mutation;
- self draft create;
- self draft metadata edit with immutable offering/fee and no duplicate;
- dependent choice and dependent draft create alongside the existing paid
  self-registration;
- paid fixture read-only/no payment or checkout;
- final reset restoration;
- exact Metro/ADB/dependency/evidence cleanup and clean Git state.

A reproducible visible app failure is a defect and must name the first
prevented criterion plus JavaScript/native/unknown boundary. A target-fenced
automation or text-entry limitation before compliant mutation is `untested`,
not a defect. Control may not repair source, change the values, use approximate
rows, or broaden the runtime method.

Control may use one ephemeral Implementer only for immutable report
preparation and static/diff checks. Control owns target-fenced device/runtime
actions, visible-state review, dummy reset, cleanup, acceptance, report
integration, and terminal delivery.

## Cleanup

At terminal:

- use dummy reset if runtime reached a safe resettable state;
- stop only the packet's Metro process;
- remove only the exact serial `tcp:8081` reverse mapping;
- remove the temporary dependency symlink and packet-created ephemeral
  screenshots/UI hierarchies/log extracts;
- prove no TCP 8081 listener, target reverse mapping, temporary symlink,
  evidence directory, Git change, or staging residue remains; and
- preserve the installed development client and existing camera permission.

## Explicit Exclusions

- no source/config/test/dependency/lockfile/native/Rails/Vue/Planning repair;
- no real local/test API, live server, production, provider, Google/Apple
  browser/OAuth, payment/ECPay/Stripe, admin, or historical-account action;
- no QR presentation/scan, camera use, payload/media handling, tenant switch,
  or permission action;
- no prebuild, Gradle, local/EAS build, APK/AAB, signing, install/uninstall,
  package/storage mutation, release/store/OTA, deployment, push, or secret;
- no version/build change: retain `1.0.0 / Android 1 / iOS 1`;
- no OAuth Candidate B construction, production preflight, release-ref move,
  migration, service restart, flag change, provider validation, or account
  remediation.

## Terminal Classifications

- `expo_v1_registration_authority_runtime_validation_complete`;
- `expo_v1_registration_authority_runtime_defect_found`;
- `expo_v1_registration_authority_runtime_evidence_partial`;
- `runtime_cleanup_reconciliation_required`;
- `no_evidence_backed_direct_repair_remaining`.

Current classification:
`expo_v1_registration_authority_runtime_validation_authorized`.

First blocker: none at dispatch.
