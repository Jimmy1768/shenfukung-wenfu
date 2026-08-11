# Current Wenfu Codex Work Mode Coordination

## Local Coordination

- Ordinary repository route: Planning -> authoritative Control A/B -> one ephemeral Implementer.
- Planning commits an accepted plan, records immutable criteria, and sends them
  directly to Control; it does not select implementation details, receive
  intermediate repair/status traffic, or monitor the Implementer.
- Strategy receives Planning traffic only for cross-repository decisions
  affecting another Planning task, Strategy-owned lifecycle action, or changed
  evidence requiring registered-gate re-evaluation. Local status, cleanup,
  closeout, terminal packets, and receipts stay between Planning and Control.
- A local-only packet misrouted to Strategy receives exactly: `Route this
  packet to the local Planning owner.`
- A Control conformance defect within unchanged criteria is a nonterminal
  bounded repair with an immutable repair packet, direct mechanism, and checks;
  at most one ephemeral Implementer is active. Planning receives no packet
  until terminal disposition.
- One immutable Control terminal packet identifies its delivery, attempt,
  source/target, continuation disposition, and next owner/action. Planning's
  paired direct receipt is `released_terminal_idle`, after which Planning
  classifies the parent and continues known authorized local work. No
  `active_packet: none` is allowed without the exact missing decision/owner.
- Protected validation requires a registered immutable policy and a trusted
  local credential-bearing validator that verifies the manifest, performs one
  exact one-use match, and returns only a typed safe receipt. Missing policy,
  validator, or tool is `protected_validator_unavailable`; human output is
  evidence, not follow-on authority.
- Active allocation: Strategy `gpt-5.6-sol/xhigh`; Planning
  `gpt-5.6-sol/high`; Control `gpt-5.6-terra/high` by default; normal
  ephemeral Implementer `gpt-5.6-terra/medium`. Terra/high requires explicit
  immutable-packet complexity rationale. Handoff eligibility precedes model
  choice; Luna is never ephemeral and legacy 5.5 allocation is absent.
- Current coordination authority and task status are read from the active Codex
  task and its file-backed records; this snapshot is not historical evidence.

## Product-Roadmap Pointers

- `ops/docs/plans/DEPLOYMENT_READINESS.md`
- `ops/docs/plans/DOCUMENTATION_HOUSEKEEPING_AND_FUTURE_WORK_PLAN.md`
- `ops/docs/plans/EXPO_ACCOUNT_APP_READINESS_AND_PARITY_PLAN.md`
- `ops/docs/plans/EXPO_ACCOUNT_JSON_API_TRACK_PLAN.md`
- `ops/docs/plans/EXPO_NATIVE_CLIENT_INFRA_TRACK_PLAN.md`
- `ops/docs/reference/future_work.md`

The Expo readiness scan remains the gap inventory. Core V1 is now divided into
two independent parallel tracks: Control A is intended to own the Rails JSON
and native email-session equivalent of the current non-payment/non-OAuth
account namespace; Control B is intended to own Expo infrastructure,
interactive dummy account screens, tenant/client interfaces, and build/API 36
evidence through an immutable pre-integration checkpoint. Both tracks terminate
and receive `released_terminal_idle` before integration. Planning then
coordinates a separate merging/integration phase through Control A; Control B
does not receive a real-adapter continuation. The Controls do not coordinate
directly. OAuth and payment remain separate deferred phases. Both parallel
implementation dispatches await explicit Director authorization, and EAS cloud
use remains separately gated.

## Current Authorized Documentation Housekeeping

`ops/docs/plans/DOCUMENTATION_HOUSEKEEPING_AND_FUTURE_WORK_PLAN.md` is the
current authorized documentation-only phase through Planning -> Wenfu Control
B. It archives completed plan evidence, refreshes durable references, and
creates the future-work record without changing runtime or activation
authority. It is accepted at `2a5f0efdd3b15ca2578eda69bcde6546e5d7269b`; the
documentation-housekeeping phase is complete.

## Current Codex Work Mode Policy Propagation

`ops/docs/plans/CODEX_WORK_MODE_CURRENT_V1_POLICY_PROPAGATION_PLAN.md` records
the current unchanged-v1 local package and policy propagation. It is the
current authorized builder-governance phase through Planning -> Wenfu Control
B; it is accepted at `9ef996431054f7bacb4765b72b7d04a9e8460a48`. The local
policy propagation and registered gate `codex_work_mode.package.f737dc3.v1`
are accepted. Product/runtime and external boundaries remain unchanged.
