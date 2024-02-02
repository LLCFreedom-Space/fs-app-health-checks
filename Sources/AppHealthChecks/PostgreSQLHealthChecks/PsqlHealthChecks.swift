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
//  PsqlHealthChecks.swift
//
//
//  Created by Mykola Buhaiov on 31.01.2024.
//

import Vapor
import Fluent
import FluentPostgresDriver

/// Service that provides psql health check functionality
public struct PsqlHealthChecks: PsqlHealthChecksProtocol {
    /// Instance of app as `Application`
    public let app: Application
    
    /// Get psql health using authorize parameters
    /// - Parameters:
    ///   - hostname: `String`
    ///   - port: `Int`
    ///   - username: `String`
    ///   - password: `String`
    ///   - database: `String`
    ///   - tls: optional `PostgresConnection.Configuration.TLS`
    /// - Returns: `HealthCheckItem`
    public func checkConnection(
        hostname: String,
        port: Int,
        username: String,
        password: String,
        database: String,
        tls: PostgresConnection.Configuration.TLS?
    ) async -> HealthCheckItem {
        let dateNow = Date().timeIntervalSinceReferenceDate
        app.databases.use(
            .postgres(
                configuration: .init(
                    hostname: hostname,
                    port: port,
                    username: username,
                    password: password,
                    database: database,
                    tls: tls ?? .disable
                )
            ),
            as: .psql
        )
        let connectionDescription = await getVersion()
        let connection = HealthCheckItem(
            componentId: app.psqlId,
            componentType: .datastore,
            observedValue: Date().timeIntervalSinceReferenceDate - dateNow,
            observedUnit: "s",
            status: connectionDescription.contains("ERROR:") ? .fail : .pass,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: connectionDescription.contains("ERROR:") ? connectionDescription : nil,
            links: nil,
            node: nil
        )
        return connection
    }

    /// Get psql health using url connection
    /// - Parameter url: `String`
    /// - Returns: `HealthCheckItem`
    public func checkConnection(by url: String) async throws -> HealthCheckItem {
        let dateNow = Date().timeIntervalSinceReferenceDate
        try app.databases.use(.postgres(url: url), as: .psql)
        let connectionDescription = await getVersion()
        let connection = HealthCheckItem(
            componentId: app.psqlId,
            componentType: .datastore,
            observedValue: Date().timeIntervalSinceReferenceDate - dateNow,
            observedUnit: "s",
            status: connectionDescription.contains("ERROR:") ? .fail : .pass,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: connectionDescription.contains("ERROR:") ? connectionDescription : nil,
            links: nil,
            node: nil
        )
        return connection
    }
    
    /// Check health psql connection
    /// - Returns: `String`
    public func getVersion() async -> String {
        let rows = try? await (app.db(.psql) as? PostgresDatabase)?.simpleQuery("SELECT version()").get()
        let row = rows?.first?.makeRandomAccess()
        guard let result = (row?[data: "version"].string) else {
            return "ERROR: No connect to Postgres database. Response: \(String(describing: row))"
        }
        return result
    }
}
