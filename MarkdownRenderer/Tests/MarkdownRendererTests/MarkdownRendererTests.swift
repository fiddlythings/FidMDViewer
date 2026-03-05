import XCTest
@testable import MarkdownRenderer

final class MarkdownRendererTests: XCTestCase {
    func testResourceBundleContainsRenderHTML() throws {
        let renderer = MarkdownRenderer()
        let htmlURL = try XCTUnwrap(renderer.renderTemplateURL)
        let contents = try String(contentsOf: htmlURL, encoding: .utf8)
        XCTAssertTrue(contents.contains("renderMarkdown"))
    }

    func testGenerateHTMLProducesValidPage() throws {
        let renderer = MarkdownRenderer()
        let html = try renderer.generateHTML(markdown: "# Hello\n\nWorld")
        XCTAssertTrue(html.contains("<script"))
        XCTAssertTrue(html.contains("renderMarkdown"))
        XCTAssertTrue(html.contains("# Hello"))
    }
}
