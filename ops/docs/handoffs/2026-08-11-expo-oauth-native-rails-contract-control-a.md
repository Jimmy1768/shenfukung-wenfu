# Expo OAuth Native Rails Contract — Control A Implementation Packet

## Identity

- Accepted plan and immutable criteria:
  `/Users/jimmy1768/Projects/shengfukung-wenfu/ops/docs/plans/EXPO_OAUTH_NATIVE_RAILS_CONTRACT_PLAN.md`.
- Readiness evidence (read-only):
  `/Users/jimmy1768/Projects/shengfukung-wenfu/ops/docs/handoffs/2026-08-11-expo-oauth-integration-readiness-control-b.md`.
- Dependent client plan (not dispatch authority):
  `/Users/jimmy1768/Projects/shengfukung-wenfu/ops/docs/plans/EXPO_OAUTH_NATIVE_CLIENT_PLAN.md`.
- Control task and authority state: Wenfu Control A
  `019fc08d-676b-7ca2-be32-3efe42fa2fca`, active and authoritative.
- Repository, worktree, branch, and base HEAD:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`;
  `/private/tmp/shengfukung-wenfu-expo-oauth-native-rails-contract`;
  `codex/expo-oauth-native-rails-contract`;
  `a75dae85eba98135174260688a9fcfb1be283bd5`.
- Immutable packet identity and implementation attempt:
  `wenfu-control-a-expo-oauth-native-rails-contract-attempt-1`.

## Scope

- Objective: Implement only the accepted Rails signed-out account-native Google/Apple OAuth start/exchange contract. Use a purpose-bound five-minute signed transaction, required S256 PKCE, fixed server-selected return URL, central one-time exchange, existing resolver/terms/profile semantics, and existing account-scoped native session issuance.
- Exact owned editable paths:
  - `rails/config/routes.rb`
  - `rails/app/controllers/api/v1/account/native_oauth_controller.rb` and only the existing native base/session controller path if a narrow shared native response helper is directly required
  - `rails/app/services/auth/native_oauth_transaction.rb`, `rails/app/services/auth/native_oauth_flow.rb`, and only the minimum existing `rails/app/services/auth/central_oauth_client.rb`, `rails/app/services/auth/oauth_identity_resolver.rb`, or `rails/app/controllers/auth/central_oauth_controller.rb` extraction required to reuse central-response normalization without altering browser behavior
  - `rails/app/lib/app_constants/oauth.rb` only for nonsecret fixed native OAuth configuration
  - new focused tests under `rails/test/integration/account/api/native_oauth*_test.rb` and `rails/test/services/auth/native_oauth*_test.rb`; existing native-session, resolver, and browser OAuth test paths only when direct regressions require them.
- Explicitly excluded: Expo/mobile, Vue, Planning documents, SourceGrid Labs and its runtime, provider account/console/credentials/secrets, live OAuth, identity list/link/unlink, Facebook/admin OAuth, payments, build/Metro/EAS/device, deployment, production, push, and all external mutation.
- Required checks/evidence:
  - Stubbed central-client request/service tests for Google and Apple start/exchange; fixed return URL and exact S256 arguments.
  - Signed transaction tamper, expiry, wrong-temple/provider, changed return URL, verifier mismatch, and replay/duplicate-exchange failure without a session.
  - Existing identity resolver outcomes, profile-required signal, closed-account protection, dual-role account-only JWT scope, account-safe redaction, and browser/email native-session regressions.
  - Routes, Ruby syntax, focused Rails suite, relevant existing regression suite, and `git diff --check`.
- Evidence status: plan/readiness are documented; exact base and clean canonical state observed; SourceGrid central auth is read-only contract authority; no local blocker observed.

## Incident-Correction Placement

- Incident correction: no. This is the accepted bounded Rails contract phase.
- Selected surface: bounded Rails routes/controllers/services/configuration/tests only.
- `AGENTS.md` excluded: no governance change or Director authorization.

## Repair And Terminal Boundary

- Bounded nonterminal repair within unchanged criteria: no.
- Planning packet prohibited until one terminal disposition: yes.

## Handoff Eligibility And Implementer Dispatch

- Persistent Handoff requested: no; eligibility was assessed before model selection and no exceptional continuity need exists.
- Selected ephemeral model/reasoning: `gpt-5.6-terra/high`.
- Deeper-bounded rationale: signed expiring transaction semantics, S256 verifier binding, one-time/replay failure behavior, and reuse of shared identity/session/account authority require careful multi-path conformance evidence.
- One ephemeral Implementer task: `/root/expo_oauth_native_rails_contract`.
- Return destination: this Control directly.
- Implementer boundaries: owned paths only; no staging, commit, merge, push, deploy, approval handling, secret/provider access, external mutation, or scope expansion.

## Control Review And Closeout

- Review strictly against the accepted endpoint/session/identity/redaction criteria and exclusions.
- Control independently reruns required checks, stages, commits, and locally integrates only an accepted result onto then-clean canonical `main`.
- Send one terminal packet directly to Wenfu Planning
  `019fea6a-c481-75d1-b9d8-6aea367ca5b6`, then wait for its paired
  `released_terminal_idle` receipt. The dependent Expo client plan remains unauthorized unless Planning separately dispatches it.
