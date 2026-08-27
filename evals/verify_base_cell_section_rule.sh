#!/usr/bin/env bash
set -euo pipefail

skill_root="$(cd "$(dirname "$0")/.." && pwd)"
rules="$skill_root/references/basecell.md"

require_text() {
  local file="$1"
  local text="$2"
  if ! rg -Fq "$text" "$file"; then
    echo "Missing required BaseCell guidance in $file: $text" >&2
    exit 1
  fi
}

require_text "$skill_root/SKILL.md" "references/basecell.md"
require_text "$skill_root/SKILL.md" "A missing heading is valid"
require_text "$rules" '`# BaseCell`'
require_text "$rules" '`## BaseCell`'
require_text "$rules" "not an OB page"
require_text "$rules" "back button and bottom next button"
require_text "$rules" 'If no heading normalizes to `BaseCell`'
require_text "$rules" "Continue directly to the page manifest"
require_text "$rules" '`GeneralOBBaseCell`'
require_text "$rules" '`GeneralOBVC.nextButton`'
require_text "$rules" '`Assets.xcassets/GeneralOB/Contents.json`'
require_text "$rules" '`GeneralOB/icon_back`'
require_text "$rules" '`icon_back@2x.png`: 88x88'
require_text "$rules" '`icon_back@3x.png`: 132x132'
require_text "$rules" 'unselected container layout and appearance in `baseView`'
require_text "$rules" 'selected container effect in `selectedBaseView`'
require_text "$rules" 'Do not create or modify `GeneralOBPage`'
require_text "$skill_root/manifest.json" '"base_cell_section_policy"'
require_text "$skill_root/manifest.json" "Absence is valid"
require_text "$skill_root/reports/output-risk-profile.md" "Missing BaseCell section"
require_text "$skill_root/evals/trigger_cases.json" "返回按钮和底部的下一步按钮"
require_text "$skill_root/evals/trigger_cases.json" "没有 BaseCell"

echo "BaseCell section guidance is present in its lazy reference."
