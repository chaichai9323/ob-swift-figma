# Output Risk Profile

## Likely Failure Modes

- Generated Swift ignores the existing architecture and creates an isolated view controller, direct `OBBaseViewController` subclass, or SwiftUI view instead of inheriting from `GeneralOBVC` or `GeneralOBCollectionVC`.
- The task starts Figma reading or Swift implementation without first verifying that the project contains the required `GeneralOB` folder structure.
- The task starts Figma reading or Swift implementation without first verifying that the project root contains `OB-Task-Doc`.
- `OB-Task-Doc` is copied into the app source tree, added to `.xcodeproj`, included in app targets, or placed in Copy Bundle Resources even though it should remain a root-level task documentation folder only.
- The skill package drops or fails to distribute `assets/OB-Task-Doc`, so other projects cannot restore the required root task-doc folder when their project lacks it.
- The project is missing `GeneralOB` or required files such as `GeneralOBCollectionVC.swift`, `GeneralOBPage.swift`, `GeneralOBPage+Data.swift`, `GeneralOBPage+VC.swift`, `GeneralOBVC.swift`, `DataModel/`, or `Pages/`, but the implementation continues anyway and produces standalone or mislocated code.
- Missing `GeneralOB` structure is papered over by creating placeholder stub files instead of copying the skill-bundled `assets/GeneralOB` scaffold into the engineering project.
- The skill package drops or fails to distribute `assets/GeneralOB`, so other projects cannot restore the required GeneralOB base files when their project lacks them.
- The task starts from a page queue but does not read `GeneralOB/OBFigma.md`, processes pages out of order, or skips a failed page instead of retrying it.
- A page block with multiple Figma links is incorrectly split into multiple `GeneralOBPage` cases, page files, or commits instead of one page with multiple UI states.
- A page block contains `### announcement`, but the implementation ignores those page-level conditions or treats them as optional notes.
- A page announcement names a reference image, reference document, attachment, filename, or relative path, but the implementation searches Figma exports, app assets, or the repository root before checking `OB-Task-Doc/`.
- A page announcement reference exists under `OB-Task-Doc/`, but the implementation never reads or visually inspects it before coding.
- A page is marked `done` without proving every `announcement` condition was satisfied.
- A generic option-list inference is applied even though the page announcement says `不使用UICollectionView`, causing the page to use `UICollectionView` or `GeneralOBCollectionVC` incorrectly.
- `OBFigma.md` status markers are missing, overwritten broadly, placed ambiguously, or mark later pages done before their implementation and commit succeed.
- Multiple pages are implemented in one unreviewable batch commit, or a completed page is not committed before moving to the next `OBFigma.md` page.
- Git staging includes unrelated user changes, unfinished later pages, or files outside the current page's implementation and status marker.
- New page implementation files are placed outside `GeneralOB/Pages`, making the onboarding flow harder to maintain.
- New page files or classes use generic names instead of the required `OB<Page>VC` pattern, making the `GeneralOBPage` mapping harder to scan.
- Displayed copy is assigned as raw Swift strings instead of `#Localized("...")`, or the file uses `#Localized` without importing `OOGMacroKits`.
- Figma values are copied as raw constants instead of using local scaling, typography, color, and asset helpers.
- A Figma page frame taller than `844` is implemented as a fixed-height static layout, causing content to be clipped on device screens.
- The bottom continue button is added inside the scroll view for a page taller than `844`, so it scrolls away with the content instead of staying fixed above the scrollable layer.
- A tall-page scroll view does not include enough bottom inset or content padding, so the last content is hidden behind the floating bottom button.
- Figma capsule radii `99` or `999` are copied into Swift instead of being translated to half the component height.
- Assets are referenced by names that do not exist in the target bundle.
- Figma resources are downloaded as SVG instead of PNG `2x` and `3x` image assets, which does not match this project's page asset convention.
- Page-specific exported images are placed at the root of `Assets.xcassets` or in a non-namespaced folder, causing asset collisions across pages.
- Swift references page-specific images without the `GeneralOB/<page>/...` asset namespace, so lookup can resolve the wrong shared name or fail.
- Title or subtitle views are added before later content and get covered by images, collection views, cards, decorative overlays, gradients, or background art.
- Figma hides the back button, progress bar, or bottom continue button, but `GeneralOBPage` metadata keeps defaults so app chrome appears incorrectly.
- Onboarding pages compile visually but are not integrated through `GeneralOBVC`, `GeneralOBPage`, `GeneralOBPage.pageData`, and the page data source.
- Option-style pages use stacked buttons, hardcoded arrays, or a from-scratch `UICollectionView` implementation instead of inheriting from `GeneralOBCollectionVC` and using `GeneralOBPage.pageData.items`.
- Option-list pages ignore Figma selection and height behavior, leaving `page.multipleSelected` false for multi-select designs or leaving `page.cellHeightIsConsistent` true when cell heights can differ.
- List pages or non-list tap-to-select pages do not add a page-specific `GeneralOBData` selected-index property, so selection is lost when the user returns to the page.
- List-page selection restore/save logic is put inside `OB<Page>VC`, a cell, or page-local helper instead of the external `GeneralOBPage` `page.vc` creation path.
- List-page `page.vc` initialization defaults to selecting the first option or another arbitrary option even though Figma, `OBFigma.md`, or the page announcement did not explicitly require an initial selected state.
- Non-list tap-to-select pages add tap UI but do not restore from `GeneralOBData`, save changes back to `GeneralOBData`, or re-render selected state after taps.
- Non-list tap-to-select pages incorrectly use `makeSelectIndexes` even though that API is reserved for list page external VC initialization.
- Multi-select pages persist only one selected index, or single-select pages use an array unnecessarily, causing restore behavior to diverge from `page.multipleSelected`.
- Option-style pages call `UICollectionView` reload APIs such as `reloadData()`, `reloadItems(at:)`, or `reloadSections(_:)` instead of relying on `GeneralOBCollectionVC` diffable snapshots, page data, selection APIs, or targeted cell state updates.
- Page implementations call `makeSelectItems`, `makeSelectIndexes`, or another `makeSelect*` helper internally, even though those helpers are reserved for external VC initialization.
- Bottom continue button enabled or disabled states are implemented with a new helper method, duplicated action path, or scattered assignments instead of overriding `nextBtnEnable` and using its `didSet`.
- Page implementations assign `UIImageView.contentMode`, causing image rendering behavior to diverge from this project's conventions.
- Option data initializes `GeneralOBPageItem` with only localized display text, or hardcodes strings in cells, instead of using `GeneralOBPageItem(title: "abc", localizedTitle: #Localized("abc"), ...)`.
- Custom `GeneralOBBaseCell` subclasses add controls directly to `contentView`, ignore inherited `titleLab`, `icon`, `checkIcon`, or `selectedBaseView`, draw selected/unselected `checkIcon` states with colors, borders, symbols, or vector code instead of cut images, skip `super.setupUI()`, or use `makeConstraints` when the inherited constraints need `snp.remakeConstraints`.
- A list cell's selected UI differs from the base class behavior, but the implementation does not override `isSelected` in the cell subclass or puts the correction in the page VC instead of the cell.
- A selected option cell background is a gradient, image, multi-layer shape, or other non-solid style, but the implementation adds a custom selected-background update method instead of using `GeneralOBBaseCell.selectedBaseView`.
- One `GeneralOBPage` case drives multiple unrelated page implementations, or one page implementation handles multiple enum cases without a clear isolated branch.
- The implementation matches a single Figma frame but breaks safe areas, iPad layout, small phones, or long localized text.
- The final answer claims pixel-perfect fidelity without an app render or screenshot comparison.

## Self-Repair Checks

- Name `GeneralOBVC`, `GeneralOBCollectionVC`, the component library, layout system, font API, and asset convention before editing.
- Before reading Figma or `OBFigma.md`, verify that `OB-Task-Doc` exists at the engineering project root; if missing, copy the skill-bundled `assets/OB-Task-Doc` scaffold into the root and keep it out of `.xcodeproj`, targets, build phases, and Copy Bundle Resources.
- Confirm `assets/OB-Task-Doc` is present in the skill package and contains the task document files needed for queue mode.
- Before reading Figma or `OBFigma.md`, verify that `GeneralOB/GeneralOBCollectionVC.swift`, `GeneralOB/GeneralOBPage.swift`, `GeneralOB/GeneralOBPage+Data.swift`, `GeneralOB/GeneralOBPage+VC.swift`, `GeneralOB/GeneralOBVC.swift`, `GeneralOB/DataModel`, and `GeneralOB/Pages` all exist.
- If the required `GeneralOB` folder or any required path is missing, copy the skill-bundled `assets/GeneralOB` scaffold into the project as `GeneralOB`, re-run the required-path check, and do not continue with stub files.
- Confirm `assets/GeneralOB` is present in the skill package and contains the same required base files and folders used by the target-project preflight.
- If `GeneralOB/OBFigma.md` exists, read it first, identify the first not-done page, and retry `failed` or `in_progress` pages before later pages.
- If an `OBFigma.md` page block has multiple Figma links, confirm all links are read and mapped to states of one page implementation.
- If an `OBFigma.md` page block has `### announcement`, list each condition before implementation and verify each one before marking the page `done`.
- If an announcement mentions a reference image, reference document, attachment, filename, or relative path, search `OB-Task-Doc/` first with direct path checks or `rg --files OB-Task-Doc`, then read or inspect the resolved file before implementation.
- Confirm announcement reference files under `OB-Task-Doc/` are used as references only unless they are explicitly required as runtime assets, and do not add reference-only files to `.xcodeproj`, targets, build phases, or Copy Bundle Resources.
- If an announcement says `不使用UICollectionView`, confirm the page implementation inherits from `GeneralOBVC` or another non-collection project pattern and that page-specific files do not contain `UICollectionView` or `GeneralOBCollectionVC`.
- Confirm each processed `OBFigma.md` page has exactly one clear status marker and that missing status is treated as `todo`.
- Confirm one successful git commit exists per completed page before moving to the next page, and record or report the commit hash.
- Confirm `git status --short` and `git diff` were inspected so unrelated user changes are not staged.
- Confirm new page files live in `GeneralOB/Pages`.
- Confirm new page file and class names use `OB<Page>VC`, such as `OBStartVC.swift` / `OBStartVC`.
- Confirm visible strings are wrapped with `#Localized("...")` and files using the macro import `OOGMacroKits`.
- If the Figma page frame height is greater than `844`, confirm main content is scrollable.
- If a page is taller than `844`, confirm the bottom continue button is outside the scroll view and remains fixed/floating above scrolling content.
- If a page is taller than `844`, confirm the scroll view has enough bottom inset or content padding so final content is not obscured by the fixed bottom button.
- Confirm `GeneralOBPage` has exactly one enum case per implemented Figma page and that `GeneralOBPage+Data.swift` has a matching `pageData` branch.
- Confirm absent Figma chrome is reflected in `GeneralOBPage` flags: `canBack = false`, `isHideProgress = true`, or `isHideContinueBtn = true`.
- For option-style pages, confirm the page inherits from `GeneralOBCollectionVC`, overrides `registerCell` and `cell(_ c: UICollectionView, path: IndexPath)`, and uses `mainPage.pageData.items`.
- Confirm `page.multipleSelected = true` for multi-select option lists, and confirm `page.cellHeightIsConsistent` is `true` for same-height cells or `false` for variable-height cells.
- For list pages or non-list tap-to-select pages, confirm `GeneralOBData` has a matching persisted selected-index property: `Int?` for single-select and `[Int]?` for multi-select.
- For list pages, confirm the external `GeneralOBPage` `page.vc` creation path calls `vc.makeSelectIndexes` to restore selected index paths from `GeneralOBData` and save selection changes back to `GeneralOBData`.
- For list pages, confirm `page.vc` uses only `GeneralOBData` as the restore source; when `GeneralOBData` is empty or missing, it must call `vc.makeSelectIndexes([])` and must not default-select the first option or any other option unless Figma or an announcement explicitly requires one.
- For non-list tap-to-select pages, confirm selection is restored from `GeneralOBData` during page setup, saved back to `GeneralOBData` in tap handlers, and rendered from page-local selected state.
- Confirm non-list tap-to-select pages do not call `makeSelectIndexes`, `makeSelectItems`, or any `makeSelect*` helper.
- Confirm `makeSelectIndexes` is not called from `OB<Page>VC`, custom cells, or page-local layout/selection helpers; non-list tap-to-select pages should not call it anywhere.
- Confirm there are no `UICollectionView` reload calls, including `reloadData()`, `reloadItems(at:)`, and `reloadSections(_:)`.
- Confirm page implementation code does not call `makeSelectItems`, `makeSelectIndexes`, or any `makeSelect*` helper; list-page initial selection must be wired externally when the VC is created, while non-list tap-to-select pages restore and save through `GeneralOBData` in page-local state/tap code.
- Confirm custom bottom continue button state changes are inside `override var nextBtnEnable` `didSet`, with no new `updateNextButtonState`, `refreshNextButton`, or equivalent helper.
- Confirm no page implementation, page-local custom view, or cell assigns `UIImageView.contentMode`.
- Confirm every option `GeneralOBPageItem` is initialized with both `title: "abc"` and `localizedTitle: #Localized("abc")`.
- Confirm custom `GeneralOBBaseCell` subclasses add new controls to `baseView`, prefer inherited `titleLab`, `icon`, `checkIcon`, and `selectedBaseView`, display `checkIcon` selected and unselected states with cut image assets only, call `super.setupUI()`, and use `snp.remakeConstraints` to change inherited layout constraints.
- If selected cell UI differs from the base class behavior, confirm the cell subclass overrides `isSelected` and applies the UI correction in `didSet`, not in the page VC or external selection persistence code.
- If a selected option cell background is not a pure color, confirm it uses `selectedBaseView` and does not add a new method just to switch selected background styling.
- Confirm any Figma radius value of `99` or `999` is implemented as `height / 2`, `cx390(height) / 2`, or `bounds.height / 2` after layout.
- Confirm page-specific exported images are PNG `2x` and `3x` resources under `GeneralOB/Assets.xcassets/GeneralOB/<page>/`, not SVG, both `GeneralOB` and `<page>` folders have `provides-namespace` enabled, and Swift references use `GeneralOB/<page>/<assetName>`.
- Confirm title and subtitle views are brought to the front after all content views are added, or have an intentional higher `zPosition`.
- Search for a nearby screen with the same UI pattern and copy its integration style.
- Prefer local helpers such as `cx390`, `UIColor("#...")`, `cornerRadius`, `SnapKit`, and `OOGFontKit` where present.
- Verify every new asset reference exists in the asset catalog or bundle.
- Include build or verification output honestly; if blocked, state the blocker and what was checked manually.

## Delivery Standard

The user should receive integrated project code, not a standalone tutorial. The final response should make it clear that the required root `OB-Task-Doc` folder was verified before implementation, whether the folder already existed or was copied from the skill-bundled `assets/OB-Task-Doc` scaffold, and that it was not added to the Xcode project, app targets, build phases, or Copy Bundle Resources; that any announcement reference images or documents were searched for in `OB-Task-Doc/` first, with resolved paths and usage called out; that the required `GeneralOB` folder structure was verified before implementation, whether the folder already existed or was copied from the skill-bundled `assets/GeneralOB` scaffold, which `OBFigma.md` page was processed, all Figma links in that block and the UI state each represents, any `announcement` conditions and how each one was satisfied, its status transition, attempt count, and commit hash; how the Figma design maps to local Swift files; whether a Figma frame taller than `844` was implemented with scrollable content and a fixed floating bottom button; how option data is represented with `GeneralOBPageItem(title:localizedTitle:)`; which `GeneralOBData` property persists selection state and whether it is single-select `Int?` or multi-select `[Int]?`; for list pages, where `page.vc` restores and saves selected indexes through `vc.makeSelectIndexes`, that restore uses only `GeneralOBData`, and that the no-saved-state path calls `vc.makeSelectIndexes([])` unless explicitly specified; for non-list tap-to-select pages, where the page restores, toggles, saves, and re-renders selected state through `GeneralOBData`; which `multipleSelected` and `cellHeightIsConsistent` values were set for option lists; that no `UICollectionView` reload methods, page-local `makeSelect*` calls, or `UIImageView.contentMode` assignments were used; that bottom continue button states are handled through `nextBtnEnable.didSet`; how any `GeneralOBBaseCell` subclass reuses `baseView`, `titleLab`, `icon`, `checkIcon`, and `selectedBaseView` for non-solid selected backgrounds with cut images for selected and unselected states; whether selected cell UI required an `isSelected.didSet` override in the custom cell subclass; which PNG `2x` and `3x` assets were exported; and which existing project primitives were reused.
