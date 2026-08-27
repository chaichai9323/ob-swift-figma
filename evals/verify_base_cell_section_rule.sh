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
require_text "$skill_root/SKILL.md" "back button and bottom next button"
require_text "$skill_root/SKILL.md" "GeneralOBVC.nextButton"
require_text "$skill_root/SKILL.md" "GeneralOB/icon_back"
require_text "$skill_root/SKILL.md" "If no BaseCell heading exists"
require_text "$skill_root/SKILL.md" "continue directly to page dispatch"
require_text "$skill_root/SKILL.md" "do not inspect or modify the BaseCell shared targets"
require_text "$skill_root/references/implementation-workflow.md" "shared BaseCell specification"
require_text "$skill_root/references/implementation-workflow.md" '`## BaseCell`'
require_text "$skill_root/references/implementation-workflow.md" "Absence of a BaseCell section is valid"
require_text "$skill_root/references/implementation-workflow.md" 'Do not add or modify `GeneralOBPage`'
require_text "$skill_root/references/implementation-workflow.md" 'selected container effect in `selectedBaseView`'
require_text "$skill_root/references/implementation-workflow.md" "icon_back@2x.png"
require_text "$skill_root/references/implementation-workflow.md" "88x88"
require_text "$skill_root/references/implementation-workflow.md" "icon_back@3x.png"
require_text "$skill_root/references/implementation-workflow.md" "132x132"
require_text "$skill_root/references/implementation-workflow.md" "Assets.xcassets/GeneralOB/Contents.json"
require_text "$skill_root/references/implementation-workflow.md" 'BaseCell asset target includes `Assets.xcassets/GeneralOB/Contents.json`'
require_text "$skill_root/references/implementation-workflow.md" '`GeneralOBVC.nextButton`'
require_text "$skill_root/reports/output-risk-profile.md" "BaseCell"
require_text "$skill_root/reports/output-risk-profile.md" "missing BaseCell section"
require_text "$skill_root/agents/interface.yaml" "BaseCell is optional"
require_text "$skill_root/manifest.json" "base_cell_section_policy"
require_text "$skill_root/manifest.json" "Absence is valid"
require_text "$skill_root/evals/trigger_cases.json" "返回按钮和底部的下一步按钮"
require_text "$skill_root/evals/trigger_cases.json" "没有 BaseCell"

echo "BaseCell section guidance is present and aligned."
