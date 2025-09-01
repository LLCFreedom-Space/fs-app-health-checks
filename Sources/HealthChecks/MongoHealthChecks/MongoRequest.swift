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
import MongoCore
import MongoClient

public struct MongoRequest: MongoRequestSendable {
    /// Instance of app as `Application`
    public let app: Application

    /// Initializer for MongoRequest
    /// - Parameter app: `Application`
    public init(app: Application) {
        self.app = app
    }

    // WARNING: - This method create new connection every time, when you use it
    /// Get mongo connection
    /// - Parameter url: `String`
    /// - Returns: `String`
    public func getConnection(by url: String) async -> String {
        guard let healthCheckMongoCluster = app.healthCheckMongoCluster else {
            app.logger.error("❌ HealthCheckMongoCluster not installed in app")
            return "disconnected"
        }
        let dbName = healthCheckMongoCluster.settings.targetDatabase ?? "unknown"
        switch healthCheckMongoCluster.connectionState {
        case .connecting:
            app.logger.debug("✅ HealthCheckMongoCluster connection")
            return "connecting"
        case .connected(connectionCount: let connectionCount):
            app.logger.debug("✅ HealthCheckMongoCluster connection and connectionCount: \(connectionCount)")
            return "connecting"
        case .disconnected:
            app.logger.error("❌ HealthCheckMongoCluster is disconnected and try to reconnect to: \(dbName)")
            await reconnect(mongoCluster: healthCheckMongoCluster)
            return "disconnected"
        case .closed:
            app.logger.error("❌ HealthCheckMongoCluster is closed and try to reconnect to: \(dbName)")
            await reconnect(mongoCluster: healthCheckMongoCluster)
            return "closed"
        }
    }

    /// Attempts to reconnect the given `MongoCluster`.
    ///
    /// - Parameter mongoCluster: The `MongoCluster` instance that should be reconnected.
    /// - Throws: Rethrows any error that occurs during the reconnect attempt.
    /// - Note:
    ///   - If `reconnect()` fails, the error will be caught internally and logged using `app.logger.error`.
    ///   - This method ensures the app does not crash on reconnect failure, but still provides
    ///     visibility of the issue in logs.
    private func reconnect(mongoCluster: MongoCluster) async {
        do {
            try await mongoCluster.reconnect()
        } catch {
            app.logger.error("MongoCluster.reconnect is failed error: \(error), localized description: \(error.localizedDescription)")
        }
    }
}
