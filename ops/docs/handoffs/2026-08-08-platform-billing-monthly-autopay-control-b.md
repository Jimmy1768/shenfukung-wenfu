# Wenfu Control B Implementation Packet — Platform Billing Monthly Autopay

## Identity

- Accepted-plan path and frozen criteria:
  `ops/docs/plans/PLATFORM_BILLING_MONTHLY_AUTOPAY_CORRECTION_PLAN.md`, all
  three phases and six criteria.
- Control task and authority state: Wenfu Control B, operating under the
  Director's direct thread instruction for this bounded local correction; no
  Control A or Planning relay is authorized.
- Repository, worktree, branch, and base HEAD:
  `/Users/jimmy1768/Projects/shengfukung-wenfu`, `main`,
  `99cbdb74060484d4f15693d5cc4075c5c6e8c392`.
- Packet status and date: Implementer returned; Control B accepted and locally
  integrated, 2026-08-08.

## Scope

- Objective: replace the misleading annual presentation of the current
  `NT$10,000` one-time onboarding fee, preserve the paid Stripe onboarding
  flow, clarify automated monthly Stripe collection, and retain the current
  30-day grace/freeze lifecycle.
- Exact owned editable paths:
  - `rails/app/forms/admin/payment_methods_form.rb`
  - `rails/app/views/admin/payment_methods/show.html.erb`
  - `rails/config/locales/admin.en.yml`
  - `rails/config/locales/admin.zh-TW.yml`
  - `rails/test/integration/admin/payment_methods_test.rb`
- Explicitly excluded: models/migrations/schema; statement pricing; monthly
  collector implementation; jobs/timers; controller routes; runtime env files;
  protected credentials; Stripe/ECPay configuration/catalog/accounts; provider
  calls; persistent external payment records; deployment/push; historical
  records; the plan and this packet.
- Required checks:
  - `cd rails && bin/rails test test/integration/admin/payment_methods_test.rb test/services/billing/stripe_payment_method_setup_test.rb test/services/billing/stripe_platform_billing_collection_test.rb test/services/billing/platform_billing_lifecycle_test.rb test/jobs/platform_billing_lifecycle_job_test.rb`
  - `git diff --check`
  - isolated local browser review of `/admin/payment_methods`, with no provider
    credentials or Checkout initiation.
- Evidence baseline: owner page mislabels current `NT$10,000` onboarding as
  annual; local code charges its configured onboarding Price in paid Checkout;
  monthly collector uses monthly Price with `charge_automatically`; lifecycle
  owns a 30-day grace window.
- First blocked surface: none.

## Incident-Correction Placement

- This is a local source correction for misleading pricing/payment-method
  onboarding and creates no governance or external financial state.
- `AGENTS.md` is excluded; no change is needed or authorized.

## Handoff Eligibility (Before Model Selection)

- Persistent Handoff requested: no.
- Eligibility confirmed before selection: yes; one bounded return is expected.

## Implementer Dispatch

- Selected model and reasoning: `gpt-5.6-terra/high` because the packet
  corrects payment-facing presentation while preserving billing invariants.
- One ephemeral Implementer task: implement only the owned paths, retain the
  current onboarding flow, run required tests, and return source/test evidence
  directly to Control B.
- Boundaries: no acceptance, staging, commit, merge, push, deploy, secret
  access, external mutation, scope expansion, plan/packet edit, or additional
  agent.

## Control Review And Closeout

- Conformance review: complete. Control returned a mid-packet correction before
  acceptance when the Director clarified that the current `NT$10,000` is a
  one-time onboarding fee, not a legacy annual charge. The same ephemeral
  Implementer then returned a five-path presentation/test-only candidate.
- Acceptance decision and rationale: accepted. The owner UI accurately
  distinguishes onboarding from monthly autopay, no longer claims annual
  billing, retains the 30-day grace wording, and leaves every provider-facing
  path untouched.
- Implementer evidence: required test suite passed with 19 runs, 121
  assertions, 0 failures, 0 errors, and 0 skips; `git diff --check` passed;
  no path outside the revised packet scope was changed.
- Control verification: reran the same focused suite with 19 runs, 121
  assertions, 0 failures, 0 errors, and 0 skips; `git diff --check` passed.
  Isolated local browser review confirmed the payment-method tab shows the
  one-time `NT$10,000` onboarding fee, monthly automatic collection, and
  30-day grace rule without opening Stripe Checkout or provider links.
- Integration, staging, and commit evidence: Control staged the seven planned
  documentation, implementation, locale, and test paths only after a clean
  owned-path review. Local commit
  `e84ce52ec1a2b4534b689fefab86f2611735ffb4` integrated the accepted candidate
  on `main` with subject `fix(billing): clarify onboarding and monthly autopay`.
- Residual risk and next owner: source is locally accepted. Production Stripe
  catalog, onboarding, and collection remain intentionally unmodified; any
  release or first-tenant operation requires its separate authorized workflow.
- Authority confirmation: the user authorized local code alignment only;
  external billing state remains untouched.
