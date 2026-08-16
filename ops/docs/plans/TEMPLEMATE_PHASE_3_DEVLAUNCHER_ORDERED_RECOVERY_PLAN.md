# TempleMate Phase 3 DevLauncher Ordered Recovery Plan

Status: accepted for direct runtime dispatch after commit

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted base: canonical `main`
`759477f941c6a40543c189d18a4226beb182b9f2`

Diagnosis:
`ops/docs/handoffs/2026-08-16-templemate-phase3-header-navigation-runtime-crash-diagnosis-and-repair-control-b.md`

Accepted source baseline:
`1fdf5911ce8217587e0489d4c6a571a5e9dd2eb8`

## Accepted Diagnosis

The exact development-client process remained alive, visible, focused, and
top-resumed. The delivered local URL produced a DevLauncher/ReactHost
context-not-ready soft exception and a blank surface. There was no JavaScript
source stack, Render Error, native process exit, or evidence implicating the
header/navigation patch.

## Objective

Recover the existing installed development client through one clean,
target-fenced process lifecycle and a readiness-ordered USB Metro attachment.
Confirm that the accepted bundle loads without a blank surface or fatal error.
This is runtime recovery only and authorizes no source repair.

## Exact Target And Preconditions

- Serial: `39011FDJH00FQ8`, Pixel 8 / shiba.
- Package: `com.jimmy1768.komainu.dev`, version `1.0.0`, code `1`, target SDK
  36, existing MainActivity.
- Source: canonical `759477f` containing accepted navigation source
  `1fdf5911`, or an exact clean isolated descendant with no product change.
- Verify canonical/isolated cleanliness, target/package identity, package
  presence, port 8081 and reverse ownership, and the prior
  `stay_on_while_plugged_in` value before runtime actions.
- If the device is locked, dozing, offline, or not the exact target, stop. Do
  not bypass credentials, keyguard, or system UI.

## Local Preparation

- Materialize the exact canonical mobile dependency closure with at most one
  project-local `yarn install --frozen-lockfile`; normal registry retrieval is
  authorized only for missing locked archives.
- Preserve byte identity of `mobile/package.json` and `mobile/yarn.lock`; no
  dependency/version/script/manifest/lockfile/global-install change.
- Run focused header/navigation tests, the full mobile suite, lint, and verify
  before device actions.
- Record the prior stay-awake value, then temporarily use USB-only value `2`
  during recovery. Restore the exact prior value on every terminal path.

## Ordered Recovery

Perform the following exact package-scoped lifecycle once, in order:

1. force-stop only `com.jimmy1768.komainu.dev`; do not clear app data, cache,
   permissions, storage, sessions, or tenant state;
2. start the exact existing MainActivity once without a development URL;
3. wait for and verify the existing DevLauncher is alive and visibly ready;
4. start one dummy localhost Metro service on port 8081 and verify the listener
   and successful bundle readiness;
5. create one exact serial-fenced `tcp:8081` reverse; and
6. deliver the established local `exp+templemate` URL once to the exact
   package/MainActivity only after both DevLauncher and Metro readiness.

Do not use a Metro/Expo QR code, Expo launcher scanner, Pixel native scanner,
or TempleMate tenant camera. Do not issue a second force-stop, MainActivity
start, URL delivery, reload, or alternate attachment in this packet.

## Acceptance Evidence

Accept recovery only if:

- the exact package process is alive and top-resumed after attachment;
- a usable TempleMate surface replaces the blank DevLauncher surface;
- no Render Error, fatal developer overlay, JavaScript source exception,
  native crash, or context-not-ready recurrence appears in the bounded
  observation;
- retained app state truthfully yields either:
  - the bound shell with Settings + Sign out in the Header and a single-line
    five-destination business menu; or
  - the accepted unbound QR-first gate with Sign out only;
- no QR scan or app-data mutation is required merely to prove recovery; and
- package-scoped/Metro evidence remains sanitized and minimal.

If the same context-not-ready/blank condition recurs after the one ordered
recovery, stop and report it. Do not infer source-repair authority, reinstall,
rebuild, clear data, restart the device, or retry with another sequence.

## Cleanup

- Stop only packet Metro processes.
- Remove the exact serial `tcp:8081` reverse and verify port/reverse absence.
- Remove only packet-created project-local `mobile/node_modules` and sanitized
  runtime evidence; shared Yarn cache may remain.
- Restore and read back the exact prior stay-awake value.
- Preserve the installed development client and app data.
- Verify manifests/lockfile unchanged, `git diff --check`, and clean/staging-
  empty canonical and isolated final state.
- Return one immutable terminal packet directly to Planning with the exact
  result, evidence, cleanup, and next owner/action.

## Explicit Exclusions

No source/test repair, dependency/config/manifest/lockfile change, app-data or
cache clear, permission reset, uninstall/reinstall, device reboot, native
build/EAS/artifact, version/build increment, QR/camera, real API/OAuth/provider,
payment, Rails/Vue, production/deployment/release/push, secret, or external
mutation.

Current blocker: none if the exact Pixel is awake, unlocked, and accessible.
