# Wenfu Codex Work Mode Reference

## Scope

Codex Work Mode is builder governance for this repository only. It does not
change Wenfu product/runtime semantics, product phases, or the separate
authorization required for payment/provider, deployment, secret, account, or
production-data work.

## Local Contract

Use the source map in `AGENTS.md` and the reusable procedure in
`$codex-work-mode`. Wenfu's ordinary route is:

```text
Planning -> authoritative Control A/B -> one ephemeral Implementer
```

Strategy receives task-lifecycle requests only when no authoritative Control
exists, a Control needs Thread Refresh, or genuinely independent work needs
Control B. Cross-repository contract, architecture, sequencing, and authority
questions route:

```text
Planning -> Strategy -> affected Planning
```

Controls do not coordinate cross-repository architecture directly. A persistent
Handoff is an exceptional, recorded-reason, one-packet continuity mechanism;
the default Implementer returns evidence directly to its Control.

## Evidence, Authority, And Allocation

Evidence precedes concrete repository URL, port, command, environment,
deployment, configuration, or live-process assertions. Name the canonical
source and distinguish configured, documented, observed, and unknown state.
Incident correction normally creates no persistent governance: use the proper
configuration, reference, skill, or test-hook surface. An `AGENTS.md` incident
edit requires explicit Director authorization.

Planning may report evidence, but cannot recommend, approve, or redefine
canonical Codex Work Mode. Strategy owns cross-repository policy and the
Director accepts it. Active allocation is Strategy `gpt-5.6-sol/high`, Planning
`gpt-5.6-terra/high`, and Control `gpt-5.6-terra/high`; Sol/high for Control
requires exceptional Strategy authorization. Normal ephemeral Implementers are
`gpt-5.6-terra/medium`; deeper bounded work requires a justified
`gpt-5.6-terra/high`. Luna is never an ephemeral Implementer and legacy 5.5 is
not an active allocation.

Persistent Handoff eligibility comes before model selection and is limited to
exceptional recorded continuity. Only after eligibility may certified
mechanical work use `gpt-5.6-luna/medium`; otherwise use Terra medium or,
where justified, Terra high. Luna availability, cost, mechanical simplicity,
or rejection never creates a Handoff or changes the allocation.

## Local Records

Control uses `ops/docs/handoffs/templates/codex_control_implementation.md` to
freeze a bounded packet. `ops/protocol/codex_work_mode.yml` is the deterministic
local contract, and `ops/docs/handoffs/codex_work_mode_current.md` is the
volatile local coordination and roadmap pointer record. Preserve historical
records; where a record exists, use pointer-only chat with its absolute path.
