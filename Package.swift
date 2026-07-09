// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Tubby",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "TubbyCore", targets: ["TubbyCore"])
    ],
    targets: [
        .target(
            name: "TubbyCore",
            path: ".",
            exclude: [
                "Tests",
                "README.md",
                ".git",
                ".agents",
                ".codex"
            ],
            sources: [
                "App",
                "Domain",
                "Features",
                "Infrastructure",
                "Lookup",
                "Persistence"
            ]
        ),
        .testTarget(
            name: "TubbyTests",
            dependencies: ["TubbyCore"],
            path: "Tests/TubbyTests"
        )
    ]
)
