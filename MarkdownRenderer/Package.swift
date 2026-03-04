// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MarkdownRenderer",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "MarkdownRenderer", targets: ["MarkdownRenderer"]),
    ],
    targets: [
        .target(
            name: "MarkdownRenderer",
            resources: [.copy("Resources")]
        ),
        .testTarget(
            name: "MarkdownRendererTests",
            dependencies: ["MarkdownRenderer"]
        ),
    ]
)
