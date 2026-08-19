# Shengfukung Wenfu — Repo Context

Local, repo-specific product/runtime and builder-procedure context for this
repository only. It does not apply to any other repository and is not copied
into other repositories. Both `AGENTS.md` (Codex) and `CLAUDE.md` (Claude
Code) reference this single file as their shared repo-context source — edit
it here once, not per-IDE-file.

Work Mode (Codex Work Mode, Claude Work Mode) governs builder coordination
only; it does not define or change Wenfu product/runtime phase integrity —
temple, patron/account, offering and registration, payment (ECPay),
deployment, or other product/runtime lifecycle semantics — those live in
this file.

**Codex Work Mode status: archived.** This repository is now
Claude-exclusive (see `ops/protocol/claude_work_mode.md`). The Codex Work
Mode source map, deterministic contract, and current-snapshot files below
are historical evidence from before the takeover — not live instructions —
and have been moved under each directory's `archive/` subfolder so a
session reading this repo today doesn't mistake them for current
governance. They are kept, not deleted, per the "historical records remain
evidence" rule further down.

## Domain And Tenancy Architecture

Recurring source of confusion (Codex, and this session too) worth
getting right once: **the Rails backend and the TempleMate mobile app
are centralized and legitimately multi-tenant — the Vue frontend is
not.**

- Rails (backend/database) and TempleMate (`mobile/`) are shared,
  single deployments serving every client/temple. A `temples` table
  with multiple tenant rows, `current_temple` resolution, and
  cross-temple switching inside those two surfaces are all legitimate.
- **Each real client gets their own separate Vue deployment on their
  own domain** — `temple1.org.tw`, etc. — not a shared multi-tenant Vue
  instance. This matches the existing `bin/deploy_vue <client-slug>`
  pattern (`ops/docs/reference/deployment_notes.md`): one build, one
  `rsync` target per client.
- `shengfukung.com.tw` is the demo domain for one specific temple
  (Shengfukung). It should resolve to exactly that one temple via
  `current_temple` (Host-based, no slug/param) — it is not a sandbox for
  creating or exposing additional temple tenants. **Do not build or
  treat any feature as "create a new temple inside shengfukung.com.tw."**
  A new real temple means a new domain and a new Vue deployment, not a
  new row reachable from an existing client's demo/production site.
- Current confusion source: `shengfukung.com.tw` is both the demo site
  *and*, informally, the de facto identity of the centralized backend —
  there's no separate domain for the platform/backend itself yet.
  **Planned fix, not yet done**: acquire and use a dedicated domain
  (e.g. `templemate.com`) for the backend/platform identity, keeping
  `shengfukung.com.tw` purely as one demo temple's site rather than
  conflated with the platform. `shengfukung.org.tw` would later be that
  same real temple's real (non-demo) site — still its own single
  domain, not multi-tenant.

## Control Track Assignment

Both Codex Work Mode and Claude Work Mode use a domain-owned Control split
in this repo, not a hand-agnostic one — inherited from how the work has
actually run so far (Track A / Track B in
`ops/docs/handoffs/2026-08-17-account-admin-personal-and-offering-data-alignment-control-a.md`
and
`ops/docs/handoffs/2026-08-17-templemate-production-runtime-eas-ota-source-control-b.md`):

- **Control A** owns Rails / account / admin / offering-data work.
- **Control B** owns TempleMate / EAS / TestFlight / OTA / native OAuth /
  mobile work.
- The two stay independent; cross-track coordination routes through
  Planning, not Control-to-Control.

This is an operating convention for this repo, not a Claude Work Mode rule —
`ops/protocol/claude_work_mode.md`'s Control A/B are hand-agnostic by
default (packet-owns-branch, either hand can pick one up). Wenfu just keeps
them specialized because the domain split is already real and keeping each
Control's accumulated context focused by domain is useful on its own merits.

## Codex Work Mode Local Source Map (archived, historical)

This section describes governance from before the Claude takeover. It no
longer applies to live work in this repository — kept as evidence only.

For Codex Work Mode builder-governance work, invoke `$codex-work-mode` and
read these Wenfu-local sources in order:

1. `AGENTS.md` — pointer to this file plus the Codex Work Mode skill.
2. `$codex-work-mode` at `.agents/skills/codex-work-mode/SKILL.md` — reusable
   builder procedure.
3. `ops/docs/plans/CODEX_WORK_MODE_SKILL_MIGRATION_PLAN.md` and
   `ops/docs/plans/CODEX_WORK_MODE_ON_DEMAND_CONTROL_LIFECYCLE_MIGRATION_PLAN.md`
   — accepted local governance and frozen criteria.
4. `ops/docs/plans/FINAL_WEB_READINESS_AND_EXPO_GATE_PLAN.md` and
   `ops/docs/plans/DEPLOYMENT_READINESS.md` — separate Wenfu product-roadmap
   pointers.
5. `ops/docs/reference/archive/codex_work_mode.md` — Wenfu-local boundary
   reference (archived).
6. `ops/protocol/archive/codex_work_mode.yml` — deterministic local contract
   (archived).
7. `ops/docs/handoffs/templates/codex_control_implementation.md` —
   Control-owned implementation-packet template.
8. `ops/docs/handoffs/archive/codex_work_mode_current.md` — current local
   coordination and product-roadmap pointers as of the takeover (archived).

The source map contains Wenfu repository paths only. The already manifested
three-file portable package at `.agents/skills/codex-work-mode` is the sole
authorized exception to the general prohibition on copying OperatorKit into
this repository. It may consist only of
`codex_work_mode_skill_package_manifest.yml`, `SKILL.md`, and
`agents/openai.yaml`; no other OperatorKit source, local path, product/runtime
rule, or repository content may be copied.

## Wenfu Authority And Terminology

Ordinary repository work routes `Planning -> authoritative Control A/B -> one
ephemeral Implementer`. Strategy owns only task-lifecycle actions and
cross-repository routing. Cross-repository contract, architecture,
sequencing, and authority questions route `Planning -> Strategy -> affected
Planning`; Controls do not coordinate that work directly. A persistent
Handoff is an exceptional, recorded-reason, one-packet continuity mechanism.

Planning owns accepted plans and criteria. Control owns the bounded
implementation packet, repository integration, and acceptance decision.
Implementers edit only packet-owned paths, run the required checks, and
return evidence directly to Control. When durable evidence exists, chat
points to its absolute repository path; historical records remain evidence
and are not rewritten to change their meaning.

> Note: this routing model was also encoded in the now-archived
> `ops/protocol/archive/codex_work_mode.yml` (`routing` / `roles` keys), from
> when Codex governed this repo. It is historical, not a live authority —
> Claude Work Mode (`ops/protocol/claude_work_mode.md`) governs current work.

## Safety, Phase, And Product Boundaries

For TempleMate Android development-client work on a USB-connected device,
attach Metro through the exact target-fenced ADB reverse and local
`exp+templemate` URL method established by accepted device evidence. Never
ask the Director to scan a Metro/Expo QR code to attach or log in to Metro.
Temple tenant QR validation is a separate app feature and must be performed
only inside TempleMate through its own `Scan demo QR` / Expo CameraView
surface after the app bundle loads. Do not use the Expo development
launcher's QR scanner or the Pixel's native Camera/QR scanner for that
feature test, and never conflate it with Metro attachment.

Without explicit authorization, do not push, deploy, publish, mutate external
systems, access or rotate secrets, alter accounts, perform destructive
actions, or inspect or change production data. Local or prototype acceptance
does not authorize release promotion.

Deployment, server, DNS, TLS, proxy, Nginx, systemd, queue, cron, production
migration, and production-data work require a separate explicit production
workflow with the exact target, commit, plan, rollback, impact, verification,
approval, and monitoring boundaries.

Payment-provider work is separately gated. Do not access real ECPay
credentials, change merchant configuration, move money, issue real refunds,
or claim legal, accounting, tax, invoice, settlement, or regulatory finality
from local or stubbed evidence.

Keep Rails, Vue, Expo, deployment, temple, account/admin, authority, payment,
and documentation ownership explicit in every bounded packet and return.
Preserve tenant isolation, owner/admin authority, secret handling, payment
and accounting semantics, user-work protections, and the assisted-onboarding
operating model unless an authorized plan explicitly changes them.
