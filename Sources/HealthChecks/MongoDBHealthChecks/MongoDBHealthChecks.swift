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
//  MongoDBHealthChecks.swift
//  
//
//  Created by Mykola Buhaiov on 15.03.2024.
//

import Vapor
import MongoClient

/// Service that provides mongoDB health check functionality
public struct MongoDBHealthChecks: MongoDBChecksProtocol {
    /// Instance of app as `Application`
    public let app: Application

    public func connection() async -> HealthCheckItem {
        let dateNow = Date().timeIntervalSinceReferenceDate
        let connectionDescription = await getConnection()
        let result = HealthCheckItem(
            componentId: app.psqlId,
            componentType: .datastore,
            observedValue: Date().timeIntervalSinceReferenceDate - dateNow,
            observedUnit: "s",
            status: connectionDescription.contains("connecting") ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: !connectionDescription.contains("connecting") ? connectionDescription : nil,
            links: nil,
            node: nil
        )
        return result
    }
    
    public func responseTime() async -> HealthCheckItem {
        let dateNow = Date().timeIntervalSinceReferenceDate
        let connectionDescription = await getConnection()
        let result = HealthCheckItem(
            componentId: app.psqlId,
            componentType: .datastore,
            observedValue: Date().timeIntervalSinceReferenceDate - dateNow,
            observedUnit: "s",
            status: connectionDescription.contains("connecting") ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: !connectionDescription.contains("connecting") ? connectionDescription : nil,
            links: nil,
            node: nil
        )
        return result
    }
    
    public func getConnection() async -> String {
//        guard let result = try? await app.Request?.getVersionDescription() else {
//            return "ERROR: No connect to Postgres database"
//        }
//        return result
        return ""
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
                result["\(ComponentName.mongo):\(MeasurementType.responseTime)"] = await responseTime()
            case .connections:
                result["\(ComponentName.mongo):\(MeasurementType.connections)"] = await connection()
            default:
                break
            }
        }
        return result
    }
}
