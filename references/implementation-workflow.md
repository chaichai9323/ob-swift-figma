# Implementation Workflow

Use this checklist when turning Figma into Swift code inside an existing iOS project.

## 1. Inputs

Confirm the concrete design target:

- `OB-Task-Doc/OBFigma.md` page queue, when present; legacy `GeneralOB/OBFigma.md` is a fallback only
- Figma URL or node id; in `OBFigma.md`, one page block may contain multiple Figma URLs
- `### announcement` content inside the selected `OBFigma.md` page block, when present
- reference images, reference documents, attachments, filenames, or relative paths mentioned by `### announcement`, resolved from `OB-Task-Doc/` first
- target screen, flow, or component
- intended device family and orientation
- Figma page frame height, especially whether it is greater than `844`
- whether the requested page belongs in the GeneralOB onboarding flow
- expected interaction states, navigation, loading, empty, disabled, and error states
- whether the page is option-style and needs selectable choices

If the Figma URL lacks a node id and the target is ambiguous, ask for the node-specific URL before implementing.

When `OB-Task-Doc/OBFigma.md` exists, read it automatically before asking for page input. If it is absent, fall back to legacy `GeneralOB/OBFigma.md`. Treat each `## <id>` section as one page task with optional title text, one or more Figma URLs, optional `### announcement` constraints, and `ob-status` marker.

## 1A. OB-Task-Doc Preflight

Before reading Figma, changing `OBFigma.md`, or editing Swift, verify that the engineering project root contains an `OB-Task-Doc` folder.

The skill package includes a fallback task-doc scaffold at `assets/OB-Task-Doc`. This bundled folder is copied from the current project and must remain part of the skill package so other projects can bootstrap the task document folder.

If `OB-Task-Doc` is missing:

- copy the skill-bundled `assets/OB-Task-Doc` folder into the engineering project root as `OB-Task-Doc`
- keep `OB-Task-Doc` as a root-level task documentation folder only
- do not add `OB-Task-Doc` to the Xcode project file, project navigator groups, app targets, build phases, or Copy Bundle Resources
- do not edit `.xcodeproj/project.pbxproj` merely to make `OB-Task-Doc` visible in Xcode
- stop and report the missing bundled scaffold if `assets/OB-Task-Doc` is unavailable or incomplete

Only continue to queue parsing or Figma implementation after this preflight passes.

## 1B. GeneralOB Structure Preflight

Before reading Figma, changing `OBFigma.md`, or editing Swift, verify that the engineering project root contains a complete `GeneralOB` folder.

Required paths, relative to the resolved app source directory, which should be one level below the directory containing the app `.xcodeproj` when the repository uses the common `Root/AppName.xcodeproj` plus `Root/AppName/` source layout:

- `GeneralOB/GeneralOBCollectionVC.swift`
- `GeneralOB/GeneralOBPage.swift`
- `GeneralOB/GeneralOBPage+Data.swift`
- `GeneralOB/GeneralOBPage+VC.swift`
- `GeneralOB/GeneralOBVC.swift`
- `GeneralOB/DataModel`
- `GeneralOB/Pages`

Use the filesystem and fast searches to confirm the structure, for example:

- `test -d GeneralOB`
- `test -f GeneralOB/GeneralOBCollectionVC.swift`
- `test -f GeneralOB/GeneralOBPage.swift`
- `test -f GeneralOB/GeneralOBPage+Data.swift`
- `test -f GeneralOB/GeneralOBPage+VC.swift`
- `test -f GeneralOB/GeneralOBVC.swift`
- `test -d GeneralOB/DataModel`
- `test -d GeneralOB/Pages`
- `rg --files GeneralOB | rg 'GeneralOB(CollectionVC|Page|VC)\.swift|GeneralOBPage\+Data\.swift|GeneralOBPage\+VC\.swift'`

The skill package includes a fallback scaffold at `assets/GeneralOB`. This bundled folder is copied from the current GeneralOB project and must remain part of the skill package so other projects can bootstrap the required onboarding architecture.

If `GeneralOB` is missing or any required file/folder is absent:

- locate the real app source directory first; when `.xcodeproj` is at `Root/AppName.xcodeproj`, the destination should normally be `Root/AppName/GeneralOB`, not `Root/GeneralOB` beside `.xcodeproj`
- copy the skill-bundled `assets/GeneralOB` folder into that app source directory as `GeneralOB`
- add every copied Swift file under `GeneralOB` to the primary app target's Compile Sources or the equivalent project-generation source list
- when editing `.xcodeproj/project.pbxproj` directly, create the needed file references, groups, and `PBXSourcesBuildPhase` entries for copied Swift files without adding unrelated files
- if the project is generated from a tool such as XcodeGen or Tuist, update the generator config instead of hand-editing generated project files, then regenerate if that is the repository convention
- do not create placeholder or stub versions of the missing files just to pass the check
- re-run the same required-path verification after the copy and verify target membership for the copied Swift files
- stop and report the missing bundled scaffold if `assets/GeneralOB` is unavailable or incomplete

Only continue to `OBFigma.md` queue parsing or Figma implementation after this preflight passes.

## 1C. OBFigma Queue Mode

Use `OB-Task-Doc/OBFigma.md` as the primary resumable queue, with legacy `GeneralOB/OBFigma.md` as a fallback when the task-doc queue file is absent:

- parse page blocks in document order from headings such as `## 001`, `## 002`, and so on
- collect every Figma URL inside the same page block
- collect any `### announcement` section inside the same page block; its text applies only to that page block
- if the announcement mentions reference images, reference documents, attachments, filenames, or relative paths, resolve those files from `OB-Task-Doc/` before checking any other location
- treat multiple Figma URLs inside one page block as multiple UI display states of the same page, not as separate pages
- implement all URLs in a block through one `GeneralOBPage` case and one `OB<Page>VC` page implementation, unless the user explicitly changes the queue structure
- treat announcement lines as hard page-level implementation constraints that must be satisfied before the page can be marked `done`
- treat any announcement-linked reference file found under `OB-Task-Doc/` as part of the hard page-level constraints
- when an announcement conflicts with a generic implementation heuristic, follow the announcement for that page unless it breaks non-negotiable GeneralOB project boundaries; report the conflict and chosen implementation
- example: `不使用UICollectionView` means do not use `UICollectionView`, `GeneralOBCollectionVC`, collection cells, or collection reload/update APIs in that page, even if it looks option-style; use `GeneralOBVC` or another existing non-collection project pattern instead
- preserve existing page text and Figma links; edit only status marker lines
- treat a missing marker as `todo`
- supported markers are HTML comments inside the page block, such as `<!-- ob-status: todo -->`, `<!-- ob-status: in_progress; attempts: 1 -->`, `<!-- ob-status: failed; attempts: 1; reason: figma read failed -->`, and `<!-- ob-status: done; commit: <hash> -->`
- choose the first page whose status is not `done`
- if the first not-done page is `failed` or `in_progress`, retry that same page before moving to later pages
- before editing Swift or assets for the selected page, mark that page `in_progress` and increment or initialize `attempts`
- after a page passes verification, mark it `done` with the commit hash
- if a page fails, mark it `failed` with the attempt count and a short reason, then stop or retry that same page; do not continue to later pages while the current page is failed
- keep status markers close to the page heading so humans can scan progress quickly

## 2. Figma Read

Gather only the design context needed for implementation:

- screenshot of the node
- frame size and constraints, including whether the frame height is greater than `844`
- text content, typography, colors, opacity, shadows, radii, strokes, blur, and spacing
- exported image assets and vector assets
- image export requirements: PNG only, with `2x` and `3x` variants; do not use SVG for downloaded Figma resources in this project
- component variants and interactive states
- motion data when the design uses animations

For an `OBFigma.md` page block with multiple links, gather screenshot and design context for every link before implementation. Compare the links to identify shared layout, state-specific differences, selection/disabled/expanded/error/empty states, and any state-specific assets. Implement those as states of one page.

When the Figma data and screenshot conflict, trust the screenshot for visual composition and name the discrepancy.

## 3. Project Discovery

Before editing, inspect the local codebase:

- complete the `OB-Task-Doc` preflight first and record whether the folder was already present or copied from the skill-bundled `assets/OB-Task-Doc` scaffold
- complete the `GeneralOB` structure preflight first and record whether the folder was already present or copied from the skill-bundled `assets/GeneralOB` scaffold; if copied, record the resolved app source directory, confirm it was not placed beside `.xcodeproj` at the top level, and record how the Swift files were added to the app target
- `sed -n '1,240p' OB-Task-Doc/OBFigma.md` to read the primary page queue when present
- `sed -n '1,240p' GeneralOB/OBFigma.md` only as a legacy fallback when `OB-Task-Doc/OBFigma.md` is absent
- `rg --files -g '*.swift'` to list Swift files
- `rg "class .*ViewController|struct .*View|OBBaseViewController|UIViewController|ViewModel|Page" -n` for architecture
- `rg "SnapKit|snp\\.makeConstraints|NSLayoutConstraint|SwiftUI|View\\s*\\{" -n` for layout style
- `rg "cx390|UIColor\\(\"#|figtree|cornerRadius|Assets|UIImage\\(named:" -n` for design utilities
- `rg "Router|pushViewController|present\\(|container\\?\\.onNext|OnboardingPagesDataSource" -n` for navigation
- `rg "GeneralOBCollectionVC|registerCell|cell\\(_ c: UICollectionView|pageData|GeneralOBPageData|GeneralOBPageItem|UICollectionView" -n` for page data and option-list patterns
- `rg "GeneralOBData|makeSelectIndexes|makeSelectItems|var .*: Int\\?|var .*: \\[Int\\]\\?" -n` for persisted selection state, list-page external VC initialization patterns, and non-list page tap handlers
- `rg "multipleSelected|cellHeightIsConsistent" -n` for option-list page metadata
- `rg "makeSelectItems|makeSelectIndexes|makeSelect" -n` to ensure page implementations do not call external selection-initialization helpers
- `rg "nextBtnEnable|nextButton|update.*Button|refresh.*Button" -n` for bottom continue button state patterns
- `rg "UIImageView|contentMode" -n` to find image views and verify page implementations do not assign `contentMode`
- `rg "reloadData|reloadItems|reloadSections|\\.reload" -n` to identify and avoid forbidden collection reload patterns
- `rg "class .*GeneralOBBaseCell|baseView|titleLab|checkIcon|selectedBaseView|remakeConstraints|setupUI" -n` for option cell customization patterns
- read `Podfile`, `Podfile.lock`, `Package.swift`, or project files to identify available libraries
- inspect the Xcode project, workspace, or project-generation config to identify the primary app target before adding copied `GeneralOB` Swift files
- inspect nearby screens with similar UI before creating new controls

Record the local primitives you will reuse before changing files.

## 3A. Announcement Reference Files

When the selected page block's `### announcement` mentions a reference image, reference document, attachment, filename, or relative path:

- search `OB-Task-Doc/` first, before `GeneralOB/`, `Assets.xcassets`, the repository root, or web/Figma resources
- use exact relative paths from the announcement when provided, such as `OB-Task-Doc/foo.png` or `foo.pdf`
- if only a filename or human-readable title is provided, use `rg --files OB-Task-Doc` and filename/title matching to locate candidates
- for images under `OB-Task-Doc`, inspect the referenced image before implementation and use it alongside the Figma screenshot
- for documents under `OB-Task-Doc`, read the document content before implementation and treat its requirements as announcement constraints for that page
- if no matching file exists under `OB-Task-Doc`, report that miss explicitly, then search other project locations only as a fallback
- do not copy announcement reference documents or images from `OB-Task-Doc` into the app bundle unless the page implementation explicitly needs them as runtime assets
- do not add reference-only files from `OB-Task-Doc` to `.xcodeproj`, app targets, build phases, or Copy Bundle Resources

Record each resolved reference path and how it influenced layout, copy, assets, or interaction decisions.

## 4. Mapping Rules

Map Figma layers to existing project primitives:

- screen container: `GeneralOBVC` for ordinary pages; `GeneralOBCollectionVC` for option-style pages unless the current page announcement forbids `UICollectionView` or otherwise requires a non-collection implementation
- file location: page implementations under `GeneralOB/Pages`; shared data model additions under `GeneralOB/Pages/Model`
- file and class naming: `OB<Page>VC.swift` and `OB<Page>VC`, derived from the `GeneralOBPage` case in PascalCase
- page identity: exactly one `GeneralOBPage` case for each implemented Figma page
- page state grouping: all Figma URLs in the same `OBFigma.md` page block map to the same page identity and should become state handling in the same page implementation
- page announcements: any `### announcement` constraints in the selected block must be explicitly mapped to code decisions and later verified
- page data: `GeneralOBPage.pageData` returns the title and option data for that page
- persisted selection state: list pages and non-list tap-to-select pages add a matching `GeneralOBData` property, using `Int?` for single-select index state and `[Int]?` for multi-select index state
- option item initialization: each `GeneralOBPageItem` should include both raw and localized text, for example `GeneralOBPageItem(title: "abc", localizedTitle: #Localized("abc"), icon: "...")`
- option-list selection metadata: if the Figma page supports multi-select, set `page.multipleSelected = true`; otherwise set or leave it `false`
- option-list height metadata: set `page.cellHeightIsConsistent = true` only when all cells have the same height; set `page.cellHeightIsConsistent = false` when Figma shows variable-height cells or selection/content state can change height
- page chrome metadata: missing Figma chrome updates `GeneralOBPage.canBack`, `GeneralOBPage.isHideProgress`, and `GeneralOBPage.isHideContinueBtn`
- navigation: current router, onboarding container, tab, modal, or coordinator
- layout: existing `SnapKit`, Auto Layout, SwiftUI layout, or project-specific helpers
- scroll behavior: if the Figma page frame height is greater than `844`, make the main content scrollable and keep the bottom continue button outside the scrollable content as a fixed floating layer
- layer order: title and subtitle views must sit above all images, collection views, cards, decorations, gradients, and background art
- typography: local font APIs such as `UIFont.figtree(...)` or existing text styles
- localization: wrap all displayed copy in `#Localized("...")` and import `OOGMacroKits` in files that use the macro
- spacing: local scale helpers such as `cx390(...)`; include iPad and small-device variants when the project does
- colors: local token, asset, or hex initializer already used by the project
- corner radius: copy ordinary Figma radii through local helpers; translate Figma radii `99` and `999` to half of the component height
- images: existing asset catalog names or newly exported Figma assets placed under the `GeneralOB/<page>/...` namespaced asset path
- image views: do not set `UIImageView.contentMode` in page code, page-local custom views, or cells
- Figma image export: use PNG resources with `2x` and `3x` variants, not SVG
- collection updates: never call `UICollectionView` reload APIs; rely on `GeneralOBCollectionVC` diffable snapshots, `mainPage.pageData.items`, selection methods, and direct state updates
- initial selection: `makeSelectItems`, `makeSelectIndexes`, and other `makeSelect*` helpers are external page-creation APIs for list pages and must not be called inside the page implementation; for list pages, use them only to restore saved `GeneralOBData` values or an explicitly specified Figma/announcement initial state, and otherwise call `vc.makeSelectIndexes([])`; for non-list tap-to-select pages, restore and save selection directly through `GeneralOBData` in the page's own state and tap handling code
- bottom continue button state: use `override var nextBtnEnable: Bool { didSet { ... } }` for custom enabled or disabled appearance; do not create a separate update or refresh method for the bottom button state
- controls: existing buttons, labels, `GeneralOBCollectionVC` and its collection cell hooks for option pages, progress bars, modals, toasts, and onboarding components

Create new code only for genuinely new UI structure or behavior. Keep new helper APIs private or file-scoped unless there is clear local precedent for sharing. Do not bypass `GeneralOBVC` by creating a direct `OBBaseViewController` or plain `UIViewController` page.

## 5. Page Structure

For every new Figma page:

- if running from `OBFigma.md`, update only the current page block's status marker before work; do not mark future pages
- if the current `OBFigma.md` block contains multiple Figma URLs, read and implement them together as UI states of the same page
- if the current `OBFigma.md` block contains `### announcement`, write down each announced condition and choose implementation details that satisfy it before editing Swift
- if the current `OBFigma.md` block's announcement references images or documents, resolve them from `OB-Task-Doc/` first and read or inspect them before editing Swift
- if the Figma page frame height is greater than `844`, plan the page as scrollable content plus a fixed bottom button layer before creating constraints
- create or update the page implementation under `GeneralOB/Pages`
- add one `GeneralOBPage` enum case for the page
- name the page implementation file and class with `OB<Page>VC`, where `<Page>` is the PascalCase form of the enum case; examples: `.start` -> `OBStartVC.swift`, `.mainGoal` -> `OBMainGoalVC.swift`
- ensure the enum case maps to exactly one page implementation
- ensure multiple Figma URLs in the same `OBFigma.md` block do not create multiple enum cases or page implementation files
- update `GeneralOBPage.swift` metadata for the enum case: no top-left back button in Figma means `canBack = false`; no top progress bar means `isHideProgress = true`; no bottom continue button means `isHideContinueBtn = true`
- update `GeneralOBPage+Data.swift` or the relevant `GeneralOBPage` extension so option-list metadata matches Figma: multi-select pages return `multipleSelected = true`; same-height cell pages return `cellHeightIsConsistent = true`; variable-height cell pages return `cellHeightIsConsistent = false`
- update `GeneralOBPage+Data.swift` so `pageData` returns that page's title, options, icons, and localized text
- update `GeneralOBData` for list pages and non-list tap-to-select pages with a matching persisted selected-index property: single-select uses `var page: Int?`; multi-select uses `var page: [Int]?`; replace `page` with the project's page-specific property name
- for list pages, update the matching `GeneralOBPage` `page.vc` or external VC creation branch to restore and save indexes with `vc.makeSelectIndexes`, using the single-select or multi-select pattern below; do not set a default selected item there unless Figma or the page announcement explicitly specifies one
- for non-list tap-to-select pages, restore from `GeneralOBData` during page setup, render the selected UI from that state, update the state on tap, and save the new value back to `GeneralOBData`
- for every option item in `pageData`, initialize `GeneralOBPageItem` with `title: "abc"` and `localizedTitle: #Localized("abc")` so raw identity and localized display text are both available
- keep `GeneralOBPageData` and `GeneralOBPageItem` as the default data model; extend or add models under `GeneralOB/Pages/Model` only when the Figma page has data that cannot fit those types
- avoid storing option titles, icons, or localized strings directly in the view controller, collection view cell, or layout code unless the localized display text is truly view-specific

## 6. UIKit Implementation

For UIKit pages:

- subclass `GeneralOBVC` for ordinary new Figma pages in this project
- subclass `GeneralOBCollectionVC` for option-style pages; it already inherits from `GeneralOBVC`, unless the current page announcement forbids `UICollectionView`
- preserve required initializers and lifecycle patterns
- define views as `lazy var` or local equivalents consistent with nearby code
- add `import OOGMacroKits` at the top of any Swift file that renders localized text with `#Localized("...")`
- set visible copy with the macro, for example `titleLab.text = #Localized("Title")`, `button.setTitle(#Localized("Continue"), for: .normal)`, and `GeneralOBPageItem(title: "Choice", localizedTitle: #Localized("Choice"), icon: "...")`
- for option data, use the full item initializer style `GeneralOBPageItem(title: "Choice", localizedTitle: #Localized("Choice"), icon: "...")` rather than storing only a localized title
- add subviews once, then set constraints in the same style used nearby
- add title and subtitle views after lower-priority content or explicitly call `view.bringSubviewToFront(titleView)` and `view.bringSubviewToFront(subtitleView)` after adding dynamic content
- when the Figma page height is greater than `844`, place the main page content inside a `UIScrollView` and content view, or use the inherited collection view when the page is allowed to be a collection page; do not put the bottom continue button inside that scrollable content
- for tall pages, constrain the scroll view above the fixed bottom button area and set enough bottom content inset or bottom content padding so the last content can scroll above the floating button instead of being hidden behind it
- use `layer.zPosition` only when subview order is not enough, and keep the value local and documented by nearby code
- use `safeAreaLayoutGuide` and responsive helpers for top, bottom, and device-specific spacing
- avoid hardcoded screen widths except through local scaling helpers
- wire actions through existing callbacks, containers, routers, delegates, Combine, or view models
- if the Figma page requires custom bottom continue button states, override the inherited `nextBtnEnable` property and put background color, title color, alpha, image, or enabled-state UI changes in `didSet`; do not create methods such as `updateNextButtonState`, `refreshNextButton`, or `configureNextButtonState`
- when creating `UIImageView`, set image, asset name, constraints, visibility, and layer properties as needed, but do not assign `contentMode`
- keep Figma-only decorative layers from becoming brittle if they should be assets or gradients

For this repository's onboarding pages, require:

- `GeneralOBPage` cases and `obPage` metadata for page identity
- `GeneralOBPage` chrome flags to match the Figma screen's visible back button, progress bar, and bottom continue button
- `GeneralOBPage.pageData` for page title and option data
- `GeneralOBData` for persisted selected indexes on list pages and non-list tap-to-select pages
- `#Localized("...")` plus `import OOGMacroKits` for all user-visible strings
- scrollable content for Figma page frames taller than `844`, with the bottom continue button fixed outside the scroll view
- `GeneralOBVC` inheritance for ordinary visual pages
- `GeneralOBCollectionVC` inheritance for option-style visual pages unless the current page announcement forbids `UICollectionView`
- `GeneralOBViewModel` and `OnboardingPagesDataSource` for page construction
- `SnapKit` constraints and `cx390(...)` scaling
- `Components` extensions such as `UIColor("#...")` and `cornerRadius`
- `OOGFontKit` typography such as `.figtree(.bold, fontSize: cx390(...))`

## 7. Option-Style Pages

If the Figma page presents selectable options, cards, goals, interests, answers, categories, or any repeated choice list:

- inherit from `GeneralOBCollectionVC`; do not create a fresh `UICollectionView`, diffable data source, delegate stack, selection pipeline, or initial data loading flow
- set the page's `multipleSelected` metadata from Figma selection behavior; multi-select lists must return `true`
- set the page's `cellHeightIsConsistent` metadata from Figma cell height behavior; same-height lists return `true`, variable-height lists return `false`
- never call `reloadData()`, `reloadItems(at:)`, `reloadSections(_:)`, or wrapper helpers that trigger `UICollectionView` reloads
- create or reuse a cell class in `GeneralOB/Pages`; prefer subclassing `GeneralOBBaseCell` when it fits the design
- override `registerCell` to register the page-specific cell
- override `cell(_ c: UICollectionView, path: IndexPath) -> GeneralOBBaseCell` to dequeue and return the page-specific cell
- let `GeneralOBCollectionVC` feed data from `mainPage.pageData.items`, apply the diffable data source, handle selection, and call `clickNext`
- add a persisted selection field in `GeneralOBData`; use `Int?` for single-select and `[Int]?` for multi-select
- in the external `GeneralOBPage` `page.vc` construction path, restore and save list selection with `vc.makeSelectIndexes`; this is the allowed place to call `makeSelectIndexes`
- unless Figma or the page announcement explicitly specifies an initial selected option, `page.vc` must not default-select the first option or any other option; when `GeneralOBData` has no saved value, call `vc.makeSelectIndexes([])`
- when UI state changes, update the model through the existing page data or selection flow, or update the affected visible cell state directly; do not refresh the collection by reload
- do not call `makeSelectItems`, `makeSelectIndexes`, or any `makeSelect*` method inside the page; those helpers are only for the external VC initialization code that creates the page
- represent choice content with `GeneralOBPageItem` fields such as `title`, `localizedTitle`, and `icon`
- initialize choice content with both `title` and `localizedTitle`, for example `GeneralOBPageItem(title: "abc", localizedTitle: #Localized("abc"), icon: "...")`
- use `#Localized("...")` for `localizedTitle` and any visible cell or tag text
- when subclassing `GeneralOBBaseCell`, add new controls to `baseView` rather than `contentView`; prefer inherited `titleLab`, `icon`, `checkIcon`, and `selectedBaseView` before adding replacement controls; implement `checkIcon` selected and unselected state display with cut image resources only, typically through `checkIcon.image` and `checkIcon.highlightedImage`; do not use background colors, borders, SF Symbols, drawn shapes, or runtime vector drawing for those states; call `super.setupUI()` from any override; use `snp.remakeConstraints` to reposition inherited controls when the Figma layout requires different constraints
- if the selected UI shown in Figma does not match the base class selected-state behavior, override `isSelected` in the custom cell subclass and put the UI correction in `didSet`; keep this correction inside the cell and update inherited controls such as `selectedBaseView`, `checkIcon`, `titleLab`, and `icon` where possible
- if the selected cell background is not a pure color, such as a gradient, image, textured fill, multi-layer shape, or other complex Figma background, configure that style through `GeneralOBBaseCell.selectedBaseView`; do not create a separate method such as `updateSelectedBackground`, `refreshSelectedStyle`, or another page-specific selected-background toggle method
- update `GeneralOBPage+Data.swift` so the matching enum case returns the full `GeneralOBPageData`
- override sizing or spacing delegate methods only when the Figma layout differs from `GeneralOBCollectionVC` defaults
- use `select(item:indexPath:)` or `unselect(item:indexPath:)` only when the page needs custom selection behavior; never use `makeSelectItems`, `makeSelectIndexes`, or any `makeSelect*` helper inside the page
- keep cell sizing, insets, and spacing responsive with `cx390(...)` and existing project layout patterns

Use this external initialization pattern for list pages, replacing `page` with the actual `GeneralOBData` property name. The `else { vc.makeSelectIndexes([]) }` branch is intentional: without saved state or an explicit Figma/announcement initial selection, list pages must start with no selected option.

```swift
if let data = GeneralOBData.shared.page {
    vc.makeSelectIndexes([.init(item: data, section: 0)]) { arr in
        GeneralOBData.shared.page = arr.first?.item
    }
} else {
    vc.makeSelectIndexes([]) { arr in
        GeneralOBData.shared.page = arr.first?.item
    }
}
```

For multi-select pages, use the same no-default rule:

```swift
if let data = GeneralOBData.shared.page {
    vc.makeSelectIndexes(data.map { IndexPath(item: $0, section: 0) }) { arr in
        GeneralOBData.shared.page = arr.map { $0.item }
    }
} else {
    vc.makeSelectIndexes([]) { arr in
        GeneralOBData.shared.page = arr.map { $0.item }
    }
}
```

For non-list pages with tap-to-select behavior:

- add the same page-specific `GeneralOBData` property for the selected index or indexes
- restore the current value from `GeneralOBData` during `setupUI`, `viewDidLoad`, or the existing page state setup point
- render selected and unselected UI from page-local state without using `makeSelectIndexes`
- in each tap handler, update the page-local selected value, save it back to `GeneralOBData`, and re-render the affected controls
- for multi-select, add or remove the tapped index from the `[Int]` value and save the full array back to `GeneralOBData`

If the current page announcement says not to use `UICollectionView`, this section does not apply to that page. Instead:

- inherit from `GeneralOBVC`
- do not introduce `UICollectionView`, `GeneralOBCollectionVC`, collection cells, or collection reload/update calls in page-specific files
- use existing non-collection controls, stack views, buttons, custom views, or static layout patterns from nearby `GeneralOBVC` pages
- keep page identity, localization, chrome flags, assets, title/subtitle layering, bottom button state, and other non-conflicting rules intact
- verify with a targeted search that page-specific files contain no `UICollectionView` or `GeneralOBCollectionVC`

## 8. SwiftUI Boundary

This skill is scoped to UIKit onboarding pages in the GeneralOB project. Do not implement a Figma page as SwiftUI under this skill. If the user explicitly asks for SwiftUI, stop and confirm whether they want to change the skill boundary or use another workflow.

## 9. Radius Translation

Figma often uses very large corner radius values such as `99` or `999` to mean a fully rounded capsule.

- When a Figma component radius is `99` or `999`, set the Swift radius to half of that component's rendered height.
- If the component height is fixed with `cx390(height)`, prefer `view.cornerRadius = cx390(height) / 2`.
- If the component height is dynamic, update the radius after layout with `view.cornerRadius = view.bounds.height / 2`, such as in `layoutSubviews`, `viewDidLayoutSubviews`, or a cell layout override.
- Do not copy `99`, `999`, `cx390(99)`, or `cx390(999)` into Swift for capsule components.
- For non-capsule Figma radii, preserve the explicit radius through the project's scaling helper, such as `cx390(24)`.

## 10. Asset Handling

Use assets deliberately:

- export bitmap images at the scale requested or implied by Figma
- export downloaded Figma images as PNG files with `2x` and `3x` variants; do not use SVG for page assets or `checkIcon` state assets in this project
- preserve transparency when needed
- put page-specific exported images under `GeneralOB/Assets.xcassets/GeneralOB/<page>/`, where `<page>` matches the `GeneralOBPage` case or project-approved page asset name
- create or update `GeneralOB/Assets.xcassets/GeneralOB/Contents.json` with `"properties" : { "provides-namespace" : true }`
- create or update `GeneralOB/Assets.xcassets/GeneralOB/<page>/Contents.json` with `"properties" : { "provides-namespace" : true }`
- choose descriptive, project-consistent image set names inside the page namespace
- for `GeneralOBBaseCell.checkIcon`, provide separate selected and unselected cut images in the asset catalog and wire them as image states instead of drawing the state in code
- reference namespaced assets in Swift with the `GeneralOB/<page>/...` pattern, such as `UIImage(named: "GeneralOB/<page>/<assetName>")`; do not rely on unqualified root-level image names for page-specific exports
- keep existing root-level assets only when they are already shared cross-page assets
- do not replace existing assets with the same name unless the user asked for that exact replacement
- verify that `UIImage(named:)`, SwiftUI `Image`, or bundle lookup matches where the asset was added

## 11. Verification

Run the strongest reasonable checks:

- confirm the `OB-Task-Doc` preflight passed before Figma reading and implementation, and that any folder copied from `assets/OB-Task-Doc` was placed at the project root without adding it to `.xcodeproj`, app targets, build phases, or Copy Bundle Resources
- confirm the `GeneralOB` structure preflight passed before Figma reading and implementation, that any folder copied from `assets/GeneralOB` was placed in the app source directory one level below the `.xcodeproj`-level directory rather than beside `.xcodeproj`, and that copied Swift files are members of the primary app target Compile Sources or equivalent generated target source list
- if `GeneralOB` was copied from the skill scaffold, run a targeted project inspection such as searching `project.pbxproj` or the generator config for `GeneralOBCollectionVC.swift`, `GeneralOBPage.swift`, `GeneralOBPage+Data.swift`, `GeneralOBPage+VC.swift`, and `GeneralOBVC.swift`
- inspect `git diff` for accidental unrelated churn
- if running from `OBFigma.md`, confirm only the current page block's status marker changed and it reflects `in_progress`, `failed`, or `done` accurately
- if the current `OBFigma.md` block contains multiple Figma links, confirm all links were treated as UI states of the same page and no extra page enum/file/commit was created for a state link
- if the current `OBFigma.md` block contains `### announcement`, confirm every announced condition is satisfied and include that proof in the final response before marking the page `done`
- if an announcement referenced images or documents, confirm `OB-Task-Doc/` was searched first, list the resolved paths, and explain how each reference was used
- if an announcement says `不使用UICollectionView`, run a targeted check on the page-specific files to confirm no `UICollectionView` or `GeneralOBCollectionVC` usage was introduced
- confirm all new page implementation files are under `GeneralOB/Pages`
- confirm new page file names and class names follow `OB<Page>VC`
- confirm every new user-visible string uses `#Localized("...")` and files using the macro import `OOGMacroKits`
- confirm each new `GeneralOBPage` case has one matching page implementation and one `pageData` branch
- confirm Figma chrome visibility is reflected in `GeneralOBPage`: absent back button -> `canBack = false`, absent progress bar -> `isHideProgress = true`, absent bottom continue button -> `isHideContinueBtn = true`
- confirm option-style pages inherit from `GeneralOBCollectionVC`, override `registerCell` and `cell(_ c: UICollectionView, path: IndexPath)`, and do not hardcode option arrays in view code
- for list pages and non-list tap-to-select pages, confirm `GeneralOBData` has a page-specific `Int?` or `[Int]?` selected-index property
- for list pages, confirm the external `page.vc` construction path calls `vc.makeSelectIndexes` to restore saved selected indexes and save later selected indexes back to `GeneralOBData`
- for list pages, confirm `page.vc` uses only `GeneralOBData` as the restore source and calls `vc.makeSelectIndexes([])` when `GeneralOBData` has no saved value, unless Figma or the page announcement explicitly requires an initial selected state
- for non-list tap-to-select pages, confirm the page restores its selected value from `GeneralOBData`, updates visible selected UI from page-local state, saves changes back to `GeneralOBData` in tap handlers, and does not call `makeSelectIndexes`
- confirm option-list page metadata matches Figma: `multipleSelected = true` for multi-select pages; `cellHeightIsConsistent = true` for same-height cells and `false` for variable-height cells
- confirm no `UICollectionView` reload methods are called, including `reloadData()`, `reloadItems(at:)`, and `reloadSections(_:)`
- confirm no page implementation, cell, or page-local helper calls `makeSelectItems`, `makeSelectIndexes`, or any `makeSelect*` method
- confirm custom bottom continue button states are implemented only through `nextBtnEnable.didSet` and no new button-state update method was added
- confirm no page implementation, page-local custom view, or cell assigns `UIImageView.contentMode`
- confirm option data uses `GeneralOBPageItem(title: "abc", localizedTitle: #Localized("abc"), ...)`
- confirm custom `GeneralOBBaseCell` subclasses add new controls to `baseView`, reuse `titleLab`, `icon`, `checkIcon`, and `selectedBaseView` where possible, implement `checkIcon` selected and unselected states with cut images only, call `super.setupUI()`, and use `snp.remakeConstraints` for inherited layout changes
- if selected cell UI differs from the base class behavior, confirm the custom cell subclass overrides `isSelected` and performs the visual correction in `didSet`
- if a selected cell background is not a pure color, confirm it uses `selectedBaseView` and no new selected-background update or refresh method was added
- confirm Figma radius values `99` and `999` are implemented as half-height capsule radii, not copied as fixed Swift constants
- confirm new page-specific image assets are under `GeneralOB/Assets.xcassets/GeneralOB/<page>/`
- confirm downloaded Figma image resources are PNG `2x` and `3x` variants, not SVG
- confirm that both the `GeneralOB` asset folder and page asset folder have `provides-namespace` enabled and Swift references use `GeneralOB/<page>/...` namespaced asset paths
- confirm title and subtitle views render above images, collections, cards, decoration, gradients, and background art
- if the Figma page frame height is greater than `844`, confirm the main content is in a scrollable region and the bottom continue button is fixed outside the scroll view, floating above it with sufficient bottom inset or padding
- run `xcodebuild` for the workspace or project when available and practical
- if build is blocked, run targeted static checks such as `xcodebuild -list`, `swiftc` only when suitable, or project file inspection
- compare the implemented layout against the Figma screenshot at the relevant device size
- check long text, small screens, iPad variants, safe-area edges, disabled states, and touch targets
- verify missing assets do not render blank

Never claim pixel-perfect implementation unless the rendered app was compared to the Figma screenshot.

## 12. Per-Page Commit and Retry

When processing pages from `OBFigma.md`:

- after a page passes verification, mark the page `done` in `OBFigma.md`
- inspect `git status --short` and `git diff` before staging
- stage only files that belong to the completed page, related assets, project metadata required for those files, and the `OBFigma.md` status marker
- do not stage unrelated user changes or other unfinished page work
- create one git commit per completed page, using a message that includes the page id or page name, for example `Implement OB 001 body reading begins`
- after the commit succeeds, record the short commit hash in that page's status marker
- continue with the next not-done page only after the current page has a successful commit
- if verification, staging, or commit fails, mark the page `failed` with the attempt count and reason, keep the current page as the next retry target, and do not advance the queue
- on retry, read the failed page's status marker, increment `attempts`, and re-run the same page task using the existing code and diff as context

## 13. Final Response

Keep the final response concise and include:

- `OB-Task-Doc` preflight result, including whether the root folder already existed or was copied from the skill-bundled `assets/OB-Task-Doc` scaffold, and confirmation that it was not added to the Xcode project
- `GeneralOB` structure preflight result, including whether the required folder already existed or was copied from the skill-bundled `assets/GeneralOB` scaffold before implementation, where it was copied in the app source directory, confirmation that it was not placed beside `.xcodeproj` at the top level, and how target membership was verified
- `OBFigma.md` page id, page title, status transition, attempt count, and commit hash when queue mode is used
- every Figma URL in the processed `OBFigma.md` block and the UI state each one represents
- any `### announcement` conditions in the processed block and how the implementation satisfies each condition
- any announcement reference images or documents, with the resolved `OB-Task-Doc/...` paths searched or used first
- changed files
- `GeneralOBPage` case to page implementation mapping
- `GeneralOBPage` chrome flags changed for back button, progress bar, or bottom continue button
- new page class and filename, confirming the `OB<Page>VC` naming rule
- localization confirmation for visible strings and `OOGMacroKits` imports
- whether the page is option-style, where its `pageData` is defined, and which `GeneralOBCollectionVC` hooks were overridden
- the `GeneralOBData` property used for selection persistence and whether it is `Int?` or `[Int]?`
- for list pages, where `page.vc` restores and saves selection through `vc.makeSelectIndexes`, and whether it calls `vc.makeSelectIndexes([])` when there is no saved value and no explicit initial-selection requirement
- for non-list tap-to-select pages, where the page restores, toggles, saves, and re-renders selection through `GeneralOBData`
- option-list metadata values for `multipleSelected` and `cellHeightIsConsistent`, with the Figma behavior that drove each value
- confirmation that the implementation does not call any `UICollectionView` reload method
- confirmation that the page implementation does not call any `makeSelect*` method
- confirmation that bottom continue button state UI is handled by `nextBtnEnable.didSet`
- confirmation that no `UIImageView.contentMode` assignment was added in page code
- whether `GeneralOBPageItem` option data uses both raw `title` and localized `localizedTitle`
- any custom `GeneralOBBaseCell` subclass details, including `baseView` additions, inherited control reuse, `selectedBaseView` for non-solid selected backgrounds, `checkIcon` selected and unselected cut images, `super.setupUI()`, and `snp.remakeConstraints`
- whether selected cell UI needed a custom `isSelected.didSet` correction and what inherited controls it updates
- any Figma `99` or `999` corner radius translations applied
- the `GeneralOB/<page>/...` asset namespace used for exported PNG `2x` and `3x` images
- whether the Figma frame height is greater than `844`; if so, how scrolling content and the fixed floating bottom button were implemented
- how title and subtitle layer order was preserved
- reused base classes, components, pods, helpers, and assets
- verification performed
- known compromises or follow-up risks
