# Shengfukung Wenfu Operator Records

This directory holds Wenfu-local implementation-packet and evidence records for
Codex collaboration. It does not define product/runtime behavior. Read the
Wenfu source map in [`AGENTS.md`](../../AGENTS.md), then invoke
[`$codex-work-mode`](../../.agents/skills/codex-work-mode/SKILL.md) for the
reusable builder procedure.

## Record Locations

- `workflows/` — active or durable local workflow packets.
- `handoffs/` — Control implementation packets and continuity records.
- `returns/` — Implementer or research returns.
- `acceptances/` — Control decisions.
- `execution_records/` — durable outcome records.
- `friction_records/` — repeated or risky coordination gaps.
- `eval_records/` — preserved evaluation or verification evidence.

## Pointer-Only Chat

When one of these records exists, chat points only to its absolute path:

```text
Done.

File:
<absolute path to the record>

Next:
<reviewer or next action>
```

Do not paste a file-backed record into chat or require the receiver to infer
its location. Historical handoffs, returns, acceptances, execution records,
friction records, and evals remain historical evidence; do not rewrite them to
modernize terminology.

## Local Authority And Safety

Planning, Control A/B, Strategy, ephemeral Implementer, and exceptional
persistent Handoff use the meanings in the required source map. Control alone
accepts implementation evidence; an Implementer never accepts its own work.
SourceGrid remains the cross-repository and product coordinator of record.

These records do not authorize automation, release promotion, deployment,
server changes, secret or provider access, payment or account changes,
destructive actions, or production-data changes. Preserve tenant isolation,
owner/admin authority, payment and accounting semantics, and the
operator-assisted onboarding model unless an authorized plan changes them.

`ops/docs/` remains the location for operational commands, plans, references,
tickets, and deployment-oriented notes. Do not move its history here.
