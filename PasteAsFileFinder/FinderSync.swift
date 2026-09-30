import AppKit
import FinderSync

final class FinderSync: FIFinderSync {
    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        switch menuKind {
        case .contextualMenuForContainer, .contextualMenuForItems, .toolbarItemMenu:
            let item = menu.addItem(withTitle: "Coller à partir du presse-papier",
                                    action: #selector(pasteFromClipboard(_:)), keyEquivalent: "")
            item.target = self
        case .contextualMenuForSidebar: break
        @unknown default: break
        }
        return menu
    }

    private func targetDirectory() -> URL? {
        let controller = FIFinderSyncController.default()
        if let selected = controller.selectedItemURLs(), selected.count == 1,
           let url = selected.first, (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
            return url
        }
        return controller.targetedURL() ?? controller.selectedItemURLs()?.first?.deletingLastPathComponent()
    }

    @IBAction func pasteFromClipboard(_ sender: AnyObject?) {
        guard let destination = targetDirectory() else { return }
        let pb = NSPasteboard.general
        let urls = pb.readObjects(forClasses: [NSURL.self],
                                  options: [.urlReadingFileURLsOnly: true]) as? [URL] ?? []
        let item = pb.pasteboardItems?.first
        var representations: [String: Data] = [:]
        if urls.isEmpty, let item {
            for format in PasteLogic.formats {
                if let data = item.data(forType: NSPasteboard.PasteboardType(format.uti)) {
                    representations[format.uti] = data
                }
            }
        }
        do {
            try PasteLogic.paste(fileURLs: urls, representations: representations, into: destination)
        } catch {
            NSLog("PasteAsFile: paste failed: %@", error.localizedDescription)
        }
    }
}
