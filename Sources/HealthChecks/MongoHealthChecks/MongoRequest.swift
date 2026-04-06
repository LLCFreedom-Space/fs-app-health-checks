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

    /// Returns the current connection state of the Mongo cluster.
    /// - Parameter url: The Mongo connection URL (currently not used in logic, but reserved for future use).
    /// - Returns: A string describing the current connection state:
    ///   - `"connecting"` — when the connection is in progress
    ///   - `"connected"` — when the cluster is connected
    ///   - `"disconnected"` — when the cluster is not available
    ///   - `"closed"` — when the connection has been closed
    public func getConnection(by url: String) async -> String {
        guard let healthCheckMongoCluster = app.healthCheckMongoCluster else {
            app.logger.error("❌ HealthCheckMongoCluster not installed in app. Check your configuration, need to set `app.healthCheckMongoCluster")
            return "disconnected"
        }
        let dbName = healthCheckMongoCluster.settings.targetDatabase ?? "unknown_database_name"
        switch healthCheckMongoCluster.connectionState {
        case .connecting:
            app.logger.debug("✅ HealthCheckMongoCluster connection.")
            return "connecting"
        case .connected(connectionCount: let connectionCount):
            app.logger.debug("✅ HealthCheckMongoCluster connection and connectionCount: \(connectionCount).")
            return "connected"
        case .disconnected:
            app.logger.error("❌ HealthCheckMongoCluster is disconnected and try to reconnect to: \(dbName).")
            await reconnect(mongoCluster: healthCheckMongoCluster)
            return "\(healthCheckMongoCluster.connectionState)"
        case .closed:
            app.logger.error("❌ HealthCheckMongoCluster is closed and try to reconnect to: \(dbName).")
            await reconnect(mongoCluster: healthCheckMongoCluster)
            return "\(healthCheckMongoCluster.connectionState)"
        }
    }

    /// Attempts to reconnect the provided Mongo cluster.
    /// - Parameter mongoCluster: The `MongoCluster` instance to reconnect.
    private func reconnect(mongoCluster: MongoCluster) async {
        do {
            app.logger.info("🔄 MongoCluster.reconnect is called.")
            try await mongoCluster.reconnect()
        } catch {
            app.logger.error("MongoCluster.reconnect is failed error: \(error), localized description: \(error.localizedDescription).")
        }
    }
}
