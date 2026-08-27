#!/usr/bin/env bash
set -euo pipefail

skill_root="$(cd "$(dirname "$0")/.." && pwd)"

require_text() {
  local file="$1"
  local text="$2"
  if ! rg -Fq "$text" "$file"; then
    echo "Missing compact routing guidance in $file: $text" >&2
    exit 1
  fi
}

require_absent() {
  local file="$1"
  local text="$2"
  if rg -Fq "$text" "$file"; then
    echo "Found obsolete eager-loading guidance in $file: $text" >&2
    exit 1
  fi
}

initial_chars=$(wc -c < "$skill_root/SKILL.md")
initial_chars=$((initial_chars + $(wc -c < "$skill_root/agents/interface.yaml")))
estimated_tokens=$((initial_chars / 4))
if (( estimated_tokens > 1000 )); then
  echo "Estimated initial load exceeds production budget: $estimated_tokens > 1000" >&2
  exit 1
fi

for reference in core-workflow queue-execution basecell page-implementation option-pages assets-and-verification; do
  test -f "$skill_root/references/$reference.md" || {
    echo "Missing routed reference: references/$reference.md" >&2
    exit 1
  }
done

require_text "$skill_root/SKILL.md" "Read only the references selected by this router"
require_text "$skill_root/SKILL.md" "references/core-workflow.md"
require_text "$skill_root/SKILL.md" "references/queue-execution.md"
require_text "$skill_root/SKILL.md" "references/basecell.md"
require_text "$skill_root/SKILL.md" "references/page-implementation.md"
require_text "$skill_root/SKILL.md" "references/option-pages.md"
require_text "$skill_root/SKILL.md" "references/assets-and-verification.md"
require_text "$skill_root/SKILL.md" "compatibility index"
require_text "$skill_root/SKILL.md" "audit material"
require_text "$skill_root/agents/interface.yaml" "lazy reference router"
require_text "$skill_root/manifest.json" '"version": "0.3.0"'
require_absent "$skill_root/SKILL.md" "references/queue-and-basecell.md"
require_absent "$skill_root/SKILL.md" 'Read `references/implementation-workflow.md` for the execution checklist.'
require_absent "$skill_root/SKILL.md" 'Read `reports/output-risk-profile.md` before final delivery.'

for basecell_only_text in GeneralOBBaseCell selectedBaseView icon_back; do
  require_absent "$skill_root/references/queue-execution.md" "$basecell_only_text"
done

for queue_only_text in "three isolated page agents" "Eligible pages are" "integrate in document order"; do
  require_absent "$skill_root/references/basecell.md" "$queue_only_text"
done

compatibility_chars=$(wc -c < "$skill_root/references/implementation-workflow.md")
if (( compatibility_chars > 2000 )); then
  echo "Compatibility index is too large: $compatibility_chars > 2000 bytes" >&2
  exit 1
fi

echo "Compact entrypoint and lazy reference routing are within budget."
