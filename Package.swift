// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "ChimeElixir",
	platforms: [.macOS(.v11)],
    products: [
        .library(name: "ChimeElixir", targets: ["ChimeElixir"]),
    ],
    dependencies: [
		.package(url: "https://github.com/ChimeHQ/ChimeKit", from: "0.1.0"),
    ],
    targets: [
        .target(name: "ChimeElixir", dependencies: ["ChimeKit"]),
        .testTarget(name: "ChimeElixirTests", dependencies: ["ChimeElixir"]),
    ]
)
