# TempleMate Phase 3 Header Navigation Runtime Crash Diagnosis And Repair Plan

Status: accepted for direct implementation dispatch after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted baseline: canonical `main`
`1fdf5911ce8217587e0489d4c6a571a5e9dd2eb8`

Accepted source plan:
`ops/docs/plans/TEMPLEMATE_PHASE_3_HEADER_UTILITY_AND_SINGLE_LINE_NAVIGATION_PLAN.md`

Accepted source terminal:
`ops/docs/handoffs/2026-08-16-templemate-phase3-header-navigation-dependency-materialization-control-b.md`

Director runtime observation: after the accepted source integration, the
Director reported that the Expo development client crashed. No error text,
process state, Metro state, or causal classification has yet been accepted.

## Objective

Reproduce and classify the reported development-client failure on the exact
Pixel and accepted source. Distinguish a stopped/unavailable Metro attachment,
DevLauncher state, JavaScript render exception, and native process exit before
attributing the observation to the navigation patch. If and only if evidence
shows an in-scope JavaScript regression, implement the smallest repair under
the unchanged accepted navigation criteria and revalidate it.

## Target And Entry Fence

- Exact target serial: `39011FDJH00FQ8`, expected Pixel 8 / shiba.
- Exact package: `com.jimmy1768.komainu.dev`, expected development client
  `1.0.0`, code `1`, target SDK 36, existing launcher/MainActivity.
- Accepted source: canonical `1fdf5911` or an isolated exact descendant that
  contains no unrelated product/source change.
- Before device mutation, verify canonical and isolated Git status/staging,
  package/lockfile byte identity, target identity, installed package identity,
  and current port 8081/reverse/process ownership.
- Read and preserve the prior `stay_on_while_plugged_in` value. A temporary
  USB-only stay-awake value may be used during this packet and must be restored
  exactly during every terminal path.

If the exact device/package/source fence fails, stop without substituting
another target, package, artifact, or source.

## Dependency And Local Check Boundary

- Materialize the exact canonical mobile dependency closure project-locally
  with at most one `yarn install --frozen-lockfile`; normal registry retrieval
  is authorized only for missing locked archives.
- `mobile/package.json` and `mobile/yarn.lock` must remain byte-identical before
  and after. No dependency add/update, alternate closure, script edit, global
  install, or second install is authorized.
- Before runtime work, run the focused header/navigation tests, full mobile
  suite, lint, and verify. A failing source assertion is diagnostic evidence;
  do not bypass it to reach the device.

## Runtime Diagnosis

Use only the established USB method:

- one exact serial-fenced `tcp:8081` reverse;
- one local dummy-mode development-client Metro service on port 8081; and
- the existing local `exp+templemate` development-client URL delivered to the
  exact package/MainActivity.

Do not use or display a Metro/Expo QR code, Expo launcher scanner, Pixel native
scanner, or TempleMate's tenant camera for attachment.

Collect only the minimum package-scoped, Metro, focus/resume, and sanitized UI
evidence required to classify one of:

1. `metro_or_attachment_unavailable`: the installed client did not have a
   usable bundle/attachment and no source crash is shown;
2. `devlauncher_or_foreground_state`: the process is alive but a launcher,
   lock/shade, or foreground condition prevents app observation;
3. `javascript_render_regression`: the current bundle reports a reproducible
   JavaScript exception with a source location/stack;
4. `native_process_exit`: the exact package process exits with package-scoped
   native crash evidence; or
5. `runtime_healthy`: the accepted bundle loads and remains visibly stable.

Do not retain notification text, unrelated logs, screenshots containing
personal information, QR pixels/payloads, credentials, provider responses, or
raw unredacted system output.

## Bounded Repair Authority

Only after a reproducible `javascript_render_regression` is tied to the
accepted header/navigation patch may Control record a nonterminal bounded
repair packet and dispatch one ephemeral Implementer.

Repair ownership is limited to:

- `mobile/App.js`
- `mobile/app/account/screen_model.js`, only if the menu model is causal
- `mobile/__tests__/account-surface.test.js`
- `mobile/__tests__/ui-refinement.test.js`
- one existing focused presentation test only if directly required
- Control records under `ops/docs/handoffs/`

The repair must preserve:

- bound Header Settings + Sign out utilities;
- unbound Header Sign out only;
- exactly five one-line business destinations without label truncation or
  touch-target shrinking;
- all existing Settings content and subordinate flows; and
- every dependency, identity, version, SDK/API, tenant, Assistance, OAuth,
  camera/QR, registration/payment, and adapter boundary.

After any repair, rerun focused tests, the full mobile suite, lint, verify, and
the exact runtime reproduction. A native-process failure or a failure outside
the owned JavaScript paths is not repair authority; report the truthful first
blocker instead.

## Runtime Acceptance

The packet may classify `runtime_healthy` only when the accepted current bundle
loads in TempleMate and remains stable through:

- initial visible app surface;
- one bound Header/business-navigation observation when retained device state
  permits it, or the safe unbound QR-first gate otherwise;
- no visible Render Error or fatal developer overlay; and
- no matching package-scoped JavaScript/native crash during the observation.

Do not require or simulate a tenant QR scan merely to prove process stability.
If the device is unbound, stop at the accepted QR-first gate.

## Cleanup And Evidence

- Stop only packet Metro processes.
- Remove only the exact serial `tcp:8081` reverse, packet-local dependency
  tree, and packet-created sanitized evidence.
- Restore and read back the exact prior stay-awake value.
- Preserve the installed development client and all unrelated device/app data.
- Verify no port listener/reverse or temporary tree remains.
- Run `git diff --check`; require clean/staging-empty isolated and canonical
  final state unless an accepted repair is locally integrated.
- Return one immutable terminal packet directly to Planning with the exact
  classification, causal evidence, changed paths/checks if repaired, cleanup,
  and next owner/action.

## Explicit Exclusions

No app-data clear/reset, uninstall/reinstall, native rebuild/EAS/artifact,
version/build increment, dependency/manifest/lockfile/config change, real API,
OAuth/provider/browser, temple QR presentation/scan, camera, payment, Rails/Vue,
production/deployment/release/push, secret, or external mutation.

Current blocker: none if the exact Pixel remains connected and accessible.
