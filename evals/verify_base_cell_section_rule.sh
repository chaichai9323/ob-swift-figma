#!/usr/bin/env bash
set -euo pipefail

skill_root="$(cd "$(dirname "$0")/.." && pwd)"

require_text() {
  local file="$1"
  local text="$2"

  if ! rg -Fq "$text" "$file"; then
    echo "Missing required BaseCell-section guidance in $file: $text" >&2
    exit 1
  fi
}

require_text "$skill_root/SKILL.md" '`# BaseCell`'
require_text "$skill_root/SKILL.md" '`## BaseCell`'
require_text "$skill_root/SKILL.md" "not an OB page"
require_text "$skill_root/SKILL.md" "GeneralOBBaseCell"
require_text "$skill_root/SKILL.md" "selectedBaseView"
require_text "$skill_root/references/implementation-workflow.md" "shared BaseCell specification"
require_text "$skill_root/references/implementation-workflow.md" '`## BaseCell`'
require_text "$skill_root/references/implementation-workflow.md" 'Do not add or modify `GeneralOBPage`'
require_text "$skill_root/references/implementation-workflow.md" 'selected container effect in `selectedBaseView`'
require_text "$skill_root/reports/output-risk-profile.md" "BaseCell"
require_text "$skill_root/agents/interface.yaml" "BaseCell"
require_text "$skill_root/manifest.json" "base_cell_section_policy"
require_text "$skill_root/evals/trigger_cases.json" "BaseCell 分页信息段"

echo "BaseCell section guidance is present and aligned."
