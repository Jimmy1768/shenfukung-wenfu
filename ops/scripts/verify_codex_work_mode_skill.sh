#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

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

require_file '.agents/skills/codex-work-mode/SKILL.md'
require_file '.agents/skills/codex-work-mode/agents/openai.yaml'
require_file '.agents/skills/codex-work-mode/codex_work_mode_skill_package_manifest.yml'

[[ "$(find .agents/skills/codex-work-mode -type f | wc -l | tr -d ' ')" == '3' ]] || \
  fail 'skill package must contain exactly its three package files'

[[ "$(shasum -a 256 .agents/skills/codex-work-mode/SKILL.md | awk '{print $1}')" == \
  'f70010e49b5b1dd218e116ccc584e6b11c657e4ecbb02c9952444349aa9ebdc3' ]] || \
  fail 'SKILL.md hash differs from the frozen package'
[[ "$(shasum -a 256 .agents/skills/codex-work-mode/agents/openai.yaml | awk '{print $1}')" == \
  'f79867a4869ff4cc5c6638955346f43d3e84f1c54c7a1d42fa9f1416f50ad007' ]] || \
  fail 'agents/openai.yaml hash differs from the frozen package'

manifest='.agents/skills/codex-work-mode/codex_work_mode_skill_package_manifest.yml'
require_text 'schema: codex_work_mode_skill_package_manifest:v1' "$manifest"
require_text 'package_ref: codex_work_mode_skill_package' "$manifest"
require_text 'package_version: v1' "$manifest"
require_text 'canonical_provenance:' "$manifest"
require_text '  repository: OperatorKit' "$manifest"
require_text '  seed_commit: fba8b20d3e6f57b2ac97b0536b96bec7b66dd162' "$manifest"
require_text '  package_identity: operatorkit:codex_work_mode_skill_package:v1' "$manifest"
require_text '  - path: SKILL.md' "$manifest"
require_text '    sha256: f70010e49b5b1dd218e116ccc584e6b11c657e4ecbb02c9952444349aa9ebdc3' "$manifest"
require_text '  - path: agents/openai.yaml' "$manifest"
require_text '    sha256: f79867a4869ff4cc5c6638955346f43d3e84f1c54c7a1d42fa9f1416f50ad007' "$manifest"

agents='AGENTS.md'
require_file "$agents"
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
