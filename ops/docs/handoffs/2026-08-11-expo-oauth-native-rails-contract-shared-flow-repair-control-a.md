# Expo OAuth Native Rails Contract — Shared Flow Repair Packet

## Identity And Finding

- Parent packet: `wenfu-control-a-expo-oauth-native-rails-contract-attempt-1`.
- Repair attempt: `wenfu-control-a-expo-oauth-native-rails-contract-attempt-2-shared-flow`.
- Observed conformance failure: `rails/app/services/auth/native_oauth_flow.rb` reimplements central-response claim extraction, identity resolution, terms acceptance, and profile-required logic already held privately by `Auth::CentralOAuthController`. This does not meet the accepted plan's explicit reuse boundary requiring a minimum shared Rails service that makes browser and native flows use identical normalization, resolver, terms, and profile-required rules.
- The plan and endpoint/authority criteria remain unchanged; this is a bounded local refactor plus regression evidence, not a Planning design gap.

## Exact Repair Scope

- Extract one minimum shared non-browser service from the existing central-controller logic. It must own central-response normalization, provider/subject extraction, existing resolver invocation, terms acceptance, and profile-required classification.
- Change the browser controller and `Auth::NativeOAuthFlow` to use that service without changing browser cookie/admin branching or native account-only session authority.
- Exact owned paths:
  - `rails/app/services/auth/oauth_exchange_identity.rb` (new)
  - `rails/app/services/auth/native_oauth_flow.rb`
  - `rails/app/controllers/auth/central_oauth_controller.rb`
  - `rails/test/services/auth/oauth_exchange_identity_test.rb` (new)
  - `rails/test/integration/account/api/native_oauth_contract_test.rb`
  - only the directly relevant existing browser OAuth test path if required to prove the refactor preserves browser behavior.
- Explicitly excluded: all other parent exclusions, especially routes/configuration changes, Expo/Vue/Planning/SourceGrid, provider access, secrets, external actions, and staging/commit/merge/push by the Implementer.

## Required Evidence

- Google and Apple response normalization—including nested claims/id-token fallback where the existing browser logic supports it—has one shared tested implementation.
- Exact existing identity, verified-email link, first user/profile-required, closed-user, malformed response, and no-sensitive-response/log behavior remain correct in native tests.
- Browser controller still delegates to the shared service and preserves its existing account/admin cookie/session behavior in focused regression evidence.
- Native OAuth transaction/session and existing browser/email/account regressions, Ruby syntax, routes, and `git diff --check` pass.

## Dispatch

- Persistent Handoff: no; new ephemeral Implementer required by repair procedure.
- Selected model/reasoning: `gpt-5.6-terra/high`, justified by shared identity/session authority and behavior-preserving extraction across browser/native paths.
- Return destination: Control A directly. Implementer may not stage, commit, merge, push, deploy, access credentials/providers, or mutate external state.
