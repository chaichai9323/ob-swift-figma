#!/usr/bin/env bash
set -euo pipefail

skill_root="$(cd "$(dirname "$0")/.." && pwd)"

require_text() {
  local file="$1"
  local text="$2"

  if ! rg -Fq "$text" "$file"; then
    echo "Missing required CollectionSection guidance in $file: $text" >&2
    exit 1
  fi
}

forbid_text() {
  local file="$1"
  local text="$2"

  if rg -Fq "$text" "$file"; then
    echo "Forbidden CollectionSection implementation in $file: $text" >&2
    exit 1
  fi
}

require_text "$skill_root/SKILL.md" "CollectionSection"
require_text "$skill_root/SKILL.md" "GeneralOBCollectionSectionVC"
require_text "$skill_root/SKILL.md" 'overriding `registerCell()` and `cell(_ c: UICollectionView, path: IndexPath) -> GeneralOBBaseCell`'
require_text "$skill_root/SKILL.md" "OBSleepVC"
require_text "$skill_root/SKILL.md" "super.registerCell()"
require_text "$skill_root/SKILL.md" "if path.item > 0"
require_text "$skill_root/SKILL.md" "return super.cell(c, path: path)"
require_text "$skill_root/SKILL.md" "override func sectionDetail"
require_text "$skill_root/SKILL.md" "expanded information"
require_text "$skill_root/references/implementation-workflow.md" "CollectionSection"
require_text "$skill_root/references/implementation-workflow.md" "GeneralOBCollectionSectionVC"
require_text "$skill_root/references/implementation-workflow.md" "OBSleepVC"
require_text "$skill_root/references/implementation-workflow.md" "sectionDetail"
require_text "$skill_root/reports/output-risk-profile.md" "CollectionSection"
require_text "$skill_root/reports/output-risk-profile.md" "OBSleepVC"
require_text "$skill_root/reports/output-risk-profile.md" "sectionDetail"
require_text "$skill_root/evals/trigger_cases.json" "GeneralOBCollectionSectionVC"
require_text "$skill_root/agents/interface.yaml" "GeneralOBCollectionSectionVC"
require_text "$skill_root/agents/interface.yaml" "OBSleepVC"
require_text "$skill_root/agents/interface.yaml" "sectionDetail"
require_text "$skill_root/manifest.json" "collection_section_policy"
require_text "$skill_root/manifest.json" "OBSleepVC"
require_text "$skill_root/manifest.json" "sectionDetail"
require_text "$skill_root/assets/GeneralOB/GeneralOBCollectionVC.swift" "func sectionDetail"
forbid_text "$skill_root/assets/GeneralOB/GeneralOBCollectionVC.swift" "private func sectionDetail"

echo "CollectionSection guidance is present and aligned."
