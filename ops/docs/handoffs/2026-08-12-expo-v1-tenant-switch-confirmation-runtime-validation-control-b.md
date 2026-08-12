# TempleMate tenant-switch confirmation runtime validation — Control packet

## Identity and authority

- Accepted plan/base:
  `ops/docs/plans/EXPO_V1_TENANT_SWITCH_CONFIRMATION_RUNTIME_VALIDATION_PLAN.md`
  at `67274f5fff6d44b627fc617d281b1e7417711601`.
- Accepted presentation repair source:
  `874cad0a2712cf1f596a59165cb7efcad82dae92`.
- Source Control -> Planning: Wenfu Control B
  `019fe020-e92e-7770-984f-b59acd547ab0` -> Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6`.
- Worktree/branch/base:
  `/private/tmp/shengfukung-wenfu-expo-v1-tenant-switch-confirmation-runtime-validation`;
  `codex/expo-v1-tenant-switch-confirmation-runtime-validation`;
  `67274f5fff6d44b627fc617d281b1e7417711601`.
- Packet/attempt:
  `2026-08-12-expo-v1-tenant-switch-confirmation-runtime-validation-control-b`,
  attempt 6.

## Bounded validation

- Control verifies repair ancestry and unchanged source proof: all three App
  connection summaries use `activePresentationTenant(binding)`;
  `requestSwitch()` preserves prior tenant/candidate separation; and
  `clearTenantState()` occurs once only inside the visible confirmation path.
- Control runs focused tenant/UI tests, complete 46-test mobile suite, lint,
  and verify before device setup. It then proves the exact Pixel 8 / `shiba`
  target, installed Komainu development package/launcher/version/code/SDK,
  empty 8081/reverse preconditions, dependency equivalence, and one temporary
  isolated dependency symlink.
- Runtime uses only the established USB reverse, explicit dummy/development
  Metro process, and that process's local `exp+templemate` URL through the
  fenced package. No QR/camera, OAuth, provider/browser/network, typed or
  changed link, source/config/test/dependency/version/native change, build/EAS,
  install, deployment, release, or push is permitted.
- Starting state: visible fixture email sign-in, accepted dummy reset only if
  needed, then only the prefilled trusted fixture link and visible `使用連結連結`
  action to establish `竹南鎮聖福宮`.
- Before the one visible `確認並切換`, Control requires header and card retain
  `竹南鎮聖福宮`, confirmation explanation/action visible, no candidate active,
  and no disconnected/unbound prior-state clear. On failure, stop without
  confirmation. On pass, invoke visible confirmation exactly once and require
  header/card `示範宮廟二號` with no failure.

## Evidence, allocation, cleanup

- One ephemeral Implementer: `gpt-5.6-terra/medium`, lowest sufficient for
  this report/static-check preparation only. It owns only this packet/report;
  no device/Metro/ADB/symlink/network/build/external action or staging/commit.
  Control owns runtime, acceptance, cleanup, integration, and terminal.
  Persistent Handoff is ineligible.
- Required report matrix: deterministic bound start; preserved header/card;
  inactive candidate; one confirmation; final second-tenant presentation;
  source-correlated confirmation-only cleanup ordering; exact runtime/repo
  cleanup.
- Cleanup removes only packet Metro, serial `tcp:8081` reverse, temporary
  isolated `mobile/node_modules` symlink, and packet-created temporary UI
  evidence. The installed application/camera permission remain intact.

## Safe receipt and terminal boundary

- Retain only check counts, fenced package/device identity, visible app
  outcomes, source-order correlation, cleanup/Git state, terminal
  classification/disposition, and next owner/action. Never retain raw Metro
  URL, link value, QR/camera media/payload, OAuth/provider/browser content,
  credentials/secrets, or broad logs.
- Control sends one terminal after validated success or concrete runtime/device
  failure. Canonical integration is only for Planning-accepted safe evidence.

## Sanitized result matrix

| Gate | Required evidence | Status | Sanitized result |
| --- | --- | --- | --- |
| Entry proof | Repair/source checks; focused/full suite; lint/verify; target fence | passed | Repair ancestor verified; three retained-presentation selector uses; prior/candidate separation and one confirmation-only cleanup call verified. Focused tests 10/10, full suite 46/46, lint and verify passed. Pixel 8 / `shiba` package/launcher/version/code/SDK fence, dependency equivalence, and empty 8081/reverse preflight passed. |
| Deterministic bound start | Fixture sign-in/reset and prefilled-link action produce `竹南鎮聖福宮` | passed | Fixture email sign-in initially restored a prior bound state; accepted reset safely returned to `尚未連結`; only the already-prefilled visible link action then established `竹南鎮聖福宮`. |
| Before confirmation | Header/card retain prior temple; confirmation visible; candidate inactive; no unbound state | passed | After visible `切換宮廟`, header and connection card retained `竹南鎮聖福宮`; explanation and `確認並切換` were visible; `示範宮廟二號` was not connected; no unbound or failure state appeared. |
| Confirmation | Visible `確認並切換` activated exactly once | passed | One visible confirmation activation only. |
| Final presentation | Header/card show `示範宮廟二號` with no failure | passed | Header and card visibly showed `示範宮廟二號`; no failure state appeared and `竹南鎮聖福宮` was no longer active. |
| Cleanup ordering | Source/test correlation: cleanup precedes `confirmSwitch()` only inside confirm | passed | Source/test correlation only: one confirmation-handler `clearTenantState()` call follows OAuth idle clear and precedes `confirmSwitch()` / `clearPriorTenant`; focused tests retain the prior tenant until then and bind the candidate only after prior cleanup. |
| Runtime/repository cleanup | Exact Metro/reverse/symlink/evidence cleanup and clean Git | passed | Packet Metro processes stopped; no 8081 listener remained; final reverse list lacked `tcp:8081` (the removal found no listener to remove); temporary symlink/evidence were removed; installed app and camera permission were retained; isolated Git contains only this untracked report with empty staging; canonical `main` remains `67274f5fff6d44b627fc617d281b1e7417711601`. |

## Implementer static-evidence preparation

Prepared by the sole ephemeral Implementer for Control B, attempt 6. This is
static/diff evidence and an initial result structure only; it makes no device,
Metro, ADB, UI, network, symlink, build, EAS, provider, or runtime claim.

### Repair ancestry and retained presentation

- `874cad0a2712cf1f596a59165cb7efcad82dae92` (`fix: retain temple during
  switch confirmation`) is an ancestor of the packet base
  `67274f5fff6d44b627fc617d281b1e7417711601`.
- `mobile/App.js` has exactly three
  `activePresentationTenant(binding)` call sites: the signed-in header, the
  home temple-connection card, and the connection screen. Each therefore reads
  the retained `binding.tenant` supplied by the selector rather than treating
  `switching` as disconnected.
- In `mobile/app/tenant/binding.js`, `requestSwitch()` parses the candidate
  link and returns `{ ...beginSwitch(binding), candidate: parsed.tenant }`.
  `beginSwitch(binding)` retains the prior `binding.tenant` and starts with a
  null candidate, so prior tenant and candidate remain separate until
  `confirmSwitch()` receives successful prior-tenant cleanup.

### Confirmation-only cleanup ordering

- `mobile/App.js` contains exactly one `adapter.clearTenantState()` call.
- That call is inside the visible `binding.state === 'switching'` confirmation
  button (`t.confirmSwitch`), after `oauthController.clear('idle')` and before
  `confirmSwitch(binding, clearPriorTenant(binding.tenant))`.
- `mobile/__tests__/ui-refinement.test.js` statically asserts all three
  selector uses and exactly one instance of that complete confirmation-only
  cleanup expression. `mobile/__tests__/tenant-binding.test.js` asserts that
  switching retains the prior tenant, keeps the alternate tenant as candidate,
  rejects confirmation without prior cleanup, and binds the candidate only
  after `clearPriorTenant(bound.tenant)`.

### Focused checks identified; not run

- Focused tenant-binding proof: `node --test __tests__/tenant-binding.test.js`
  from `mobile/`.
- Focused presentation proof: `node --test __tests__/ui-refinement.test.js`
  from `mobile/`.
- The package full-suite script is `node --test __tests__/*.test.js`.
- Required full-suite expectation: `yarn test` reports 46 passing tests.
- Required static project checks for Control: `yarn lint` and `yarn verify`.

The static preparation Implementer did not run focused tests, the full suite,
lint, or verify. The completed outcomes in the matrix are Control-supplied.
Control later created and removed the temporary symlink for authorized
tests/runtime; the Implementer itself did not materialize dependencies.

### Static checks performed

- `git merge-base --is-ancestor 874cad0a2712cf1f596a59165cb7efcad82dae92 HEAD`
  exited `0`.
- `git diff --check 874cad0a2712cf1f596a59165cb7efcad82dae92^ 874cad0a2712cf1f596a59165cb7efcad82dae92`
  and the packet worktree `git diff --check` produced no whitespace errors.
- A static count of `activePresentationTenant(binding)` in `mobile/App.js`
  returned `3`; a static search found one `clearTenantState(` call in that
  file, at the confirmation button.

### Terminal closeout

- Terminal classification:
  `tenant_switch_confirmation_runtime_validation_complete`.
- Continuation disposition: `accepted_frozen_outcome`.
- Next owner/action: Planning review and canonical integration of this safe
  report.
- Active runtime continuation: none, unless Planning dispatches a new
  authorized packet.

Retain only the packet's safe receipt fields; do not record raw URL/link
values, QR or camera data, OAuth, provider/browser content, credentials,
secrets, or broad logs.
