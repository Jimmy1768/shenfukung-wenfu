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
- `ops/docs/plans/EXPO_ACCOUNT_NATIVE_INTEGRATION_PLAN.md`
- `ops/docs/reference/future_work.md`

The Expo readiness scan remains the gap inventory. Both parallel V1 inputs are
now accepted and terminal: Track A at `740aa39bb38806d2207636bb391167c2fee6a9b1`
provides the Rails account JSON/native-email contract, and Track B at
`274dd7f763b7d95274a28f5241b0766cbea1d853` provides the Expo infrastructure,
interactive dummy account client, tenant/client interfaces, and local API 36
debug-build evidence. Both Controls received `released_terminal_idle`.

The separate account-native integration phase is complete on canonical `main`
at `6cab3f1b52ebaeaf68667f19a3c804f8d9c43079`. That commit contains the exact
Track A and Track B checkpoint ancestry plus the accepted real local/test
adapter candidate `bccd60f9f3372edfb95bb15d4402da965c5b5281`. The integrated
TempleMate `1.0.0` local source baseline passed the required Rails, mobile,
version/API 36, contract, and offline Expo Doctor checks. Control A and Control
B are both `released_terminal_idle`.

Physical development-client installation was not an integration criterion and
remains deferred. The exact current missing decision belongs to the Director:
whether to open the separately deferred final V1 UI-refinement phase and what
product/UI criteria it must satisfy. No Control packet is active until that
decision. OAuth, payment, live tenant-domain/trust, device execution, EAS
cloud, store/release, deployment, external action, and push remain separately
gated.

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
