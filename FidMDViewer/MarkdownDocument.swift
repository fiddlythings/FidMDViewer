import Cocoa
import WebKit

class MarkdownDocument: NSDocument {
    var markdownContent: String = ""
    private var fileMonitor: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1

    override init() {
        super.init()
    }

    override class var autosavesInPlace: Bool {
        return false
    }

    override var isEntireFileLoaded: Bool {
        return true
    }

    // MARK: - Reading

    override func read(from url: URL, ofType typeName: String) throws {
        markdownContent = try String(contentsOf: url, encoding: .utf8)
        startMonitoringFile(at: url)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        markdownContent = content
    }

    // We don't support writing
    override func write(to url: URL, ofType typeName: String) throws {
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func makeWindowControllers() {
        let controller = MarkdownWindowController()
        addWindowController(controller)
    }

    // MARK: - File Monitoring

    private func startMonitoringFile(at url: URL) {
        stopMonitoringFile()

        fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor >= 0 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .rename, .delete],
            queue: .main
        )

        source.setEventHandler { [weak self] in
            guard let self = self, let fileURL = self.fileURL else { return }
            if let newContent = try? String(contentsOf: fileURL, encoding: .utf8) {
                self.markdownContent = newContent
                self.notifyWindowControllersOfChange()
            }
        }

        source.setCancelHandler { [weak self] in
            guard let self = self else { return }
            if self.fileDescriptor >= 0 {
                Darwin.close(self.fileDescriptor)
                self.fileDescriptor = -1
            }
        }

        source.resume()
        fileMonitor = source
    }

    private func stopMonitoringFile() {
        fileMonitor?.cancel()
        fileMonitor = nil
    }

    private func notifyWindowControllersOfChange() {
        for controller in windowControllers {
            if let mdController = controller as? MarkdownWindowController {
                mdController.reloadContent()
            }
        }
    }

    deinit {
        stopMonitoringFile()
    }
}
