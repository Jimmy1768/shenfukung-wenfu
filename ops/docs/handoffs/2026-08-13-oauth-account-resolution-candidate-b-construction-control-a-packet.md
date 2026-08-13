# Control Packet — OAuth Account Resolution Candidate B Construction And Review

## Identity

- Accepted-plan path and immutable criteria: `ops/docs/plans/OAUTH_ACCOUNT_RESOLUTION_CANDIDATE_B_CONSTRUCTION_PLAN.md` at canonical base `776ace4358791ed58ea15099c3275dfc374d31fa`.
- Control task and authority state: Wenfu Control A `019fc08d-676b-7ca2-be32-3efe42fa2fca`; direct Planning dispatch; local-only Candidate B construction/review.
- Repository, worktrees, branches, and bases:
  - canonical evidence worktree: `/private/tmp/shengfukung-wenfu-oauth-account-resolution-candidate-b-control`, `codex/oauth-account-resolution-candidate-b-control`, base `776ace4358791ed58ea15099c3275dfc374d31fa`;
  - retained candidate worktree: `/private/tmp/shengfukung-wenfu-oauth-account-resolution-candidate-b`, `codex/oauth-account-resolution-candidate-b`, base `99a0a6929c5cb0eace21d5fa074cdab3950b269c`.
- Packet status and date: immutable before implementation; 2026-08-13 Asia/Taipei.
- Immutable packet identity and implementation attempt: `wenfu-control-a-oauth-account-resolution-candidate-b-construction-attempt-1`.

## Scope

- Objective: mechanically apply exactly the five Director-accepted source commits, in order, onto the retained release-derived candidate; independently prove source/patch equivalence, Rails-only boundary, guarded migration compatibility/integrity, and regressions; record sanitized evidence only.
- Candidate source commits, in order: `684c9efcd43127b07281fe0bf67d4932f98e0ef2`, `740aa39bb38806d2207636bb391167c2fee6a9b1`, `7fa60f01a05e009a2722c55b878e013acccd4473`, `6eb57c3563d39a24f29e753866c3f030287ab84f`, `dcc258b8e97e3c48803c6eb292a592ee6d990371`.
- Exact owned editable path: `ops/docs/handoffs/2026-08-13-oauth-account-resolution-candidate-b-construction-control-a-report.md` in the canonical evidence worktree. The retained candidate receives only clean exact cherry-picks by Control and no manual source edit or extra commit.
- Explicitly excluded: canonical `main` source/product changes; `mobile/`, `vue/`, payment, provider/Central Auth, public assets, deployment/release references, environment/secrets, production/SSH/network, user 22/keeper records, and every shared/default/development database.
- Required checks and evidence: construction/five-commit source mapping and patch equivalence; Rails-only paths; `git diff --check`; guarded disposable migration up/rollback/forward and duplicate-index stop; full Rails and named focused regressions; syntax/routes; disabled feature-gates/non-routed consolidator/no generic email/name/relay linking scans; candidate/canonical cleanup and clean staging.
- Database fence: every Rails/schema/fixture/test write uses `RAILS_ENV=test` and packet-owned disposable PostgreSQL names beginning `oauth_candidate_b_`; both configured name and `current_database()` must equal the declared name immediately before every write. `golden_template_dev`, `golden_template_test`, production, and all shared/default databases are prohibited. A guard failure stops; no alternate target may be tried.
- Evidence sources and status: accepted plan/documented; exact commits and release baseline/observed locally; production/provider/account state/unknown and not observed.
- First blocked surface: none known.

## Incident-Correction Placement

- Is this an incident correction? no; this is a local construction/review phase.
- Selected surface: immutable Control packet and report only; no persistent governance change.
- `AGENTS.md` excluded; no Director authorization for an edit.

## Repair And Terminal Boundary

- Is this a bounded nonterminal repair within unchanged immutable criteria? no.
- Failed attempt identity and evidence: none.
- Planning packet prohibited until a terminal disposition: yes.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no.
- Eligibility confirmed before selecting a model: yes; no continuity exception exists.
- Luna disqualifiers checked: Luna is never ephemeral; availability/cost/mechanical simplicity/rejection do not qualify.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra/high`.
- Selection reason and lowest-sufficient configuration: exact migration construction, rollback/forward proof, synthetic uniqueness failure, full Rails regression, and retained candidate/database isolation are deeper bounded transactional/schema work.
- Ephemeral allocation: `gpt-5.6-terra/high` with the explicit immutable-packet complexity rationale above.
- One ephemeral Implementer task: construct and review evidence only, returning directly to this Control.
- Return destination: this Control directly.
- Implementer boundaries: may run only the packet-described local guarded commands and write the one report path; may not stage, commit, merge, push, deploy, access secrets/providers, make external calls, inspect production, alter canonical/candidate source, or expand scope.

## Control Review And Closeout

- Conformance review: exact committed plan criteria only.
- Acceptance: accepted after independent exact patch-hash/source-map review, Rails-only cumulative boundary review, clean candidate review, and the Implementer's complete guarded migration, integrity, regression, syntax, route, flag, scan, diff, and cleanup evidence.
- Integration: Control commits only this packet/report documentation onto canonical `main`; the release-derived candidate remains local, inactive, and unmerged.
- Immutable terminal: direct to Wenfu Planning `019fea6a-c481-75d1-b9d8-6aea367ca5b6`, implementation attempt 1, with one continuation disposition.
- Paired Planning receipt: `released_terminal_idle`.
- Authority confirmation: no release/current movement, production/provider/account/deployment/external action, source repair, or public-asset work is authorized.
