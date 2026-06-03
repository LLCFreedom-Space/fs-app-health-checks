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
//  PostgresRequest.swift
//
//
//  Created by Mykola Buhaiov on 14.03.2024.
//

import Vapor
import Fluent
import FluentPostgresDriver

/// Concrete implementation of `PostgresRequestSendable` for interacting with PostgreSQL.
public struct PostgresRequest: PostgresRequestSendable {
    /// Instance of the application.
    public let app: Application
    /// Initializes a new `PostgresRequest` instance.
    /// - Parameter app: The `Application` instance.
    public init(app: Application) {
        self.app = app
    }
    
    /// Retrieves PostgreSQL connection statistics and server version.
    /// - Returns: A tuple containing:
    ///   - `activeConnections`: Number of currently active database connections (Int)
    ///   - `version`: PostgreSQL server version string
    /// - Throws: `HealthCheckError`
    public func getDatabaseHealthMetrics() async throws -> (activeConnections: Int, version: String) {
        guard let db = app.db(.psql) as? (any PostgresDatabase) else {
            throw HealthCheckError.databaseNotSetup(name: ComponentName.postgresql.rawValue)
        }

        let query = """
            SELECT
                COUNT(*) FILTER (
                    WHERE datname = current_database()
                      AND pid != pg_backend_pid()
                      AND state = 'active'
                ) AS active_connections,
                version() AS version
            FROM pg_stat_activity;
        """

        let rows = try await db.simpleQuery(query).get()

        guard
            let row = rows.first?.makeRandomAccess(),
            let activeConnectionsString = row[data: "active_connections"].string,
            let activeConnections = Int(activeConnectionsString),
            let version = row[data: "version"].string
        else {
            throw HealthCheckError.responseDecodingFailed
        }
        return (activeConnections, version)
    }
}
