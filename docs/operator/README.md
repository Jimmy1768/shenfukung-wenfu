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
performs Thread Refresh. It creates or refreshes Control A only when no
authoritative Control exists and Planning sends a valid task-lifecycle request.
Planning is one unnumbered repository task: it freezes the plan and acceptance
criteria, then sends them directly to the authoritative Control for ordinary
repository work. It sends Strategy a lifecycle request only when no Control
exists, a Control needs Thread Refresh, or a genuinely independent Control B
must be created. Planning does not select implementation-packet details.

Control A is the default repository Control. Control B may be created or
refreshed only for genuinely independent parallel work, not as a standing
partner or replacement slot; it does not require Control A to be active.
Control selects the branch, execution mode, Implementer model and reasoning,
exact owned paths, and required checks, then freezes one bounded implementation
packet.

The normal dispatch is exactly one ephemeral Implementer. Control supervises
the work, reviews the return and frozen-plan conformance, locally integrates
accepted work into canonical `main`, and sends exactly one terminal packet to
Planning. The ephemeral Implementer returns directly to its parent Control
through the parent-agent return. It does not send cross-task terminal messages,
own a cross-task terminal-return or wake workflow, or use a heartbeat.
Planning does not monitor Implementer activity while the owning Control
supervises the active build.

A persistent Handoff may be used only exceptionally as a one-packet continuity
mechanism with a recorded qualifying continuity reason. It is never a permanent
Control pairing. Only this exceptional persistent Handoff may write its
authoritative terminal return in its own task, then send a minimal cross-task
terminal wake containing its task ID, terminal status, and instruction to read
that return once; the wake is not the return. A workload-sized heartbeat is
fallback recovery only if that wake fails or the Handoff becomes unreachable.
Legacy numbered Controls and permanent-pair task IDs are non-authoritative,
receive no new work, and are preserved without cleanup or reconciliation of
unsafe or dirty lanes.

After Planning accepts its terminal packet, Control remains visible and idle.
It is not automatically archived; any later Strategy archive requires the
explicit Director archival instruction, complete idle gate, and exact current
snapshot record.

Cross-repository contract, architecture, sequencing, and authority questions
route from Wenfu Planning to Strategy and then to the affected repository
Planning tasks. Controls do not coordinate cross-repository architecture
Control-to-Control or freely interrupt another Planning task.

Strategy explicitly selects model and reasoning for durable tasks. Control
selects the lowest sufficient Implementer configuration for each packet and
records the selected model, reasoning, and selection reason in the packet and
dispatch. An Implementer cannot self-select or escalate; if the selected
configuration is unavailable, Control reports a blocker rather than silently
substituting it.

## Authority

Shengfukung Wenfu uses the on-demand Control lifecycle in this lane: Planning
sends ordinary frozen work directly to the authoritative Control; Strategy
handles only the lifecycle request when no Control exists, a Control needs
Thread Refresh, or independent Control B work is needed. Control normally
dispatches one ephemeral Implementer, and only the recorded-reason persistent
Handoff exception uses cross-task coordination.

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

Implementers report evidence to Control. They do not decide acceptance.

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
