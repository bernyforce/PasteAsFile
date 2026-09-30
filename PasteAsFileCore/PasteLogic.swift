import Foundation

public enum PasteLogic {
    public static let formats: [(uti: String, ext: String)] = [
        ("public.tiff", "tiff"), ("public.png", "png"), ("public.jpeg", "jpeg"),
        ("com.apple.icns", "icns"), ("com.adobe.pdf", "pdf"),
        ("public.svg-image", "svg"), ("public.rtf", "rtf"),
        ("public.html", "html"), ("public.plain-text", "txt")
    ]

    public static func chooseFormat(_ available: Set<String>) -> (uti: String, ext: String)? {
        formats.first { available.contains($0.uti) }
    }

    public static func timestamp(_ date: Date, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd 'à' HH.mm.ss"
        return formatter.string(from: date)
    }

    public static func fileName(date: Date, extension ext: String, timeZone: TimeZone = .current) -> String {
        "Collé \(timestamp(date, timeZone: timeZone)).\(ext)"
    }

    public static func uniqued(_ url: URL, exists: (URL) -> Bool = { FileManager.default.fileExists(atPath: $0.path) }) -> URL {
        guard exists(url) else { return url }
        let base = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        var index = 1
        while true {
            let name = "\(base) \(index)" + (ext.isEmpty ? "" : ".\(ext)")
            let candidate = url.deletingLastPathComponent().appendingPathComponent(name)
            if !exists(candidate) { return candidate }
            index += 1
        }
    }

    public static func hasFiles(_ urls: [URL]) -> Bool { !urls.isEmpty }

    @discardableResult
    public static func paste(fileURLs: [URL], representations: [String: Data],
                             into directory: URL, date: Date = Date(),
                             timeZone: TimeZone = .current) throws -> [URL] {
        if hasFiles(fileURLs) {
            return try fileURLs.map { source in
                let target = uniqued(directory.appendingPathComponent(source.lastPathComponent))
                try FileManager.default.copyItem(at: source, to: target)
                return target
            }
        }
        guard let format = chooseFormat(Set(representations.keys)),
              let data = representations[format.uti] else { return [] }
        let target = uniqued(directory.appendingPathComponent(fileName(date: date, extension: format.ext, timeZone: timeZone)))
        try data.write(to: target, options: .atomic)
        return [target]
    }
}
