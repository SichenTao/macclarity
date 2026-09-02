// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacClarity",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MacClarityDomain", targets: ["MacClarityDomain"]),
        .library(name: "MacClarityCollectors", targets: ["MacClarityCollectors"]),
        .library(name: "MacClarityRules", targets: ["MacClarityRules"]),
        .library(name: "MacClarityReport", targets: ["MacClarityReport"]),
        .executable(name: "macclarity", targets: ["MacClarityCLI"]),
        .executable(name: "MacClarityApp", targets: ["MacClarityApp"])
    ],
    targets: [
        .target(name: "MacClarityDomain"),
        .target(name: "MacClarityCollectors", dependencies: ["MacClarityDomain"]),
        .target(name: "MacClarityRules", dependencies: ["MacClarityDomain"]),
        .target(name: "MacClarityReport", dependencies: ["MacClarityDomain"]),
        .executableTarget(name: "MacClarityCLI", dependencies: ["MacClarityDomain", "MacClarityCollectors", "MacClarityRules", "MacClarityReport"]),
        .executableTarget(name: "MacClarityApp", dependencies: ["MacClarityDomain", "MacClarityCollectors", "MacClarityRules", "MacClarityReport"]),
        .testTarget(name: "MacClarityTests", dependencies: ["MacClarityDomain", "MacClarityCollectors", "MacClarityRules", "MacClarityReport"])
    ]
)
