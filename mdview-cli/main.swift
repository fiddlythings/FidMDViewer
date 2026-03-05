import Foundation

// Minimal CLI — no ArgumentParser dependency for maximum compatibility
let args = CommandLine.arguments

func printUsage() {
    let usage = """
    Usage: mdview [options] <file.md>

    Options:
      --html              Output rendered HTML to stdout
      --html -o <file>    Write rendered HTML to file
      -h, --help          Show this help message

    Without --html, opens the file in MDViewer.app.
    """
    print(usage)
}

func openInApp(path: String) {
    let absolutePath = URL(fileURLWithPath: path).path
    let task = Process()
    task.launchPath = "/usr/bin/open"
    task.arguments = ["-a", "MDViewer", absolutePath]
    task.launch()
    task.waitUntilExit()

    if task.terminationStatus != 0 {
        fputs("Error: Could not open MDViewer.app\n", stderr)
        exit(1)
    }
}

func renderToHTML(inputPath: String, outputPath: String?) {
    do {
        let markdown = try String(contentsOfFile: inputPath, encoding: .utf8)

        // Load the render template from the app bundle's Resources
        // When installed, mdview lives at MDViewer.app/Contents/Resources/mdview
        let binaryURL = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath()
        let resourcesDir = binaryURL.deletingLastPathComponent()

        let templateURL = resourcesDir.appendingPathComponent("render.html")
        guard FileManager.default.fileExists(atPath: templateURL.path) else {
            fputs("Error: Could not find render.html template\n", stderr)
            exit(1)
        }

        var template = try String(contentsOf: templateURL, encoding: .utf8)

        let escaped = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")

        let injection = """
        <script>
        document.addEventListener('DOMContentLoaded', function() {
            renderMarkdown(`\(escaped)`);
        });
        </script>
        """

        template = template.replacingOccurrences(of: "</body>", with: "\(injection)\n</body>")

        if let outputPath = outputPath {
            try template.write(toFile: outputPath, atomically: true, encoding: .utf8)
        } else {
            print(template)
        }
    } catch {
        fputs("Error: \(error.localizedDescription)\n", stderr)
        exit(1)
    }
}

// Parse arguments
guard args.count >= 2 else {
    printUsage()
    exit(1)
}

if args[1] == "-h" || args[1] == "--help" {
    printUsage()
    exit(0)
}

if args[1] == "--html" {
    guard args.count >= 3 else {
        fputs("Error: --html requires a markdown file argument\n", stderr)
        exit(1)
    }

    if args[2] == "-o" {
        guard args.count >= 5 else {
            fputs("Error: -o requires output path and input file\n", stderr)
            exit(1)
        }
        renderToHTML(inputPath: args[4], outputPath: args[3])
    } else {
        renderToHTML(inputPath: args[2], outputPath: nil)
    }
} else {
    openInApp(path: args[1])
}
