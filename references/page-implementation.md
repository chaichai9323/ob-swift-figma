# Page Implementation

Read this reference for every actual onboarding page.

## Design Context

Read every Figma link in the selected block before editing. Gather screenshots, frame size, constraints, copy, typography, color, opacity, stroke, radius, shadow, spacing, assets, variants, and interaction states. Treat links in one block as states of the same page. Trust the screenshot for visual composition when Figma metadata conflicts, and report the discrepancy.

List the page's announcement constraints and any resolved `OB-Task-Doc` reference files. An announcement overrides a conflicting generic rule for that page. For example, `不使用UICollectionView` requires a non-collection GeneralOB pattern even when the design looks option-style.

## GeneralOB Mapping

- Create the implementation under `GeneralOB/Pages` as `OB<Page>VC.swift` with class `OB<Page>VC`, where `<Page>` is the PascalCase `GeneralOBPage` case.
- Map one Figma page block to exactly one `GeneralOBPage` case, one page implementation, and one matching `GeneralOBPage.pageData` branch. Multiple links remain states inside that mapping.
- Ordinary pages inherit `GeneralOBVC`. Option pages follow [option-pages.md](option-pages.md).
- Use existing `GeneralOBViewModel`, `OnboardingPagesDataSource`, router/container callbacks, and nearby lifecycle/initializer patterns.
- Every new or modified page Swift file, including page-local views and cells, imports `UIKit`, `Components`, `OOGFontKit`, `OOGMacroKits`, and `SnapKit`.
- Wrap every visible string with `#Localized("...")`. Initialize option data with both raw and localized identity: `GeneralOBPageItem(title: "abc", localizedTitle: #Localized("abc"), ...)`.
- Map missing chrome to page metadata: no back button -> `canBack = false`; no top progress -> `isHideProgress = true`; no bottom continue button -> `isHideContinueBtn = true`.
- Keep title and subtitle above images, collections, cards, gradients, and decoration through insertion order, `bringSubviewToFront`, or an intentional local `zPosition`.

## Layout And Interaction

Use local SnapKit, `cx390`, color, font, safe-area, and responsive conventions. Figma radius `99` or `999` means half the rendered height, not a literal radius.

For a Figma frame taller than `844`, place main content in a scrollable region with enough bottom inset/padding. Keep the inherited bottom continue button outside the scroll view as a fixed floating layer.

When privacy and terms copy appears, use `GeneralLinkTextView.createLinkView`, localized `Privacy Policy` and `Terms of Use` text, and `setlinkAttribute` with `QACheck.PRIVACY_URL` and `QACheck.TERM_OF_USE_URL`; both links must be tappable.

Implement custom continue-button states only with:

```swift
override var nextBtnEnable: Bool {
    didSet {
        // Apply the Figma enabled/disabled appearance.
    }
}
```

Do not add a button-state refresh/update helper. Do not call collection reload APIs. Do not call `makeSelectItems`, `makeSelectIndexes`, or any `makeSelect*` helper inside a page, view, or cell. Do not assign `UIImageView.contentMode` in page code.

When Figma shows circular progress, use `GeneralOBCircleProgress` unless the announcement overrides it:

```swift
private lazy var progressView: GeneralOBCircleProgress = {
    let view = GeneralOBCircleProgress()
    view.lineWidth = cx390(14)
    view.trackColor = .init("#0F172A0D")
    view.gradientColors = [.init("#9E95FC"), .init("#5E7BFB")]
    return view
}()
```

Create new private/file-scoped helpers only for genuinely new UI or behavior. Do not bypass GeneralOB with a direct `OBBaseViewController`, plain `UIViewController`, or SwiftUI implementation.
