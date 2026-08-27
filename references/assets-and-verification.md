# Assets And Verification

Read this reference for asset work and before accepting any implementation.

## Assets

Export in a format and scale supported by both Figma and the project; SVG is valid when supported. Preserve transparency where required.

- Put page assets under `GeneralOB/Assets.xcassets/GeneralOB/<page>/`.
- Enable `"provides-namespace" : true` in both `GeneralOB/Contents.json` and `<page>/Contents.json`.
- Use descriptive image-set names and reference them as `GeneralOB/<page>/<assetName>`.
- Keep existing root assets only when genuinely shared. Do not overwrite same-named assets unless explicitly requested.
- Figma list icons are required assets; never replace them with system symbols. Preserve inherited `GeneralOBBaseCell.checkIcon` images.
- BaseCell back-button export is the special shared contract in [basecell.md](basecell.md), not a page namespace.

## Per-Page Acceptance

Each page agent verifies without `xcodebuild`:

- **Source:** correct `OB<Page>VC` location/name/imports/localization; one page-case/pageData mapping; no forbidden reload, page-local `makeSelect*`, `contentMode`, system-symbol fallback, or unrelated changes.
- **Project:** new Swift files are in the app target/source list; asset JSON and lookups resolve; announcement reference-only files remain outside the target.
- **Visual:** compare the rendered page at the relevant device size with every Figma state; inspect title/subtitle stacking, safe areas, small screens, iPad behavior, long localization, tall-page scrolling, fixed continue button, disabled/selected states, touch targets, and blank assets.
- **Interaction:** exercise navigation chrome, continue-button state, links, selection restore/save, multi-select behavior, and every announcement constraint.

When relevant, additionally confirm:

- `CollectionSection` uses `GeneralOBCollectionSectionVC`, the exact `OBSleepVC` cell-hook order, and real `sectionDetail` expansion data.
- BaseCell changed only its allowed shared targets; unselected treatment is in `baseView`, selected container treatment is in `selectedBaseView`, and `GeneralOBVC.nextButton` owns the shared bottom-button style.
- `sips -g pixelWidth -g pixelHeight -g format` or equivalent reports `icon_back@2x.png` as PNG 88x88 and `icon_back@3x.png` as PNG 132x132, with correct JSON scales and `GeneralOB/icon_back` lookup.
- Option selection uses `GeneralOBData`; external list initialization uses `vc.makeSelectIndexes([])` for empty state; non-list selection uses no `makeSelect*` helper.
- Radius `99`/`999` became half-height, circular progress uses the required configuration, and privacy/terms links open both QACheck URLs.

Inspect `git status --short` and diffs before staging. A page agent commits only its assigned files. Never claim pixel-perfect fidelity without an actual render-to-Figma comparison.

## Final Gate

After all page commits are integrated or explicitly blocked, the parent performs cross-page checks and runs exactly one workspace/project scheme `xcodebuild ... build`. Do not run per-page builds.

The final response reports preflight results; BaseCell present/absent handling; parsed concurrency and batches; each page's status, attempts, commit, states, announcement compliance, changed files, page mapping, chrome, imports/localization, selection/data/cell behavior, assets, and source/project/visual/interaction evidence; conflict resolution; blockers; and the single final build result. State visual limits honestly.
