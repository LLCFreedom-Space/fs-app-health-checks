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
//  MongoHealthChecks.swift
//  
//
//  Created by Mykola Buhaiov on 15.03.2024.
//

import Vapor
import MongoClient

/// Concrete implementation of `MongoHealthChecksProtocol` for monitoring MongoDB health.
public struct MongoHealthChecks: MongoHealthChecksProtocol {
    /// Instance of the application.
    public let app: Application
    /// Connection URL for the MongoDB instance.
    public let url: String
    /// Initializes a new `MongoHealthChecks` instance.
    ///
    /// - Parameters:
    ///   - app: The `Application` instance.
    ///   - url: Connection URL string for MongoDB.
    public init(app: Application, url: String) {
        self.app = app
        self.url = url
    }

    /// Checks the MongoDB connection status.
    ///
    /// - Returns: A `HealthCheckItem` representing the connection state.
    public func connection() async -> HealthCheckItem {
        let connectionDescription = await getConnection()
        let connectionStatus = ["disconnected", "closed"].contains(where: connectionDescription.contains)
        let result = HealthCheckItem(
            componentId: app.mongoId,
            componentType: .datastore,
            // TODO: fetch active connection count/value if available
            status: connectionStatus ? .fail : .pass,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: connectionStatus ? connectionDescription : nil,
            links: nil,
            node: nil
        )
        return result
    }

    /// Measures the MongoDB response time.
    ///
    /// - Returns: A `HealthCheckItem` with the response time in milliseconds.
    public func responseTime() async -> HealthCheckItem {
        let startTime = Date().timeIntervalSince1970
        let connectionDescription = await getConnection()
        let connectionStatus = ["disconnected", "closed"].contains(where: connectionDescription.contains)
        let result = HealthCheckItem(
            componentId: app.mongoId,
            componentType: .datastore,
            observedValue: (Date().timeIntervalSince1970 - startTime) * 1000,
            observedUnit: "ms",
            status: connectionStatus ? .fail : .pass,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: connectionStatus ? connectionDescription : nil,
            links: nil,
            node: nil
        )
        return result
    }

    /// Retrieves the MongoDB connection description.
    ///
    /// - Returns: A `String` describing the connection status.
    public func getConnection() async -> String {
        guard let mongoRequest = app.mongoRequest else {
            app.logger.error("MongoRequest in app not set. Check your configuration, need to set `app.mongoRequest`")
            return "disconnected"
        }
        return await mongoRequest.getConnection(by: url)
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
