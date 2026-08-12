# TempleMate dummy OAuth and in-app QR runtime validation — Control packet

## Identity and authority

- Accepted plan and exact base:
  `ops/docs/plans/EXPO_V1_DUMMY_OAUTH_AND_TEMPLE_QR_RUNTIME_VALIDATION_PLAN.md`
  at `f793b698f156bdfdcc778c2be349973130cee08d`.
- Accepted PKCE repair source:
  `a7824ce37093210c4e2d3e5b2c133ae3b12f93f4`.
- Source Control -> Planning: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0` -> Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Worktree/branch/base:
  `/private/tmp/shengfukung-wenfu-expo-v1-dummy-oauth-temple-qr-runtime-validation`;
  `codex/expo-v1-dummy-oauth-temple-qr-runtime-validation`;
  `f793b698f156bdfdcc778c2be349973130cee08d`.
- Packet and attempt:
  `2026-08-12-expo-v1-dummy-oauth-and-temple-qr-runtime-validation-control-b`,
  attempt 5.

## Bounded scope

- Control first proves the accepted source ancestor, supported Expo Crypto
  `BASE64` plus strict Base64URL conversion, absence of the rejected
  `CryptoEncoding.BASE64URL`, focused/full mobile checks, and the exact
  Pixel/package/port/reverse/dependency-symlink preconditions.
- Runtime uses only serial `39011FDJH00FQ8`, exact `tcp:8081` reverse, explicit
  dummy/development Metro, and Metro's emitted local `exp+templemate` URL
  through target-fenced ADB. Metro/Expo QR attachment, Expo launcher scanning,
  Pixel native scanning, real mode/API/OAuth/provider/browser, source edits,
  native build/EAS, installation, and unrelated device activity are excluded.
- Control proves one visible Google dummy success and sign-out cleanup, then
  one visible Apple dummy success and sign-out/reset cleanup. A provider failure
  stops the QR path after minimal sanitized app-scoped evidence and cleanup.
- Only after both provider checks pass, Control opens TempleMate's own visible
  `Scan demo QR` / CameraView in an unbound dummy state. It records the
  CameraView warning recurrence/impact without repair.
- The only permitted nonterminal Planning callbacks are the exact text
  `director_action_required: untrusted_qr`, sent only while TempleMate's in-app
  camera is visibly ready for the first physical fixture, and
  `director_action_required: trusted_qr`, sent only after visible untrusted
  rejection and visible `Scan again` restores that in-app camera. Control keeps
  the exact session, Metro, and reverse live through each recurring bounded
  wait; it does not invent a timeout or read/retain QR image, payload, or media.
- The visible trusted binding must be `竹南鎮聖福宮`; switch confirmation must
  precede clearing scoped state and the visible switch to `示範宮廟二號`.

## Evidence, allocation, and cleanup

- Required evidence: source/config scans; focused dummy OAuth/runtime-boundary
  tests, complete 44-test suite, lint, verify; target-fenced package/port/
  reverse/symlink preflight; minimal sanitized app-scoped evidence; complete
  result matrix; exact cleanup; diff/Git state.
- One ephemeral Implementer: `gpt-5.6-terra/medium`, lowest sufficient for
  report preparation and static/diff checks only. It may edit only this
  packet/report path, must not stage/commit/merge, and must not run Metro, ADB,
  device/UI, symlink, network, or external actions. Control owns runtime,
  physical-callback coordination, acceptance, cleanup, commit, integration,
  and terminal delivery. Persistent Handoff is ineligible.
- Exact cleanup at terminal: only the packet Metro process, serial
  `tcp:8081` reverse, temporary isolated `mobile/node_modules` symlink, and
  packet-created ephemeral UI evidence. Preserve installed package and
  accepted camera permission. Prove no 8081 listener/reverse/symlink/evidence
  residue and clean Git/staging.

## Safe receipt and terminal boundary

- Retain only check summaries, fenced package/device identity, visible
  app outcomes, warning classification, callback state, cleanup/Git state,
  terminal classification, continuation disposition, and next owner/action.
  Never retain raw Metro URL, QR image/payload/media, provider/browser content,
  credentials, secrets, or broad logs.
- Planning receives one terminal only after both required callbacks resolve or
  a concrete runtime/device failure ends the packet. Canonical integration is
  permitted only for an accepted immutable safe report/packet.

## Sanitized runtime result matrix

| Gate | Required visible evidence | Status | Sanitized Control result |
| --- | --- | --- | --- |
| Google dummy success and cleanup | Account-only fixture profile, then signed-out/reset cleanup | passed | Reached existing account-only fixture state; visible sign-out returned signed out; no provider browser, network, or real API. |
| Apple dummy success and cleanup | Account-only fixture profile, then signed-out/reset cleanup | passed | Reached the same account-only state; accepted dummy reset established an unbound signed-in fixture state; no provider browser, network, or real API. |
| In-app camera entry | TempleMate-only CameraView in unbound dummy state | passed | Entered only with TempleMate's visible `Scan demo QR`; existing camera grant remained and no microphone/audio prompt occurred. |
| Untrusted fixture | Visible rejection and preserved unbound state | passed | Planning/Director confirmed visible safe rejection; header/card remained `尚未連結`; visible `Scan again` restored CameraView. |
| Trusted fixture | One visible binding to `竹南鎮聖福宮` | passed | Planning/Director confirmed visible binding to `竹南鎮聖福宮`. |
| Confirmed tenant switch | Confirmation before state clear and visible `示範宮廟二號` switch | failed | Prior binding visibly cleared before confirmation; Control did not confirm. `示範宮廟二號` switch and post-confirm cleanup were not performed. |
| CameraView warning | Recurrence and observable impact | unknown | No retained or asserted recurrence evidence. |
| Runtime/repository cleanup | Exact Metro/reverse/symlink/evidence cleanup and clean Git | passed | Packet Metro processes stopped; temporary symlink/evidence removed; no 8081 listener/reverse residue; installed app/camera permission retained; isolated Git has only this untracked report and empty staging. |

## Implementer static-preparation receipt

This section is report preparation only. No runtime command, Metro process,
ADB/device/UI action, symlink action, network action, build, EAS action, or
external/provider action was performed by this Implementer. Consequently, no
runtime outcome is recorded below.

### Static source and ancestry evidence

- Observed worktree `HEAD`:
  `f793b698f156bdfdcc778c2be349973130cee08d` (the packet's exact base).
- Accepted PKCE repair source:
  `a7824ce37093210c4e2d3e5b2c133ae3b12f93f4` is an ancestor of the observed
  `HEAD` (`git merge-base --is-ancestor` exit `0`).
- The packet base is an ancestor of the observed `HEAD`
  (`git merge-base --is-ancestor` exit `0`).
- `mobile/app/oauth/runtime.js:12-14` requests the supported
  `Crypto.CryptoEncoding.BASE64`, converts the digest with
  `base64ToBase64Url(digest)`, and retains `S256`.
- `mobile/__tests__/expo-oauth-runtime.test.js:12-24` asserts Expo SDK 54's
  standard `BASE64` support, rejects `CryptoEncoding.BASE64URL`, verifies the
  strict conversion against Node's Base64URL digest, and rejects malformed
  standard-Base64 input. The source scan found no
  `Crypto.CryptoEncoding.BASE64URL` request.

### Control execution checklist (not executed)

The following are the focused and complete mobile checks Control must run at
the authorized runtime boundary, before device setup. They are recorded here
as commands and expectations, not as results:

```sh
cd mobile && node --test __tests__/dummy-oauth.test.js __tests__/oauth-transaction.test.js __tests__/expo-oauth-runtime.test.js
cd mobile && yarn test
cd mobile && yarn lint
cd mobile && yarn verify
```

- Focused scope: dummy OAuth, OAuth transaction, and Expo PKCE runtime-boundary
  coverage.
- Full-suite expectation: `yarn test` reports 44 passing tests.
- A failed or different count is a Control runtime-entry failure; this report
  does not infer its cause or authorize a repair.

### Physical-action callback ledger

Current callback state: `not_requested_static_preparation_only`. The in-app
camera has not been opened and no runtime session, Metro process, or target
fenced reverse was created by this Implementer.

| Callback | Exact permitted Control-to-Planning text | Preconditions before sending | Current state | Resolution receipt |
| --- | --- | --- | --- | --- |
| Untrusted fixture | `director_action_required: untrusted_qr` | TempleMate's own in-app camera was visibly ready for the first physical fixture. | requested and resolved | Planning/Director confirmed visible safe rejection; header/card remained `尚未連結`, then visible `Scan again` restored CameraView. No image, payload, or media retained. |
| Trusted fixture | `director_action_required: trusted_qr` | Untrusted rejection was visibly complete, unbound state was preserved, and visible `Scan again` restored TempleMate's in-app camera. | requested and resolved | Planning/Director confirmed visible binding to `竹南鎮聖福宮`. No image, payload, or media retained. |

Only those exact callback strings are permitted. Control keeps the same
authorized Metro/reverse/session and visibly open in-app camera surface during
each bounded wait; no timeout, QR fixture content, or physical-scan outcome is
invented here.

### Completed runtime outcome matrix

| Gate | Required visible or fenced evidence | Status | Safe receipt on completion |
| --- | --- | --- | --- |
| Runtime entry checks | Focused tests; full suite with 44 tests; lint; verify. | passed | Accepted repair ancestor; supported `BASE64`/strict Base64URL conversion; focused OAuth suite 9/9; full `yarn test` 44/44; lint and verify passed; Pixel 8/shiba package/launcher/`1.0.0`/code `1`/SDK 36/dependency-equivalence preflight passed. |
| Google dummy success and cleanup | Account-only fixture profile, then signed-out/reset cleanup. | passed | Existing account-only fixture state, then visible signed-out state; no provider browser, network, or real API. |
| Apple dummy success and cleanup | Account-only fixture profile, then signed-out/reset cleanup. | passed | Same account-only state, then accepted dummy reset to unbound signed-in fixture state; no provider browser, network, or real API. |
| In-app camera entry | TempleMate-only unbound dummy CameraView after both provider successes. | passed | Entered only through visible TempleMate `Scan demo QR`; existing camera grant retained; no microphone/audio prompt. |
| Untrusted fixture | Visible rejection and preserved unbound state. | passed | Callback resolved: safe rejection confirmed, header/card remained `尚未連結`, and `Scan again` restored CameraView. |
| Trusted fixture | One visible binding to `竹南鎮聖福宮`. | passed | Callback resolved: visible binding to `竹南鎮聖福宮` confirmed. |
| Confirmed tenant switch | Confirmation before state clear and visible `示範宮廟二號` switch. | failed | After visible bound state, visible `切換宮廟` led to a screen whose header/card were already `尚未連結`, before visible `確認並切換`; Control did not press confirmation. |
| CameraView warning | Recurrence and observable scanning impact. | unknown | No retained or asserted recurrence evidence. |
| Runtime cleanup | Packet Metro process, serial `tcp:8081` reverse, temporary isolated dependency symlink, and packet-created UI evidence removed. | passed | Metro processes stopped; temporary symlink/evidence removed; `lsof` found no 8081 listener; reverse removal reported listener not found; final reverse list had no `tcp:8081`; app/camera permission retained. |
| Repository cleanup | Clean working tree and staging after Control's integration decision. | passed | Isolated Git contains only this untracked report; staging empty; canonical `main` unchanged. |

### Static/diff check receipt

The Implementer ran only read-only static/diff checks. Exact output:

```text
## codex/expo-v1-dummy-oauth-temple-qr-runtime-validation
?? ops/docs/handoffs/2026-08-12-expo-v1-dummy-oauth-and-temple-qr-runtime-validation-control-b.md
f793b698f156bdfdcc778c2be349973130cee08d
accepted-repair-ancestor=0
packet-base-ancestor=0
```

- `git diff --check` produced no output and exited `0` before this report was
  edited; Control must rerun it against the final report before integration.
- The static test-declaration count was `44` (`rg -n '^test\\(' mobile/__tests__/*.test.js | wc -l`). This is an inventory count, not a test run.
- No files other than this report were edited, and no staging action occurred.

## Control-supplied completed runtime result

### Safe receipt and terminal classification

- Terminal classification: `temple_qr_runtime_defect_found`.
- Terminal basis: Google and Apple dummy OAuth each reached the existing
  account-only fixture state with their specified cleanup; the in-app
  untrusted and trusted callback sequence completed, ending in the visible
  `竹南鎮聖福宮` binding. After Control activated visible `切換宮廟`, the next
  visible screen already showed header and card `尚未連結`, alongside text that
  confirmation would clear prior tenant-scoped data and the control
  `確認並切換`. This is a visible pre-confirmation clearing of the prior
  binding.
- Containment: Control deliberately did not press `確認並切換`. The requested
  switch to `示範宮廟二號` and all post-confirmation cleanup are
  `untested_not_performed`.
- Warning classification: `unknown`; no CameraView-warning recurrence or
  impact is retained or asserted.
- Runtime cleanup: passed. Packet Metro processes stopped; packet temporary
  symlink and ephemeral UI evidence were removed; `lsof` found no 8081
  listener; ADB reverse removal reported listener not found; the final reverse
  list contained no `tcp:8081`. The installed development app and existing
  camera permission were retained.
- Repository state: isolated worktree has only this untracked report; staging
  is empty and canonical `main` is unchanged.
- Next owner/action: Planning owns a bounded diagnosis/repair decision for the
  observed pre-confirmation tenant-state clear and a later renewed validation
  of confirmation-to-`示範宮廟二號`/post-confirm cleanup.
- Privacy boundary: this receipt retains no QR image, QR payload, camera media,
  provider/browser content, credentials, secrets, or broad logs.

### Completed result ledger

| Gate | Completed safe result |
| --- | --- |
| Entry validation | Accepted repair ancestor, supported standard `BASE64` plus strict Base64URL conversion, focused OAuth suite 9/9, full `yarn test` 44/44, lint, verify, and Pixel 8/shiba package/launcher/version/code/SDK/dependency-equivalence preflight all passed. |
| Google dummy | Passed to the existing account-only fixture state; visible sign-out returned the app to signed-out state; no provider browser, network, or real API. |
| Apple dummy | Passed to the same account-only fixture state; accepted dummy reset established unbound signed-in fixture state; no provider browser, network, or real API. |
| In-app QR | CameraView was entered only through TempleMate `Scan demo QR`; the existing camera grant remained and no microphone/audio prompt occurred. |
| Callback sequence | Both exact permitted callbacks were requested and resolved. Untrusted scan safely rejected with `尚未連結` preserved and `Scan again` restoring CameraView; trusted scan visibly bound `竹南鎮聖福宮`. |
| Switch defect | Failed: prior binding visibly cleared before confirmation. Confirmation, `示範宮廟二號` switch, and post-confirm cleanup were not performed. |
