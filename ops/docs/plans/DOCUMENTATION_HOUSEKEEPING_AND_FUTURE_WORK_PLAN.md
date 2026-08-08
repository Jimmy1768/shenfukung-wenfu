# Documentation Housekeeping And Future-Work Plan

Status: Director-requested; local documentation housekeeping authorized

Owner: Wenfu Planning

Date: 2026-08-08

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Observed base: `b3943530e2b6909de16b1c247774fbf2a2e28443`

## Purpose

Remove completed plans from the active planning surface without deleting their
historical evidence. Move their durable present-tense facts into focused
references, and put deferred work plus retained active plans in one current
future-work record. This is documentation-only housekeeping; it does not
change product/runtime behavior or authorize release, provider, secret,
production, or external work.

## Authority And Preservation Rules

Planning freezes this exact documentation map and sends it directly to Wenfu
Control B. Control owns one documentation-only implementation packet and local
integration; it must not rewrite historical evidence to change its meaning.

`AGENTS.md` and the portable Codex Work Mode package are excluded. The
`AGENTS.md` source map requires the two Codex Work Mode migration paths and the
final-web-readiness path to remain readable at their existing locations.
Therefore each such completed plan is preserved in full under the archive and
replaced at the old path only by a short historical-index stub that links to
the archived record. The stub is not an active plan or a replacement of the
historical record.

Use Git moves for each archived record. Do not delete an archived record,
change its body, scrub its evidence, or copy secrets/personal data into a
reference. Retained plans are neither renamed nor edited in this cleanup.

## Frozen Archive Map

Create `ops/docs/plans/archive/` and move these complete records intact:

| Current completed plan | Archived record | Active-path result |
| --- | --- | --- |
| `ADMIN_PERMISSIONS_UI_AND_NAVIGATION_ALIGNMENT_PLAN.md` | `archive/ADMIN_PERMISSIONS_UI_AND_NAVIGATION_ALIGNMENT_PLAN.md` | Removed from active plans. |
| `PLATFORM_BILLING_MONTHLY_AUTOPAY_CORRECTION_PLAN.md` | `archive/PLATFORM_BILLING_MONTHLY_AUTOPAY_CORRECTION_PLAN.md` | Removed from active plans. |
| `FIRST_TENANT_BILLING_ENTITLEMENT_AND_REGISTRATION_GATE_PLAN.md` | `archive/FIRST_TENANT_BILLING_ENTITLEMENT_AND_REGISTRATION_GATE_PLAN.md` | Removed from active plans. |
| `FINAL_WEB_READINESS_AND_EXPO_GATE_PLAN.md` | `archive/FINAL_WEB_READINESS_AND_EXPO_GATE_PLAN.md` | Replace with a historical-index stub linking to the archive and current future-work record. |
| `CODEX_WORK_MODE_SKILL_MIGRATION_PLAN.md` | `archive/CODEX_WORK_MODE_SKILL_MIGRATION_PLAN.md` | Replace with a historical-index stub linking to the archive and current local governance sources. |
| `CODEX_WORK_MODE_ON_DEMAND_CONTROL_LIFECYCLE_MIGRATION_PLAN.md` | `archive/CODEX_WORK_MODE_ON_DEMAND_CONTROL_LIFECYCLE_MIGRATION_PLAN.md` | Replace with a historical-index stub linking to the archive and current local governance sources. |

The historical-index stubs may contain only title, archived-record link,
completion classification, and links to their active current sources. They
must not restate or reinterpret the archived plan.

## Frozen Durable Reference And Future-Work Map

| Path | Required result |
| --- | --- |
| `ops/docs/reference/templemate_platform_billing_runtime.md` | Retain the canonical Stripe/ECPay boundary, pricing, entitlement/lifecycle, timer-disabled, and first-tenant activation facts. Add only the locally accepted entitlement/collection/presentation result if that fact is absent; do not add a live-readiness claim. |
| `ops/docs/reference/onboarding.md` | Add a concise first-tenant future gate: reviewed real-client offering intake; ECPay staging versus live verification; controlled Stripe setup and matching webhook evidence; and separately authorized activation/rollback/monitoring. It must state that no real client is currently named and no local acceptance simulates one. |
| `ops/docs/reference/future_work.md` | Create the single current future-work record. Include (a) deferred first-tenant activation prerequisites and explicit external boundaries, (b) the retained active/deferred plan inventory below, and (c) an index linking each archived completed record to its durable reference destination. |
| `ops/docs/handoffs/codex_work_mode_current.md` | Replace pointers to archived completed product plans with `future_work.md`; record this housekeeping phase as current until Control acceptance, then as complete. Preserve current routing/allocation language. |
| `ops/docs/reference/admin_portal.md`, `ops/docs/reference/platform_payments.md`, `ops/docs/reference/deployment_notes.md`, `ops/docs/reference/codex_work_mode.md` | Treat current content as the durable source when it already states the fact. Verify archive/future-work links rather than duplicating or broadening these references. |

### Deferred first-tenant facts for `future_work.md`

- A real approved temple and owner, reviewed offering DOCX/intake classification,
  and any required service/event workflow remain unavailable and must not be
  simulated.
- ECPay credential entry is staged configuration only; real merchant,
  callback, payment, refund, and accounting verification require a separate
  authorized provider-safe workflow.
- Stripe catalog/configuration and local code evidence do not create a
  customer, Checkout, invoice, subscription, payment, or entitlement. A
  controlled setup and matching signed webhook event remain future proof.
- Timers are installed but disabled. Enabling timers, first collection,
  deployment, production migration/data work, and provider actions require a
  future target-specific packet with exact target, commit, rollback,
  verification, monitoring, and authority.

### Retained active or deferred plan inventory

Retain these files at their present paths as active/deferred source material:

- `ACCOUNT_CLOSURE_AND_PRIVACY_REQUESTS_PLAN.md`
- `ACCOUNT_PASSWORD_ADDITION_PLAN.md`
- `ACCOUNT_PORTAL_REFINE.md`
- `ADMIN_ACCOUNTING_AND_ARCHIVES_WORKFLOW_PLAN.md`
- `ADMIN_PERIOD_KEY_GOVERNANCE.md`
- `ADMIN_PORTAL_REFINE.md`
- `ADMIN_ROLE_MODEL_SIMPLIFICATION_PLAN.md`
- `ADMIN_ROLE_TRANSITIONS_PLAN.md`
- `API_ABUSE_BLACKLIST_GOVERNANCE_PLAN.md`
- `DEPLOYMENT_READINESS.md`
- `EMAIL_DELIVERY_QUEUE_AND_DEDUPE_PLAN.md`
- `EXPO_MULTI_ROLE_MODE_SWITCH_PLAN.md`
- `INTERNAL_TEMPLE_ACCESS_DASHBOARD_PLAN.md`
- `OAUTH_GOOGLE_SUBJECT_COMPATIBILITY_REPAIR_PLAN.md`
- `OAUTH_PROVIDERS_SETUP_PLAN.md`
- `PATRON_REQUEST_ASSISTANCE_ALERTS.md`
- `PAYMENTS_CORE_SUBSYSTEM_PLAN.md`
- `REGISTRATION_LIFECYCLE_EDIT_POLICY.md`
- `SHENGFUKUNG_OFFERINGS_CONFIG_PLAN.md`
- `SYSTEM_AUDIT_COVERAGE_AND_RETENTION_PLAN.md`
- `SYSTEM_WIDE_ABUSE_PROTECTION_TELEMETRY_FOLLOWUP.md`
- `TEMPLE_OFFERING_SYSTEM_SPEC.md`

This inventory is a retention classification, not a claim that every listed
plan has the same priority or is ready to implement.

## Frozen Acceptance Criteria

1. Every listed complete plan has an intact archive path; no archived body is
   rewritten, and every active-path stub required by `AGENTS.md` resolves to
   that archive.
2. No completed product plan remains in the active planning surface except the
   three required source-map historical-index stubs. Every listed retained
   active/deferred plan remains untouched at its original path.
3. `future_work.md`, onboarding, and the platform-billing runtime reference
   agree that live first-tenant activation is deferred, not blocked, and not
   authorized by local evidence.
4. Current references preserve temple isolation, owner/admin authority,
   ECPay-versus-Stripe money-flow separation, SourceGrid catalog ownership,
   historical records, secret safety, assisted onboarding, and product/runtime
   boundaries.
5. Run focused Markdown/path/link and stale-active-plan scans, the repository
   documentation checks if available, `git diff --check`, and final
   status/staging checks. Do not run product suites unless a documentation
   check requires them.

## Explicit Exclusions

Do not edit `AGENTS.md`, the portable skill package, Rails/Vue/Expo code,
schemas, configuration, environment files, deployment/host files, or provider
records. Do not push, deploy, access secrets/providers, change a scheduler,
mutate production data, or perform any external action.
