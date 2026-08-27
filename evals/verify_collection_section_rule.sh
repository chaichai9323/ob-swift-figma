#!/usr/bin/env bash
set -euo pipefail

skill_root="$(cd "$(dirname "$0")/.." && pwd)"
rules="$skill_root/references/option-pages.md"

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

require_text "$skill_root/SKILL.md" "references/option-pages.md"
require_text "$rules" "CollectionSection"
require_text "$rules" "GeneralOBCollectionSectionVC"
require_text "$rules" "OBSleepVC"
require_text "$rules" "super.registerCell()"
require_text "$rules" "if path.item > 0"
require_text "$rules" "return super.cell(c, path: path)"
require_text "$rules" "override func sectionDetail"
require_text "$rules" "real localized Figma expanded information"
require_text "$skill_root/reports/output-risk-profile.md" "CollectionSection"
require_text "$skill_root/manifest.json" '"collection_section_policy"'
require_text "$skill_root/evals/trigger_cases.json" "GeneralOBCollectionSectionVC"
require_text "$skill_root/assets/GeneralOB/GeneralOBCollectionVC.swift" "func sectionDetail"
forbid_text "$skill_root/assets/GeneralOB/GeneralOBCollectionVC.swift" "private func sectionDetail"

echo "CollectionSection guidance is present in its lazy reference."
