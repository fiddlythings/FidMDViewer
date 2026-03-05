# MDViewer - Session Memory

## Project Status
- **Phase:** Implementation complete, all 11 tasks done
- **Design doc:** `docs/plans/2026-03-04-mdviewer-design.md`
- **Implementation plan:** `docs/plans/2026-03-04-mdviewer-implementation.md`
- **All targets build successfully** via xcodebuild

## What Was Built
A native macOS markdown viewer app with three access methods:
1. **Standalone viewer** (NSDocument-based, WKWebView rendering) — opens .md files, live-reloads on change
2. **Quick Look extension** (embedded in app bundle as QuickLookExtension.appex)
3. **CLI tool** (`mdview` command, bundled in app Resources)

## Project Structure
- `project.yml` — XcodeGen spec (use `xcodegen generate` to regenerate .xcodeproj)
- `MarkdownRenderer/` — Swift Package with shared rendering module (HTML template + JS/CSS resources)
- `MDViewer/` — Main app target (AppDelegate, MarkdownDocument, MarkdownWindowController)
- `QuickLookExtension/` — Quick Look preview extension
- `mdview-cli/` — CLI tool source
- `scripts/build-release.sh` — Release build with signing/notarization/DMG
- `ExportOptions.plist` — Archive export config (needs TEAM_ID)

## Key Technical Details
- **XcodeGen:** Project uses xcodegen (project.yml) to generate .xcodeproj
- **DEVELOPER_DIR:** Must set `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` for xcodebuild (xcode-select points to CommandLineTools)
- **Build phase:** Post-build script copies mdview binary + render resources into MDViewer.app/Contents/Resources/
- **Bundle.module:** MarkdownRenderer uses SPM resource bundling for render.html, JS, CSS, fonts
- **Darwin.close:** Had to disambiguate `close()` call in MarkdownDocument.swift with `Darwin.close()`

## Still Needs
- `scripts/build-release.sh` — Replace YOUR NAME, TEAM_ID, YOUR_TEAM_ID with actual values
- `ExportOptions.plist` — Replace YOUR_TEAM_ID
- AppDelegate `installCommandLineTool` menu item not yet wired (needs MainMenu.xib or programmatic menu)
- Visual testing: app opened with test file, HTML export opened in browser — user should verify rendering
- Quick Look testing: `qlmanage -p /tmp/test.md` after running app once to register extension

## Apple Developer Account
User has an active Apple Developer Program membership for code signing and notarization.

## Environment
- Primary dev machine: M4 Mac Mini ("dave")
- User's domain: fiddlythings.net
