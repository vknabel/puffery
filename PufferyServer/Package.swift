// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "PufferyServer",
    platforms: [
        .macOS(.v10_15), .iOS(.v13),
    ],
    products: [
        .library(name: "PufferyServer", targets: ["App"]),
        .executable(name: "puffery", targets: ["Run"]),
    ],
    dependencies: [
        .package(name: "APIDefinition", path: "../APIDefinition"),

        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on Postegres.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-rc"),

        // 👤 Authentication and Authorization layer for Fluent.
//        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0-rc"),

        // 📱 APNS Push Notifications
//        .package(url: "https://github.com/vapor/apns.git", .exact("1.0.0-rc.1")),
        .package(url: "https://github.com/vknabel/apns.git", .revision("d3eea3eb94aede320c66714efa5ff7b2316430c0")),
        .package(url: "https://github.com/kylebrowning/APNSwift.git", .exact("2.0.0-rc1")),

        // 👩‍🔧 Jobs and Queues
        .package(url: "https://github.com/vapor/queues.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.0-rc"),

        // ✉️
        .package(url: "https://github.com/vapor-community/sendgrid.git", from: "4.0.0"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "APNS", package: "apns"),
            .product(name: "JWT", package: "jwt"),
            .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
            .product(name: "SendGrid", package: "sendgrid"),
            "APIDefinition",
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
