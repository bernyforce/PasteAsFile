// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PasteAsFileCore",
    platforms: [.macOS(.v13)],
    products: [.library(name: "PasteAsFileCore", targets: ["PasteAsFileCore"])],
    targets: [
        .target(name: "PasteAsFileCore", path: "PasteAsFileCore"),
        .testTarget(name: "PasteAsFileCoreTests", dependencies: ["PasteAsFileCore"], path: "Tests/PasteAsFileCoreTests")
    ]
)
