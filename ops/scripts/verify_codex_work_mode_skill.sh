#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"
base_commit='48b6d00fe38681fa1ca150f9f65e58a3d06f778f'

fail() {
  printf 'verify_codex_work_mode_skill: %s\n' "$*" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

require_text() {
  local needle="$1" file="$2"
  grep -F -- "$needle" "$file" >/dev/null ||
    fail "missing required text in $file: $needle"
}

require_no_match() {
  local pattern="$1" file="$2"
  ! grep -Eiq -- "$pattern" "$file" ||
    fail "forbidden residue in $file: $pattern"
}

require_unchanged_from_base() {
  local file="$1"
  git diff --exit-code "$base_commit" -- "$file" >/dev/null ||
    fail "must be unchanged from $base_commit: $file"
}

skill_dir='.agents/skills/codex-work-mode'
skill="$skill_dir/SKILL.md"
manifest="$skill_dir/codex_work_mode_skill_package_manifest.yml"
descriptor="$skill_dir/agents/openai.yaml"
agents='AGENTS.md'
reference='ops/docs/reference/codex_work_mode.md'
protocol='ops/protocol/codex_work_mode.yml'
template='ops/docs/handoffs/templates/codex_control_implementation.md'
snapshot='ops/docs/handoffs/codex_work_mode_current.md'

for file in "$skill" "$manifest" "$descriptor" "$agents" "$reference" "$protocol" "$template" "$snapshot"; do
  require_file "$file"
done

mapfile -t package_files < <(find "$skill_dir" -type f | sort)
expected_package_files=(
  "$skill_dir/SKILL.md"
  "$skill_dir/agents/openai.yaml"
  "$skill_dir/codex_work_mode_skill_package_manifest.yml"
)
[[ "${package_files[*]}" == "${expected_package_files[*]}" ]] ||
  fail 'skill package must contain exactly its three package files'

[[ "$(shasum -a 256 "$skill" | awk '{print $1}')" == '6547d2aeee198bcc9e16c6f8fb6120f0efd443fe1d39b828ecaff2ca872182ae' ]] ||
  fail 'SKILL.md hash differs from the immutable package'
[[ "$(shasum -a 256 "$descriptor" | awk '{print $1}')" == 'f79867a4869ff4cc5c6638955346f43d3e84f1c54c7a1d42fa9f1416f50ad007' ]] ||
  fail 'agents/openai.yaml hash differs from the immutable package'
[[ "$(shasum -a 256 "$manifest" | awk '{print $1}')" == '0afe96c5f10ad621c720d248e3dcd4d84e98279de62052933b5d250cd8ca623a' ]] ||
  fail 'manifest hash differs from the immutable package'

ruby -ryaml -e '
  data = YAML.load_file(ARGV.fetch(0))
  abort "invalid manifest schema" unless data["schema"] == "codex_work_mode_skill_package_manifest:v1"
  payload = data.fetch("portable_payload")
  abort "manifest payload closure" unless payload.map { |entry| entry.fetch("path") } == ["SKILL.md", "agents/openai.yaml"]
' "$manifest"
ruby -ryaml -e '
  data = YAML.load_file(ARGV.fetch(0))
  abort "invalid protocol schema" unless data["schema"] == "shengfukung_wenfu_codex_work_mode:v1"
' "$protocol"

require_unchanged_from_base "$agents"
require_unchanged_from_base "$descriptor"
require_text 'builder coordination only; it does not define or change Wenfu product/runtime' "$agents"
require_text 'three-file portable package at `.agents/skills/codex-work-mode` is the sole' "$agents"
require_text 'no other OperatorKit source, local path, product/runtime' "$agents"

require_text 'Route ordinary repository work as `Planning -> authoritative Control A/B ->' "$skill"
require_text 'changed evidence requiring re-evaluation of a registered' "$skill"
require_text 'Route this packet to the local' "$skill"
require_text 'Planning owner.' "$skill"
require_text 'bounded repair finding' "$skill"
require_text 'released_terminal_idle' "$skill"
require_text 'active_packet: none' "$skill"
require_text 'protected_validator_unavailable' "$skill"
require_text 'uncertain-outcome fence' "$skill"
require_text 'gpt-5.6-sol` with xhigh reasoning' "$skill"
require_text 'Planning: `gpt-5.6-sol` with high reasoning' "$skill"
require_text 'explicit packet complexity' "$skill"

for file in "$reference" "$protocol" "$template" "$snapshot"; do
  require_text 'Planning' "$file"
  require_text 'immutable' "$file"
done
require_text 'Route this packet to the local Planning owner.' "$reference"
require_text 'released_terminal_idle' "$reference"
require_text 'protected_validator_unavailable' "$reference"
require_text 'gpt-5.6-sol/xhigh' "$reference"
require_text 'not record the immutable implementation packet, select implementation details,' "$reference"
require_text 'affecting another Planning task, a Strategy-owned lifecycle action, or changed' "$reference"
require_text 'Control-owned bounded, nonterminal repair.' "$reference"
require_text 'disposition, and next owner/action.' "$reference"
require_text 'do not use generic active-prose “freeze”.' "$reference"
require_text 'credential injection owner, safe receipt schema, side-effect/concurrency,' "$reference"
require_text 'trusted local credential-bearing validator—not' "$reference"
require_text 'explicit immutable-packet complexity rationale.' "$reference"
require_text 'local_only_packet_misroute_response: Route this packet to the local Planning owner.' "$protocol"
require_text 'local_status_terminal_packets_and_receipts_stay_planning_control: true' "$protocol"
require_text 'planning_selects_implementation_details: false' "$protocol"
require_text 'planning_receives_intermediate_repair_or_status: false' "$protocol"
require_text 'planning_monitors_implementer: false' "$protocol"
require_text 'control_keeps_at_most_one_ephemeral_implementer_active: true' "$protocol"
require_text 'conformance_defect_within_unchanged_criteria_is_nonterminal_bounded_repair: true' "$protocol"
require_text 'repair_packet_requires_attempt_evidence_direct_mechanism_and_checks: true' "$protocol"
require_text 'planning_packet_before_terminal_outcome: false' "$protocol"
require_text 'terminal_packet_identifies_delivery_attempt_source_target_disposition_and_next_owner: true' "$protocol"
require_text 'planning_paired_receipt: released_terminal_idle' "$protocol"
require_text 'active_packet_none_requires_exact_missing_decision_and_owner: true' "$protocol"
require_text 'generic_active_prose_freeze_allowed: false' "$protocol"
require_text 'registered_immutable_policy_required: true' "$protocol"
require_text 'unavailable_result: protected_validator_unavailable' "$protocol"
require_text 'deeper_ephemeral_implementer: explicit_immutable_packet_complexity_rationale_gpt-5.6-terra/high' "$protocol"
require_text 'Immutable repair packet direct mechanism, owned paths, and checks:' "$template"
require_text 'Paired Planning receipt: `released_terminal_idle`:' "$template"
require_text 'explicit immutable-packet complexity rationale' "$template"
require_text 'Planning packet prohibited until a terminal disposition:' "$template"
require_text 'continuation disposition, and next owner/action:' "$template"
require_text 'local-only packet misrouted to Strategy receives exactly' "$snapshot"
require_text 'protected_validator_unavailable' "$snapshot"
require_text 'Terra/high requires explicit' "$snapshot"
require_text 'until terminal disposition.' "$snapshot"
require_text 'exact missing decision/owner.' "$snapshot"

for file in "$skill" "$reference" "$protocol" "$template" "$snapshot"; do
  require_no_match 'gpt-5\.5' "$file"
  require_no_match 'ephemeral.{0,80}(luna|gpt-5\.6-luna)' "$file"
done
require_no_match 'FIRST_TENANT_BILLING_ENTITLEMENT_AND_REGISTRATION_GATE_PLAN\.md' "$snapshot"
require_no_match 'freeze(s|d|ing)? (the )?(plan|criteria|packet)' "$reference"

printf 'verify_codex_work_mode_skill: pass\n'
