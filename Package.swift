// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "fs-app-health-checks",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppHealthChecks",
            targets: ["AppHealthChecks"])
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        // 🖋 Swift ORM (queries, models, and relations) for NoSQL and SQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.1.0"),
        // 🐘 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.1.1"),
        // Vapor provider for RedisKit + RedisNIO
        .package(url: "https://github.com/vapor/redis.git", from: "5.0.0-alpha.2.1"),
        // 〽️ SwiftPrometheus
        .package(url: "https://github.com/MrLotU/SwiftPrometheus.git", from: "1.0.0"),
        //
        .package(url: "https://github.com/LLCFreedom-Space/SwiftKafka.git", from: "0.0.3"),
        //
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0"),
        //
        .package(url: "https://github.com/apple/swift-metrics-extras.git", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppHealthChecks",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Redis", package: "redis"),
                .product(name: "SwiftPrometheus", package: "SwiftPrometheus"),
                .product(name: "SwiftKafka", package: "SwiftKafka"),
                .product(name: "GRPC", package: "grpc-swift"),
            ]
        ),
        .testTarget(
            name: "AppHealthChecksTests",
            dependencies: ["AppHealthChecks"])
    ]
)
