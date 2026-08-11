# Expo OAuth Native Rails Contract — Central Invalid-Grant Repair Packet

## Identity And Finding

- Parent packet: `wenfu-control-a-expo-oauth-native-rails-contract-attempt-1`.
- Repair attempt: `wenfu-control-a-expo-oauth-native-rails-contract-attempt-3-invalid-grant`.
- Observed conformance failure: SourceGrid central-auth's typed HTTP 400 JSON `{ error: "invalid_grant" }` currently becomes a message-only `Auth::CentralOAuthClient::RequestError`, and `Auth::NativeOAuthFlow` converts all such errors to generic upstream failure. This violates the accepted failure contract for invalid, expired, and replayed central grants.
- The plan remains unchanged. The existing signed transaction, shared identity authority, session issuance, browser behavior, and all boundaries remain accepted input.

## Exact Repair Scope

- Preserve one safe typed `invalid_grant` classification at `Auth::CentralOAuthClient` without retaining or emitting raw upstream body, credentials, code, verifier, subject, or provider details.
- Ensure a `RequestError` raised by response parsing is not accidentally rewrapped by generic request-error handling.
- Map exactly that safe central classification to `Auth::NativeOAuthFlow::InvalidGrant` and the existing `invalid_oauth_grant` JSON response. Map malformed JSON, network failure, all other HTTP failures, and unrecognized upstream codes to the existing generic safe upstream path.
- Update direct client and native contract tests for exact invalid-grant, consumed/replayed exchange, arbitrary upstream detail redaction, and no additional native session on failure.
- Exact owned paths:
  - `rails/app/services/auth/central_oauth_client.rb`
  - `rails/app/services/auth/native_oauth_flow.rb`
  - `rails/test/services/auth/central_oauth_client_test.rb` (new if needed)
  - `rails/test/integration/account/api/native_oauth_contract_test.rb`
  - only the existing parent packet test paths directly necessary for this mapping proof.
- Excluded: all other source/config/routes/schema changes, Expo/client plan, SourceGrid/provider/secret/network/live OAuth, build/device, payment, deployment, push, and external mutation.

## Required Evidence

- Exact `{ error: "invalid_grant" }` is a safe typed client error and no raw field crosses the client boundary.
- Exact invalid-grant and a replay/consumed exchange return `invalid_oauth_grant`, issue no additional native session, and expose no arbitrary provider detail.
- Nonmatching client error code, malformed JSON, network exception, and generic HTTP failure remain `oauth_exchange_failed` without sensitive content.
- Full parent focused Rails/browser/email/native-session suite, Ruby syntax/routes, redaction scan, and `git diff --check` pass.

## Dispatch

- Persistent Handoff: no. One fresh ephemeral Implementer is required.
- Selected model/reasoning: `gpt-5.6-terra/high`, retained due central error classification at the one-time/replay and native-session boundary.
- Return destination: Control A directly. The Implementer may not stage, commit, merge, push, access provider/secrets/network, or mutate external state.
