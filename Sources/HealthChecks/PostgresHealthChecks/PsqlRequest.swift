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

public struct PsqlRequest: PsqlRequestSendable {
    /// Instance of app as `Application`
    public let app: Application
    
    /// Initializer for PsqlRequest
    /// - Parameter app: `Application`
    public init(app: Application) {
        self.app = app
    }

    // WARNING: - This method create new connection every time, when you use it
    /// Get version description
    /// - Returns: `String`
    public func getVersionDescription() async throws -> String {
        let rows = try? await (app.db(.psql) as? PostgresDatabase)?.simpleQuery("SELECT version()").get()
        let row = rows?.first?.makeRandomAccess()
        var connectionDescription = "ERROR: No connect to Postgres database and not get version"
        if let result = (row?[data: "version"].string) {
            connectionDescription = result
        }
        return connectionDescription
    }

    // WARNING: - This method create new connection every time, when you use it
    /// Check for exist connection
    /// - Returns: `String`
    public func checkConnection(for databaseName: String) async throws -> String {
        let rows = try? await (app.db(.psql) as? PostgresDatabase)?.simpleQuery("SELECT * FROM pg_stat_activity WHERE datname = '\(databaseName)' and state = 'active';").get()
        let row = rows?.first?.makeRandomAccess()
        var connectionDescription = "ERROR: No connect to Postgres database and not check state connection"
        if let result = (row?[data: "state"].string) {
            connectionDescription = result
        }
        return connectionDescription
    }
}
