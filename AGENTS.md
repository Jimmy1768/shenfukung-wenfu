# Shengfukung Wenfu Agent Instructions

These instructions apply to the entire repository. Codex Work Mode governs
builder coordination only; it does not define or change Wenfu product/runtime
phase integrity, temple, account, payment, deployment, Worker, Incarnation,
Route, Step, Receipt, reincarnation, or other product/runtime lifecycle
semantics.

## Required Source Map

For Codex Work Mode builder-governance work, invoke `$codex-work-mode` and read
these Wenfu-local sources in order:

1. `AGENTS.md` — Wenfu-local authority, safety, phase, and product/runtime
   boundaries.
2. `$codex-work-mode` at `.agents/skills/codex-work-mode/SKILL.md` — reusable
   builder procedure.
3. `ops/docs/plans/CODEX_WORK_MODE_SKILL_MIGRATION_PLAN.md` and
   `ops/docs/plans/CODEX_WORK_MODE_ON_DEMAND_CONTROL_LIFECYCLE_MIGRATION_PLAN.md`
   — accepted local governance and frozen criteria.
4. `ops/docs/plans/FINAL_WEB_READINESS_AND_EXPO_GATE_PLAN.md` and
   `ops/docs/plans/DEPLOYMENT_READINESS.md` — separate Wenfu product-roadmap
   pointers.
5. `ops/docs/reference/codex_work_mode.md` — Wenfu-local boundary reference.
6. `ops/protocol/codex_work_mode.yml` — deterministic local contract.
7. `ops/docs/handoffs/templates/codex_control_implementation.md` —
   Control-owned implementation-packet template.
8. `ops/docs/handoffs/codex_work_mode_current.md` — current local coordination
   and product-roadmap pointers.

The source map contains Wenfu repository paths only. The already manifested
three-file portable package at `.agents/skills/codex-work-mode` is the sole
authorized exception to the general prohibition on copying OperatorKit into
this repository. It may consist only of
`codex_work_mode_skill_package_manifest.yml`, `SKILL.md`, and
`agents/openai.yaml`; no other OperatorKit source, local path, product/runtime
rule, or repository content may be copied.

## Wenfu Authority And Terminology

Ordinary repository work routes `Planning -> authoritative Control A/B -> one ephemeral Implementer`. Strategy owns only task-lifecycle actions and
cross-repository routing. Cross-repository contract, architecture, sequencing,
and authority questions route `Planning -> Strategy -> affected Planning`;
Controls do not coordinate that work directly. A persistent Handoff is an
exceptional, recorded-reason, one-packet continuity mechanism.

Planning owns accepted plans and criteria. Control owns the bounded
implementation packet, repository integration, and acceptance decision.
Implementers edit only packet-owned paths, run the required checks, and return
evidence directly to Control. When durable evidence exists, chat points to its
absolute repository path; historical records remain evidence and are not
rewritten to change their meaning.

## Safety, Phase, And Product Boundaries

For TempleMate Android development-client work on a USB-connected device,
attach Metro through the exact target-fenced ADB reverse and local
`exp+templemate` URL method established by accepted device evidence. Never ask
the Director to scan a Metro/Expo QR code to attach or log in to Metro. Temple
tenant QR scanning is a separate app feature and must never be conflated with
Metro attachment.

Without explicit authorization, do not push, deploy, publish, mutate external
systems, access or rotate secrets, alter accounts, perform destructive actions,
or inspect or change production data. Local or prototype acceptance does not
authorize release promotion.

Deployment, server, DNS, TLS, proxy, Nginx, systemd, queue, cron, production
migration, and production-data work require a separate explicit production
workflow with the exact target, commit, plan, rollback, impact, verification,
approval, and monitoring boundaries.

Payment-provider work is separately gated. Do not access real ECPay
credentials, change merchant configuration, move money, issue real refunds, or
claim legal, accounting, tax, invoice, settlement, or regulatory finality from
local or stubbed evidence.

Keep Rails, Vue, Expo, deployment, temple, account/admin, authority, payment,
and documentation ownership explicit in every bounded packet and return.
Preserve tenant isolation, owner/admin authority, secret handling, payment and accounting semantics, user-work protections, and the assisted-onboarding operating model unless an authorized plan explicitly changes them.
