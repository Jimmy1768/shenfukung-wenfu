#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"
base_commit='4dfc771783be9083b75df7e8f4765ddf921adaa4'

fail() {
  printf 'verify_codex_work_mode_skill: %s\n' "$*" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

require_text() {
  local needle="$1"
  local file="$2"
  grep -Fqx -- "$needle" "$file" >/dev/null || fail "missing required text in $file: $needle"
}

require_contains() {
  local boundary="$1"
  local needle="$2"
  local file="$3"
  grep -F -- "$needle" "$file" >/dev/null || \
    fail "AGENTS boundary missing ($boundary): $needle"
}

require_no_match() {
  local pattern="$1"
  local file="$2"
  ! grep -Eiq -- "$pattern" "$file" || fail "forbidden residue in $file: $pattern"
}

require_unchanged_from_base() {
  local file="$1"
  git diff --exit-code "$base_commit" -- "$file" >/dev/null || \
    fail "must be unchanged from $base_commit: $file"
}

require_file '.agents/skills/codex-work-mode/SKILL.md'
require_file '.agents/skills/codex-work-mode/agents/openai.yaml'
require_file '.agents/skills/codex-work-mode/codex_work_mode_skill_package_manifest.yml'

mapfile -t package_files < <(find .agents/skills/codex-work-mode -type f | sort)
expected_package_files=(
  '.agents/skills/codex-work-mode/SKILL.md'
  '.agents/skills/codex-work-mode/agents/openai.yaml'
  '.agents/skills/codex-work-mode/codex_work_mode_skill_package_manifest.yml'
)
[[ "${package_files[*]}" == "${expected_package_files[*]}" ]] || \
  fail 'skill package must contain exactly its three package files'

[[ "$(shasum -a 256 .agents/skills/codex-work-mode/SKILL.md | awk '{print $1}')" == \
  'aabcf7aa4adb80c75bf4784149aeef242bd57d7ffcb6d88b9d3bbb3c420542fa' ]] || \
  fail 'SKILL.md hash differs from the frozen package'
[[ "$(shasum -a 256 .agents/skills/codex-work-mode/agents/openai.yaml | awk '{print $1}')" == \
  'f79867a4869ff4cc5c6638955346f43d3e84f1c54c7a1d42fa9f1416f50ad007' ]] || \
  fail 'agents/openai.yaml hash differs from the frozen package'

manifest='.agents/skills/codex-work-mode/codex_work_mode_skill_package_manifest.yml'
[[ "$(shasum -a 256 "$manifest" | awk '{print $1}')" == \
  '2b49269f6e86ab12c5aba400ea35fb328c9c98626b6854c80d4a62d493833452' ]] || \
  fail 'manifest hash differs from the frozen package'
require_text 'schema: codex_work_mode_skill_package_manifest:v1' "$manifest"
require_text 'package_ref: codex_work_mode_skill_package' "$manifest"
require_text 'package_version: v1' "$manifest"
require_text 'canonical_provenance:' "$manifest"
require_text '  repository: OperatorKit' "$manifest"
require_text '  seed_commit: fba8b20d3e6f57b2ac97b0536b96bec7b66dd162' "$manifest"
require_text '  package_identity: operatorkit:codex_work_mode_skill_package:v1' "$manifest"
require_text '  - path: SKILL.md' "$manifest"
require_text '    sha256: aabcf7aa4adb80c75bf4784149aeef242bd57d7ffcb6d88b9d3bbb3c420542fa' "$manifest"
require_text '  - path: agents/openai.yaml' "$manifest"
require_text '    sha256: f79867a4869ff4cc5c6638955346f43d3e84f1c54c7a1d42fa9f1416f50ad007' "$manifest"

agents='AGENTS.md'
require_file "$agents"
require_unchanged_from_base 'AGENTS.md'
require_unchanged_from_base '.agents/skills/codex-work-mode/agents/openai.yaml'
require_contains 'builder-governance/product-runtime separation' \
  'builder coordination only; it does not define or change Wenfu product/runtime' \
  "$agents"
require_contains 'sole authorized OperatorKit package exception' \
  'three-file portable package at `.agents/skills/codex-work-mode` is the sole' \
  "$agents"
require_contains 'sole authorized OperatorKit package files' \
  '`codex_work_mode_skill_package_manifest.yml`, `SKILL.md`, and' \
  "$agents"
require_contains 'OperatorKit copy prohibition' \
  'no other OperatorKit source, local path, product/runtime' \
  "$agents"
require_contains 'no-push/deploy/publish/external-mutation safety' \
  'do not push, deploy, publish, mutate external' \
  "$agents"
require_contains 'separately gated ECPay/provider boundary' \
  'Payment-provider work is separately gated. Do not access real ECPay' \
  "$agents"
require_contains 'tenant isolation' \
  'Preserve tenant isolation' \
  "$agents"
require_contains 'owner/admin authority' \
  'owner/admin authority' \
  "$agents"
require_contains 'secret handling' \
  'secret handling' \
  "$agents"
require_contains 'payment/accounting semantics' \
  'payment and accounting semantics' \
  "$agents"
require_contains 'user-work protection' \
  'user-work protections' \
  "$agents"
require_contains 'assisted-onboarding operating model' \
  'assisted-onboarding' \
  "$agents"
for source_path in \
  'AGENTS.md' \
  '$codex-work-mode' \
  '.agents/skills/codex-work-mode/SKILL.md' \
  'ops/docs/plans/CODEX_WORK_MODE_SKILL_MIGRATION_PLAN.md' \
  'ops/docs/plans/CODEX_WORK_MODE_ON_DEMAND_CONTROL_LIFECYCLE_MIGRATION_PLAN.md' \
  'ops/docs/plans/FINAL_WEB_READINESS_AND_EXPO_GATE_PLAN.md' \
  'ops/docs/plans/DEPLOYMENT_READINESS.md' \
  'ops/docs/reference/codex_work_mode.md' \
  'ops/protocol/codex_work_mode.yml' \
  'ops/docs/handoffs/templates/codex_control_implementation.md' \
  'ops/docs/handoffs/codex_work_mode_current.md'; do
  grep -F -- "$source_path" "$agents" >/dev/null || fail "AGENTS source map omits $source_path"
done

source_line() {
  local needle="$1"
  grep -nF -- "$needle" "$agents" | head -n 1 | cut -d: -f1
}

previous_line=0
for source_path in \
  '1. `AGENTS.md`' \
  '2. `$codex-work-mode`' \
  '3. `ops/docs/plans/CODEX_WORK_MODE_SKILL_MIGRATION_PLAN.md`' \
  '4. `ops/docs/plans/FINAL_WEB_READINESS_AND_EXPO_GATE_PLAN.md`' \
  '5. `ops/docs/reference/codex_work_mode.md`' \
  '6. `ops/protocol/codex_work_mode.yml`' \
  '7. `ops/docs/handoffs/templates/codex_control_implementation.md`' \
  '8. `ops/docs/handoffs/codex_work_mode_current.md`'; do
  current_line="$(source_line "$source_path")"
  [[ "$current_line" =~ ^[0-9]+$ && "$current_line" -gt "$previous_line" ]] || \
    fail "AGENTS source map is out of order at $source_path"
  previous_line="$current_line"
done

for required in \
  ops/docs/plans/CODEX_WORK_MODE_SKILL_MIGRATION_PLAN.md \
  ops/docs/plans/CODEX_WORK_MODE_ON_DEMAND_CONTROL_LIFECYCLE_MIGRATION_PLAN.md \
  ops/docs/plans/FINAL_WEB_READINESS_AND_EXPO_GATE_PLAN.md \
  ops/docs/plans/DEPLOYMENT_READINESS.md \
  ops/docs/reference/codex_work_mode.md \
  ops/protocol/codex_work_mode.yml \
  ops/docs/handoffs/templates/codex_control_implementation.md \
  ops/docs/handoffs/codex_work_mode_current.md; do
  require_file "$required"
done

protocol='ops/protocol/codex_work_mode.yml'
require_text 'schema: shengfukung_wenfu_codex_work_mode:v1' "$protocol"
require_text '  ordinary: Planning -> authoritative Control A/B -> one ephemeral Implementer' "$protocol"
require_text '  cross_repository: Planning -> Strategy -> affected Planning' "$protocol"
require_text '  default: ephemeral_implementer_direct_return' "$protocol"
require_text '  persistent: exceptional_recorded_reason_one_packet_continuity' "$protocol"
require_text '  controls_do_not_coordinate_cross_repository_architecture: true' "$protocol"
ruby -ryaml -e 'data = YAML.load_file(ARGV.fetch(0)); abort "invalid protocol schema" unless data["schema"] == "shengfukung_wenfu_codex_work_mode:v1"' "$protocol"
require_text '  committed_frozen_plan_authorizes_routine_local_execution: true' "$protocol"
require_text '  planning_dispatches_or_monitors_implementer: false' "$protocol"
require_text '  control_authors_or_reopens_planning_documents: false' "$protocol"
require_text '  blocker_requires_undeferred_current_frozen_criterion: true' "$protocol"
require_text '  blocker_requires_evidence_first_prevented_action_and_no_independent_continuation: true' "$protocol"
require_text '  deferred_later_client_specific_or_independent_dependency_blocks_current_phase: false' "$protocol"
require_text '  planning_sends_next_frozen_phase_after_accepted_terminal_receipt: true' "$protocol"
require_text '  repeated_director_approval_required_between_routine_local_phases: false' "$protocol"

reference='ops/docs/reference/codex_work_mode.md'
template='ops/docs/handoffs/templates/codex_control_implementation.md'
snapshot='ops/docs/handoffs/codex_work_mode_current.md'
skill='.agents/skills/codex-work-mode/SKILL.md'

require_text 'Before asserting a concrete repository fact about a URL, port, command,' "$skill"
require_text 'usage and current observed state, and say that the fact is unknown when it is' "$skill"
require_text 'An incident correction normally creates no persistent governance change.' "$skill"
require_text 'invariant. Do not propose or edit `AGENTS.md` for an incident without explicit' "$skill"
require_text 'Director authorization; preserve its line and byte budget by consolidating or' "$skill"
require_text 'Planning may report observations and evidence, but does not recommend,' "$skill"
require_text 'policy decisions, and the Director accepts them. After a Strategy decision,' "$skill"
require_text '- Normal ephemeral Implementer: `gpt-5.6-terra` with medium reasoning.' "$skill"
require_text '- Persistent Handoff, certified mechanical: `gpt-5.6-luna` with medium' "$skill"
require_text 'This eligibility is established before model selection. Model availability,' "$skill"

require_text '  state_labels: [configured, documented, observed, unknown]' "$protocol"
require_text '  persistent_governance_default: false' "$protocol"
require_text '  agents_edit_requires_explicit_director_authorization: true' "$protocol"
require_text '  planning_cannot_recommend_approve_or_redefine_canonical_policy: true' "$protocol"
require_text '  strategy_owns_cross_repository_policy: true' "$protocol"
require_text '  director_accepts_cross_repository_policy: true' "$protocol"
require_text '  normal_ephemeral_implementer: gpt-5.6-terra/medium' "$protocol"
require_text '  luna_ephemeral_implementer_allowed: false' "$protocol"
require_text '  gpt_5_5_active_allocation_allowed: false' "$protocol"
require_text '  eligibility_before_model_selection: true' "$protocol"
require_text '  certified_mechanical_after_eligibility: gpt-5.6-luna/medium' "$protocol"
require_text '  luna_availability_cost_mechanical_simplicity_or_rejection_qualifies: false' "$protocol"

require_text '- Evidence sources and status (configured / documented / observed / unknown):' "$template"
require_text '- `AGENTS.md` excluded unless explicit Director authorization is recorded:' "$template"
require_text '## Handoff Eligibility (Before Model Selection)' "$template"
require_text '- Luna disqualifiers checked: availability, cost, mechanical simplicity, and rejection do not qualify:' "$template"
require_text '- Authority confirmation: Planning reported evidence only; Strategy owns any cross-repository policy and the Director accepts it:' "$template"

require_text '  work. Luna is never ephemeral; legacy 5.5 allocation is absent.' "$snapshot"
require_text '- Persistent Handoff eligibility comes before model selection; only eligible' "$snapshot"
require_contains 'committed plan execution authority' \
  'An accepted committed Planning plan is authority for ordinary, reversible,' \
  "$reference"
require_contains 'planning implementer boundary' \
  'or monitor an Implementer. Control owns one implementation packet and cannot' \
  "$reference"
require_contains 'control planning document boundary' \
  'author or reopen Planning documents.' \
  "$reference"
require_contains 'valid blocker boundary' \
  'A blocker is valid only when an undeferred current frozen criterion prevents a' \
  "$reference"
require_contains 'deferred dependency boundary' \
  'Deferred, later, client-specific, or independent external work cannot block an' \
  "$reference"
require_contains 'phase continuation boundary' \
  'receipt, Planning sends the next frozen phase without repeated Director' \
  "$reference"
require_contains 'billing plan snapshot pointer' \
  'FIRST_TENANT_BILLING_ENTITLEMENT_AND_REGISTRATION_GATE_PLAN.md' \
  "$snapshot"

for active_source in "$skill" "$reference" "$protocol" "$template" "$snapshot"; do
  require_no_match 'gpt-5\\.5' "$active_source"
  require_no_match 'ephemeral.{0,80}(luna|gpt-5\\.6-luna)' "$active_source"
done

require_no_match 'Luna is not selected when' "$skill"
require_no_match 'Certified mechanical Implementer' "$skill"

for local_source in AGENTS.md docs/operator/README.md; do
  require_file "$local_source"
  if grep -Eiq 'Control[/ -]Handoff pair|permanent (Control|Handoff)|numbered (Control|builder)' "$local_source"; then
    fail "obsolete permanent-pair authority in $local_source"
  fi
  if grep -Eiq '^## (On-Demand Control Lifecycle|Return Requirements|Model Allocation|Acceptance)$|cross-task terminal|workload-sized heartbeat|Control remains visible and idle' "$local_source"; then
    fail "duplicated reusable workflow section in $local_source"
  fi
done

printf 'verify_codex_work_mode_skill: pass\n'
