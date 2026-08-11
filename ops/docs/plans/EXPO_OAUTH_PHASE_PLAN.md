# Expo OAuth Phase Plan

Status: separately deferred capability phase; not part of core V1 and not
current implementation authority

Created: 2026-08-11

Owner: Wenfu Planning

Core-track predecessors: `ops/docs/plans/EXPO_ACCOUNT_JSON_API_TRACK_PLAN.md`
and `ops/docs/plans/EXPO_NATIVE_CLIENT_INFRA_TRACK_PLAN.md`

## Objective

Add native Google and Apple account authentication and existing identity
link/unlink behavior only after core email authentication and account parity are
stable. OAuth is not required to build or test core V1.

## Scope Boundary

This phase may include only OAuth behavior already supported by the web account
namespace for the target environment:

- Google/Apple sign-in where configured;
- native initiation and browser/app return;
- state, nonce, PKCE, cancellation, failure, and interrupted-return handling;
- safe native-session exchange through the account-only API boundary;
- identity list/link/unlink with the existing last-login-method protection;
- account signup/linking behavior consistent with existing Rails authority;
- truthful unavailable states when a provider is not configured.

DojoMate may provide native browser-return, state-machine, secure-session, and
test patterns. Wenfu central-auth and account identity rules remain
authoritative.

## External Boundary

- No client secret may be embedded in Expo source or public configuration.
- Local/stubbed contract work does not authorize provider-console changes,
  real credentials, production callback changes, app-store records, or live
  validation.
- Any provider configuration or protected live check requires its own exact
  authority and safe evidence path.

## Immutable Acceptance Criteria

1. OAuth is additive to the accepted email session and does not weaken it.
2. Google/Apple behavior matches the existing web-authorized account identity
   model without adding providers or linking operations.
3. State/nonce/PKCE, cancellation, retry, interrupted return, and failure paths
   fail safely.
4. Link/unlink preserves the last-login-method rule.
5. OAuth tokens grant no admin authority and remain scoped to the validated
   temple account context.
6. No provider secret, production action, deployment, or release action occurs
   without separate authority.

## Current Gate

OAuth is deferred until core email authentication and account parity are
accepted. It is planned separately so provider and deep-link complexity cannot
delay dummy UI or basic account CRUD testing.
