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
    /// The Vapor application instance used to access services.
    public let app: Application
    /// Creates a new `MongoRequest`.
    /// - Parameter app: The Vapor `Application` instance used to access the database.
    public init(app: Application) {
        self.app = app
    }

    /// Checks whether MongoDB is reachable and responding.
    /// - Returns: `"connected"` if the database responds successfully.
    /// - Throws: `HealthCheckError` if the database is missing,
    ///           unreachable, or the request fails.
    public func checkConnection() async throws -> String {
        guard let db = app.healthCheckMongoDatabase else {
            app.logger.error("HealthCheckMongoDatabase is not installed.")
            throw HealthCheckError(.cannotConnect, reason: .databaseNotConfigured)
        }
        do {
            try await db.checkConnection()
            return "connected"
        } catch let error as HealthCheckError {
            throw error
        } catch {
            app.logger.warning("MongoDB health check failed.", error: error)
            throw HealthCheckError(.queryFailed, reason: .queryExecutionFailed)
        }
    }

    /// Returns the number of available MongoDB connections.
    /// - Returns: The number of currently available connections.
    /// - Throws: `HealthCheckError` if the stats cannot be retrieved.
    public func getTotalConnection() async throws -> Int {
        guard let db = app.healthCheckMongoDatabase else {
            app.logger.error("HealthCheckMongoDatabase is not installed.")
            throw HealthCheckError(.cannotConnect, reason: .databaseNotConfigured)
        }
        do {
            let connectionStats = try await db.getConnectionStats()
            return connectionStats.active
        } catch let error as HealthCheckError {
            throw error
        } catch {
            app.logger.warning("MongoDB health check failed.", error: error)
            throw HealthCheckError(.queryFailed, reason: .queryExecutionFailed)
        }
    }

    /// Retrieves the MongoDB server version.
    /// - Returns: Version string returned by MongoDB (e.g. `"7.0.4"`).
    /// - Throws: `HealthCheckError` if build info is missing or request fails.
    public func getVersion() async throws -> String {
        guard let db = app.healthCheckMongoDatabase else {
            app.logger.error("HealthCheckMongoDatabase is not installed.")
            throw HealthCheckError(.cannotConnect, reason: .databaseNotConfigured)
        }
        do {
            let buildInfo = try await db.buildInfo()
            guard !buildInfo.version.isEmpty else {
                app.logger.error("MongoDB buildInfo returned an empty version string.")
                throw HealthCheckError(.emptyResponse, reason: .unexpectedState)
            }
            return buildInfo.version
        } catch let error as HealthCheckError {
            throw error
        } catch {
            app.logger.warning("MongoDB health check failed.", error: error)
            throw HealthCheckError(.queryFailed, reason: .queryExecutionFailed)
        }
    }
}
