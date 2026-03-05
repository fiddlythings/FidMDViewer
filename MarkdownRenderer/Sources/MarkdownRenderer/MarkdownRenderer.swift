import Foundation

public class MarkdownRenderer {
    public init() {}

    /// URL to the render.html template in the bundle
    public var renderTemplateURL: URL? {
        Bundle.module.url(forResource: "render", withExtension: "html", subdirectory: "Resources")
    }

    /// URL to the Resources directory containing all JS/CSS assets
    public var resourcesDirectoryURL: URL? {
        Bundle.module.url(forResource: "Resources", withExtension: nil)
    }

    /// Generate a complete HTML page that will render the given markdown.
    /// The markdown is embedded as a JS string and rendered client-side.
    public func generateHTML(markdown: String) throws -> String {
        guard let templateURL = renderTemplateURL else {
            throw RendererError.missingTemplate
        }
        var template = try String(contentsOf: templateURL, encoding: .utf8)

        // Escape the markdown for safe embedding in a JS string literal
        let escaped = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")

        // Inject a script that calls renderMarkdown with the content
        let injection = """
        <script>
        document.addEventListener('DOMContentLoaded', function() {
            renderMarkdown(`\(escaped)`);
        });
        </script>
        """

        template = template.replacingOccurrences(of: "</body>", with: "\(injection)\n</body>")
        return template
    }

    public enum RendererError: Error, LocalizedError {
        case missingTemplate

        public var errorDescription: String? {
            switch self {
            case .missingTemplate:
                return "Could not find render.html template in bundle"
            }
        }
    }
}
