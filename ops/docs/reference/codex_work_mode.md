# Wenfu Codex Work Mode Reference

## Scope

Codex Work Mode is builder governance for this repository only. It does not
change Wenfu product/runtime semantics, product phases, or the separate
authorization required for payment/provider, deployment, secret, account, or
production-data work.

## Local Routing And Immutable Artifacts

Use the source map in `AGENTS.md` and the reusable procedure in
`$codex-work-mode`. Ordinary work routes:

```text
Planning -> authoritative Control A/B -> one ephemeral Implementer
```

Planning writes and commits an accepted plan, records its acceptance criteria
as immutable, and sends them directly to the authoritative Control. It does
not record the immutable implementation packet, select implementation details,
receive intermediate repair/status traffic, or monitor the Implementer.
Control records one immutable implementation packet, selects the bounded
implementation details, and dispatches at most one ephemeral Implementer.

Strategy receives a Planning message only for a cross-repository decision
affecting another Planning task, a Strategy-owned lifecycle action, or changed
evidence requiring re-evaluation of a registered gate. Local plan status,
cleanup, closeout, terminal packets, and receipts remain between Planning and
Control. A local-only packet misrouted to Strategy receives exactly:
`Route this packet to the local Planning owner.`

Use “freeze” in active prose only when identifying the immutable artifact in
the same statement. Write and commit an accepted plan, record acceptance
criteria or a Control packet as immutable, approve a policy, or send a packet;
do not use generic active-prose “freeze”.

## Repair, Terminal Packets, And Receipts

An observed conformance defect or failed required check within unchanged
criteria is a Control-owned bounded, nonterminal repair. Control records the
failed attempt and evidence, records an immutable repair packet naming the
direct mechanism and checks, and keeps at most one ephemeral Implementer
active. It sends no Planning packet until an accepted outcome, a true Planning
design gap, a Director authority decision, or no evidence-backed direct repair
remains.

One immutable Control terminal packet identifies its direct delivery,
implementation attempt, source Control, target Planning, continuation
disposition, and next owner/action. Planning sends the paired direct receipt
with `released_terminal_idle`, then classifies the parent and directly
continues known authorized local work. It may not use `active_packet: none`
without recording the exact missing decision and owner.

## Evidence, Protected Validation, And Allocation

Evidence precedes concrete repository URL, port, command, environment,
deployment, configuration, or live-process assertions. Name the canonical
source and distinguish configured, documented, observed, and unknown state.
Incident correction normally creates no persistent governance: use the proper
configuration, reference, skill, or test-hook surface. An `AGENTS.md`
incident edit requires explicit Director authorization.

A protected validation invocation requires a registered immutable policy with
identity/version, repository/target/validator/command/worktree/commit,
credential injection owner, safe receipt schema, side-effect/concurrency,
nonce/replay, expiry/revocation, preconditions/postconditions, and an
uncertain-outcome fence. A trusted local credential-bearing validator—not
Planning or the Director—holds credentials, verifies the manifest, executes
an exact one-use match, and emits only a typed safe receipt. An unavailable
policy, validator, or tool is `protected_validator_unavailable`; human output
is evidence, not follow-on authority.

Planning may report evidence, but cannot recommend, approve, or redefine
canonical Codex Work Mode. Strategy owns cross-repository policy and the
Director accepts it. Active allocation is Strategy `gpt-5.6-sol/xhigh`,
Planning `gpt-5.6-sol/high`, and Control `gpt-5.6-terra/high` by default.
Normal ephemeral Implementers use `gpt-5.6-terra/medium`; Terra/high requires
an explicit immutable-packet complexity rationale. Handoff eligibility
precedes model choice; it remains exceptional, with certified mechanical
`gpt-5.6-luna/medium` only after eligibility. Legacy 5.5 allocation is
absent and Luna is never ephemeral.

## Local Records

Control uses `ops/docs/handoffs/templates/codex_control_implementation.md` to
record a bounded packet. `ops/protocol/codex_work_mode.yml` is the
deterministic local contract, and `ops/docs/handoffs/codex_work_mode_current.md`
is the volatile local coordination and roadmap pointer record. Preserve
historical records; where a record exists, use pointer-only chat with its
absolute path.
