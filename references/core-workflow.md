# Core Workflow

Read this reference for every task.

## Preflight

Before reading Figma, editing Swift, or changing queue markers:

1. Resolve the engineering-project root and app source directory. In the common `Root/AppName.xcodeproj` plus `Root/AppName/` layout, the app source directory is `Root/AppName/`.
2. Ensure `<root>/OB-Task-Doc` exists. If missing, copy bundled `assets/OB-Task-Doc` there. Keep it out of `.xcodeproj`, targets, build phases, and Copy Bundle Resources. Stop if the bundled scaffold is missing or incomplete.
3. Ensure the app source directory contains all of:
   - `GeneralOB/GeneralOBCollectionVC.swift`
   - `GeneralOB/GeneralOBPage.swift`
   - `GeneralOB/GeneralOBPage+Data.swift`
   - `GeneralOB/GeneralOBPage+VC.swift`
   - `GeneralOB/GeneralOBVC.swift`
   - `GeneralOB/DataModel`
   - `GeneralOB/Pages`
4. If any GeneralOB path is absent, copy bundled `assets/GeneralOB` into the app source directory, not beside `.xcodeproj`. Add every copied Swift file to the primary app target's Compile Sources or the repository's generated source list. For XcodeGen or Tuist, edit the generator config and follow the repository's regeneration convention. Do not create stubs.
5. Re-run the path checks and verify target membership before continuing.

## Project Fit

Inspect the project before editing:

- nearby GeneralOB pages with the same UI or interaction pattern
- `GeneralOBPage`, `pageData`, `page.vc`, `GeneralOBData`, and navigation wiring
- `GeneralOBCollectionVC`, `GeneralOBCollectionSectionVC`, `OBSleepVC`, and cell hooks when relevant
- local helpers and dependencies such as SnapKit, `cx390`, `UIColor("#...")`, `cornerRadius`, Components, OOGFontKit, and OOGMacroKits
- the workspace/project, primary scheme, app target, and project-generation source of truth
- `git status --short` and the relevant diff so unrelated user changes remain untouched and unstaged

Reuse existing architecture and conventions. This skill owns UIKit GeneralOB onboarding implementation; do not introduce SwiftUI, a parallel onboarding framework, or unrelated refactors. If a direct Figma request has no node id and the target is ambiguous, ask for the node-specific URL before implementation.

Record whether each preflight resource already existed or was copied, its resolved location, and how app-target membership was verified.
