# Implementation Workflow

Use this checklist when turning Figma into Swift code inside an existing iOS project.

## 1. Inputs

Confirm the concrete design target:

- `OB-Task-Doc/OBFigma.md` page queue, when present; legacy `GeneralOB/OBFigma.md` is a fallback only
- optional shared BaseCell specification headed `# BaseCell` or `## BaseCell` in `OBFigma.md`, including Figma links that show its cell states, back button, and bottom next button
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

When `OB-Task-Doc/OBFigma.md` exists, read it automatically before asking for page input. If it is absent, fall back to legacy `GeneralOB/OBFigma.md`. Treat a section whose normalized heading is `BaseCell`, including `# BaseCell` or `## BaseCell`, as a shared BaseCell specification rather than a page, and treat each numeric or project-approved `## <id>` section as one page task with optional title text, one or more Figma URLs, optional `### announcement` constraints, and `ob-status` marker.

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

## 1C. OBFigma Queue and BaseCell Mode

Use `OB-Task-Doc/OBFigma.md` as the primary resumable queue, with legacy `GeneralOB/OBFigma.md` as a fallback when the task-doc queue file is absent:

- when a heading normalized by trimming Markdown heading markers and whitespace equals `BaseCell`, parse it separately from the page manifest; support both `# BaseCell` and `## BaseCell`, and end its content at the first subsequent `## <id>` page block or next heading of the same or higher level
- require every Figma link in the BaseCell section to visibly include its cell state, back button, and bottom next button; if a link omits either shared button, stop and report the missing design evidence instead of borrowing styles from a page block
- process the BaseCell section in the parent worktree before dispatching any page subagent because it owns shared onboarding foundations
- locate the existing file that declares `GeneralOBBaseCell`, normally `GeneralOB/GeneralOBCollectionVC.swift`, and modify only the `GeneralOBBaseCell` declaration there; do not create a parallel base cell, page-specific cell, or wrapper
- locate `GeneralOBVC.swift` and put the Figma bottom next button's common visual properties directly in the existing `GeneralOBVC.nextButton` lazy declaration; do not put this baseline in an `OB<Page>VC`, a page-specific override, or a new button
- locate the primary app asset catalog and create or replace `Assets.xcassets/GeneralOB/icon_back.imageset`; BaseCell asset target includes `Assets.xcassets/GeneralOB/Contents.json` only to enable `provides-namespace`, plus the image-set files; verify the shared lookup is `UIImage(named: "GeneralOB/icon_back")` or its existing equivalent
- export the back control at a 44x44 pt logical size as PNG: `icon_back@2x.png` must be exactly 88x88 pixels and `icon_back@3x.png` must be exactly 132x132 pixels; map them to `2x` and `3x` in `Contents.json` and do not generate a page-namespaced copy
- Do not add or modify `GeneralOBPage`, `GeneralOBPage.pageData`, `GeneralOBPage.vc`, `GeneralOBData`, any `OB<Page>VC`, anything under `GeneralOB/Pages`, page-specific assets, or page routing for the BaseCell section
- implement the unselected container layout and appearance in `baseView`; implement every selected container effect in `selectedBaseView`, including its background, border, gradient, shadow, and corner treatment; keep `isSelected` responsible only for showing or hiding these shared states and updating shared foreground content
- do not give `# BaseCell` or `## BaseCell` a page id, `ob-status` marker, page attempt count, page agent, `GeneralOBPage` mapping, or page-specific commit; report it separately as a shared-foundation update covering the cell, back icon, and next button
- parse page blocks in document order from headings such as `## 001`, `## 002`, and so on
- collect every Figma URL inside the same page block
- collect any `### announcement` section inside the same page block; its text applies only to that page block
- if the announcement mentions reference images, reference documents, attachments, filenames, or relative paths, resolve those files from `OB-Task-Doc/` before checking any other location
- treat multiple Figma URLs inside one `## <id>` page block as multiple UI display states of the same page, not as separate pages; this page rule does not apply to the `# BaseCell` variants above
- implement all URLs in a block through one `GeneralOBPage` case and one `OB<Page>VC` page implementation, unless the user explicitly changes the queue structure
- before implementation, apply every non-conflicting requirement from the opening Workflow and Project Fit Rules to the selected page block; queue mode does not waive those requirements
- treat announcement lines as hard page-level implementation constraints that must be satisfied before the page can be marked `done`
- treat any announcement-linked reference file found under `OB-Task-Doc/` as part of the hard page-level constraints
- when a page announcement conflicts with any opening Workflow or Project Fit implementation rule, follow the announcement for that page, retain all non-conflicting rules, and report the conflict plus the announcement-driven implementation
- example: `不使用UICollectionView` means do not use `UICollectionView`, `GeneralOBCollectionVC`, collection cells, or collection reload/update APIs in that page, even if it looks option-style; use `GeneralOBVC` or another existing non-collection project pattern instead
- preserve existing page text and Figma links; edit only status marker lines
- treat a missing marker as `todo`
- supported markers are HTML comments inside the page block, such as `<!-- ob-status: todo -->`, `<!-- ob-status: in_progress; attempts: 1 -->`, `<!-- ob-status: failed; attempts: 1; reason: figma read failed -->`, `<!-- ob-status: blocked; reason: <external dependency> -->`, and `<!-- ob-status: done; commit: <hash> -->`
- build a complete manifest of every page block before implementation, including id, title, URLs, announcement, references, and status
- the parent agent dispatches exactly one isolated subagent for the next page not marked `done`; do not dispatch another page agent until the active page commit is integrated
- before dispatch, the parent records `in_progress` and initializes or increments attempts only for the active page; subagents do not edit `OBFigma.md` markers in the parent worktree
- after its page passes verification, each subagent stages only the assigned page's implementation, assets, and required project metadata in its isolated worktree and creates exactly one page-specific git commit
- each subagent returns that commit hash, its verification evidence, announcement compliance, changed-file list, and shared-file integration conflicts
- the parent integrates the active page commit, resolves conflicts in shared `GeneralOBPage`, page-data, data-model, asset, localization, and queue files, then records the accepted page as `done` before dispatching the next agent
- retry a failed page before dispatching later pages; record a true external blocker as `blocked` and include it in the consolidated summary
- after every page is integrated or explicitly blocked, run one workspace/project scheme `xcodebuild ... build` action, then provide one final response
- keep status markers close to the page heading so humans can scan progress quickly

## 2. Figma Read

Gather only the design context needed for implementation:

- screenshot of the node
- frame size and constraints, including whether the frame height is greater than `844`
- text content, typography, colors, opacity, shadows, radii, strokes, blur, and spacing
- exported image assets and vector assets
- image export requirements: choose the resource format and scale supported by Figma and the project
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
- `rg "GeneralOBCollectionVC|GeneralOBCollectionSectionVC|OBSleepVC|registerCell|cell\\(_ c: UICollectionView|pageData|GeneralOBPageData|GeneralOBPageItem|UICollectionView" -n` for page data and option-list patterns; for `CollectionSection`, inspect `GeneralOB/Pages/OBSleepVC.swift` before writing the cell hooks
- `rg "GeneralOBData|makeSelectIndexes|makeSelectItems|var .*: Int\\?|var .*: \\[Int\\]\\?" -n` for persisted selection state, list-page external VC initialization patterns, and non-list page tap handlers
- `rg "multipleSelected|cellHeightIsConsistent" -n` for option-list page metadata
- `rg "UIImage\\s*\\(\\s*systemName:|systemName:" -n GeneralOB/Pages` to ensure changed list-page code does not substitute Figma list-item icons with system symbols
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

- screen container: `GeneralOBVC` for ordinary pages; `GeneralOBCollectionVC` for option-style pages unless the current page announcement forbids `UICollectionView` or otherwise requires a non-collection implementation; `GeneralOBCollectionSectionVC` when the page declaration contains `CollectionSection`, with a page override of `sectionDetail(sec:)` for expanded information
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
- page imports and localization: every new or modified Figma page Swift file, including page-specific views and cells, imports `UIKit`, `Components`, `OOGFontKit`, `OOGMacroKits`, and `SnapKit` before declarations; wrap all displayed copy in `#Localized("...")`
- agreement links: when a page contains privacy policy and terms-of-use copy, use `GeneralLinkTextView` with `QACheck.PRIVACY_URL` and `QACheck.TERM_OF_USE_URL` so both links are tappable
- spacing: local scale helpers such as `cx390(...)`; include iPad and small-device variants when the project does
- colors: local token, asset, or hex initializer already used by the project
- corner radius: copy ordinary Figma radii through local helpers; translate Figma radii `99` and `999` to half of the component height
- images: existing asset catalog names or newly exported Figma assets placed under the `GeneralOB/<page>/...` namespaced asset path
- image views: do not set `UIImageView.contentMode` in page code, page-local custom views, or cells
- Figma image export: choose the resource format and scale supported by Figma and the project
- collection updates: never call `UICollectionView` reload APIs; rely on `GeneralOBCollectionVC` diffable snapshots, `mainPage.pageData.items`, selection methods, and direct state updates
- initial selection: `makeSelectItems`, `makeSelectIndexes`, and other `makeSelect*` helpers are external page-creation APIs for list pages and must not be called inside the page implementation; for list pages, use them only to restore saved `GeneralOBData` values or an explicitly specified Figma/announcement initial state, and otherwise call `vc.makeSelectIndexes([])`; for non-list tap-to-select pages, restore and save selection directly through `GeneralOBData` in the page's own state and tap handling code
- bottom continue button state: use `override var nextBtnEnable: Bool { didSet { ... } }` for custom enabled or disabled appearance; do not create a separate update or refresh method for the bottom button state
- controls: existing buttons, labels, `GeneralOBCollectionVC` and its collection cell hooks for option pages, progress bars, modals, toasts, and onboarding components
- circular progress: when Figma shows a circular progress view, use `GeneralOBCircleProgress` rather than drawing a new circular layer or using another progress control. Configure it as follows unless the page announcement conflicts:

```swift
private lazy var progressView: GeneralOBCircleProgress = {
    let res = GeneralOBCircleProgress()
    res.lineWidth = cx390(14)
    res.trackColor = .init("#0F172A0D")
    res.gradientColors = [
        .init("#9E95FC"),
        .init("#5E7BFB")
    ]
    return res
}()
```

Create new code only for genuinely new UI structure or behavior. Keep new helper APIs private or file-scoped unless there is clear local precedent for sharing. Do not bypass `GeneralOBVC` by creating a direct `OBBaseViewController` or plain `UIViewController` page.

## 5. Page Structure

For every new Figma page:

- if running from `OBFigma.md`, update only the current page block's status marker before work; do not mark future pages
- if the current `OBFigma.md` block contains multiple Figma URLs, read and implement them together as UI states of the same page
- if the current `OBFigma.md` block contains `### announcement`, write down each announced condition and choose implementation details that satisfy it before editing Swift
- before editing Swift, identify the opening Workflow and Project Fit Rules that apply to the selected page; preserve all non-conflicting rules and record any page-announcement conflict as an announcement override
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
- when the page declaration contains `CollectionSection`, subclass `GeneralOBCollectionSectionVC` instead of `GeneralOBCollectionVC`; this specialized class retains the shared collection behavior while rendering option data as sections
- preserve required initializers and lifecycle patterns
- define views as `lazy var` or local equivalents consistent with nearby code
- every new or modified Figma page Swift file, including page-specific views and cells, must declare this complete import set before declarations, even if a module is not visibly referenced:

```swift
import UIKit
import Components
import OOGFontKit
import OOGMacroKits
import SnapKit
```
- set visible copy with the macro, for example `titleLab.text = #Localized("Title")`, `button.setTitle(#Localized("Continue"), for: .normal)`, and `GeneralOBPageItem(title: "Choice", localizedTitle: #Localized("Choice"), icon: "...")`
- when a page includes the agreement text for `Privacy Policy` and `Terms of Use`, implement it with this project pattern so both links remain clickable; do not replace it with a plain `UILabel`, a static `NSAttributedString`, or non-clickable text:

```swift
private lazy var agreementLabel: GeneralLinkTextView = {
    let privacy = #Localized("Privacy Policy")
    let term = #Localized("Terms of Use")
    let s = #Localized("By continuing you agree to the %@ and %@")
    let txt = String(format: s, privacy, term)

    let baseAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.laien(.regular, fontSize: cx390(14)),
        .foregroundColor: UIColor("#A9B2C2"),
        .paragraphStyle: centeredParagraphStyle
    ]
    let linkAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.laien(.regular, fontSize: cx390(14)),
        .underlineStyle: NSUnderlineStyle.single.rawValue,
        .underlineColor: UIColor("#7C8798"),
        .paragraphStyle: self.centeredParagraphStyle
    ]

    let label = GeneralLinkTextView.createLinkView(
        with: txt,
        attributes: baseAttributes
    )
    label.tintColor = UIColor("#7C8798")
    label.setlinkAttribute(
        privacy,
        QACheck.PRIVACY_URL,
        linkAttributes
    )
    label.setlinkAttribute(
        term,
        QACheck.TERM_OF_USE_URL,
        linkAttributes
    )
    return label
}()
```

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
- the complete page import set: `UIKit`, `Components`, `OOGFontKit`, `OOGMacroKits`, and `SnapKit`; use `#Localized("...")` for all user-visible strings
- scrollable content for Figma page frames taller than `844`, with the bottom continue button fixed outside the scroll view
- `GeneralOBVC` inheritance for ordinary visual pages
- `GeneralOBCollectionVC` inheritance for option-style visual pages unless the current page announcement forbids `UICollectionView`
- `GeneralOBViewModel` and `OnboardingPagesDataSource` for page construction
- `SnapKit` constraints and `cx390(...)` scaling
- `Components` extensions such as `UIColor("#...")` and `cornerRadius`
- `OOGFontKit` typography such as `.figtree(.bold, fontSize: cx390(...))`

## 7. Option-Style Pages

If the Figma page presents selectable options, cards, goals, interests, answers, categories, or any repeated choice list:

- when the page declaration contains `CollectionSection`, inherit from `GeneralOBCollectionSectionVC` and implement the two cell hooks with the current project's `GeneralOB/Pages/OBSleepVC.swift` pattern. Do this even when the cell otherwise resembles `GeneralOBBaseCell`; this rule takes precedence over the ordinary default-cell reuse rule:

```swift
override func registerCell() {
    super.registerCell()
    collection.register(cellWithClass: OB<Page>Cell.self)
}

override func cell(
    _ c: UICollectionView,
    path: IndexPath
) -> GeneralOBBaseCell {
    if path.item > 0 {
        return c.dequeueReusableCell(
            withClass: OB<Page>Cell.self,
            for: path
        )
    }
    return super.cell(c, path: path)
}
```

  Do not omit `super.registerCell()`, replace the `path.item > 0` condition, or bypass the `super.cell(c, path: path)` fallback unless the page announcement explicitly overrides this rule.

  Also override `sectionDetail(sec: Int) -> GeneralOBPageItem` to return the selected section's real expanded information. Preserve the selected item's applicable title, localized title, and icon, and supply the Figma-defined localized expansion text; do not return the base placeholder or `.init(icon: "")`:

```swift
override func sectionDetail(
    sec: Int
) -> GeneralOBPageItem {
    guard let item = dataList[safe: sec]?.first else {
        return .init(icon: "")
    }
    return .init(
        title: item.title,
        localizedTitle: item.localizedTitle,
        localizedSubtitle: #Localized("<Figma expansion text>"),
        icon: item.icon
    )
}
```
- otherwise inherit from `GeneralOBCollectionVC`; do not create a fresh `UICollectionView`, diffable data source, delegate stack, selection pipeline, or initial data loading flow
- set the page's `multipleSelected` metadata from Figma selection behavior; multi-select lists must return `true`
- set the page's `cellHeightIsConsistent` metadata from Figma cell height behavior; same-height lists return `true`, variable-height lists return `false`
- never call `reloadData()`, `reloadItems(at:)`, `reloadSections(_:)`, or wrapper helpers that trigger `UICollectionView` reloads
- for pages without `CollectionSection`, first compare the Figma cell with `GeneralOBBaseCell`: when it is the inherited `icon` + `titleLab` + `checkIcon` layout and the title font and color match, use `GeneralOBCollectionVC`'s default `GeneralOBBaseCell` registration and dequeue flow. Do not create a cell subclass or override `registerCell` / `cell(_ c: UICollectionView, path: IndexPath)` for this matching case
- create or reuse a cell class in `GeneralOB/Pages` only when Figma requires a real layout, title typography/color, icon treatment, or behavior difference from `GeneralOBBaseCell`
- when a page-specific cell is required, override `registerCell()` to register it and `cell(_ c: UICollectionView, path: IndexPath) -> GeneralOBBaseCell` to dequeue and return it; for `CollectionSection` pages, use the `OBSleepVC` call order and fallback exactly
- let `GeneralOBCollectionVC` feed data from `mainPage.pageData.items`, apply the diffable data source, handle selection, and call `clickNext`
- add a persisted selection field in `GeneralOBData`; use `Int?` for single-select and `[Int]?` for multi-select
- in the external `GeneralOBPage` `page.vc` construction path, restore and save list selection with `vc.makeSelectIndexes`; this is the allowed place to call `makeSelectIndexes`
- unless Figma or the page announcement explicitly specifies an initial selected option, `page.vc` must not default-select the first option or any other option; when `GeneralOBData` has no saved value, call `vc.makeSelectIndexes([])`
- when UI state changes, update the model through the existing page data or selection flow, or update the affected visible cell state directly; do not refresh the collection by reload
- do not call `makeSelectItems`, `makeSelectIndexes`, or any `makeSelect*` method inside the page; those helpers are only for the external VC initialization code that creates the page
- represent choice content with `GeneralOBPageItem` fields such as `title`, `localizedTitle`, and `icon`
- initialize choice content with both `title` and `localizedTitle`, for example `GeneralOBPageItem(title: "abc", localizedTitle: #Localized("abc"), icon: "...")`
- when Figma shows an icon in a list item, export that icon in a Figma- and project-supported format and set `GeneralOBPageItem.icon` to its namespaced asset name; do not use SF Symbols, `UIImage(systemName:)`, `systemName:`, drawn shapes, or runtime vectors as a substitute. When Figma provides different selected and unselected list icons, export and wire both state-specific assets.
- use `#Localized("...")` for `localizedTitle` and any visible cell or tag text
- when subclassing `GeneralOBBaseCell`, add new controls to `baseView` rather than `contentView`; prefer inherited `titleLab`, `icon`, `checkIcon`, and `selectedBaseView` before adding replacement controls. Preserve the base class `checkIcon` images: do not assign `checkIcon.image` or `checkIcon.highlightedImage`, and do not add page-specific selected or unselected `checkIcon` assets; call `super.setupUI()` from any override; use `snp.remakeConstraints` to reposition inherited controls when the Figma layout requires different constraints
- if the selected UI shown in Figma does not match the base class selected-state behavior, override `isSelected` in the custom cell subclass and put the UI correction in `didSet`; keep this correction inside the cell and update only foreground content such as `titleLab`, `icon`, and other text or image state. Do not assign `checkIcon.image` or `checkIcon.highlightedImage`, and do not change `baseView` or `selectedBaseView` backgrounds, borders, layer properties, corner radius, shadows, gradients, or other selected-container visual effects
- do not implement Figma-specific selected cell backgrounds, borders, gradients, shadows, or other container effects in a custom cell's `isSelected`; preserve the base class container treatment
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

- export Figma assets in a format and scale supported by both Figma and the project
- preserve transparency when needed
- put page-specific exported images under `GeneralOB/Assets.xcassets/GeneralOB/<page>/`, where `<page>` matches the `GeneralOBPage` case or project-approved page asset name
- create or update `GeneralOB/Assets.xcassets/GeneralOB/Contents.json` with `"properties" : { "provides-namespace" : true }`
- create or update `GeneralOB/Assets.xcassets/GeneralOB/<page>/Contents.json` with `"properties" : { "provides-namespace" : true }`
- choose descriptive, project-consistent image set names inside the page namespace
- treat Figma list-item icons as required page assets whenever the design displays them; keep their image set names descriptive and reference them through `GeneralOB/<page>/...`, never through a system-symbol fallback
- preserve the base class `GeneralOBBaseCell.checkIcon` image configuration; do not add or wire page-specific selected or unselected `checkIcon` assets
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
- when a BaseCell section exists, confirm it was processed before page dispatch, was excluded from the page manifest and page status markers, and every Figma link visibly showed the shared cell, back button, and bottom next button
- confirm BaseCell implementation changes are limited to the existing `GeneralOBBaseCell` declaration, `GeneralOBVC.nextButton`, and the shared asset target consisting of `Assets.xcassets/GeneralOB/Contents.json` plus `icon_back.imageset`
- confirm the cell's unselected container treatment is implemented in `baseView` and every selected background, border, gradient, shadow, and corner treatment is implemented in `selectedBaseView`
- confirm the shared bottom-button Figma style is implemented directly in `GeneralOBVC.nextButton`, not an `OB<Page>VC`, page-specific override, or new button
- use `sips -g pixelWidth -g pixelHeight -g format` or an equivalent image inspector to confirm `icon_back@2x.png` is PNG 88x88 and `icon_back@3x.png` is PNG 132x132; inspect `Contents.json` for correct `2x` and `3x` mappings and verify the lookup `GeneralOB/icon_back` resolves
- confirm no `GeneralOBPage`, `pageData`, `page.vc`, `GeneralOBData`, `OB<Page>VC`, `GeneralOB/Pages` file, page-specific cell, page asset namespace, or page routing change was introduced for BaseCell
- if running from `OBFigma.md`, confirm the parent alone updated page status markers after collecting subagent results and that every dispatched page accurately reflects `in_progress`, `failed`, `blocked`, or `done`
- if the current `OBFigma.md` block contains multiple Figma links, confirm all links were treated as UI states of the same page and no extra page enum/file/commit was created for a state link
- if the current `OBFigma.md` block contains `### announcement`, confirm every announced condition is satisfied and include that proof in the final response before marking the page `done`
- if a page announcement conflicts with an opening Workflow or Project Fit implementation rule, confirm the announcement was followed for that page, every non-conflicting opening rule was still satisfied, and the conflict is reported
- if an announcement referenced images or documents, confirm `OB-Task-Doc/` was searched first, list the resolved paths, and explain how each reference was used
- if an announcement says `不使用UICollectionView`, run a targeted check on the page-specific files to confirm no `UICollectionView` or `GeneralOBCollectionVC` usage was introduced
- confirm all new page implementation files are under `GeneralOB/Pages`
- confirm new page file names and class names follow `OB<Page>VC`
- confirm every new or modified Figma page Swift file, including page-specific views and cells, imports `UIKit`, `Components`, `OOGFontKit`, `OOGMacroKits`, and `SnapKit` before declarations; confirm every new user-visible string uses `#Localized("...")`
- if the page contains privacy policy or terms-of-use agreement text, confirm it is implemented with `GeneralLinkTextView.createLinkView`, localized `Privacy Policy`, localized `Terms of Use`, localized `By continuing you agree to the %@ and %@`, and clickable `QACheck.PRIVACY_URL` / `QACheck.TERM_OF_USE_URL` link attributes
- confirm each new `GeneralOBPage` case has one matching page implementation and one `pageData` branch
- confirm Figma chrome visibility is reflected in `GeneralOBPage`: absent back button -> `canBack = false`, absent progress bar -> `isHideProgress = true`, absent bottom continue button -> `isHideContinueBtn = true`
- confirm option-style pages inherit from `GeneralOBCollectionVC` and do not hardcode option arrays in view code. When the page declaration contains `CollectionSection`, confirm it inherits from `GeneralOBCollectionSectionVC` and matches `OBSleepVC`: `registerCell()` calls `super.registerCell()` before registering the page-specific cell; `cell(_:path:)` dequeues it only for `path.item > 0` and otherwise returns `super.cell(c, path: path)`; `sectionDetail(sec:)` is overridden to return the selected section's localized Figma expansion data, rather than the base placeholder. For pages without `CollectionSection`, when the Figma cell is the inherited `icon` + `titleLab` + `checkIcon` layout with matching title font and color, confirm the page uses the default `GeneralOBBaseCell` flow with no cell subclass or `registerCell` / `cell(_ c: UICollectionView, path: IndexPath)` override; otherwise confirm the custom cell is required by a real Figma difference
- when Figma displays list-item icons, confirm every icon uses the corresponding exported `GeneralOB/<page>/...` asset, state-specific Figma assets are used when shown, and changed list-page code has no `UIImage(systemName:)` or `systemName:` fallback
- for list pages and non-list tap-to-select pages, confirm `GeneralOBData` has a page-specific `Int?` or `[Int]?` selected-index property
- for list pages, confirm the external `page.vc` construction path calls `vc.makeSelectIndexes` to restore saved selected indexes and save later selected indexes back to `GeneralOBData`
- for list pages, confirm `page.vc` uses only `GeneralOBData` as the restore source and calls `vc.makeSelectIndexes([])` when `GeneralOBData` has no saved value, unless Figma or the page announcement explicitly requires an initial selected state
- for non-list tap-to-select pages, confirm the page restores its selected value from `GeneralOBData`, updates visible selected UI from page-local state, saves changes back to `GeneralOBData` in tap handlers, and does not call `makeSelectIndexes`
- confirm option-list page metadata matches Figma: `multipleSelected = true` for multi-select pages; `cellHeightIsConsistent = true` for same-height cells and `false` for variable-height cells
- confirm no `UICollectionView` reload methods are called, including `reloadData()`, `reloadItems(at:)`, and `reloadSections(_:)`
- confirm no page implementation, cell, or page-local helper calls `makeSelectItems`, `makeSelectIndexes`, or any `makeSelect*` method
- confirm custom bottom continue button states are implemented only through `nextBtnEnable.didSet` and no new button-state update method was added
- confirm no page implementation, page-local custom view, or cell assigns `UIImageView.contentMode`
- when Figma shows a circular progress view, confirm the page uses `GeneralOBCircleProgress` with `lineWidth = cx390(14)`, track color `#0F172A0D`, and gradient colors `#9E95FC` / `#5E7BFB`, unless the page announcement overrides that configuration
- confirm option data uses `GeneralOBPageItem(title: "abc", localizedTitle: #Localized("abc"), ...)`
- confirm custom `GeneralOBBaseCell` subclasses add new controls to `baseView`, reuse `titleLab`, `icon`, `checkIcon`, and `selectedBaseView` where possible, preserve inherited `checkIcon` images without assigning `checkIcon.image` or `checkIcon.highlightedImage`, call `super.setupUI()`, and use `snp.remakeConstraints` for inherited layout changes
- if a page-specific selected cell UI differs from the shared base-class behavior, confirm the custom cell subclass overrides `isSelected` only to update foreground title, icon, text, or image state in `didSet`, without assigning `checkIcon.image` or `checkIcon.highlightedImage`
- confirm page-specific cell subclasses do not modify `baseView` or `selectedBaseView` backgrounds, borders, layer properties, corner radius, shadows, gradients, or other container effects; those shared effects belong to the `# BaseCell` implementation in `GeneralOBBaseCell`
- confirm Figma radius values `99` and `999` are implemented as half-height capsule radii, not copied as fixed Swift constants
- confirm new page-specific image assets are under `GeneralOB/Assets.xcassets/GeneralOB/<page>/`
- confirm downloaded Figma image resources use a Figma- and project-supported format and scale
- confirm that both the `GeneralOB` asset folder and page asset folder have `provides-namespace` enabled and Swift references use `GeneralOB/<page>/...` namespaced asset paths
- confirm title and subtitle views render above images, collections, cards, decoration, gradients, and background art
- if the Figma page frame height is greater than `844`, confirm the main content is in a scrollable region and the bottom continue button is fixed outside the scroll view, floating above it with sufficient bottom inset or padding
- each subagent performs non-`xcodebuild` source, project-file, visual, and interaction checks for its assigned page; after all page commits are integrated, the parent performs cross-page checks and runs one workspace/project scheme `xcodebuild ... build` action for the complete queue
- compare the implemented layout against the Figma screenshot at the relevant device size
- check long text, small screens, iPad variants, safe-area edges, disabled states, and touch targets
- verify missing assets do not render blank

Never claim pixel-perfect implementation unless the rendered app was compared to the Figma screenshot.

## 12. Parent Integration and Retry

When processing pages from `OBFigma.md`:

- the parent completes and verifies the optional BaseCell shared-foundation update for `GeneralOBBaseCell`, `GeneralOBVC.nextButton`, and `GeneralOB/icon_back` before dispatching the first page subagent; it does not assign that work to a page agent or add a page status marker
- the parent dispatches exactly one isolated subagent at a time and integrates its result before dispatching the next page agent
- subagents do not stage, commit, or edit `OBFigma.md` on the parent branch; after each successful assigned page, they stage only that page's changes and create exactly one page-specific commit in their isolated worktree
- the parent inspects `git status --short` and `git diff`, integrates the active page commit, and resolves shared-file conflicts before updating that page's `done` marker or dispatching the next agent
- stage only accepted integration files; do not stage unrelated user changes
- record each subagent page commit hash and the applicable integration commit hash in the accepted page's status marker
- retry failed pages before dispatching later page agents; record genuine external blockers as `blocked`

## 13. Final Response

Write one final response only after every page result is integrated or explicitly blocked and the single final workspace/project scheme `xcodebuild ... build` action has completed. Include each page's agent outcome, integration status, retry count, announcement compliance, verification evidence, shared-file conflict resolution, applicable integration commit hash, and final build result.

Keep the final response concise and include:

- `OB-Task-Doc` preflight result, including whether the root folder already existed or was copied from the skill-bundled `assets/OB-Task-Doc` scaffold, and confirmation that it was not added to the Xcode project
- `GeneralOB` structure preflight result, including whether the required folder already existed or was copied from the skill-bundled `assets/GeneralOB` scaffold before implementation, where it was copied in the app source directory, confirmation that it was not placed beside `.xcodeproj` at the top level, and how target membership was verified
- when a BaseCell section exists, every Figma URL and confirmation that it visibly contained the shared cell, back button, and bottom next button; confirmation that implementation was limited to `GeneralOBBaseCell`, `GeneralOBVC.nextButton`, and `GeneralOB/icon_back`; the 44x44 pt back asset's 88x88 `@2x` and 132x132 `@3x` PNG verification; confirmation that unselected cell UI lives in `baseView`, selected cell UI lives in `selectedBaseView`, and shared bottom-button styling lives in `GeneralOBVC.nextButton`; and confirmation that no page case, page VC, page data, selection persistence, page asset namespace, routing, page status, or page-specific commit was created
- `OBFigma.md` page id, page title, status transition, attempt count, and commit hash when queue mode is used
- the source, project-file, visual, and interaction checks used for the completed page; do not include `xcodebuild` as single-page completion verification
- every Figma URL in the processed `OBFigma.md` block and the UI state each one represents
- any `### announcement` conditions in the processed block, how the implementation satisfies each condition, and any opening-rule conflict overridden by the announcement
- any announcement reference images or documents, with the resolved `OB-Task-Doc/...` paths searched or used first
- changed files
- `GeneralOBPage` case to page implementation mapping
- `GeneralOBPage` chrome flags changed for back button, progress bar, or bottom continue button
- new page class and filename, confirming the `OB<Page>VC` naming rule
- confirmation that every new or modified Figma page Swift file imports `UIKit`, `Components`, `OOGFontKit`, `OOGMacroKits`, and `SnapKit`, plus localization confirmation for visible strings
- privacy/terms agreement confirmation when present, including that `GeneralLinkTextView` is used and both `QACheck` URLs are clickable
- whether the page is option-style or `CollectionSection`, where its `pageData` is defined, and which `GeneralOBCollectionVC` or `GeneralOBCollectionSectionVC` hooks were overridden; for `CollectionSection`, explicitly report `sectionDetail(sec:)` and the returned expanded information, plus the `OBSleepVC`-matching `registerCell()` and `cell(_:path:)` behavior
- the `GeneralOBData` property used for selection persistence and whether it is `Int?` or `[Int]?`
- for list pages, where `page.vc` restores and saves selection through `vc.makeSelectIndexes`, and whether it calls `vc.makeSelectIndexes([])` when there is no saved value and no explicit initial-selection requirement
- for non-list tap-to-select pages, where the page restores, toggles, saves, and re-renders selection through `GeneralOBData`
- option-list metadata values for `multipleSelected` and `cellHeightIsConsistent`, with the Figma behavior that drove each value
- confirmation that the implementation does not call any `UICollectionView` reload method
- confirmation that the page implementation does not call any `makeSelect*` method
- confirmation that bottom continue button state UI is handled by `nextBtnEnable.didSet`
- confirmation that no `UIImageView.contentMode` assignment was added in page code
- whether `GeneralOBPageItem` option data uses both raw `title` and localized `localizedTitle`
- whether each option-list cell reused `GeneralOBBaseCell` directly or needed a custom cell, including the Figma difference that justified any subclass and registration/dequeue override
- any custom `GeneralOBBaseCell` subclass details, including `baseView` additions, inherited foreground-control reuse, confirmation that it preserves inherited `checkIcon` images without reassignment, `super.setupUI()`, and `snp.remakeConstraints`
- whether a page-specific selected cell UI needed a custom `isSelected.didSet` correction, which foreground title/icon controls it updates, and confirmation that it does not change the shared `baseView` or `selectedBaseView` container effects
- any Figma `99` or `999` corner radius translations applied
- the `GeneralOB/<page>/...` asset namespace used for exported Figma assets
- whether the Figma frame height is greater than `844`; if so, how scrolling content and the fixed floating bottom button were implemented
- how title and subtitle layer order was preserved
- reused base classes, components, pods, helpers, and assets
- verification performed
- known compromises or follow-up risks
