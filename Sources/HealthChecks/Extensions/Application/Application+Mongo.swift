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
//  Application+Mongo.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 27.03.2026.
//

import Vapor
import MongoKitten

extension Application {
    // MARK: - Mongo Cluster

    /// Storage key for MongoDB cluster instance.
    ///
    /// Used to store a shared ``MongoCluster`` inside ``Application.storage``.
    /// This allows reusing a single cluster across the entire application lifecycle
    /// (e.g., for health checks or shared database access).
    public struct MongoClusterKey: StorageKey {
        /// Stored value type.
        public typealias Value = MongoCluster
    }

    /// Shared MongoDB cluster instance.
    ///
    /// This property provides access to a shared ``MongoCluster`` stored in the application.
    ///
    /// - Note: Typically initialized during application bootstrap (`configure.swift`).
    /// - Important: The cluster should be initialized only once and reused.
    /// - Thread-Safety: ``MongoCluster`` is designed to be shared across concurrent contexts,
    ///   but lifecycle management (initialization/shutdown) must be controlled.
    ///
    /// ## Example
    /// ```swift
    /// if let cluster = app.healthCheckMongoCluster {
    ///     let db = cluster["my_database"]
    ///     let collection = db["users"]
    ///     let users = try await collection.find().drain()
    /// }
    /// ```
    public var healthCheckMongoCluster: MongoCluster? {
        get { storage[MongoClusterKey.self] }
        set { storage[MongoClusterKey.self] = newValue }
    }

    /// Initializes MongoDB cluster using an eager connection strategy.
    ///
    /// This method establishes a connection immediately and suspends until the connection
    /// is fully ready.
    ///
    /// - Parameter connectionString: MongoDB connection string (e.g. `"mongodb://localhost:27017"`).
    /// - Throws: An error if the connection fails or configuration is invalid.
    ///
    /// - Important:
    ///   Call this method during application startup to ensure the database is reachable.
    ///
    /// - Thread-Safety:
    ///   Should be called once during bootstrap before the application starts handling requests.
    ///
    /// ## Example (configure.swift)
    /// ```swift
    /// try await app.initializeMongoCluster(
    ///     connectionString: "mongodb://localhost:27017"
    /// )
    /// ```
    ///
    /// ## Example (usage in route)
    /// ```swift
    /// app.get("users") { req async throws -> [User] in
    ///     guard let cluster = req.application.healthCheckMongoCluster else {
    ///         throw Abort(.internalServerError, reason: "Mongo cluster not initialized")
    ///     }
    ///
    ///     let db = cluster["my_database"]
    ///     let collection = db["users"]
    ///
    ///     return try await collection.find().decode(User.self).drain()
    /// }
    /// ```
    public func initializeMongoCluster(connectionString: String) async throws {
        self.healthCheckMongoCluster = try await MongoCluster(connectingTo: ConnectionSettings(connectionString))
    }

    /// Initializes MongoDB cluster using a lazy connection strategy.
    ///
    /// The connection is not established until the first database operation is executed.
    /// This is useful during application startup when:
    /// - external services may be temporarily unavailable
    /// - you want faster boot time
    ///
    /// - Parameter connectionString: MongoDB connection string.
    /// - Throws: An error only if configuration is invalid.
    ///
    /// - Note:
    ///   Connection errors will surface later during actual queries.
    ///
    /// - Thread-Safety:
    ///   Safe to store globally, but first access may trigger connection concurrently.
    ///
    /// ## Example (configure.swift)
    /// ```swift
    /// try await app.initializeLazyMongoCluster(
    ///     connectionString: "mongodb://localhost:27017"
    /// )
    /// ```
    ///
    /// ## Example (first usage triggers connection)
    /// ```swift
    /// let cluster = req.application.healthCheckMongoCluster!
    /// let db = cluster["my_database"]
    /// let collection = db["users"]
    ///
    /// // Connection happens here if not already established
    /// let users = try await collection.find().drain()
    /// ```
    public func initializeLazyMongoCluster(connectionString: String) async throws {
        self.healthCheckMongoCluster = try MongoCluster(lazyConnectingTo: ConnectionSettings(connectionString))
    }
}
