# Option Pages

Read this reference only for option lists, selectable cells, persisted selection, or `CollectionSection`.

## Base Class And Data

Use `GeneralOBCollectionVC` for selectable repeated options unless the page announcement forbids `UICollectionView`. Let it own collection setup, diffable data, selection, and `clickNext`; source items from `mainPage.pageData.items`.

- Set `page.multipleSelected = true` for multi-select; otherwise false.
- Set `page.cellHeightIsConsistent = true` only for equal-height cells and false for variable/state-dependent heights.
- Use `GeneralOBPageItem(title: "abc", localizedTitle: #Localized("abc"), icon: "...")`.
- Never call `reloadData`, `reloadItems`, `reloadSections`, or wrapper reload helpers.
- If an announcement forbids `UICollectionView`, inherit `GeneralOBVC`, use an existing static/stack/button pattern, and verify page-specific files contain neither `UICollectionView` nor `GeneralOBCollectionVC`.

## CollectionSection

When the page declaration contains `CollectionSection`, inherit `GeneralOBCollectionSectionVC`. This specialized path takes precedence over ordinary default-cell reuse. Inspect the current project's `OBSleepVC` and preserve this hook sequence:

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
        return c.dequeueReusableCell(withClass: OB<Page>Cell.self, for: path)
    }
    return super.cell(c, path: path)
}
```

Also implement `override func sectionDetail(sec: Int) -> GeneralOBPageItem`. Return the selected section's real localized Figma expanded information while preserving applicable title, localized title, and icon. Do not return the base placeholder or `.init(icon: "")` except as an out-of-range fallback.

## Selection Persistence

List pages and non-list tap-to-select pages add a page-specific property to `GeneralOBData`: `Int?` for single-select or `[Int]?` for multi-select.

For list pages, restore and save only in the external `GeneralOBPage.page.vc` construction path through `vc.makeSelectIndexes`. Use only `GeneralOBData` as the restore source. Unless Figma or the announcement explicitly defines an initial selection, empty saved state must call `vc.makeSelectIndexes([])` and must not select the first option.

Single-select shape:

```swift
if let index = GeneralOBData.shared.page {
    vc.makeSelectIndexes([IndexPath(item: index, section: 0)]) { paths in
        GeneralOBData.shared.page = paths.first?.item
    }
} else {
    vc.makeSelectIndexes([]) { paths in
        GeneralOBData.shared.page = paths.first?.item
    }
}
```

For multi-select, map the saved `[Int]` to/from `[IndexPath]` with the same empty-state branch.

For a non-list tap-to-select page, restore from `GeneralOBData` during setup, render page-local selected state, update it in tap handlers, and save it back. Do not use any `makeSelect*` helper.

## Cell Reuse And Customization

For non-`CollectionSection` pages, reuse the inherited `GeneralOBBaseCell` without `registerCell` or `cell(_:path:)` overrides when Figma matches its `icon` + `titleLab` + `checkIcon` layout and title typography/color. Create a page-specific cell only for a real layout, typography, icon, or behavior difference.

Custom `GeneralOBBaseCell` rules:

- call `super.setupUI()`
- add controls to `baseView`, not `contentView`
- prefer inherited `titleLab`, `icon`, `checkIcon`, and `selectedBaseView`
- use `snp.remakeConstraints` when changing inherited layout
- preserve inherited `checkIcon` images; never assign `checkIcon.image` or `checkIcon.highlightedImage`, and do not add page-specific checkmark assets
- when selected foreground UI differs, override `isSelected` in the cell and correct only title, icon, text, or image state in `didSet`
- never put page-specific background, border, layer, corner radius, shadow, gradient, or other container effects in `isSelected`; `baseView` and `selectedBaseView` container treatment belongs to shared `GeneralOBBaseCell`

When Figma displays list icons, export and use matching page-namespaced Figma assets, including selected/unselected variants. Never substitute SF Symbols, `UIImage(systemName:)`, `systemName:`, generated drawings, or generic system artwork.
