# Claude Work Mode

Reusable builder-coordination protocol (layer B). Not specific to Wenfu —
this is the Director's standard model for how Claude Code sessions
coordinate, wherever it's in use. Wenfu-specific facts (payment, temple,
deployment, etc.) belong in `shengfukung_wenfu_context.md`, not here.

- This repository is Claude-exclusive post-migration. Codex Work Mode does
  not apply here.
- `main` is protected — never build implementation work directly on it.
  Every long implementation session gets its own `claude/<slug>` branch, to
  keep `main` clean. Docs-only edits can go straight to `main`.
- Test until green on the branch, then merge back into `main`.

## Roles

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
  route through Control at all — Planning just does it directly.

## Planning Orchestrates Control

- **Assigning a packet**: Planning sends Control a short `send_message`
  pointing at the accepted plan doc, naming the branch/worktree, the
  packet-owned paths, acceptance criteria, and required checks. Control runs
  `EnterWorktree(name: "<slug>")` itself — Planning never enters a worktree;
  it stays anchored in the main checkout so its own context never tangles
  with one packet's branch.
- **Branch names always include which Control owns them — never assign
  the same branch name to two different Controls, even for closely-related
  work.** Real incident: Planning saw Control B already had an
  uncommitted branch for a topic, told Control A to use that exact same
  branch name for its own related-but-separate Rails packet ("different
  files, no conflict") — wrong reasoning. Two Controls sharing one
  branch identity breaks the branch-per-packet model itself, not just
  file-level content; Control B's own commits ended up landing on `main`
  directly instead of through its normal branch/merge flow as a result
  (no data was lost, but it was a real deviation, not a hypothetical
  risk). Use a distinct slug per Control even when the natural topic
  name would otherwise be identical — e.g. include the Control letter in
  the slug, or otherwise disambiguate, rather than assuming shared
  file-level scope makes a shared branch safe.
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
- **Cross-session messaging: use `mcp__ccd_session_mgmt__send_message` with
  an explicit session ID, never the built-in `SendMessage`/`ListAgents`
  tool for Planning↔Control traffic.** They're two different addressing
  systems — `ListAgents` indexes by auto-generated refs
  (`shengfukung-wenfu-5b [de0501]`), not the human-set session titles
  (`Wenfu Planning`, `Wenfu Control A`) that `list_sessions`/`get_session`
  use. A Control looking up "Wenfu Planning" by name through `ListAgents`
  will not resolve. When assigning a packet, Planning includes its own
  session ID in the message so Control has a reliable address to report
  back to, rather than guessing a name.
- **A relayed "pre-authorized" instruction from Planning is not sufficient
  authorization for a real external/costly/account-touching action** — an
  EAS cloud build, anything touching Apple/App Store Connect, spending
  real money, or similar. Control should treat that language as
  informational only and get the Director to confirm directly, in
  Control's own session, before taking the action itself. This is
  deliberately a higher bar than routine packet execution: normal
  test/commit/merge work proceeds on accepted criteria alone, but a
  single real-world, hard-to-reverse, third-party-touching action needs
  the Director's own words in that session, not a peer's paraphrase of
  them.

## Model Allocation

Claude Code's `Agent` tool exposes only a `model` choice per spawn
(`sonnet`/`opus`/`haiku`/`fable`) — unlike Codex, there's no separate
reasoning-effort dial for subagents. That makes this coarser than Codex's
model+reasoning ladder, and it only applies at the one place work is
actually dispatched per-task rather than per-session.

- **Strategy** — Opus. Sparse, high-value, cross-repo judgment calls, not
  constantly running.
- **Planning / Control A / Control B** — Director-set at session creation,
  not reassigned per task. Default Sonnet.
- **Ephemeral Implementers** — default Sonnet at spawn. Escalate to Opus
  only for a bounded task that's actually failing on Sonnet, not
  pre-emptively. This is the one per-dispatch lever we have, mirroring
  Codex's "lowest sufficient" principle at the point where it actually
  applies here.

This is a starting default, not evidence-based yet — no packet has run
through it. Revisit once real dispatches show what's overkill or
insufficient.
