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
//  PostgresHealthChecks.swift
//
//
//  Created by Mykola Buhaiov on 31.01.2024.
//

import Vapor
import Fluent
import FluentPostgresDriver

/// Concrete implementation of `PostgresHealthChecksProtocol` for monitoring PostgreSQL health.
public struct PostgresHealthChecks: PostgresHealthChecksProtocol {
    /// Instance of the application.
    public let app: Application
    /// Name of the PostgreSQL database to check.
    public let postgresDatabase: String
    /// Initializes a new `PostgresHealthChecks` instance.
    ///
    /// - Parameters:
    ///   - app: The `Application` instance.
    ///   - postgresDatabase: Name of the PostgreSQL database.
    public init(app: Application, postgresDatabase: String) {
        self.app = app
        self.postgresDatabase = postgresDatabase
    }

    /// Checks the PostgreSQL connection status.
    ///
    /// - Returns: A `HealthCheckItem` representing the connection state.
    public func connection() async -> HealthCheckItem {
        let connectionDescription = await checkConnection()
        let result = HealthCheckItem(
            componentId: app.psqlId,
            componentType: .datastore,
            status: connectionDescription.contains("active") ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: !connectionDescription.contains("active") ? connectionDescription : nil,
            links: nil,
            node: nil
        )
        return result
    }

    /// Measures the PostgreSQL response time.
    ///
    /// - Returns: A `HealthCheckItem` containing the response time in milliseconds.
    public func responseTime() async -> HealthCheckItem {
        let startTime = Date().timeIntervalSince1970
        let versionDescription = await getVersion()
        let result = HealthCheckItem(
            componentId: app.psqlId,
            componentType: .datastore,
            observedValue: (Date().timeIntervalSince1970 - startTime) * 1000,
            observedUnit: "ms",
            status: versionDescription.contains("PostgreSQL") ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: !versionDescription.contains("PostgreSQL") ? versionDescription : nil,
            links: nil,
            node: nil
        )
        return result
    }

    /// Retrieves the PostgreSQL version.
    ///
    /// - Returns: A `String` describing the PostgreSQL version.
    public func getVersion() async -> String {
        guard let result = try? await app.psqlRequest?.getVersionDescription() else {
            return "ERROR: No connect to Postgres database for get version"
        }
        return result
    }

    /// Checks the connection for the PostgreSQL database.
    ///
    /// - Returns: A `String` describing the connection status.
    public func checkConnection() async -> String {
        guard let result = try? await app.psqlRequest?.checkConnection(for: postgresDatabase) else {
            return "ERROR: No connect to Postgres database for check database"
        }
        return result
    }

    /// Performs health checks for the given measurement types.
    ///
    /// - Parameter options: Array of `MeasurementType` specifying which metrics to check.
    /// - Returns: Dictionary mapping `"<ComponentName>:<MeasurementType>"` to `HealthCheckItem`.
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var result = ["": HealthCheckItem()]
        let measurementTypes = Array(Set(options)) // Remove duplicates
        for type in measurementTypes {
            switch type {
            case .responseTime:
                result["\(ComponentName.postgresql):\(MeasurementType.responseTime)"] = await responseTime()
            case .connections:
                result["\(ComponentName.postgresql):\(MeasurementType.connections)"] = await connection()
            default:
                break
            }
        }
        return result
    }
}
