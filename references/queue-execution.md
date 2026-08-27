# Queue Execution

Read this reference for `OBFigma.md`, queue status, concurrency, or page-agent execution.

## Parse The Queue

Use `OB-Task-Doc/OBFigma.md` first and legacy `GeneralOB/OBFigma.md` only when the primary queue is absent. Before implementation, build a document-ordered manifest of every `## <id>` page block: id, title, all Figma URLs, `### announcement`, referenced files, status, and attempt count.

- Detect whether a heading normalizes to `BaseCell`. If found, load [basecell.md](basecell.md) and complete that parent-owned work before dispatch. If absent, do not load that reference or create a BaseCell gate.
- Multiple Figma URLs in one page block are states of one page, not separate tasks.
- Opening Workflow and Project Fit Rules apply to every page unless that page's announcement conflicts. Announcements are hard constraints and win only for their page; retain all non-conflicting global rules.
- Resolve announcement filenames, images, documents, attachments, and relative paths from `OB-Task-Doc/` first. Inspect/read them before implementation. Do not add reference-only files to the app bundle or Xcode project.
- Preserve page text and Figma links. The parent edits only status-marker lines.
- Missing status means `todo`. Supported states are `todo`, `in_progress`, `failed`, `blocked`, and `done`, with `attempts`, `reason`, and `commit` metadata where applicable.
- Eligible pages are missing-status, `todo`, `failed`, or interrupted `in_progress` blocks. Exclude `done`, unresolved `blocked`, and pages already assigned in this run. Retry failed pages at their document position.

## Concurrency

Parse the opening `是否并发完成执行` declaration after removing optional Markdown list prefixes, whitespace, and full-width `【...】` brackets. Accept `true` or `false` case-insensitively. Missing or `false` means serial; invalid or conflicting declarations stop dispatch.

- `false` or missing: mark and dispatch exactly one eligible page, then integrate it before the next.
- `true`: take the next three eligible pages in document order and start three isolated page agents concurrently. Use fewer only when fewer than three eligible pages remain.
- Each page agent owns one page, one isolated worktree, and exactly one page-specific commit containing only its page implementation, assets, and required project metadata.
- The parent owns queue markers, attempts, shared-file conflict resolution, and integration. Agents never edit parent-worktree queue markers.
- Collect the whole concurrent batch and integrate in document order even if agents finish out of order. Resolve shared `GeneralOBPage`, data, model, localization, asset, and project-file conflicts per accepted page.
- Do not open the next batch until every current result is integrated or explicitly blocked. A failed page is retried at its position before later results are accepted.
- Each agent returns its commit hash, changed files, announcement compliance, source/project/visual/interaction evidence, and shared-file conflicts. The parent records accepted hashes in status markers.

The optional shared BaseCell task never consumes a page-agent slot.
