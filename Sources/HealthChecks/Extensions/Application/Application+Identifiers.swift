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
//  Application+Identifiers.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 27.03.2026.
//

import Vapor

extension Application {
    // MARK: - Identifiers

    /// Storage key for service identifier.
    private struct ServiceIdKey: StorageKey {
        typealias Value = UUID
    }

    /// Unique identifier of the current service instance.
    ///
    /// - Thread-Safety: Access is **not synchronized**, use with care in multi-threaded contexts.
    /// - Example: `serviceId = UUID()`
    public var serviceId: UUID? {
        get { storage[ServiceIdKey.self] }
        set { storage[ServiceIdKey.self] = newValue }
    }

    /// Storage key for release identifier.
    private struct ReleaseIdKey: StorageKey {
        typealias Value = String
    }

    /// Identifier of the current application release.
    ///
    /// - Example: `releaseId = "1.0.0"`
    public var releaseId: String? {
        get { storage[ReleaseIdKey.self] }
        set { storage[ReleaseIdKey.self] = newValue }
    }

    /// Storage key for PostgreSQL identifier.
    private struct PsqlIdKey: StorageKey {
        typealias Value = String
    }

    /// Unique identifier for the PostgreSQL database instance.
    ///
    /// - Example: `psqlId = "db-prod-001"`
    public var psqlId: String? {
        get { storage[PsqlIdKey.self] }
        set { storage[PsqlIdKey.self] = newValue }
    }

    /// Storage key for Redis identifier.
    private struct RedisIdKey: StorageKey {
        typealias Value = String
    }

    /// Unique identifier for the Redis instance.
    ///
    /// - Example: `redisId = "redis-main-01"`
    public var redisId: String? {
        get { storage[RedisIdKey.self] }
        set { storage[RedisIdKey.self] = newValue }
    }

    /// Storage key for MongoDB identifier.
    private struct MongoIdKey: StorageKey {
        typealias Value = String
    }

    /// Unique identifier for the MongoDB instance.
    ///
    /// - Example: `mongoId = "mongo-cluster-01"`
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
    /// - Default: Current timestamp if not previously set.
    /// - Thread-Safety: Access is **not synchronized**.
    /// - Example: `launchTime = Date().timeIntervalSince1970`
    public var launchTime: Double {
        get { storage[LaunchTimeKey.self] ?? Date().timeIntervalSince1970 }
        set { storage[LaunchTimeKey.self] = newValue }
    }
}
