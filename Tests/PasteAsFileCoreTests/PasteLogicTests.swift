import XCTest
import AppKit
import CryptoKit
@testable import PasteAsFileCore

final class PasteAsFileCoreTests: XCTestCase {
    private let fixed = Date(timeIntervalSince1970: 1_787_011_200)
    private let utc = TimeZone(secondsFromGMT: 0)!
    private let png = Data([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 0])
    private let tiff = Data([0x49, 0x49, 0x2a, 0x00, 0x08, 0, 0, 0])
    private let rtf = Data("{\\rtf1\\ansi Rich}".utf8)

    private func directory(_ name: String = UUID().uuidString) throws -> URL {
        let root = URL(fileURLWithPath: ProcessInfo.processInfo.environment["PASTE_BUILD_DIR"] ?? "build", isDirectory: true)
        let dir = root.appendingPathComponent("test-fixtures/\(name)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: dir) }
        return dir
    }

    private func check(_ uti: String, _ ext: String) {
        XCTAssertEqual(PasteLogic.chooseFormat([uti])?.ext, ext)
    }
    func testT1Tiff() { check("public.tiff", "tiff") }
    func testT2Png() { check("public.png", "png") }
    func testT3Jpeg() { check("public.jpeg", "jpeg") }
    func testT4Icns() { check("com.apple.icns", "icns") }
    func testT5Pdf() { check("com.adobe.pdf", "pdf") }
    func testT6RtfPriority() { XCTAssertEqual(PasteLogic.chooseFormat(["public.plain-text", "public.rtf"])?.ext, "rtf") }
    func testT7Html() { check("public.html", "html") }
    func testT8Txt() { check("public.plain-text", "txt") }
    func testT9UnknownProducesNothing() throws {
        let dir = try directory()
        XCTAssertTrue(try PasteLogic.paste(fileURLs: [], representations: ["unknown": png], into: dir).isEmpty)
        XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: dir.path).isEmpty)
    }
    func testT10ExactName() {
        XCTAssertEqual(PasteLogic.fileName(date: fixed, extension: "png", timeZone: utc),
                       "Collé 2026-08-18 à 00.00.00.png")
    }
    func testT11Collisions() throws {
        let dir = try directory()
        let a = try PasteLogic.paste(fileURLs: [], representations: ["public.png": png], into: dir, date: fixed, timeZone: utc)
        let b = try PasteLogic.paste(fileURLs: [], representations: ["public.png": png], into: dir, date: fixed, timeZone: utc)
        let c = try PasteLogic.paste(fileURLs: [], representations: ["public.png": png], into: dir, date: fixed, timeZone: utc)
        XCTAssertEqual([a[0].lastPathComponent, b[0].lastPathComponent, c[0].lastPathComponent],
                       ["Collé 2026-08-18 à 00.00.00.png", "Collé 2026-08-18 à 00.00.00 1.png", "Collé 2026-08-18 à 00.00.00 2.png"])
    }
    func testT12RawBytesSHA256() throws {
        let dir = try directory()
        for (uti, bytes) in [("public.png", png), ("public.tiff", tiff), ("public.rtf", rtf)] {
            let result = try PasteLogic.paste(fileURLs: [], representations: [uti: bytes], into: dir, date: fixed)
            XCTAssertEqual(SHA256.hash(data: bytes), SHA256.hash(data: try Data(contentsOf: result[0])))
        }
    }
    func testT13FilesOverrideRawAndUniqued() throws {
        let source = try directory()
        let target = try directory()
        let file = source.appendingPathComponent("image.png")
        try png.write(to: file)
        let a = try PasteLogic.paste(fileURLs: [file], representations: ["public.rtf": rtf], into: target)
        let b = try PasteLogic.paste(fileURLs: [file], representations: [:], into: target)
        XCTAssertEqual([a[0].lastPathComponent, b[0].lastPathComponent], ["image.png", "image 1.png"])
        XCTAssertEqual(try Data(contentsOf: a[0]), png)
        XCTAssertEqual(try Data(contentsOf: b[0]), png)
    }
    func testT14RichTextPasteboardIntegration() throws {
        let pb = NSPasteboard(name: NSPasteboard.Name(UUID().uuidString))
        defer { pb.releaseGlobally() }
        pb.clearContents()
        let item = NSPasteboardItem()
        item.setData(rtf, forType: NSPasteboard.PasteboardType("public.rtf"))
        item.setData(Data("Rich".utf8), forType: .string)
        XCTAssertTrue(pb.writeObjects([item]))
        let representations = Dictionary(uniqueKeysWithValues: PasteLogic.formats.compactMap { entry -> (String, Data)? in
            guard let data = pb.pasteboardItems?.first?.data(forType: NSPasteboard.PasteboardType(entry.uti)) else { return nil }
            return (entry.uti, data)
        })
        let result = try PasteLogic.paste(fileURLs: [], representations: representations, into: directory())
        XCTAssertEqual(result.first?.pathExtension, "rtf")
        XCTAssertEqual(try Data(contentsOf: result[0]), rtf)
    }
    func testPasteboardPNGAndTIFFRaw() throws {
        for (uti, bytes, ext) in [("public.png", png, "png"), ("public.tiff", tiff, "tiff")] {
            let pb = NSPasteboard(name: NSPasteboard.Name(UUID().uuidString))
            pb.clearContents()
            let item = NSPasteboardItem()
            item.setData(bytes, forType: NSPasteboard.PasteboardType(uti))
            XCTAssertTrue(pb.writeObjects([item]))
            let raw = try XCTUnwrap(pb.pasteboardItems?.first?.data(forType: NSPasteboard.PasteboardType(uti)))
            let result = try PasteLogic.paste(fileURLs: [], representations: [uti: raw], into: directory())
            XCTAssertEqual(result[0].pathExtension, ext)
            XCTAssertEqual(try Data(contentsOf: result[0]), bytes)
            pb.releaseGlobally()
        }
    }
}
