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
//  Application+HealthChecks.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 27.03.2026.
//

import Vapor

extension Application {
    // MARK: - Health Checks

    /// Storage key for PostgreSQL health checks.
    public struct PostgresHealthChecksKey: StorageKey {
        public typealias Value = PostgresHealthChecksProtocol
    }

    /// PostgreSQL health checks handler.
    ///
    /// - Thread-Safety: Should be **immutable** or `Sendable`.
    /// - Example:
    ///   ```swift
    ///   application.psqlHealthChecks = MyPostgresHealthChecks()
    ///   ```
    public var psqlHealthChecks: PostgresHealthChecksProtocol? {
        get { storage[PostgresHealthChecksKey.self] }
        set { storage[PostgresHealthChecksKey.self] = newValue }
    }

    /// Storage key for Consul health checks.
    public struct ConsulHealthChecksKey: StorageKey {
        public typealias Value = ConsulHealthChecksProtocol
    }

    /// Consul health checks handler.
    ///
    /// - Thread-Safety: Should be **immutable** or `Sendable`.
    public var consulHealthChecks: ConsulHealthChecksProtocol? {
        get { storage[ConsulHealthChecksKey.self] }
        set { storage[ConsulHealthChecksKey.self] = newValue }
    }

    /// Storage key for aggregated application health checks.
    public struct ApplicationHealthChecksKey: StorageKey {
        public typealias Value = ApplicationHealthChecksProtocol
    }

    /// Aggregated application health checks handler.
    ///
    /// - Thread-Safety: Should be **immutable** or `Sendable`.
    /// - Example:
    ///   ```swift
    ///   application.applicationHealthChecks = MyAppHealthChecks()
    ///   ```
    public var applicationHealthChecks: ApplicationHealthChecksProtocol? {
        get { storage[ApplicationHealthChecksKey.self] }
        set { storage[ApplicationHealthChecksKey.self] = newValue }
    }

    /// Storage key for Redis health checks.
    public struct RedisHealthChecksKey: StorageKey {
        public typealias Value = RedisHealthChecksProtocol
    }

    /// Redis health checks handler.
    ///
    /// - Thread-Safety: Should be **immutable** or `Sendable`.
    public var redisHealthChecks: RedisHealthChecksProtocol? {
        get { storage[RedisHealthChecksKey.self] }
        set { storage[RedisHealthChecksKey.self] = newValue }
    }

    /// Storage key for MongoDB health checks.
    public struct MongoHealthChecksKey: StorageKey {
        public typealias Value = MongoHealthChecksProtocol
    }

    /// MongoDB health checks handler.
    ///
    /// - Thread-Safety: Should be **immutable** or `Sendable`.
    public var mongoHealthChecks: MongoHealthChecksProtocol? {
        get { storage[MongoHealthChecksKey.self] }
        set { storage[MongoHealthChecksKey.self] = newValue }
    }
}
