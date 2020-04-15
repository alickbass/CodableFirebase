// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "CodableFirebase",
    products: [
        .library(name: "CodableFirebase", targets: ["CodableFirebase"])
    ],
    targets: [
        .target(
            name: "CodableFirebase",
            dependencies: []),
        .testTarget(
            name: "CodableFirebaseTests",
            dependencies: ["CodableFirebase"]),
    ]
)
