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
//  PsqlRequest.swift
//
//
//  Created by Mykola Buhaiov on 14.03.2024.
//

import Vapor
import Fluent
import FluentPostgresDriver

/// Concrete implementation of `PsqlRequestSendable` for interacting with PostgreSQL.
public struct PsqlRequest: PsqlRequestSendable {
    /// Instance of the application.
    public let app: Application
    /// Initializes a new `PsqlRequest` instance.
    ///
    /// - Parameter app: The `Application` instance.
    public init(app: Application) {
        self.app = app
    }

    /// Retrieves the PostgreSQL version description.
    ///
    /// - Returns: A `String` containing the PostgreSQL version, or an error message if the connection fails.
    public func getVersionDescription() async throws -> String {
        let rows = try? await (app.db(.psql) as? PostgresDatabase)?
            .simpleQuery("SELECT version()")
            .get()
        let row = rows?.first?.makeRandomAccess()
        var connectionDescription = "ERROR: No connect to Postgres database and not get version"
        if let result = (row?[data: "version"].string) {
            connectionDescription = result
        }
        return connectionDescription
    }

    /// Checks the connection state for a specific PostgreSQL database.
    ///
    /// - Parameter databaseName: Name of the PostgreSQL database.
    /// - Returns: A `String` describing the connection status, e.g., `"active"` or an error message.
    public func checkConnection(for databaseName: String) async throws -> String {
        let rows = try? await (app.db(.psql) as? PostgresDatabase)?
            .simpleQuery("SELECT * FROM pg_stat_activity WHERE datname = '\(databaseName)' and state = 'active';")
            .get()
        let row = rows?.first?.makeRandomAccess()
        var connectionDescription = "ERROR: No connect to Postgres database and not check state connection"
        if let result = (row?[data: "state"].string) {
            connectionDescription = result
        }
        return connectionDescription
    }
}
