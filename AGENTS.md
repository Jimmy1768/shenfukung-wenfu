# Shengfukung Wenfu Agent Instructions

These instructions apply to the entire repository.

Shengfukung Wenfu is built with Codex Work Mode. These rules govern Codex
builder coordination only. They do not define temple, account, payment,
deployment, Worker, Incarnation, Route, Step, Receipt, reincarnation, or other
product/runtime lifecycle semantics. Do not install or copy OperatorKit into
this repository.

## Repository Authority And Lifecycle

Strategy is the single owner of workspace cross-repository coordination,
durable task creation, and Thread Refresh. It creates Wenfu Control A only
after receiving one valid Control-ready request from Wenfu Planning.

Planning is one unnumbered repository task. It freezes accepted plans and
acceptance criteria, then sends the Control-ready request to Strategy. Planning
does not choose an implementation branch, execution mode, model or reasoning,
owned paths, checks, or an implementation packet.

Control A is the default repository Control. Strategy creates Control B only
for genuinely independent parallel work; it is neither a standing partner nor a
replacement slot. Control owns repository-local reasoning, packet construction,
acceptance review, approvals, Git state, and local integration. It selects the
branch, execution mode, implementation model and reasoning, exact owned paths,
and required checks, then freezes one bounded implementation packet.

Control normally dispatches and supervises exactly one ephemeral Implementer.
The Implementer edits only packet-owned paths, runs required checks, and
returns exact evidence; it does not decide acceptance, stage, commit, merge,
push, deploy, resolve approvals, broaden scope, or mutate external systems.
Control independently reviews frozen-plan conformance and the evidence, locally
integrates accepted work into canonical `main`, and then sends exactly one
terminal packet to Planning.

A persistent Handoff is exceptional: it may be used only as a one-packet
continuity mechanism with a recorded qualifying continuity reason. It is never
a permanent Control pairing. Legacy numbered Controls and permanent-pair task
IDs are non-authoritative, receive no new work, and remain preserved without
deleting, cleaning, resetting, archiving, or otherwise reconciling unsafe or
dirty historical lanes.

After Planning accepts Control A's terminal packet, Control A remains visible
and idle; it is not automatically archived. Any later Strategy archive requires
the complete idle gate and an exact current snapshot record.

SourceGrid remains the cross-repository and product coordinator of record.
Cross-repository work routes through Strategy to the owning repository Control.
Kernel architecture, cross-repository contracts, and authority-boundary changes
route to the owning Control instead of being silently absorbed into Wenfu work.

## Model Allocation

Strategy explicitly selects the model and reasoning for each durable task it
creates. For every implementation packet, Control selects the lowest sufficient
Implementer configuration and records the model, reasoning, and selection
reason in the packet and dispatch. An Implementer cannot select or escalate its
own configuration; an unavailable selected configuration is reported as a
blocker rather than silently substituted.

## Return And Acceptance Boundary

The default ephemeral Implementer returns directly to its parent Control
through the parent-agent return. It does not send cross-task terminal messages,
own a cross-task terminal-return or wake workflow, or use a heartbeat. Control
independently reviews the diff and evidence and records acceptance or retry. An
Implementer never accepts its own work.

Only an exceptional persistent Handoff uses the cross-task terminal-return,
minimal terminal wake, and fallback heartbeat workflow. Its authoritative
terminal return is written in its own task, and its final wake signal contains
only the Handoff task ID, terminal status, and instruction to read that return
once; it is not the return body. That workflow is permitted only for the
recorded-reason one-packet continuity mechanism described above.

When a handoff, return, acceptance, execution, friction, or eval record exists
as a repository file, chat points to the absolute file path instead of copying
the full record.

## Repository And Runtime Safety

Without explicit authorization, do not push, deploy, publish, mutate external
systems, access or rotate secrets, alter accounts, perform destructive actions,
or inspect or change production data.

Local or prototype acceptance does not authorize production promotion. Release
promotion, deployment, server, DNS, TLS, proxy, Nginx, systemd, queue, cron,
production migration, or production-data work requires a separate explicit
production workflow with the exact target, commit, plan, rollback, impact,
verification, approval, and monitoring boundaries.

Payment-provider work remains separately gated. Do not access real ECPay
credentials, change merchant configuration, move money, issue real refunds, or
claim legal, accounting, tax, invoice, settlement, or regulatory finality from
local or stubbed evidence.

Keep Rails, Vue, Expo, deployment, temple, account/admin, authority, payment,
and documentation ownership explicit in every bounded packet and return.
Preserve tenant isolation, owner/admin authority, secret handling, payment and
accounting semantics, and the assisted-onboarding operating model unless an
authorized plan explicitly changes them.

## Linked Repository Guidance

Detailed Wenfu record formats, historical binding evidence, pointer-only chat
rules, and operational references remain in `docs/operator/README.md` and
`ops/docs/`. Where linked guidance conflicts with this file on the current
Codex builder lifecycle, this root file is current. Do not rewrite historical
handoffs, returns, acceptances, or execution evidence to make them appear
current.
