// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PufferyKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PufferyUI",
            targets: ["PufferyUI"]
        ),
        .library(
            name: "PufferyKit",
            targets: ["PufferyKit"]
        ),
        .library(
            name: "AckeeTracker",
            targets: ["AckeeTracker"]
        ),
    ],
    dependencies: [
        .package(name: "APIDefinition", path: "../APIDefinition"),
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Overture", url: "https://github.com/pointfreeco/swift-overture.git", from: "0.5.0"),
        .package(name: "KeychainSwift", url: "https://github.com/evgenyneu/keychain-swift.git", from: "19.0.0"),
//        .package(name: "AckeeTracker", url: "https://github.com/vknabel/AckeeTracker-Swift.git", from: "0.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.8.0"),
        .package(url: "https://github.com/nachonavarro/Pages.git", from: "0.1.5"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PufferyUI",
            dependencies: [
                "PufferyKit",
                "RegistrationModule",
                "GettingStartedModule",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "AckeeTracker",
            dependencies: []
        ),
        .target(
            name: "PufferyKit",
            dependencies: [
                "Overture",
                "KeychainSwift",
                "AckeeTracker",
                "APIDefinition",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "GettingStartedModule",
            dependencies: [
                "Pages",
                "Overture",
                "PufferyKit",
                "RegistrationModule",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .testTarget(
            name: "PufferyKitTests",
            dependencies: [
                "PufferyKit",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),

        .target(name: "DesignSystem", dependencies: [
            "PlatformSupport",
            "PufferyKit",
        ]),
        .target(name: "PlatformSupport", dependencies: [
            "APIDefinition",
            "PufferyKit",
        ]),
        .target(name: "PrivacyPolicyModule", dependencies: [
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
        .target(name: "RegistrationModule", dependencies: [
            "PufferyKit",
            "DesignSystem",
            "PlatformSupport",
            "PrivacyPolicyModule",
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        ]),
    ]
)
