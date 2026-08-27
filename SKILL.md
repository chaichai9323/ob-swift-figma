---
name: ob-swift-figma
description: Use when implementing GeneralOB UIKit Swift onboarding screens from Figma URLs, screenshots, design specs, or OBFigma.md queues, including BaseCell, option selection, and queue execution. Exclude SwiftUI and web targets.
metadata:
  author: Yao Team
---

# OB Swift Figma

Implement inside the existing GeneralOB architecture. Reuse project components, helpers, assets, fonts, and layout conventions; do not generate a parallel onboarding framework.

## Reference Router

Read only the references selected by this router:

1. Always read [core-workflow.md](references/core-workflow.md).
2. For `OBFigma.md`, queue status, concurrency, or page agents, read [queue-execution.md](references/queue-execution.md).
3. Read [basecell.md](references/basecell.md) only for a direct BaseCell task or when queue parsing finds a BaseCell heading. A missing heading is valid and must not load or gate on BaseCell rules.
4. For every actual onboarding page, read [page-implementation.md](references/page-implementation.md).
5. Additionally read [option-pages.md](references/option-pages.md) only for option lists, selectable cells, persisted selection, or `CollectionSection`.
6. Read [assets-and-verification.md](references/assets-and-verification.md) when exporting assets and before accepting an implementation.

Do not load unrelated references. [implementation-workflow.md](references/implementation-workflow.md) is a compatibility index, not an execution prerequisite. [output-risk-profile.md](reports/output-risk-profile.md) is audit material, not required runtime context.

## Invariants

- Preflight `OB-Task-Doc` and the complete GeneralOB scaffold before Figma work.
- Treat each page block as one `GeneralOBPage` plus one `OB<Page>VC`; multiple links are states of that page. Announcements override conflicting generic rules.
- Keep pages under `GeneralOB/Pages`, localize visible strings with `#Localized`, and preserve existing UIKit base-class behavior.
- Page agents own one page, one isolated worktree, and one commit. The parent owns queue markers, shared BaseCell work, ordered integration, and the single final build.
- Never stage or overwrite unrelated user changes.

After skill-package edits, run the relevant scripts under `evals/`.
