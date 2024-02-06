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
//  PostgresqlHealthCheck.swift
//
//
//  Created by Mykola Buhaiov on 31.01.2024.
//

import Vapor
import Fluent
import FluentPostgresDriver

/// Service that provides psql health check functionality
public struct PostgresqlHealthCheck: PostgresChecksProtocol {
    /// Instance of app as `Application`
    public let app: Application

    /// Get psql health using url connection
    /// - Parameter url: `String`
    /// - Returns: `HealthCheckItem`
    public func checkHealth(options: Set<MeasurementType>) async -> [String: HealthCheckItem] {
        var result = ["": HealthCheckItem()]
        for option in options {
            switch option {
            case .connections:
                let response = await getVersion()
                result["postgresql:\(MeasurementType.connections)"] = response
            case .utilization:
                break
            case .responseTime:
                let response = await getResponseTime()
                result["postgresql:\(MeasurementType.responseTime)"] = response
            case .uptime:
                break
            }
        }
        return result
    }
    
    /// Get  postgresql version
    /// - Returns: `HealthCheckItem`
    public func getVersion() async -> HealthCheckItem {
        let dateNow = Date().timeIntervalSinceReferenceDate
        let rows = try? await (app.db(.psql) as? PostgresDatabase)?.simpleQuery("SELECT version()").get()
        let row = rows?.first?.makeRandomAccess()
        var connectionDescription = "ERROR: No connect to Postgres database"
        if let result = (row?[data: "version"].string) {
            connectionDescription = result
        }
        let result = HealthCheckItem(
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
        return result
    }

    /// Get response time from postgresql
    /// - Returns: `HealthCheckItem`
    public func getResponseTime() async -> HealthCheckItem {
        let dateNow = Date().timeIntervalSinceReferenceDate
        let result = HealthCheckItem(
            componentId: app.psqlId,
            componentType: .datastore,
            observedValue: Date().timeIntervalSinceReferenceDate - dateNow,
            observedUnit: "s",
            status: .pass,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: "",
            links: nil,
            node: nil
        )
        return result
    }
}
