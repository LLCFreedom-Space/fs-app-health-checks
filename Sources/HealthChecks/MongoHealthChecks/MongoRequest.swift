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
//  MongoRequest.swift
//
//
//  Created by Mykola Buhaiov on 15.03.2024.
//

import Vapor
import MongoClient

/// Concrete implementation of `MongoRequestSendable` for interacting with MongoDB.
public struct MongoRequest: MongoRequestSendable {
    /// Instance of app as `Application`
    public let app: Application
    /// Initializer for MongoRequest
    /// - Parameter app: `Application`
    public init(app: Application) {
        self.app = app
    }
    
    /// Checks whether MongoDB is reachable and responding.
    /// - Throws: `HealthCheckError`
    public func checkConnection() async throws {
        guard let db = app.healthCheckMongoDatabase else {
            throw HealthCheckError.databaseNotSetup(name: ComponentName.mongo.rawValue)
        }
        try await db.checkConnection()
    }
    
    /// Returns the number of available MongoDB connections.
    /// - Returns: The number of currently available connections.
    /// - Throws: `HealthCheckError` if the stats cannot be retrieved.
    public func getActiveConnections() async throws -> Int {
        guard let db = app.healthCheckMongoDatabase else {
            throw HealthCheckError.databaseNotSetup(name: ComponentName.mongo.rawValue)
        }
        let connectionStats = try await db.getConnectionStats()
        return connectionStats.active
    }
    
    /// Retrieves the MongoDB server version.
    /// - Returns: Version string returned by MongoDB (e.g. `"7.0.4"`).
    /// - Throws: `HealthCheckError` if build info is missing or request fails.
    public func getVersion() async throws -> String {
        guard let db = app.healthCheckMongoDatabase else {
            throw HealthCheckError.databaseNotSetup(name: ComponentName.mongo.rawValue)
        }
        let buildInfo = try await db.buildInfo()
        return buildInfo.version
    }
}
