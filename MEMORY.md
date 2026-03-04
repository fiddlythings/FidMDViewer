# MDViewer - Session Memory

## Project Status
- **Phase:** Design complete, implementation plan written, ready for execution
- **Design doc:** `docs/plans/2026-03-04-mdviewer-design.md`
- **Implementation plan:** `docs/plans/2026-03-04-mdviewer-implementation.md`
- **Execution approach:** Parallel session using `superpowers:executing-plans`

## What We're Building
A native macOS markdown viewer app with three access methods:
1. Standalone viewer (NSDocument-based, WKWebView rendering)
2. Quick Look extension (spacebar preview in Finder)
3. CLI tool (`mdview` command)

## Key Decisions
- **Rendering:** WKWebView + bundled JS (markdown-it, highlight.js, KaTeX, Mermaid) — all offline
- **Target:** macOS 10.15+, universal binary (x86_64 + arm64)
- **Theme:** Follows system light/dark mode via CSS `prefers-color-scheme`
- **Live reload:** Yes — DispatchSource file watcher, auto-refreshes on change
- **Distribution:** Signed + notarized with Apple Developer ID, distributed as .dmg
- **No editing** — viewer only

## Apple Developer Account
User has an active Apple Developer Program membership for code signing and notarization.

## Environment
- Primary dev machine: M4 Mac Mini ("dave")
- User's domain: fiddlythings.net
