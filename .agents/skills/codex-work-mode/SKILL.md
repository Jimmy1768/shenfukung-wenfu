---
name: codex-work-mode
description: Run a repository's reusable builder-governance workflow. Use for Codex Work Mode Strategy, repository Planning, Control A/B, ephemeral Implementer, exceptional Handoff, accepted-plan dispatch, implementation supervision, conformance review, local integration, terminal packet, cross-repository coordination, task lifecycle, Thread Refresh, snapshot, or sidebar-topology work.
---

# Codex Work Mode

Apply the repository's accepted builder workflow without transferring Codex
task mechanics into product or runtime semantics.

## Load Source Truth

Before acting:

1. Read the repository's `AGENTS.md` for repository-specific authority, safety,
   phase, and product/runtime boundaries.
2. Read the repository-local source map declared by that `AGENTS.md`, in the
   order and at the paths it declares.
3. Read the accepted plans and references linked by that local source map, then
   classify the current phase under the repository's authority.
4. Verify the actual repository, worktree, branch, HEAD, status, staging, and
   relevant process state.

Treat accepted documents and actual state as authoritative. Do not reconstruct
authority from conversation memory, task titles, or context compression.

## Establish Evidence And Authority

Before asserting a concrete repository fact about a URL, port, command,
environment or deployment target, configuration, or live runtime or process
state, inspect the applicable canonical repository source. Identify the
supporting path and evidence, distinguish a configured default from documented
usage and current observed state, and say that the fact is unknown when it is
not verified. Do not infer such facts from conventions, defaults, memory, or a
similar repository.

An incident correction normally creates no persistent governance change.
Before persisting a change, classify it as a canonical fact, configuration,
reference, skill, test/script hook, or the only essential always-loaded
invariant. Do not propose or edit `AGENTS.md` for an incident without explicit
Director authorization; preserve its line and byte budget by consolidating or
replacing rather than appending. Do not copy incident wording into authoritative
commands.

Planning may report observations and evidence, but does not recommend,
approve, or redefine canonical Codex Work Mode. A transcript or report is
evidence rather than authority. Strategy owns cross-repository Codex Work Mode
policy decisions, and the Director accepts them. After a Strategy decision,
Planning may document frozen repository-local criteria and route ordinary work
without redesign.

## Route The Work

- Route ordinary repository work as `Planning -> authoritative Control A/B ->
  one ephemeral Implementer`.
- Route cross-repository contract, architecture, sequencing, or authority as
  `Planning -> Strategy -> affected Planning`.
- Ask Strategy for a task-lifecycle action only when no authoritative Control
  exists, an idle Control requires Thread Refresh, or genuinely independent
  work requires the other Control slot.
- Send Strategy a Planning message only for a cross-repository decision that
  affects another repository's Planning task, a Strategy-owned task-lifecycle
  action, or changed evidence requiring re-evaluation of a registered
  cross-repository gate. A cross-repository decision request identifies the
  source and affected Planning tasks and repositories, exact unresolved
  decision, why local authority cannot decide it, evidence, and requested
  Strategy outcome. A registered-gate re-evaluation identifies the gate ID,
  prior Strategy disposition, changed evidence, requested re-evaluation, and
  affected Planning task.
- Keep local plan freezes, acceptance results, phase status, cleanup,
  closeout, housekeeping, checks, repository state, terminal-idle reports, and
  deferred local next actions in repository Planning. Local Control terminal
  packets go only to authoritative Planning, and Planning receipts only to the
  source Control; neither is copied or summarized to Strategy. Local completion
  reaches Strategy only through a registered gate with changed evidence and a
  named requested Strategy decision.
- For a local-only packet misrouted to Strategy, take no substantive action.
  If a response is required, use exactly: `Route this packet to the local
  Planning owner.` Do not record, re-dispatch, reason about, or create a
  lifecycle action from the packet. This rejection is not a blocker, incident,
  plan, or `AGENTS.md` change. Temporary read-only Strategy discussion remains
  available only while the Director actively uses Strategy for that surface;
  it never admits local completion or status packets.
- Keep Control A and Control B independent. Neither slot depends on the other
  being active.
- Name the two stable slots `Control A` and `Control B`.
- Keep Strategy out of ordinary repository implementation dispatch and keep
  Controls out of cross-repository architecture coordination.

## Plan And Dispatch

Planning writes and commits the accepted plan on canonical `main`, records its
identified acceptance criteria as immutable, and sends the plan and criteria
directly to the authoritative Control. Planning does not select the
implementation branch, record the immutable implementation packet, or monitor
the Implementer.

After Planning writes and commits the accepted plan with identified acceptance
criteria, its next ordinary action is direct delivery to that Control. It does
not write another accepted plan for unchanged criteria,
receive intermediate repair or status packets, or compose an implementation
packet. Control composes the implementation packet and sends Planning one
terminal packet, followed by the paired receipt.

After a Control is authoritative, Planning sends ordinary repository work directly to it.

Control verifies the frozen plan, selects the branch/worktree, execution mode,
model and reasoning, exact owned paths, checks, blocked surfaces, and required
evidence. Control then freezes exactly one packet using the repository-local
implementation packet template and dispatches one ephemeral Implementer by
default.

Treat the frozen plan and packet as authority for ordinary, reversible,
in-scope implementation choices. Report `blocked` only when a required
condition is actually unmet and prevents safe or truthful completion. Name the
first prevented action and its evidence. Do not invent requirements, broaden
readiness, or replace an execution attempt with procedural speculation.

## Implement And Supervise

The Implementer receives the packet rather than Control's full conversation. It
edits only owned paths, runs the required checks, and sends its result directly
to Control. It does not stage, commit, merge, push, deploy, resolve approvals,
access secrets, mutate external systems, broaden the packet, or spawn another
agent.

Control remains active while its ephemeral Implementer is active. Observe
activity and useful progress updates, then wait for the direct result. Do not
use supervision to edit implementation, repeatedly inspect partial diffs,
widen the packet, or interrupt merely for status.

An observed conformance defect or failed required check within unchanged frozen
criteria is a Control-owned bounded repair finding. Control records the attempt
identity and evidence, freezes one new repair packet, and keeps at most one
ephemeral Implementer active. The repair packet names the observed failure,
direct mechanism, owned paths, checks, and why the plan is unchanged; it is not
an unchanged retry or speculative hardening. `planning_design_gap` applies
only when the remedy requires an accepted semantic, ownership, phase,
acceptance-criteria, or authority change—not insufficient diagnostics, missing
direct proof, a conformance omission, or a repairable implementation defect.

## Review And Integrate

Review only for frozen-plan conformance, required checks, authority boundaries,
and concrete observed failures of required behavior. Do not reopen accepted
planning or add hypothetical acceptance cases.

On acceptance, Control reruns required checks, stages, commits, and locally
integrates the accepted implementation. A bounded repair finding is nonterminal:
Control sends no packet to Planning until it has an accepted frozen outcome, a
true planning design gap, a Director decision or authority, or no
evidence-backed direct repair remaining. It then prepares one immutable terminal
packet and sends it directly to authoritative Planning. It contains:

- implementation agent and model/reasoning;
- repository, worktree, branch, base HEAD, and final HEAD;
- decision, changed paths, checks, and accepted commit when applicable;
- final status and staging;
- first blocker when applicable; and
- authority-boundary confirmation.

The terminal packet also identifies itself, its implementation attempt, its
source Control and target Planning tasks, one continuation disposition
(`accepted_frozen_outcome`, `true_planning_design_gap`,
`director_decision_or_authority`, or
`no_evidence_backed_direct_repair_remaining`), and next owner/action. Control
records the direct task-message acknowledgement and waits for Planning's direct
receipt. Planning receipts pair every terminal disposition with
`released_terminal_idle`. A local bounded repair requires a new implementation
attempt and has no Planning-facing terminal packet. Retried delivery or receipt
reuses its identity;
the same identity with different payload is rejected. A printed self-final
packet or Director copy/paste is not direct delivery.

Terminal packet delivery and `released_terminal_idle` finish one Control
packet; neither proves its parent complete. Before ending its turn after the
paired receipt, Planning classifies the parent. When the parent is incomplete
and a known repository-local next action is already authorized, Planning
writes or selects the exact continuation authority and sends it directly to
the authoritative Control. It may not end the turn with `active_packet: none`
unless it records the exact missing decision and owner. Repository-local
sequencing stays between Planning and Control; Strategy is not a relay or
second-opinion hop for it.

Use **send** for results, evidence, status, and packets. Use **handoff** only for
an intentional continuity transfer.

## Select Models

- Strategy: `gpt-5.6-sol` with xhigh reasoning for frontier cross-repository
  architecture, sequencing, model-policy, new-contract, and authority decisions.
  This low-volume, high-consequence role uses added exploration and verification,
  but still rejects repository-local status, cleanup, receipts, and evidence-only FYI.
- Planning: `gpt-5.6-sol` with high reasoning for first-principles repository
  reasoning, semantic plans, and immutable acceptance criteria. Planning does not self-escalate to xhigh; cross-repository, new-contract, model-policy, and
  task-lifecycle work goes to Strategy.
- Control: `gpt-5.6-terra` with high reasoning by default; use Sol/high only
  with Strategy authorization for a demanding contract or high-risk acceptance
  review.
- Normal ephemeral Implementer: `gpt-5.6-terra` with medium reasoning.
- Deeper bounded ephemeral Implementer: `gpt-5.6-terra` with high reasoning
  only when the packet demonstrates semantic or implementation complexity.

Packets involving transactional persistence, multi-relation or schema migration,
replay/idempotency, concurrency, rollback, destructive cleanup, or shared
retained-state mutation are deeper bounded work and require Terra/high. A
Strategy-authorized Sol/high Control may review high-risk acceptance.
- Persistent Handoff, certified mechanical: `gpt-5.6-luna` with medium
  reasoning.
- Persistent Handoff, normal: `gpt-5.6-terra` with medium reasoning.
- Persistent Handoff, deeper bounded: `gpt-5.6-terra` with high reasoning
  only when the packet demonstrates semantic or implementation complexity.

Control selects the lowest sufficient configuration from the frozen packet. A
rejection alone never justifies raising model or reasoning; Control must justify
Terra/high from newly explicit packet complexity. Model tier and reasoning effort
are separate selections; neither implies the other. Every task creation, Thread
Refresh, and implementation packet records its exact model, reasoning, and
applicable rationale class. A mismatch is a readiness/configuration defect.

Before a protected or shared persistent-state invocation, Control proves the
complete source path at a database-free or fake boundary: every planned failure
stage at the public command boundary, exact allowed output, atomicity or
rollback, idempotency/replay/conflict behavior, and no private leakage. The
diagnostic stage taxonomy is complete before protected invocation; it is not
extended one live failure at a time when database-free stage testing is
available. Prefer a disposable isolated candidate target. A shared retained
target requires a separately authorized exact command and a frozen target
identity, preconditions, atomicity, rollback or cleanup, postconditions, and an
uncertain-outcome fence. A candidate may not leave unaccepted state unfenced;
an uncertain result is `reconciliation_required` and is never blindly retried.
Human or user command output is evidence for Control review, not automatic
acceptance or permission for a follow-on command.

## Use Registered Protected Validation

Separate Director authority approval from protected validation execution. A
Director-approved registered protected-validation policy authorizes repeated
Control submissions only when their manifests match exactly. The policy names
its stable identity and version, repository and target class, validator identity
and immutable digest, command or argv identity, worktree and commit rule,
credential owner and injection mechanism, typed safe receipt schema and keys,
side-effect and concurrency classes, nonce/idempotency/replay rule, expiry or
revocation, preconditions, postconditions, and uncertain-outcome fence.

A trusted local credential-bearing validator, never Planning or the Director,
holds and injects the credential, verifies the manifest, consumes one one-use
nonce, executes once, suppresses private output, and returns only the typed
safe receipt plus public status. Control may submit and supervise an exact match
without receiving or emitting a secret. Strategy or the Director is needed only
to create, change, or revoke policy; approve a nonmatching target, command, or
side-effect class; authorize uncovered destructive, production, or external
work; or resolve an uncertain outcome. An unregistered policy, unavailable
validator, or unavailable tool is `protected_validator_unavailable`; do not ask
the Director to run a command or paste a receipt. A Director may choose one-off
execution, but it is never the default. Human-provided output remains evidence,
not follow-on authority.

## Name Immutable Artifacts Precisely

Use “freeze” in active prose only to describe immutability of an identified
artifact in the same statement. State the actual action instead: write and
commit the accepted plan, record acceptance criteria as immutable, Control
records the immutable implementation packet, approve the policy, or send the
packet. Machine identifiers such as `accepted_frozen_outcome` and historical
evidence remain unchanged.

Cleanup, rollback, reconciliation, diagnostic, and readiness work may accept a
subslice but cannot rename or complete its parent phase. Parent acceptance
requires affirmative proof of every completion criterion. Snapshots and the
roadmap state the accepted subslice, incomplete parent, exact current gate, and
next owner/action. Cleanup success proves baseline restoration only.

## Use Exceptional Handoff And Thread Refresh Sparingly

Request a persistent Handoff only for durable independent continuity such as
multiple implementation rounds, extended waiting, approval-sensitive pauses,
or separately inspectable high-blast-radius history. Difficulty alone does not
qualify. Strategy creates it for one packet; Control remains the sole reviewer.
This eligibility is established before model selection. Model availability,
cost, mechanical simplicity, or a desire to use Luna never qualifies a
persistent Handoff.

Use Strategy-owned Thread Refresh for durable task replacement. Before any
creation, transfer, archive, or workspace migration, read the exact procedure
and idle gate identified in the repository-local source map. Never infer
archive authority from terminal idleness; Control archival also requires a
separate explicit Director instruction and a current snapshot record.

Thread Refresh requires evidence that the authoritative task cannot perform
its role. Normal terminal idleness, stale initialization prose, or the absence
of a next packet are not that evidence. An incomplete parent with a known
authorized local next action instead requires direct Planning-to-Control
continuation.

A Control may be replaced only through Strategy-owned Thread Refresh and only while the Control is idle.
Idle means no active Implementer or Handoff, pending review or integration,
unresolved approval or callback, unsent or unacknowledged direct terminal
delivery, absent direct Planning receipt, missing continuation or next
owner/action, or required Control continuation.
Control archival requires a separate explicit Director archival instruction and a current snapshot record.
For workspace migration, Inventory or task API state alone is not sidebar proof.
Reconcile it with a current direct sidebar inspection or screenshot.
