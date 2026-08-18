# Shengfukung Wenfu — Claude Code Instructions

These instructions apply to the entire repository.

- Work Mode: Claude Work Mode (below) — no separate skill file yet; this is
  the whole of it for now.
- Repo context: `ops/protocol/shengfukung_wenfu_context.md` — Wenfu-local
  authority, safety, phase, and product/runtime boundaries. Read it before
  any product/runtime-affecting change.

## Claude Work Mode

- This repository is Claude-exclusive post-migration. Codex Work Mode does
  not apply here.
- `main` is protected — never build implementation work directly on it.
  Every long implementation session gets its own `claude/<slug>` branch, to
  keep `main` clean. Docs-only edits can go straight to `main`.
- Test until green on the branch, then merge back into `main`.

### Roles

- **Planning** — the session where the Director and the model actually
  discuss and accept plans. Plans are written to `ops/docs/plans/`; that doc
  is the durable "why," not the chat history.
- **Control A / Control B** — the two "hands" that receive bounded packets
  from Planning, spawn ephemeral Implementers, and integrate results. No
  Track C: a third packet in flight means one of A/B should be closing out,
  not a new one opening.
- The Director rarely prompts Control directly — mostly short
  authorize/proceed. Planning is the one that assigns and coordinates
  Control, not the Director.
- Small, self-contained work (docs edits, one-off fixes) doesn't need to
  route through Control at all — Planning just does it directly, same as
  everything above this section was done.

### Planning Orchestrates Control

- **Assigning a packet**: Planning sends Control a short `send_message`
  pointing at the accepted plan doc, naming the branch/worktree, the
  packet-owned paths, acceptance criteria, and required checks. Control runs
  `EnterWorktree(name: "<slug>")` itself — Planning never enters a worktree;
  it stays anchored in the main checkout so its own context never tangles
  with one packet's branch.
- **Monitoring**: Planning doesn't babysit. Control spawns/monitors its own
  ephemeral Implementer(s) (`Agent` tool, `run_in_background: true`,
  `isolation: "worktree"`) and reports back only at terminal states —
  done-and-merged, or blocked-needs-a-decision. Planning can check
  `list_events` on a Control session anytime without interrupting it.
- **Redirecting Control is checkpoint-based, not an interrupt.** The
  Director rarely pauses a Control mid-run. The normal case: Control reaches
  a natural checkpoint (a bounded step done, or it checks in on its own),
  and only then does Planning/Director decide whether to continue, redirect,
  or switch it to a different packet. This isn't just a preference — it
  matches the mechanics: `send_message` queues rather than interrupts, so it
  lands only after Control's current turn finishes anyway. A mid-flight
  "pause" can't actually stop a live action.
  - **Real-error exception**: if something is actually wrong (a mistake in
    progress, a dangerous action about to happen), send the stop instruction
    immediately rather than waiting for a checkpoint — it will land at
    Control's next tool-call boundary, not sooner, but don't wait to send it.
- **Pause**: Control runs `ExitWorktree(action: "keep")` — worktree and
  branch stay on disk untouched, including uncommitted changes.
- **Resume**: Planning tells whichever Control has capacity to
  `EnterWorktree(path: "<worktree path>")` — addressed by worktree, not by
  whichever Control started it. Either hand can resume a paused packet,
  since the worktree carries the code state and the plan doc carries the
  why. Keep plan docs specific enough that any Control can pick a packet up
  cold.
- **Integration authority stays with Control**: once Planning has accepted a
  packet's criteria, Control tests/commits/merges to `main` without
  re-approval per step. It escalates back to Planning only for a genuinely
  new decision, a scope change, or a blocker it can't resolve alone.
