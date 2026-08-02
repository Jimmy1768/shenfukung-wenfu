# Codex Work Mode Skill Migration Plan

Status: Director-authorized; Planning accepted

Owner: Wenfu Planning

Date: 2026-08-02

Repository: `/Users/jimmy1768/Projects/shengfukung-wenfu`

Canonical main base: `ddaab24df5f08b16fd2efce8bc2376456f2d6eaf`

## Purpose And Phase

Install the portable Codex Work Mode skill package and move reusable builder
procedure out of Wenfu's active local governance sources. This is the current
Director-authorized builder-governance migration. It does not open, replace, or
change any Shengfukung Wenfu product/runtime phase, roadmap, deployment,
provider, payment, or account work.

The canonical package is `operatorkit:codex_work_mode_skill_package:v1` from
OperatorKit commit `bb67611def509c2ae8089521e3e93f9c329ef7a8`, seeded at
`fba8b20d3e6f57b2ac97b0536b96bec7b66dd162`.

## Frozen Package Identity

Control must copy the self-excluding manifest and the two payload files exactly
from `/private/tmp/operator-kit-runtime-fulfillment-v3-7-plan-main/.agents/skills/codex-work-mode`
to `.agents/skills/codex-work-mode`:

| Path | SHA-256 |
| --- | --- |
| `SKILL.md` | `f70010e49b5b1dd218e116ccc584e6b11c657e4ecbb02c9952444349aa9ebdc3` |
| `agents/openai.yaml` | `f79867a4869ff4cc5c6638955346f43d3e84f1c54c7a1d42fa9f1416f50ad007` |

The manifest is copied without modification and retains schema
`codex_work_mode_skill_package_manifest:v1`, package reference
`codex_work_mode_skill_package`, version `v1`, and its canonical provenance.
No repository may fork, rewrite, or add local payload files to this package.

## Frozen Local Source Map

After migration, `AGENTS.md` must require `$codex-work-mode` for Codex Work
Mode builder-governance work and declare this source order:

1. `AGENTS.md` for Wenfu-local authority, safety, phase, and product/runtime
   boundaries;
2. `$codex-work-mode` at `.agents/skills/codex-work-mode/SKILL.md` for reusable
   Planning, Control, Implementer, Handoff, routing, and lifecycle procedure;
3. `ops/docs/plans/CODEX_WORK_MODE_SKILL_MIGRATION_PLAN.md` and
   `ops/docs/plans/CODEX_WORK_MODE_ON_DEMAND_CONTROL_LIFECYCLE_MIGRATION_PLAN.md`
   for accepted local governance and frozen criteria;
4. `ops/docs/plans/FINAL_WEB_READINESS_AND_EXPO_GATE_PLAN.md` and
   `ops/docs/plans/DEPLOYMENT_READINESS.md` as separate, unchanged Wenfu
   product-roadmap pointers;
5. `ops/docs/reference/codex_work_mode.md` for the Wenfu-local builder boundary
   and source-map reference;
6. `ops/protocol/codex_work_mode.yml` for deterministic local contract truth;
7. `ops/docs/handoffs/templates/codex_control_implementation.md` for the
   Control-owned implementation-packet shape; and
8. `ops/docs/handoffs/codex_work_mode_current.md` for volatile local task and
   current product-roadmap pointers.

The source map must point only to Wenfu repository paths and Wenfu product
roadmaps. It must not copy OperatorKit local paths, Native UI obligations, or
OperatorKit product/runtime rules.

## Frozen Acceptance Criteria

1. The three-file package is installed at the exact path and its two payload
   SHA-256 values and manifest provenance exactly match the canonical package.
2. `AGENTS.md` is concise and practical: it retains Wenfu-local authority,
   phase integrity, repository/product-runtime boundary, payment/provider,
   deployment, secret, tenant/authority, assisted-onboarding, user-work, and
   external-action rules; it invokes `$codex-work-mode` and declares the exact
   Wenfu-local source map.
3. Reusable Planning/Control/Implementer/Handoff procedure appears in the
   installed skill, not duplicated in local `AGENTS.md` or `docs/operator/README.md`.
   Local sources retain only Wenfu-specific authority, records, safety, and
   terminology needed to route work safely.
4. The local reference, protocol, packet template, and current snapshot agree
   with the installed package and direct ordinary routing:
   `Planning -> authoritative Control A/B -> one ephemeral Implementer`.
   Strategy is used for lifecycle action or cross-repository routing only.
5. A persistent Handoff remains an exceptional, recorded-reason one-packet
   continuity mechanism. Existing send/handoff terminology and historical
   evidence remain preserved.
6. Controls do not coordinate cross-repository architecture; such work routes
   `Planning -> Strategy -> affected Planning`.
7. No Rails, Vue, Expo, temple, account/admin, payment, provider, deployment,
   secret, production-data, or historical-record behavior changes.
8. Focused deterministic verification proves skill discovery/invocation,
   manifest/payload identity, concise local source map, no duplicated reusable
   workflow, and retained Wenfu boundaries. Broad product suites are not
   required absent an observed product failure.

## Direct Control Dispatch Boundary

Wenfu Control A is authoritative and idle. Planning sends this accepted plan
and criteria directly to it as ordinary repository work. Control alone selects
the branch/worktree, execution mode, model/reasoning, exact owned paths,
checks, blocked surfaces, and one implementation packet. It normally uses one
ephemeral Implementer, reviews frozen-plan conformance, locally integrates
accepted work on canonical `main`, and sends one terminal packet to Planning.

Likely implementation surfaces for Control to assess are the skill package,
`AGENTS.md`, `docs/operator/README.md`, the declared source-map artifacts, and
a deterministic verifier. This is scope guidance, not a frozen packet.

## External And Historical Boundaries

Do not modify the portable package source or any repository outside the
Director allowlist. Do not touch DojoMate-Vue, thesis-record, or another
repository from this packet. Do not rewrite historical handoffs, sends,
acceptances, execution records, evals, or friction records. Do not push,
deploy, publish, access providers or secrets, resolve approvals, or mutate an
external system.
