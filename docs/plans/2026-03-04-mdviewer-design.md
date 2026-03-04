# MDViewer Design

A native macOS markdown viewer app providing three access methods: standalone viewer, Quick Look extension, and CLI tool. Renders GitHub-Flavored Markdown with syntax highlighting, LaTeX math, and Mermaid diagrams. Follows system light/dark mode. Distributed as a signed and notarized universal binary (x86_64 + arm64), targeting macOS 10.15+.

## Architecture

Single Xcode project, Swift, producing one `.app` bundle containing:

1. **MDViewer.app** — standalone document-based viewer
2. **Quick Look Extension** (`.appex`) — spacebar preview in Finder
3. **mdview CLI** — bundled in `Contents/Resources/`

All three share a common rendering module.

```
MDViewer.app/
├── Contents/
│   ├── MacOS/MDViewer
│   ├── Resources/mdview
│   ├── PlugIns/
│   │   └── QuickLookExtension.appex
│   └── Resources/
│       ├── render.html
│       ├── markdown-it.min.js
│       ├── highlight.min.js
│       ├── mathjax/ (or katex/)
│       ├── mermaid.min.js
│       └── style.css
```

**Target:** macOS 10.15 (Catalina) and later.

## Rendering Engine

Pipeline: `.md` file → String → markdown-it (JS) → HTML → styled HTML page → WKWebView

Bundled JS/CSS libraries (all local, no CDN — works offline):
- **markdown-it** + GFM plugin — tables, strikethrough, task lists
- **highlight.js** — syntax highlighting for code blocks
- **MathJax** or **KaTeX** — LaTeX math rendering
- **Mermaid** — diagram rendering

Styling:
- Clean CSS, system font stack, comfortable line height, constrained content width
- `prefers-color-scheme` media query for automatic light/dark mode

## Standalone Viewer

- Document-based app (`NSDocument` subclass)
- Each file opens in its own window with rendered markdown in a `WKWebView`
- Registers as handler for `.md`, `.markdown`, `.mdown`, `.mkd` via UTI declarations
- Supports double-click, Open With, drag-and-drop onto app/window, `Cmd+O`
- Live reload: watches open file via `DispatchSource` file system observer, auto-refreshes on change
- Print support via `WKWebView` (`Cmd+P`)
- No editing, no toolbar, no sidebar, no preferences UI in v1

## Quick Look Extension

- `QLPreviewingController` app extension
- Same shared rendering module as standalone viewer
- Displays rendered markdown in a `WKWebView`
- Registered via `Info.plist` UTI declarations
- No live reload (Quick Look previews are static)

## CLI Tool

```
mdview file.md                      # opens in MDViewer.app
mdview --html file.md               # renders HTML to stdout
mdview --html -o out.html file.md   # writes HTML to file
```

- Default mode: `open -a MDViewer file.md`
- `--html` mode: headless rendering using shared module
- Installation: app menu item "Install Command Line Tool" symlinks to `/usr/local/bin`

## Signing & Distribution

- All targets signed with Apple Developer ID certificate
- Hardened Runtime enabled
- Notarized via `notarytool`, ticket stapled to `.app` and `.dmg`
- Distributed as `.dmg` with drag-to-Applications
- Universal binary: `ARCHS = arm64 x86_64`
