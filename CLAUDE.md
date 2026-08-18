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
