// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwiftDefaultApps",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "swda", targets: ["SWDA-CLI"]),
        .library(name: "SWDAPrefpane", type: .dynamic, targets: ["SWDA-Prefpane"]),
        .executable(name: "DummyApp", targets: ["DummyApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/Centaurioun/SwiftCLI", branch: "master")
    ],
    targets: [
        .target(
            name: "SWDA-Common",
            dependencies: [],
            path: "Sources/SWDA-Common"
        ),
        .executableTarget(
            name: "SWDA-CLI",
            dependencies: [
                .product(name: "SwiftCLI", package: "SwiftCLI"),
                "SWDA-Common"
            ],
            path: "Sources/SWDA-CLI",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "SWDA-Prefpane",
            dependencies: ["SWDA-Common"],
            path: "Sources/SWDA-Prefpane",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "DummyApp",
            dependencies: [],
            path: "Sources/DummyApp",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
