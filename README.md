# FidMDViewer

A native macOS markdown viewer with syntax highlighting, math rendering, and diagram support. View-only — no editing, no distractions.

## Features

- **Rendered markdown** — Headers, bold, italic, links, images, tables, task lists
- **Syntax highlighting** — Code blocks with language-aware coloring via highlight.js
- **Math equations** — LaTeX math via KaTeX (`$inline$` and `$$display$$`)
- **Mermaid diagrams** — Flowcharts, sequence diagrams, and more
- **Live reload** — Automatically re-renders when the file changes on disk
- **Light/dark mode** — Follows your system appearance
- **Quick Look** — Press spacebar in Finder to preview markdown files
- **CLI tool** — `mdview` command to open files or export to HTML
- **Fully offline** — All rendering libraries are bundled, no network required

## Install

Download the latest DMG from [Releases](https://github.com/fiddlythings/FidMDViewer/releases). Open the DMG and drag FidMDViewer to your Applications folder.

> **Note:** The app is not yet notarized. On first launch, right-click > Open and click "Open" in the Gatekeeper dialog.

Or build from source:

```bash
# Requires Xcode and xcodegen
brew install xcodegen
git clone https://github.com/fiddlythings/FidMDViewer.git
cd FidMDViewer
xcodegen generate
xcodebuild -project FidMDViewer.xcodeproj -scheme FidMDViewer -configuration Release build
```

## Usage

**Open a file:**
- Double-click a `.md` file (after setting FidMDViewer as the default viewer)
- Right-click a `.md` file > Open With > FidMDViewer
- File > Open (Cmd+O) from within the app
- `mdview myfile.md` from the terminal (after installing the CLI tool)

**Quick Look:**
After running the app once, press spacebar on any `.md` file in Finder to see a rendered preview.

**CLI tool:**
Install via FidMDViewer > Install Command Line Tool, then:

```bash
mdview README.md                     # Open in FidMDViewer
mdview --html README.md              # Print rendered HTML to stdout
mdview --html -o output.html README.md  # Write HTML to file
```

## Architecture

FidMDViewer renders markdown client-side in a WKWebView using bundled JavaScript libraries:

- [markdown-it](https://github.com/markdown-it/markdown-it) — CommonMark parsing with GFM extensions
- [highlight.js](https://highlightjs.org/) — Syntax highlighting
- [KaTeX](https://katex.org/) — Math rendering
- [Mermaid](https://mermaid.js.org/) — Diagrams

The app is a single Xcode project with three targets sharing a common `MarkdownRenderer` Swift package:

| Target | Description |
|--------|-------------|
| FidMDViewer | Standalone NSDocument-based viewer app |
| QuickLookExtension | Finder Quick Look preview extension |
| mdview | Command-line tool |

## Requirements

- macOS 10.15 (Catalina) or later
- Universal binary (Apple Silicon + Intel)

## License

[MIT](LICENSE)
