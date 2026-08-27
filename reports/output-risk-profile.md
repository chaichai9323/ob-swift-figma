# Output Risk Profile

Audit-only matrix. Runtime agents use the routed references in `SKILL.md`.

| Risk | Required control | Runtime source |
|---|---|---|
| Missing task-doc or misplaced scaffold | Preflight `OB-Task-Doc`; copy GeneralOB into the app source directory and verify target membership | `core-workflow.md` |
| Queue reordered, duplicate page work, or unsafe concurrency | Parse statuses first; serial by default; `是否并发完成执行: true` uses ordered batches of three isolated agents | `queue-execution.md` |
| Missing BaseCell section blocks pages | Treat missing BaseCell section as valid and skip all shared-target checks/edits | `basecell.md` |
| BaseCell becomes a page or leaks into page files | Parent owns only `GeneralOBBaseCell`, `GeneralOBVC.nextButton`, namespace metadata, and `GeneralOB/icon_back` | `basecell.md` |
| Selected container styling is duplicated in cells | Shared unselected UI belongs to `baseView`; selected container effects belong to `selectedBaseView` | `basecell.md` |
| Figma states or announcements are lost | One block maps to one page; all links are states; announcement overrides conflicts | `queue-execution.md`, `page-implementation.md` |
| Page bypasses GeneralOB architecture | One `GeneralOBPage`, `pageData`, and `OB<Page>VC` mapping with required imports/localization | `page-implementation.md` |
| Tall layouts clip or the continue button scrolls away | Scroll main content above a fixed bottom button for frames over 844 | `page-implementation.md` |
| CollectionSection behaves like a flat option list | Use `GeneralOBCollectionSectionVC`, exact `OBSleepVC` hooks, and real `sectionDetail` data | `option-pages.md` |
| Selection is lost or defaults incorrectly | Persist in `GeneralOBData`; restore list state externally; empty state calls `makeSelectIndexes([])` | `option-pages.md` |
| Custom cells override shared selected containers/checkmarks | Preserve `checkIcon`; limit page-cell `isSelected` to foreground content | `option-pages.md` |
| Assets collide or render blank | Namespace page assets and verify catalog lookup; preserve exact BaseCell icon sizes | `assets-and-verification.md` |
| Per-page builds waste time or final integration is untested | Page agents run focused checks; parent runs one final `xcodebuild` | `assets-and-verification.md` |
| Fidelity is overstated | Require rendered visual comparison before claiming pixel-perfect output | `assets-and-verification.md` |

Primary residual risk: no external benchmark scan has been recorded; this remains `missing evidence` for broader distribution.
