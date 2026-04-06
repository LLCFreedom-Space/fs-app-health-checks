// FS App Health Checks
// Copyright (C) 2024  FREEDOM SPACE, LLC

//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as published
//  by the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

//
//  Application+Extensions.swift
//
//
//  Created by Mykola Buhaiov on 31.01.2024.
//

import Vapor
import MongoClient

extension Application {
    /// Storage key for PostgreSQL request context.
    private struct PsqlRequestKey: StorageKey {
        typealias Value = PsqlRequestSendable
    }
    /// PostgreSQL request context associated with the current request.
    public var psqlRequest: PsqlRequestSendable? {
        get { storage[PsqlRequestKey.self] }
        set { storage[PsqlRequestKey.self] = newValue }
    }

    /// Storage key for Redis request context.
    private struct RedisRequestKey: StorageKey {
        typealias Value = RedisRequestSendable
    }
    /// Redis request context associated with the current request.
    public var redisRequest: RedisRequestSendable? {
        get { storage[RedisRequestKey.self] }
        set { storage[RedisRequestKey.self] = newValue }
    }

    /// Storage key for MongoDB request context.
    private struct MongoRequestKey: StorageKey {
        typealias Value = MongoRequestSendable
    }
    /// MongoDB request context associated with the current request.
    public var mongoRequest: MongoRequestSendable? {
        get { storage[MongoRequestKey.self] }
        set { storage[MongoRequestKey.self] = newValue }
    }
}

extension Application {
    /// Storage key for service identifier.
    private struct ServiceIdKey: StorageKey {
        typealias Value = UUID
    }
    /// Unique identifier of the current service instance.
    public var serviceId: UUID? {
        get { storage[ServiceIdKey.self] }
        set { storage[ServiceIdKey.self] = newValue }
    }

    /// Storage key for release identifier.
    private struct ReleaseIdKey: StorageKey {
        typealias Value = String
    }
    /// Identifier of the current application release.
    public var releaseId: String? {
        get { storage[ReleaseIdKey.self] }
        set { storage[ReleaseIdKey.self] = newValue }
    }

    /// Storage key for PostgreSQL identifier.
    private struct PsqlIdKey: StorageKey {
        typealias Value = String
    }
    /// Unique identifier for the PostgreSQL instance.
    public var psqlId: String? {
        get { storage[PsqlIdKey.self] }
        set { storage[PsqlIdKey.self] = newValue }
    }

    /// Storage key for Redis identifier.
    private struct RedisIdKey: StorageKey {
        typealias Value = String
    }
    /// Unique identifier for the Redis instance.
    public var redisId: String? {
        get { storage[RedisIdKey.self] }
        set { storage[RedisIdKey.self] = newValue }
    }

    /// Storage key for MongoDB identifier.
    private struct MongoIdKey: StorageKey {
        typealias Value = String
    }
    /// Unique identifier for the MongoDB instance.
    public var mongoId: String? {
        get { storage[MongoIdKey.self] }
        set { storage[MongoIdKey.self] = newValue }
    }

    /// Storage key for application launch time.
    private struct LaunchTimeKey: StorageKey {
        typealias Value = Double
    }
    /// UNIX timestamp representing the application launch time.
    ///
    /// - Note: Returns current timestamp if not previously set.
    public var launchTime: Double {
        get { storage[LaunchTimeKey.self] ?? Date().timeIntervalSince1970 }
        set { storage[LaunchTimeKey.self] = newValue }
    }
}

extension Application {
    /// Storage key for PostgreSQL health checks.
    private struct PostgresHealthChecksKey: StorageKey {
        typealias Value = PostgresHealthChecksProtocol
    }
    /// PostgreSQL health checks handler.
    public var psqlHealthChecks: PostgresHealthChecksProtocol? {
        get { storage[PostgresHealthChecksKey.self] }
        set { storage[PostgresHealthChecksKey.self] = newValue }
    }

    /// Storage key for Consul health checks.
    private struct ConsulHealthChecksKey: StorageKey {
        typealias Value = ConsulHealthChecksProtocol
    }
    /// Consul health checks handler.
    public var consulHealthChecks: ConsulHealthChecksProtocol? {
        get { storage[ConsulHealthChecksKey.self] }
        set { storage[ConsulHealthChecksKey.self] = newValue }
    }

    /// Storage key for aggregated application health checks.
    private struct ApplicationHealthChecksKey: StorageKey {
        typealias Value = ApplicationHealthChecksProtocol
    }
    /// Aggregated application health checks handler.
    public var applicationHealthChecks: ApplicationHealthChecksProtocol? {
        get { storage[ApplicationHealthChecksKey.self] }
        set { storage[ApplicationHealthChecksKey.self] = newValue }
    }

    /// Storage key for Redis health checks.
    private struct RedisHealthChecksKey: StorageKey {
        typealias Value = RedisHealthChecksProtocol
    }
    /// Redis health checks handler.
    public var redisHealthChecks: RedisHealthChecksProtocol? {
        get { storage[RedisHealthChecksKey.self] }
        set { storage[RedisHealthChecksKey.self] = newValue }
    }

    /// Storage key for MongoDB health checks.
    private struct MongoHealthChecksKey: StorageKey {
        typealias Value = MongoHealthChecksProtocol
    }
    /// MongoDB health checks handler.
    public var mongoHealthChecks: MongoHealthChecksProtocol? {
        get { storage[MongoHealthChecksKey.self] }
        set { storage[MongoHealthChecksKey.self] = newValue }
    }
}

extension Application {
    /// Storage key for Consul configuration.
    private struct ConsulConfigKey: StorageKey {
        typealias Value = ConsulConfig
    }
    /// Consul configuration for the application.
    public var consulConfig: ConsulConfig? {
        get { storage[ConsulConfigKey.self] }
        set { storage[ConsulConfigKey.self] = newValue }
    }
}

extension Application {
    /// Storage key for MongoDB cluster.
    private struct MongoClusterKey: StorageKey {
        typealias Value = MongoCluster
    }
    /// Shared MongoDB cluster instance.
    /// - Important: Should be initialized once during application bootstrap.
    public var healthCheckMongoCluster: MongoCluster? {
        get { storage[MongoClusterKey.self] }
        set { storage[MongoClusterKey.self] = newValue }
    }

    /// Initializes MongoDB cluster with eager connection.
    /// - Parameter connectionString: MongoDB connection string.
    /// - Note: See README for comparison of connection strategies:
    ///   <https://github.com/LLCFreedom-Space/fs-app-health-checks#mongodb-connection-strategies>
    public func initializeMongoCluster(connectionString: String) async throws {
        self.healthCheckMongoCluster = try await MongoCluster(
            connectingTo: ConnectionSettings(connectionString)
        )
    }

    /// Initializes MongoDB cluster with lazy connection.
    /// - Parameter connectionString: MongoDB connection string.
    /// - Note: See README for comparison of connection strategies:
    ///   <https://github.com/LLCFreedom-Space/fs-app-health-checks#mongodb-connection-strategies>
    public func initializeLazyMongoCluster(connectionString: String) throws {
        self.healthCheckMongoCluster = try MongoCluster(
            lazyConnectingTo: ConnectionSettings(connectionString)
        )
    }
}

extension Application {
    /// ISO 8601-like date formatter (`yyyy-MM-dd'T'HH:mm:ss.SSS`).
    /// - Warning: `DateFormatter` is not thread-safe.
    /// - Note: Creates a new instance on each access.
    public var dateTimeISOFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }
}
