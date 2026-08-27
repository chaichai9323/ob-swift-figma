#!/usr/bin/env bash
set -euo pipefail

skill_root="$(cd "$(dirname "$0")/.." && pwd)"
rules="$skill_root/references/queue-execution.md"

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

require_text "$skill_root/SKILL.md" "references/queue-execution.md"
require_text "$rules" '`是否并发完成执行`'
require_text "$rules" 'Missing or `false` means serial'
require_text "$rules" "start three isolated page agents concurrently"
require_text "$rules" "fewer than three eligible pages remain"
require_text "$rules" "integrate in document order"
require_text "$rules" "Eligible pages are"
require_text "$rules" "BaseCell task never consumes a page-agent slot"
require_text "$skill_root/manifest.json" '"parallel_execution_policy"'
require_text "$skill_root/evals/trigger_cases.json" "是否并发完成执行: true"
require_text "$skill_root/assets/OB-Task-Doc/OBFigma.md" "是否并发完成执行: false"
require_absent "$skill_root/manifest.json" "Only one page subagent may be active at a time."

echo "Parallel execution guidance is present in its lazy reference."
