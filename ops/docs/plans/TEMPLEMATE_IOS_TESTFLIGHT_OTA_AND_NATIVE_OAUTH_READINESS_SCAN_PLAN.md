# TempleMate iOS TestFlight, OTA, And Native OAuth Readiness Scan Plan

Status: accepted read-only readiness authority; report only

Accepted: 2026-08-16

Owner: Wenfu Planning / Director

Target Control: Wenfu Control B
`019fe020-e92e-7770-984f-b59acd547ab0`

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Accepted base: canonical `main`
`38a73acb3e0d9ab0fcfd0460d8ca7fcd4c855526`

Parent track:
`ops/docs/plans/TEMPLEMATE_IOS_TESTFLIGHT_OTA_AND_NATIVE_OAUTH_PLAN.md`

Operational reference, read-only:
`/Users/jimmy1768/Projects/DojoMate-Expo`

Required report:
`ops/docs/handoffs/2026-08-16-templemate-ios-testflight-ota-native-oauth-readiness-control-b.md`

## Objective

Perform the complete Phase B0 readiness scan for the production-identity iOS
TestFlight lane, guarded TestFlight/production OTA structure, production-capable
TempleMate real runtime, trusted test-temple binding, and native Google/Apple
OAuth validation surface.

The scan must produce the smallest ordered source and external-action packets
needed to reach the first TestFlight beta. It must not build, upload, publish,
configure, link, register, mutate, or repair anything.

Web Google/Apple OAuth is already accepted. This scan does not reopen web
provider functionality. It inventories what the new iOS native surface must
prove: browser handoff, `templemate://oauth/complete` return, PKCE exchange,
native session, cancellation/interruption/repeat behavior, restoration, and
absence of duplicate identity/session creation.

## Read-Only Meaning

The packet may read TempleMate and DojoMate source, tests, configuration,
documentation, local Git history, installed CLI versions/help, and current
official Expo and Apple documentation. Technical web evidence must use primary
official sources and record access dates because store and EAS rules change.

It may run existing mobile tests, lint, verification, Expo Doctor, static
configuration resolution, and other non-building local checks. If the isolated
worktree lacks dependencies, it may perform exactly one project-local
`yarn install --frozen-lockfile` after recording pre-install manifest/lock
hashes. It must prove those files remain byte-identical and remove only the
packet-created dependency tree before closeout. Registry cache reads/downloads
are allowed only for the exact lock closure; no package update or global
install is allowed.

Already authenticated EAS state may be queried only through commands known to
be non-mutating and only when they do not prompt for login, consent, project
creation/linking, credential setup, or configuration writes. Retain sanitized
labels, IDs, statuses, channels, runtimes, versions, timestamps, and presence
booleans only. Do not run a command that reveals credential, signing, token,
session, or environment-variable values. If no safe interface exists, record
the state as unknown and specify the later exact authority needed.

No Apple Developer/App Store Connect or Google/provider login is authorized.
An already configured local read-only tool may report nonsecret record presence
only if it requires no new session and exposes no private material; otherwise
the record remains unknown. No device or simulator action is authorized.

The only committed paths are the required sanitized Control report and
Control-owned packet record. No TempleMate, DojoMate, Rails, Vue, plan,
reference, configuration, dependency, native, or version source may change.

## Required Inventory

### TempleMate source and resolved identity

Record configured and resolvable values for development, TestFlight target,
and reserved production target:

- app name, owner, slug, EAS project ID, bundle/package identifiers, scheme,
  icon/splash assets, permissions, privacy declarations, SDK and native target;
- marketing version, iOS build number, Android version code, version source,
  auto-increment behavior, and all current verification assumptions;
- EAS build profiles, distribution types, channels, environment selection,
  update URL, runtime policy, and release/development client flags;
- public configuration keys and any source path that could embed localhost,
  `.test`, dummy mode, DevLauncher, a secret, or a provider client secret; and
- whether current source can resolve a truthful TestFlight/production config
  without inventing missing profiles.

Do not fabricate a resolved TestFlight profile when it does not exist. Report
the exact first prevented resolution and required source work.

### Production real runtime

Trace the complete current real-mode boundary:

- accepted API and trust origins;
- HTTP transport, JSON/error behavior, retry/timeout/cancellation semantics,
  and dummy/local fallback boundaries;
- token/session storage, environment scoping, tenant scoping, logout, reset,
  restoration, and account-only authority;
- current native OAuth start/exchange adapter and Rails response contract;
- tenant discovery/binding, QR trust, unbound gate, switching, and
  confirmation-only cleanup; and
- help, privacy, support, account-deletion, and store-facing URLs.

Classify each requirement as implemented and covered, implemented but
uncovered, local/test-only, absent, externally configured, or unknown. The scan
must identify whether the first TestFlight build is blocked by a missing Rails
endpoint/deployment contract, a mobile-only source gap, or an external record.

### Native Google and Apple surface

Inventory the already accepted Rails/web/provider evidence separately from the
unproven native surface. Establish:

- exact redirect URI/scheme and provider/central-auth callback chain;
- PKCE verifier/challenge/start/exchange/session ownership;
- browser return handling on a production-signed iOS build;
- success, cancel/deny, interruption, malformed/expired/replayed exchange,
  repeated login, logout, and restoration cases;
- Google versus Apple account-resolution responses visible to native clients;
  and
- duplicate-user/session prevention and sanitized logging requirements.

Do not inspect, delete, merge, relink, or remediate user 22. Do not treat the
separate Apple account-resolution rollout as native TestFlight evidence or use
a known historical account mismatch as the OAuth test account.

### EAS build, signing, channels, and updates

Using local source and only safe sanitized read-only EAS observations,
inventory:

- authenticated account label, exact linked project, CLI version, existing
  builds, platforms, profiles, sources, artifact availability, and statuses;
- current channel/branch/update/runtime state when safely observable;
- whether iOS signing/credential readiness has a proven non-mutating inspection
  path; otherwise mark it unknown;
- environment-key names/presence only when a safe value-suppressing path
  exists; otherwise mark them unknown;
- exact source work needed for `testflight` and reserved `production` profiles,
  EAS Update URL/runtime policy, build scripts, OTA scripts, guardrails,
  ledgers, receipts, and rollback; and
- whether any planned native dependency/configuration change requires the
  first iOS binary to be built only after Phase B1.

No EAS channel/branch/environment/project/credential/build/update action is
authorized. No interactive `eas credentials`, `eas init`, build, submit,
update publish, channel edit, environment edit, or project mutation may run.

### App Store/TestFlight readiness

Record source evidence and safely observable facts for:

- production bundle identity and Apple team ownership;
- App Store Connect record existence and role/agreement readiness;
- stable app name, SKU choice boundary, category, age rating, export
  compliance, privacy nutrition, privacy policy, support/help, account deletion,
  review notes, screenshots, and tester-group prerequisites;
- EAS-managed versus Apple-managed signing decision and private-material
  boundary;
- first upload `1.0.0 (1)` and later build-number-only increments; and
- internal versus external TestFlight tester/review implications.

Unknown external state is an acceptable truthful outcome. The report must name
the smallest later B2 action needed to verify or create it; it must not ask the
Director to paste credentials or private output.

### DojoMate operational comparison

Compare TempleMate with DojoMate's current, exact operational structure for:

- EAS profiles and channel names;
- OTA branch/channel/runtime separation;
- version/build/update receipt ledgers;
- package scripts and guarded entry points;
- production localhost/config/secret rejection;
- source/worktree/commit/artifact attribution;
- cloud-build default and separately gated local-build fallback;
- TestFlight update and rollback procedure; and
- stale-command or documentation drift.

Classify every pattern as `adopt`, `adapt`, `not_applicable`, or `reject`, with
the TempleMate reason. Do not copy identifiers, secrets, Firebase, IAP,
RevenueCat, China-payment behavior, versions, dependencies, or commands that
do not match current DojoMate source.

## Required Existing Checks

Run the smallest focused native-config/real-adapter/OAuth/tenant/version tests
and the full mobile suite when dependency closure is available, followed by
lint, the canonical native-client verifier, and offline or online Expo Doctor
under the plan's exact materialization boundary. No test may contact the real
API/provider or create a build/update.

Use static scans and resolved public config to establish secret, localhost,
dummy, development-identifier, runtime, version, permission, and channel
boundaries. If current source cannot resolve a production-like profile, report
that fact rather than weakening verification.

## Required Report

The durable report must contain:

1. exact repository/base/worktree/branch/status/staging and dependency
   materialization evidence;
2. TempleMate development/TestFlight/production identity and configuration
   matrix;
3. production real-runtime and trusted-tenant-binding gap matrix;
4. web-accepted versus native-unproven Google/Apple OAuth matrix;
5. sanitized EAS project/build/channel/update/signing/environment findings,
   with unknowns where no safe read path exists;
6. App Store/TestFlight prerequisite and external-unknown matrix;
7. DojoMate `adopt/adapt/not_applicable/reject` comparison;
8. existing focused/full test, lint, verify, Doctor, and resolved-config
   results;
9. an ordered dependency graph for B1 source, B2 external readiness, B3 first
   build/upload, B4 native OAuth, B5 TestFlight OTA, and B6 staff acceptance;
10. exact likely changed paths, separately protected external actions,
    rollback/reconciliation rules, evidence receipts, and stop conditions for
    each later phase; and
11. first blocker, next owner/action, and one terminal classification:
    `templemate_ios_testflight_ota_native_oauth_ready_for_source_phase` or a
    precise evidence-backed Planning/authority gap.

The report must label facts `configured`, `documented`, `observed`, or
`unknown`, and cite exact repository paths or official primary URLs. It must
contain no token, credential, signing material, environment value, private
session, provider secret, account data, QR content, or artifact download URL.

## Acceptance Criteria

Planning may accept the scan only if:

- every required source/runtime/build/update/OAuth/store surface is accounted
  for without conflating web and native evidence;
- the real transport and trusted-tenant-binding prerequisites are explicit;
- TestFlight and production OTA lanes are distinct and Android remains
  deferred;
- the exact DojoMate patterns to adopt or reject are source-backed;
- current external facts are sanitized or truthfully unknown;
- B1 through B6 have an ordered, minimal, non-overlapping authority map;
- existing checks and all unproven rows are reported truthfully;
- no source/config/dependency-lock/version/native change, build, upload,
  publish, device action, provider action, or account mutation occurred;
- packet-created dependencies/evidence are removed, `git diff --check` passes,
  and canonical `main` remains unchanged and clean.

## Explicit Exclusions

- product/source/test/configuration/dependency/native/version edits;
- EAS project, channel, branch, environment, credential, build, submit, or
  update mutation;
- Apple Developer/App Store Connect creation or mutation;
- Google/Apple provider-console login, registration, validation, or mutation;
- device/simulator installation, OAuth execution, QR scan, Metro, or runtime
  interaction;
- user 22 or any account/session/identity action;
- public App Store release, Play AAB, Android/China APK, or production OTA;
- live ECPay, Stripe, payment, deployment, production data, release-ref
  movement, push, or external mutation; and
- implementation of any readiness recommendation.

## Next Owner

On terminal delivery, Planning sends the paired `released_terminal_idle`
receipt and decides whether to commit the narrow Phase B1 production-runtime,
EAS, OTA, and ledger source plan. No build, Apple/EAS mutation, provider work,
or runtime continuation is implied by this scan.
