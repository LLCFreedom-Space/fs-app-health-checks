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

/// Service that provides psql health check functionality
public struct PostgresHealthChecks: PostgresHealthChecksProtocol {
    /// Instance of app as `Application`
    public let app: Application

    /// Instance of url as `String` for mongo
    public let postgresDatabase: String

    /// Initializer for PostgresHealthChecks
    /// - Parameter app: `Application`
    /// - Parameter postgresDatabase: `String`
    public init(app: Application, postgresDatabase: String) {
        self.app = app
        self.postgresDatabase = postgresDatabase
    }

    /// Get  psql version
    /// - Returns: `HealthCheckItem`
    public func connection() async -> HealthCheckItem {
        let connectionDescription = await checkConnection()
        let result = HealthCheckItem(
            componentId: app.psqlId,
            componentType: .datastore,
            observedValue: 1,
            status: connectionDescription.contains("active") ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: !connectionDescription.contains("active") ? connectionDescription : nil,
            links: nil,
            node: nil
        )
        return result
    }

    /// Get psql response time
    /// - Returns: `HealthCheckItem`
    public func responseTime() async -> HealthCheckItem {
        let dateNow = Date().timeIntervalSince1970
        let versionDescription = await getVersion()
        let result = HealthCheckItem(
            componentId: app.psqlId,
            componentType: .datastore,
            observedValue: (Date().timeIntervalSince1970 - dateNow) * 1000,
            observedUnit: "ms",
            status: versionDescription.contains("PostgreSQL") ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: !versionDescription.contains("PostgreSQL") ? versionDescription : nil,
            links: nil,
            node: nil
        )
        return result
    }

    /// Get psql version
    /// - Returns: `String`
    public func getVersion() async -> String {
        guard let result = try? await app.psqlRequest?.getVersionDescription() else {
            return "ERROR: No connect to Postgres database for get version"
        }
        return result
    }

    /// Check connection
    /// - Returns: `String`
    public func checkConnection() async -> String {
        guard let result = try? await app.psqlRequest?.checkConnection(for: postgresDatabase) else {
            return "ERROR: No connect to Postgres database"
        }
        return result
    }

    /// Check with setup options
    /// - Parameter options: array of `MeasurementType`
    /// - Returns: dictionary `[String: HealthCheckItem]`
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var result = ["": HealthCheckItem()]
        let measurementTypes = Array(Set(options))
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
