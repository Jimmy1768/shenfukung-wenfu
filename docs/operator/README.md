# Shengfukung Wenfu Operator Workflow

This folder holds Shengfukung Wenfu-local implementation-packet and evidence
records used by Wenfu Planning, Control, and Implementer tasks.

SourceGrid remains the cross-repo and product coordinator of record. These files
coordinate Shengfukung Wenfu-internal Rails, Vue, Expo, deployment, and docs
work only.

These records support Codex collaboration only. Codex is not governed by
OperatorKit, and no OperatorKit kernel is installed into Codex for this repo.

## Folder Shape

- `docs/operator/workflows/`
  Active or durable local workflow packets.
- `docs/operator/handoffs/`
  Detailed Control implementation packets for Shengfukung Wenfu work.
- `docs/operator/returns/`
  Detailed implementation or research returns from Implementer tasks.
- `docs/operator/acceptances/`
  Wenfu Control acceptance, retry, rejection, blocked, or route-onward
  decisions.
- `docs/operator/execution_records/`
  Durable records of what happened after a return and acceptance decision.
- `docs/operator/friction_records/`
  Repeated or risky workflow gaps that should change future coordination.
- `docs/operator/eval_records/`
  Eval or verification evidence that should be preserved separately from a return.

## Pointer-Only Chat Rule

When a handoff, return, acceptance, execution record, friction record, or eval
record exists as a file, chat should only point to the file.

Required chat format:

```text
Done.

File:
<absolute path to handoff/return/acceptance/execution/friction/eval record>

Next:
<who should review or what should happen next>
```

Do not paste the full handoff or return in chat if the file exists.

Do not ask the receiving thread to infer the file path.

Do not let Implementer tasks decide acceptance. Acceptance belongs to Control
only.

## On-Demand Control Lifecycle

Strategy alone coordinates cross-repository work, creates durable tasks, and
performs Thread Refresh. It creates Control A only after Planning sends one
valid Control-ready request. Planning is one unnumbered repository task: it
freezes the plan and acceptance criteria, but does not select implementation
packet details.

Control A is the default repository Control. Control B may be created only for
genuinely independent parallel work, not as a standing partner or replacement
slot. Control selects the branch, execution mode, Implementer model and
reasoning, exact owned paths, and required checks, then freezes one bounded
implementation packet.

The normal dispatch is exactly one ephemeral Implementer. Control supervises
the work, reviews the return and frozen-plan conformance, locally integrates
accepted work into canonical `main`, and sends exactly one terminal packet to
Planning. The Implementer writes its terminal return in its own task and, after
all mutations and checks, sends one minimal wake signal containing its task ID,
terminal status, and instruction to read that return once. The wake is not the
return. A workload-sized heartbeat is fallback recovery only if that wake fails
or the task becomes unreachable.

A persistent Handoff may be used only exceptionally as a one-packet continuity
mechanism with a recorded qualifying continuity reason. It is never a permanent
Control pairing. Legacy numbered Controls and permanent-pair task IDs are
non-authoritative, receive no new work, and are preserved without cleanup or
reconciliation of unsafe or dirty lanes.

After Planning accepts its terminal packet, Control remains visible and idle.
It is not automatically archived; any later Strategy archive requires the
complete idle gate and an exact current snapshot record.

Strategy explicitly selects model and reasoning for durable tasks. Control
selects the lowest sufficient Implementer configuration for each packet and
records the selected model, reasoning, and selection reason in the packet and
dispatch. An Implementer cannot self-select or escalate; if the selected
configuration is unavailable, Control reports a blocker rather than silently
substituting it.

## Authority

Shengfukung Wenfu uses manual Wenfu Control/Handoff coordination in this lane
unless a later owner decision upgrades the permission model.

This folder does not authorize automation, release promotion, deployment,
server changes, secret access, payment changes, account changes, destructive
actions, or production data changes.

## Return Requirements

Implementation returns should include:

- objective;
- completed work;
- repo path;
- branch role and branch name;
- latest commit hash and subject;
- staged, unstaged, untracked, committed, and pushed state;
- ahead/behind state if known;
- files changed;
- verification commands and pass/fail output;
- skipped checks and reasons;
- Rails/Vue/Expo boundary confirmation if touched;
- payment, auth, temple, or admin boundary confirmation if touched;
- deployment, server, OTA, or public-site impact;
- residual risk;
- production gaps;
- next owner.

## Acceptance

Wenfu Handoff tasks report evidence. They do not decide acceptance.

Acceptance records should use one of:

```text
accepted
accepted_with_gaps
retry_required
rejected
blocked
meeting_required
promote
watch
```

Do not accept production-readiness, deployment, payment, or public-site claims
from prototype evidence alone.

## Existing Ops Docs

This repo also has `ops/docs/` for operational commands, plans, references,
tickets, and deployment-oriented notes. Do not move that history into
`docs/operator/`.

Use `docs/operator/` only for Wenfu-local Codex implementation-packet, return,
acceptance, execution, friction, eval, and workflow records.
