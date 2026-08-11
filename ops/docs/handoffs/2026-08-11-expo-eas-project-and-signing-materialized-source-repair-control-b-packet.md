# Expo EAS project/signing preflight — materialized-source repair packet

## Identity And Finding

- Accepted unchanged plan:
  `ops/docs/plans/EXPO_EAS_PROJECT_AND_SIGNING_PREFLIGHT_PLAN.md` at
  `18bf7503e769be2bce7e6c062091ad651ff9216e`.
- Control: Wenfu Control B `019fe020-e92e-7770-984f-b59acd547ab0`.
- Failed first protected command context: P3 in
  `/private/tmp/shengfukung-wenfu-expo-eas-project-signing-preflight/mobile`
  stopped before a project receipt because the fresh isolated worktree has no
  ignored `node_modules` and EAS could not resolve `expo-secure-store`.
- Direct evidence: `git diff --quiet
  b476d42a422f28fbe9918fb8870a93e633486d99
  18bf7503e769be2bce7e6c062091ad651ff9216e -- mobile` passed. The accepted
  camera worktree at
  `/private/tmp/shengfukung-wenfu-expo-temple-qr-camera` is clean at
  `b476d42a422f28fbe9918fb8870a93e633486d99` and contains the materialized
  project-local Expo executable.

## Bounded Direct Remedy

- Use the source-identical, materialized `mobile/` directory only for one
  corrected P3 `CI=1 /opt/homebrew/bin/eas project:info` and one P4
  `CI=1 /opt/homebrew/bin/eas config --platform android --profile development
  --json` invocation.
- Target identity, EAS account/session, commands, allowed safe fields,
  hard-stop prompt fence, redaction, no-mutation postcondition, and signing
  exclusion remain exactly those of the attempt-1 packet. Before each call,
  record its distinct source-identical worktree/commit and safe receipt.
- This is not a retry of P3 in the empty worktree: it is a distinct,
  provenance-proven execution environment with the same tracked `mobile/`
  source. No `yarn install`, source/config/dependency/lockfile edit, build,
  or external mutation is permitted.
- If either invocation prompts, returns a write/selection path, contains
  secret-bearing output, or has an ambiguous outcome, stop as
  `reconciliation_required` without input or retry.

## Scope, Allocation, And Terminal Boundary

- Exact report path remains
  `ops/docs/handoffs/2026-08-11-expo-eas-project-and-signing-preflight-control-b.md`.
  This repair packet and the attempt-1 packet are Control-only records.
- Persistent Handoff requested/eligible: no; Luna disqualifiers checked.
- The sole ephemeral Implementer remains one fresh
  `gpt-5.6-terra/medium` agent, dispatched after Control has sanitized the
  protected receipts. It edits only the report and performs no EAS command.
- Planning receives no message until a terminal disposition. This repair
  changes no plan criterion, source, configuration, or external authority.

## Control Review And Closeout

- Conformance review: accepted. Tracked `mobile/` source was proven identical
  and the materialized worktree yielded one distinct noninteractive P3/P4
  receipt: EAS project not configured, with no input or write.
- Acceptance rationale: the repair supplied a valid local dependency context
  without installing or changing dependencies, and preserved the hard-stop and
  redaction boundaries. The unlinked result is definitive enough to classify
  the next decision without probing a remote project or credentials.
