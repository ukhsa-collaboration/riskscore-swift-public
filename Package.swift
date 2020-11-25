// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RiskScore",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "RiskScore",
            targets: ["RiskScore"]),
        .executable(
            name: "risk-score-checker",
            targets: ["RiskScoreChecker"]),
        .executable(
            name: "kalman-checker",
            targets: ["KalmanChecker"]),
    ],
    dependencies: [
        .package(name: "BoostSwift", url: "https://github.com/nhsx/boostswift-public", .upToNextMajor(from: "1.0.0")),
        .package(name: "SwiftCheck", url: "https://github.com/typelift/SwiftCheck.git", from: "0.12.0"),
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", from: "0.3.1"),
        .package(name: "Files", url: "https://github.com/JohnSundell/Files", from: "4.0.0")
        
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "RiskScore",
            dependencies: ["Kalman1D", "BoostSwift"]),
        .target(
            name: "Kalman1D",
            dependencies: []),
        .target(
            name: "Support",
            dependencies: ["RiskScore"]),
        .target(
            name: "RiskScoreChecker",
            dependencies: [
                "RiskScore",
                "Support",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Files"
            ]),
        .target(
            name: "KalmanChecker",
            dependencies: [
                "RiskScore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Files",
                "Support",
            ]),
        .testTarget(
            name: "RiskScoreTests",
            dependencies: ["RiskScore", "SwiftCheck", "Support"],
            resources: [.copy("TestData")]),
        .testTarget(
            name: "Kalman1DTests",
            dependencies: ["Kalman1D", "SwiftCheck"]),
    ]
)
