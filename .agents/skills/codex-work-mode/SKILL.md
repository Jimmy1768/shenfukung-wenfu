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
- Keep Control A and Control B independent. Neither slot depends on the other
  being active.
- Name the two stable slots `Control A` and `Control B`.
- Keep Strategy out of ordinary repository implementation dispatch and keep
  Controls out of cross-repository architecture coordination.

## Plan And Dispatch

Planning writes the accepted plan on canonical `main`, freezes acceptance
criteria, and sends the plan and criteria directly to the authoritative
Control. Planning does not select the implementation branch, freeze the
implementation packet, or monitor the Implementer.

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

## Review And Integrate

Review only for frozen-plan conformance, required checks, authority boundaries,
and concrete observed failures of required behavior. Do not reopen accepted
planning or add hypothetical acceptance cases.

On acceptance, Control reruns required checks, stages, commits, and locally
integrates the accepted implementation. After `accept`, `reject`, or `blocked`,
Control sends exactly one terminal packet to Planning containing:

- implementation agent and model/reasoning;
- repository, worktree, branch, base HEAD, and final HEAD;
- decision, changed paths, checks, and accepted commit when applicable;
- final status and staging;
- first blocker when applicable; and
- authority-boundary confirmation.

Use **send** for results, evidence, status, and packets. Use **handoff** only for
an intentional continuity transfer.

## Select Models

- Strategy: `gpt-5.6-sol` with high reasoning.
- Planning: `gpt-5.6-terra` with high reasoning for deep repository reasoning,
  readiness, plans, and frozen criteria. Cross-repository or new-contract work
  goes to Strategy; Planning does not self-upgrade to Sol.
- Control: `gpt-5.6-terra` with high reasoning by default; use Sol/high only
  with Strategy authorization for a demanding contract or high-risk acceptance
  review.
- Normal ephemeral Implementer: `gpt-5.6-terra` with medium reasoning.
- Deeper bounded ephemeral Implementer: `gpt-5.6-terra` with high reasoning
  only when the packet demonstrates semantic or implementation complexity.
- Persistent Handoff, certified mechanical: `gpt-5.6-luna` with medium
  reasoning.
- Persistent Handoff, normal: `gpt-5.6-terra` with medium reasoning.
- Persistent Handoff, deeper bounded: `gpt-5.6-terra` with high reasoning
  only when the packet demonstrates semantic or implementation complexity.

Control selects the lowest sufficient configuration from the frozen packet. A
rejection alone never justifies raising model or reasoning; Control must justify
Terra/high from newly explicit packet complexity.

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

A Control may be replaced only through Strategy-owned Thread Refresh and only while the Control is idle.
Idle means no active Implementer or Handoff, pending review or integration,
unresolved approval or callback, or unsent terminal packet to Planning.
Control archival requires a separate explicit Director archival instruction and a current snapshot record.
For workspace migration, Inventory or task API state alone is not sidebar proof.
Reconcile it with a current direct sidebar inspection or screenshot.
