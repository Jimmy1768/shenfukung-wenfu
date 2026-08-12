# Expo V1 Dummy OAuth Success Repair Plan

Status: accepted for direct implementation dispatch to Control A after commit

Created: 2026-08-12

Owner: Wenfu Planning

Target: Wenfu Control A
`019fc08d-676b-7ca2-be32-3efe42fa2fca`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`11511d35d4fd807e4bd68c7c757c7fa206ff4529`

Runtime evidence:
`ops/docs/handoffs/2026-08-12-expo-v1-dummy-device-validation-after-render-repair-control-b.md`

## Objective

Diagnose and repair the provider-independent, network-free dummy Google and
Apple success journeys that failed on the installed TempleMate development
client, add focused proof at the actual Expo runtime boundary, and integrate
the smallest JavaScript correction without rebuilding or touching a device.

This packet repairs dummy-mode test behavior only. It does not validate or
change real Google/Apple OAuth, Rails, Central Auth, provider configuration, or
the signed-in account contract.

## Confirmed Evidence And Gap

The renewed Pixel run proved that the prior signed-out render defect is fixed
and that email/account dummy paths render. In the same bounded session:

- one visible dummy Google action and one visible dummy Apple action each
  returned to signed-out state with
  `External sign-in did not complete. Start again.`;
- neither reached the required account-only signed-in state;
- no provider browser, provider account, Rails/Central Auth request, or real
  OAuth result was used;
- the mechanism remained unknown from sanitized package-scoped runtime
  evidence;
- existing deterministic dummy-controller and PKCE tests passed.

Canonical source shows a material coverage difference that this repair must
close: the app creates PKCE through `createExpoOAuthRuntime()` and the installed
Expo Crypto module, while current controller tests inject a synthetic PKCE
function and current dummy tests do not exercise that Expo runtime boundary.
That gap is evidence for diagnosis, not a predetermined root cause.

## Owned Paths

Control A may authorize one ephemeral Implementer to edit only the minimum
necessary subset of:

- `mobile/App.js`;
- `mobile/app/oauth/runtime.js`;
- `mobile/app/oauth/pkce.js`;
- `mobile/app/oauth/transaction.js`;
- `mobile/app/dummy/adapter.js`;
- `mobile/__tests__/dummy-oauth.test.js`;
- `mobile/__tests__/oauth-transaction.test.js`;
- one new focused mobile OAuth-runtime test only if required by the direct
  mechanism.

Control-owned immutable packet/report paths under `ops/docs/handoffs/` are
also allowed. No other product, configuration, dependency, lockfile, version,
native, Rails, Vue, camera/QR, or Planning path is owned.

## Required Diagnosis And Implementation

1. Reproduce the failed success path at the narrowest source-controlled
   boundary that uses the same Expo runtime inputs as `App.js`, without a
   provider, browser, network request, Metro session, or device action.
2. Identify the first exact failing phase and direct mechanism. Do not infer a
   native or Expo Crypto defect from the generic UI message alone.
3. If the Expo runtime PKCE path is involved, verify the installed Expo SDK 54
   module surface from the accepted byte-identical dependency tree and prove
   that the resulting verifier/challenge satisfy the existing S256 contract.
   Do not add a crypto dependency or weaken PKCE.
4. Apply the smallest JavaScript repair so both dummy Google and dummy Apple
   success journeys reach `authenticated`, expose the existing repository
   snapshot, and allow `App.js` to enter the account-only signed-in state.
5. Preserve the same provider-independent controller and real-mode path. Dummy
   mode must remain visibly fixture-only and network-disabled; it must never
   open a provider browser or fall back to real mode.
6. Preserve cancellation, denial, failure, interruption, profile-required,
   replay, expiry, provider-correlation, fail-closed cleanup, and session-clear
   behavior.

If direct evidence identifies a mechanism outside the owned paths or requires
a dependency, configuration, native, Rails, provider, or semantic contract
change, stop with a Planning design gap. Do not broaden the packet.

## Required Tests And Checks

Focused tests must prove:

- the direct mechanism that failed on the installed runtime is covered and the
  rejected form fails deterministically;
- Google and Apple dummy success each reach `authenticated` through the same
  provider-independent controller used by `App.js`;
- the accepted snapshot is available for the account-only signed-in
  transition;
- dummy success performs no network request and opens no real/provider browser;
- existing cancellation, denial, failure, interruption, profile-required,
  replay, expiry, and cleanup cases remain passing;
- real-mode adapter/controller contracts and return-URL correlation are not
  changed.

Control independently runs:

- the focused dummy OAuth, OAuth transaction, and any new runtime-boundary
  test;
- full `yarn test`;
- `yarn lint`;
- `yarn verify`;
- `git diff --check`, staged diff check, and focused owned-path review;
- rejected dependency, config, identifier, version/build, provider SDK, live
  origin, and network-fallback scans.

Use only an already available byte-identical dependency tree through the
accepted temporary-symlink method if the isolated worktree lacks
`node_modules`; remove it before acceptance. Do not install, copy, or update
dependencies.

Expo Doctor, export, prebuild, Gradle, EAS, and physical-device evidence are
not acceptance criteria for this JavaScript-only repair. Renewed device proof
is a separate Control B packet after source integration.

## Acceptance Criteria

1. The exact failing dummy success mechanism is identified with direct source
   or deterministic runtime-boundary evidence.
2. Both dummy Google and Apple success journeys reach the existing
   account-only authenticated state without provider/browser/network use.
3. Focused regression evidence covers the actual Expo runtime inputs that the
   pre-repair injected tests did not cover.
4. All existing OAuth safety, correlation, replay, cleanup, real-mode, and
   account-only boundaries remain intact.
5. Mobile tests, lint, and native identity/version guards pass.
6. No dependency, lockfile, Expo config, native code, Rails, camera/QR,
   version/build, provider, or external-system change occurs.
7. Canonical and isolated Git states are clean with staging empty after Control
   integration.

## Explicit Exclusions

- Metro, ADB, Pixel/device interaction, app launch/reload, screenshot, camera,
  QR, or runtime re-observation;
- real Google/Apple OAuth, provider browser/account/console, credentials,
  secrets, Central Auth/Rails calls, or deployed server validation;
- dependency/manifest/lockfile/config/version/build/native changes;
- EAS/local build, prebuild, APK/AAB, signing, deployment, release, OTA, store,
  payment, production, or push;
- CameraView warning repair, dependent/registration automation refinement, QR
  binding, tenant switching, UI refinement, or unrelated cleanup.

## Sequencing

On accepted integration, Planning will separately dispatch Control B to reuse
the installed development client and exact accepted USB Metro method. That
runtime packet will first prove dummy Google and Apple success, then separately
resume TempleMate's in-app QR and tenant-switch subslice. It will also retain
the observed CameraView presentation warning as a distinct follow-up rather
than silently treating it as repaired.

Current classification:
`expo_v1_dummy_oauth_success_repair_authorized`.

First blocker: none.
