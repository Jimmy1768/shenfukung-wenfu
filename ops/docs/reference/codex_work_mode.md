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

## Local Records

Control uses `ops/docs/handoffs/templates/codex_control_implementation.md` to
freeze a bounded packet. `ops/protocol/codex_work_mode.yml` is the deterministic
local contract, and `ops/docs/handoffs/codex_work_mode_current.md` is the
volatile local coordination and roadmap pointer record. Preserve historical
records; where a record exists, use pointer-only chat with its absolute path.
