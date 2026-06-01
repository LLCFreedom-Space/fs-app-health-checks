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
    
    /// Retrieves the PostgreSQL server version.
    /// Executes `SELECT version()` and parses the result into a structured format.
    /// - Returns: A string representing the PostgreSQL version (e.g. `"16.1"`).
    /// - Throws: `HealthCheckError` if the database is unavailable, query fails,
    ///           or version cannot be parsed.
    public func getVersion() async throws -> String {
        guard let db = app.db(.psql) as? (any PostgresDatabase) else {
            throw HealthCheckError.databaseNotSetup
        }
        let rows = try await db.simpleQuery("SELECT version()").get()
        guard let row = rows.first?.makeRandomAccess() else {
            throw HealthCheckError.responseDecodingFailed
        }
        guard let version = row[data: "version"].string else {
            throw HealthCheckError.responseDecodingFailed
        }
        return version
    }
    
    /// Checks whether the PostgreSQL database is reachable.
    /// Executes a lightweight `SELECT 1` query.
    /// - Throws: `HealthCheckError` if the query execution fails.
    public func checkConnection() async throws {
        guard let db = app.db(.psql) as? (any PostgresDatabase) else {
            throw HealthCheckError.databaseNotSetup
        }
        try await db.simpleQuery("SELECT 1").get()
    }
    
    /// Returns the number of active connections to the current PostgreSQL database.
    /// Queries `pg_stat_activity` excluding the current backend process.
    /// - Returns: Number of active connections as a string.
    /// - Throws: `HealthCheckError` if query fails or response is invalid.
    public func getActiveConnections() async throws -> Int {
        guard let db = app.db(.psql) as? (any PostgresDatabase) else {
            throw HealthCheckError.databaseNotSetup
        }
        let query = """
            SELECT COUNT(*) AS count
            FROM pg_stat_activity
            WHERE datname = current_database()
              AND pid != pg_backend_pid()
              AND state = 'active'
        """

        let rows = try await db.simpleQuery(query).get()
        guard
            let row = rows.first?.makeRandomAccess(),
            let countString = row[data: "count"].string,
            let count = Int(countString)
        else {
            throw HealthCheckError.responseDecodingFailed
        }

        return count
    }
}
