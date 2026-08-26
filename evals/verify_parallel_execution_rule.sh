#!/usr/bin/env bash
set -euo pipefail

skill_root="$(cd "$(dirname "$0")/.." && pwd)"

require_text() {
  local file="$1"
  local text="$2"

  if ! rg -Fq "$text" "$file"; then
    echo "Missing required parallel-execution guidance in $file: $text" >&2
    exit 1
  fi
}

require_absent() {
  local file="$1"
  local text="$2"

  if rg -Fq "$text" "$file"; then
    echo "Found obsolete unconditional serial guidance in $file: $text" >&2
    exit 1
  fi
}

require_text "$skill_root/SKILL.md" '是否并发完成执行: true'
require_text "$skill_root/SKILL.md" 'three isolated page subagents concurrently'
require_text "$skill_root/SKILL.md" 'missing or `false`'
require_text "$skill_root/references/implementation-workflow.md" 'three-page concurrent batch'
require_text "$skill_root/references/implementation-workflow.md" 'document order'
require_text "$skill_root/references/implementation-workflow.md" 'fewer than three eligible pages remain'
require_text "$skill_root/references/implementation-workflow.md" 'Eligible pages are'
require_text "$skill_root/reports/output-risk-profile.md" '是否并发完成执行'
require_text "$skill_root/agents/interface.yaml" 'three page agents concurrently'
require_text "$skill_root/manifest.json" 'parallel_execution_policy'
require_text "$skill_root/evals/trigger_cases.json" '是否并发完成执行: true'
require_text "$skill_root/assets/OB-Task-Doc/OBFigma.md" '是否并发完成执行: false'
require_absent "$skill_root/manifest.json" 'Only one page subagent may be active at a time.'
require_absent "$skill_root/SKILL.md" 'After the active subagent returns'

echo "Parallel execution guidance is present and aligned."
