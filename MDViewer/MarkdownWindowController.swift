import Cocoa
import WebKit
import MarkdownRenderer

class MarkdownWindowController: NSWindowController, WKNavigationDelegate {
    private var webView: WKWebView!

    convenience init() {
        // Create the window programmatically
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.setFrameAutosaveName("MDViewerWindow")
        window.minSize = NSSize(width: 400, height: 300)

        self.init(window: window)

        // Create WKWebView
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        webView = WKWebView(frame: window.contentView!.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        window.contentView?.addSubview(webView)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        loadContent()
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        loadContent()
    }

    func reloadContent() {
        loadContent()
    }

    private func loadContent() {
        guard let document = document as? MarkdownDocument else { return }

        let renderer = MarkdownRenderer()
        guard let html = try? renderer.generateHTML(markdown: document.markdownContent),
              let resourcesURL = renderer.resourcesDirectoryURL else {
            return
        }

        webView.loadHTMLString(html, baseURL: resourcesURL)
    }

    // MARK: - WKNavigationDelegate

    // Open links in the default browser instead of in the viewer
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
