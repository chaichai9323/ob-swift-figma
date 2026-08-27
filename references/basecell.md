# BaseCell

Read this reference only for a direct BaseCell request or after queue parsing finds `# BaseCell` or `## BaseCell`.

## Absence

BaseCell is optional. If no heading normalizes to `BaseCell`, skip every BaseCell design-evidence check and do not inspect, create, replace, or modify these shared targets for BaseCell work:

- `GeneralOBBaseCell`
- `GeneralOBVC.nextButton`
- `Assets.xcassets/GeneralOB/Contents.json`
- `Assets.xcassets/GeneralOB/icon_back.imageset`

Continue directly to the page manifest and selected dispatch mode.

## Present Section

When `# BaseCell` or `## BaseCell` exists, parse it separately from page blocks and complete it in the parent worktree before page dispatch. It is a shared BaseCell specification, not an OB page. Every linked Figma state must visibly include the cell, back button and bottom next button; stop and report missing design evidence rather than borrowing it from a page.

Implementation is limited to:

- the existing `GeneralOBBaseCell` declaration, normally in `GeneralOBCollectionVC.swift`; do not create a parallel or page-specific base cell
- the existing `GeneralOBVC.nextButton` lazy declaration for the shared bottom-button visual style
- `Assets.xcassets/GeneralOB/Contents.json` only when needed to enable `provides-namespace`
- `Assets.xcassets/GeneralOB/icon_back.imageset`, resolving as `GeneralOB/icon_back`

Put the unselected container layout and appearance in `baseView`. Put every selected container effect in `selectedBaseView`, including background, border, gradient, shadow, radius, and other selected treatment. `isSelected` may only switch shared states and update shared foreground content.

The back control is 44x44 pt. Export PNG files exactly as:

- `icon_back@2x.png`: 88x88 pixels, mapped to `2x`
- `icon_back@3x.png`: 132x132 pixels, mapped to `3x`

Do not create or modify `GeneralOBPage`, `pageData`, `page.vc`, `GeneralOBData`, an `OB<Page>VC`, anything under `GeneralOB/Pages`, a page asset namespace, routing, selection persistence, page status, page agent, or page-specific commit for BaseCell. It has no page id, attempt count, or page-agent slot. Report it separately as a shared cell/back-icon/next-button update.
