// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "fs-app-health-checks",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HealthChecks",
            targets: ["HealthChecks"])
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        // 🖋 Swift ORM (queries, models, and relations) for NoSQL and SQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.1.0"),
        // 🐘 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.1.1"),
        //  Vapor provider for RedisKit + RedisNIO
        .package(url: "https://github.com/vapor/redis.git", from: "5.0.0-alpha.2.2"),
        // 🐈 Mongo driver based on Swift NIO.
        .package(url: "https://github.com/orlandos-nl/MongoKitten.git", exact: "7.6.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HealthChecks",
            dependencies: [
                .product(
                    name: "Vapor",
                    package: "vapor"
                ),
                .product(
                    name: "Fluent",
                    package: "fluent"
                ),
                .product(
                    name: "FluentPostgresDriver",
                    package: "fluent-postgres-driver"
                ),
                .product(
                    name: "Redis",
                    package: "redis"
                ),
                .product(
                    name: "MongoKitten",
                    package: "MongoKitten"
                ),
            ]
        ),
        .testTarget(
            name: "HealthChecksTests",
            dependencies: [
                .target(
                    name: "HealthChecks"
                ),
                .product(
                    name: "XCTVapor",
                    package: "vapor"
                ),
            ]
        )
    ]
)

#if swift(>=5.6)
// Add the documentation compiler plugin if possible
package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
)
#endif
