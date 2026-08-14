# TempleMate Phase 3 Tenant And Support UI Readiness

Status: immutable report-only readiness evidence for Planning review

Date: 2026-08-14 (Asia/Taipei)

## Evidence Boundary

- Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`
- Inspection worktree: `/private/tmp/shengfukung-wenfu-templemate-phase-3-tenant-support-readiness`
- Branch / base / final inspected HEAD: `codex/templemate-phase-3-tenant-support-readiness` / `db0083602a576144c9a1b0b7ed1181c828fc8e72` / `db0083602a576144c9a1b0b7ed1181c828fc8e72`.
- Accepted scan: `ops/docs/plans/TEMPLEMATE_PHASE_3_TENANT_AND_SUPPORT_UI_READINESS_SCAN_PLAN.md`; findings: `ops/docs/plans/TEMPLEMATE_PHASE_3_UI_AUDIT_FINDINGS.md`; parent: `ops/docs/plans/TEMPLEMATE_PHASE_3_DIRECTOR_HOLISTIC_UI_AUDIT_PLAN.md`.
- Method: read-only source, test, route, and focused history inspection. No test, Metro, ADB, device, API, email, provider, account, production, or other external operation was run.
- This report distinguishes observations from recommendations. It creates no source implementation authority.

## Finding 001 — Tenant Binding, Switching, And Unbound Gate

### Observed current mechanism

1. `mobile/App.js:30,98,103` always renders the six-tab account navigation after authentication (`home`, `profile`, `dependents`, `registrations`, `discover`, `settings`). It does not branch that navigation or `AccountSurface` on `binding.state`. Thus an authenticated dummy user reset to `unbound` can still navigate to all account content; this confirms the recorded unbound-gate defect.
2. Dummy state starts as `unbound` (`mobile/app/tenant/binding.js:22`), while normal dummy email/OAuth sign-in immediately binds the trusted fixture (`mobile/App.js:82,89`). `reset` returns the already signed-in dummy session to `initialBinding()` (`App.js:84`). This is the current deliberate test/demo seam for an unbound state.
3. Home currently contains both connection UI and ordinary switching: the dummy-only fixture link input, `Connect with link`, and QR camera entry appear while not bound; `Switch temple` appears on Home while bound (`App.js:110-114`). The link input is presentation-only fixture wiring: `fixtureConnectionLink`, `bindFixture`, and `parseConnectionLink` enforce known HTTPS fixture origins and the exact connection path (`mobile/app/tenant/binding.js:1-40`), and `mobile/__tests__/tenant-binding.test.js` covers that deterministic seam. It should remain available to tests/fixtures even if removed from user-facing production treatment.
4. The existing switch invariant is sound and must be retained. `requestSwitch` keeps the prior tenant and stores only a candidate; `activePresentationTenant` returns `binding.tenant`, never the candidate; `confirmSwitch` requires a cleanup receipt whose `clearedTenantId` matches the prior tenant (`binding.js:26-38`). Home invokes `oauthController.clear('idle')` and `adapter.clearTenantState()` before `confirmSwitch` (`App.js:114`). `mobile/__tests__/tenant-binding.test.js` proves retained presentation until confirmation and rejection when cleanup is absent; `mobile/__tests__/ui-refinement.test.js` statically asserts the one confirmation-only cleanup shape.
5. Header, Home connection summary, and connection screen all use `activePresentationTenant(binding)` (`App.js:102,114,122`), preserving the already accepted confirmation presentation repair. No later gate may replace this with candidate presentation.
6. Real mode is deliberately local/test-only and has no fallback to dummy (`mobile/app/real/config.js`, `mobile/app/real/adapter.js:1-77`, `mobile/__tests__/real-adapter.test.js`). On restore and direct sign-in it assigns `localTenantBinding(clientConfig)` (`App.js:57,82`), whose tenant is the explicit `localTenantSlug`; real QR binding is explicitly deferred (`mobile/app/tenant/scanner.js:14`). Therefore a production-real unbound binding protocol is not present in current source and must not be invented by a UI packet.
7. Real requests include the explicit tenant slug on every native path (`mobile/app/real/adapter.js:4-25`); Rails rejects blank or unknown `temple_slug` before account authentication (`rails/app/controllers/api/v1/account/native_base_controller.rb:20-45`). Existing client storage is scoped by environment and tenant (`mobile/app/real/storage.js:1-21`); real `clearTenantState` clears all scoped session/cache/pending state (`real/adapter.js:46-47`). These constraints support a UI gate but prohibit a dummy fallback, a shared storage scope, or silent tenant substitution.
8. Camera permission/loading/denied/blocked/retry/cancel states are already handled by `TempleQrCamera` (`mobile/app/tenant/camera_surface.js:8-32`). Android Back consumes active camera and returns to Home; otherwise it returns a non-home screen to Home (`mobile/app/tenant/back.js:1-7`, used in `App.js:46-50`). Resume clears transient feedback (`App.js:46-49`); reset/sign-out also clear feedback and reset/signed-out state (`App.js:83-84`). A gate must retain these outcomes and remain screen-reader reachable.

### Direction, defects, and decisions

- **Accepted Director direction:** bound users should see temple context as stable; ordinary switching moves from Home to the lowest-priority Settings action. Unbound users should reach a QR-first setup gate with sign-out and other safe escape/accessibility actions, without presenting authentication and QR binding as the same event.
- **Confirmed defect:** the current authenticated/unbound state still renders all tabs and tenant-scoped content. Home also exposes the fixture connection-link field and puts switching prominently on Home.
- **Open Director decisions:**
  1. Which non-tenant actions remain visible inside the unbound gate beyond sign-out and the required QR/camera permission/error/retry/cancel controls. Locale/theme are plausible accessibility-safe candidates, but privacy/closure/support/account profile actions are not currently defined as safe unbound behavior and all native calls require a tenant.
  2. Whether the testing-only link seam is entirely hidden in every user-facing dummy treatment or only absent in the future production-facing treatment. The underlying fixture helper/test seam should be retained either way.
  3. Whether the future real tenant-binding protocol is separately designed before real-mode QR becomes executable. It is not a UI-readiness decision.

### Smallest coherent later packet: binding hierarchy and gate

Own a shared tenant-presentation/state phase rather than patches to Home and Settings independently. Likely paths are `mobile/App.js`, `mobile/app/tenant/binding.js`, a new narrowly scoped gate/presentation helper if needed, `mobile/app/tenant/back.js`, `mobile/app/ui/copy.js`, and `mobile/__tests__/tenant-binding.test.js`, `mobile/__tests__/account-surface.test.js`, and `mobile/__tests__/ui-refinement.test.js` (or a focused new gate test). Rails should remain read-only unless a separately accepted real binding contract is required.

Required deterministic evidence: bound versus unbound menu/screen availability; QR camera loading/denied/blocked/retry/cancel; retained prior tenant and hidden candidate through switch confirmation; confirmation-only cleanup; tenant/environment-scoped storage clearing; real adapter local-only/no-fallback behavior; Back from active camera and ordinary Home/non-Home behavior; reset, sign-out, app-resume, locale/theme, error, and notice behavior. Later installed-client evidence should cover both locales and light/dark: unbound sign-in/reset -> gate -> camera permission outcomes -> trusted QR -> bound home; plus bound -> Settings low-priority switch -> candidate confirmation -> cleanup -> new tenant. It must use TempleMate's in-app CameraView only, never a launcher/native-camera QR scanner.

Rollback is a source-only reversion of the gate/hierarchy commit; no tenant, session, QR trust, provider, server, or production rollback action is implied. Native conclusion is below.

## Finding 002 — Assistance Is Retained Work; Contact Temple Is Email Delivery

### Observed current mechanism

1. Expo Settings exposes `Need help` and `Contact temple` as peer buttons with no destination explanation (`mobile/App.js:119`). Both screens render only the same `supportMessage` input and return a generic saved notice to Settings (`App.js:120`). This confirms the recorded information-architecture issue.
2. In dummy mode, `submitAssistance({ message })` stores only `{ submitted, message }` in local fixture state and `contactTemple({ message })` does the same independently (`mobile/app/dummy/repository.js:143-151`; adapter pass-through at `mobile/app/dummy/adapter.js:33-34`). Dummy mode has `network: 'disabled'`; it does not send Rails, temple-admin, or email work. `mobile/__tests__/account-surface.test.js` proves only those local fixture-state results.
3. In real mode the distinct adapter calls are `POST /assistance` with `{ assistance: input }` and `POST /contact` with `{ contact: input }` (`mobile/app/real/adapter.js:69`), always through the local/test tenant-scoped request wrapper.
4. Rails assistance resolves an optional registration only inside `current_native_temple` and `current_native_user`; it finds an existing open request for the same temple/user/registration and returns it as `{ duplicate: true }`, otherwise creates a tenant-scoped `TempleAssistanceRequest` and logs `account.assistance_requests.created` (`rails/app/controllers/api/v1/account/native_resources_controller.rb:31-40,75-90`). Valid channels are exactly `profile`, `registration_list`, and `registration_detail`; status is `open` or `closed`; message is optional but capped at 280 (`rails/app/models/temple_assistance_request.rb:3-42`).
5. Authorized temple admins can see those retained requests in the dashboard and index, filter by status, and close them with audit evidence (`rails/app/controllers/admin/dashboard_controller.rb:28-48`, `rails/app/controllers/admin/assistance_requests_controller.rb:1-39`, and `rails/test/integration/admin/assistance_requests_test.rb`). Browser tests also prove duplicate open reuse and registration context (`rails/test/integration/account/assistance_requests_test.rb`).
6. Rails Contact Temple validates a subject and message, calls `Contact::TempleInquirySender`, and only then logs `account.contact_temple_requests.created` / returns `{ accepted: true }`; delivery failure returns `contact_delivery_failed` (`native_resources_controller.rb:43-49`). The sender resolves the configured temple contact email (or fallback support), sends the temple email and patron acknowledgement through `Notifications::BrevoClient`, and returns failure for absent recipient or either failed send (`rails/app/services/contact/temple_inquiry_sender.rb:18-83,101-106`). There is no `TempleAssistanceRequest` or admin-webapp inbox creation in this path.
7. Existing Rails tests stub Brevo and verify two sends/audit on success and no email on invalid browser input (`rails/test/integration/account/contact_temple_requests_test.rb`). The native account test stubs the sender and proves a valid contact returns `accepted: true` (`rails/test/integration/account/api/native_account_resources_test.rb:58-72`). These are local contract tests, not evidence of a real email delivery.

### Direction and remaining product decision

- **Confirmed distinction:** Assistance is a durable, tenant-scoped admin-visible work item with duplicate-open and close lifecycle; Contact Temple is an email attempt plus patron acknowledgement and audit only. The client must not claim that Contact created an admin inbox/request, or that dummy submission delivered an email/admin request.
- **Accepted Director direction:** the two unexplained generic message forms must not remain peer placeholders.
- **Open Director product decision (first blocker for support implementation):** retain both actions with explicit destination/response-path labels, consolidate/remove one, or choose another product treatment. A combined Expo visual shell can only be implemented after that choice; it cannot unify the backend destination semantics or silently turn email into retained admin work.

## Finding 003 — Rendered Forms Do Not Satisfy the Native Contracts

### Confirmed call-shape defects

1. The rendered assistance form calls `adapter.submitAssistance({ message: supportMessage })` (`mobile/App.js:120`). The real adapter emits `{ assistance: { message: ... } }` (`mobile/app/real/adapter.js:69`). Rails permits `registration_id`, `channel`, and `message`, creates with `channel: assistance_params[:channel]`, and the model requires one of the three channels. With no channel, the `create!` path fails validation; it is not rescued as a valid assistance response. Thus the rendered real-mode form cannot create a valid assistance request.
2. The rendered contact form calls `adapter.contactTemple({ message: supportMessage })` (`App.js:120`), hence `{ contact: { message: ... } }` (`real/adapter.js:69`). Rails' `Account::ContactTempleRequestForm` requires nonempty subject (max 120) and message length 10–2,000 after tag/whitespace normalization (`rails/app/forms/account/contact_temple_request_form.rb:8-42`). Thus the rendered real-mode form is invalid before delivery; it cannot truthfully show a sent/delivered claim.
3. The current generic `run` helper converts any successful adapter response to the generic localized `saved` notice (`App.js:81,120`), while dummy mode's success only updates fixture state. Any later retained form needs outcome copy scoped to the real returned semantic and a dummy disclosure; otherwise a generic success can overstate destination/delivery.
4. Existing real-adapter coverage intentionally calls structurally valid payloads directly: `adapter.submitAssistance({ message: 'help' })` and `adapter.contactTemple({ subject: 'hello', message: 'help' })` (`mobile/__tests__/real-adapter.test.js`, complete-contract test). Rails native integration likewise posts a valid `channel: 'profile'` and valid contact subject/message (`rails/test/integration/account/api/native_account_resources_test.rb:58-72`). Therefore neither test exercises the actual rendered form payload; the coverage gap is confirmed, not inferred.

### Smallest coherent later packet: retained support contract and presentation

After the Director resolves Finding 002, use one support-contract phase for every retained action. Likely Expo paths: `mobile/App.js`, `mobile/app/ui/copy.js`, possibly a small form/payload helper, `mobile/app/dummy/repository.js`, `mobile/app/dummy/adapter.js`, `mobile/app/real/adapter.js`, and focused mobile account-surface/real-adapter tests. Likely Rails paths should be limited to native contract/integration tests and perhaps explicit error serialization tests; Rails behavior is already authoritative and should not be redesigned. If product direction requires a new semantic (for example, a combined retained/e-mail workflow), that is a new Planning/Director decision rather than a client repair.

Minimum contract evidence:

- Assistance renders/selects a permitted `channel`, includes it in `{ assistance: { registration_id?, channel, message? } }`, truthfully handles `{ assistance_request: { id, status }, duplicate }`, and preserves tenant ownership/registration association. Cover invalid/missing channel, foreign registration, duplicate-open, and admin-visible/close lifecycle through Rails tests.
- Contact renders `subject` and message, performs local validation compatible with Rails' nonempty/max-120 subject and normalized 10–2,000 message constraints, submits `{ contact: { subject, message, website? } }`, handles Rails validation errors and `contact_delivery_failed`, and only calls it accepted after the server's `{ accepted: true }`. Cover absent/too-long subject, short/too-long message, honeypot, delivery failure, tenant isolation, success audit, and the absence of a `TempleAssistanceRequest`/admin inbox record.
- Dummy tests must state fixture-only outcomes and not simulate an actual administrator or email recipient. Real adapter tests must capture the exact request body emitted from an exercised rendered-form payload, not only adapter-direct fixtures.

Later installed-client runtime evidence, separately authorized, should test both locales/themes and the chosen retained action(s): required fields/context; client validation; server validation/failure presentation; dummy disclosure; real local/test API accepted and failed response mapping; admin queue visibility/close for Assistance only; and actual email-provider validation only under a separate provider/email authority. No live email claim follows from fixture or stub tests.

Rollback is a source-only reversal of the support UI/contract phase. It must leave Rails assistance records, audits, email configuration, tenant data, and delivery history untouched.

## Recommended Sequencing

1. **Director decision packet:** resolve the exact unbound safe-action set and the Assistance/Contact retain-versus-consolidate choice. These are product/navigation decisions; source inspection cannot select them.
2. **Shared tenant binding/gate implementation:** apply Finding 001 as one state/navigation packet, then validate it on the installed client. This is independent of support wording and preserves the existing switch state machine.
3. **Support semantics and native contract implementation:** only after the Director decision, implement every retained support action's full rendered payload, truthful copy, and contract tests as one coherent phase.
4. **Installed-client validation:** a separately authorized runtime packet covers both source phases. Real email/provider delivery, a real tenant-binding protocol, and any new native capability remain separately gated.

This order avoids hiding a form without a product decision, introducing a fake real-mode binding fallback, or patching Home/Settings independently while breaking confirmation semantics.

## Native, Version, And Runtime Conclusion

The observed work is JavaScript/UI/state/copy/test and existing Rails test-contract work. It introduces no dependency, lockfile, app configuration, Expo plugin, native project, camera capability, or provider configuration need. `TempleQrCamera` already imports `CameraView` from the existing `expo-camera` surface (`mobile/app/tenant/camera_surface.js`). Therefore neither proposed source phase requires a native rebuild, version increment, or Android/iOS build-number change. An installed-client runtime validation may be needed after source changes, but it is not authority for a build or device action and must use an already compatible client through a later accepted packet.

## Boundary And Rollback Matrix

| Later phase | Owned domains | Required checks | Runtime evidence | Rollback | Preserved boundaries |
| --- | --- | --- | --- | --- | --- |
| Tenant gate/switch hierarchy | Expo App, tenant binding/presentation/back/copy and focused JS tests | binding state machine, selector, navigation/gate, QR permission states, confirmation-only cleanup, storage scope, Back/reset/sign-out/feedback, lint/full mobile tests | Dummy installed client only: unbound gate and QR fixture, then bound switch confirmation; locales/themes/accessibility | Revert source commit only | Real adapter no fallback; tenant slug/storage scope; trusted QR; account-only authority; no admin/payment/OAuth change |
| Support contract/presentation | Expo rendered forms/adapters/copy/tests; Rails native tests only if needed for contract coverage | exact payload capture; Rails native validation/error/dedup/tenant tests; dummy disclosure; full mobile/Rails focused suites | Dummy and local/test-real response handling; admin queue only for Assistance; no provider email unless separately approved | Revert source commit only | Assistance retained/audited and tenant-scoped; Contact email-only/audited; no inbox conversion; no provider/credential/email action |
| Runtime validation | No source change absent a new repair authority | predeclared device/session matrix only | Both locales/themes; gate/camera/switch and selected support flows | terminate session/reset only if separately authorized | No Metro/ADB/device work until its own packet; no real tenant/provider/email/production account action |

## Final State And Authority Confirmation

Only this report was created. The Control packet was already present and remains untracked; no product, source, test, dependency, configuration, native, plan, or historical-record path was changed. No canonical merge, staging, commit, provider/email/API call, account/data operation, production inspection, device/Metro/ADB interference, deployment, release, or push occurred. Control B's active runtime packet was not inspected or interfered with.

First true blocker: the two Director product decisions listed under Findings 001 and 002 are required before implementation, not before this report-only scan. Next owner/action: Wenfu Planning/Director reviews this immutable report, records the decisions, and only then may dispatch coherent implementation packets.
