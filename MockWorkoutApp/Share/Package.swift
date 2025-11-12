// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Share",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "Share",
            targets: ["Share"]
        ),
    ],
    targets: [
        .target(
            name: "Share",
            dependencies: [],
            swiftSettings: [
                .define("CAN_IMPORT_ACTIVITYKIT", .when(platforms: [.iOS, .watchOS]))
            ]
        ),
    ]
)
