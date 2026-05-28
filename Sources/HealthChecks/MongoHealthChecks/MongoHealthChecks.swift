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
    /// Initializes a new `MongoHealthChecks` instance.
    /// - Parameters:
    ///   - app: The `Application` instance.
    public init(app: Application) {
        self.app = app
    }

    /// Measures the MongoDB response time.
    /// - Returns: A `HealthCheckItem` with the response time in milliseconds.
    public func responseTime() async -> HealthCheckItem {
        let startTime = Date().timeIntervalSince1970
        async let connectionDescription = checkConnection()
        async let version = getVersion()
        let (connections, resolvedVersion) = await (connectionDescription, version)
        let isConnected = connections.localizedCaseInsensitiveContains("connected")
        return HealthCheckItem(
            componentId: app.mongoId,
            componentType: .datastore,
            observedValue: (Date().timeIntervalSince1970 - startTime) * 1000,
            observedUnit: "ms",
            status: isConnected ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: isConnected ? nil : connections,
            links: nil,
            node: nil,
            version: resolvedVersion
        )
    }

    /// Checks the MongoDB connection status.
    /// - Returns: A `HealthCheckItem` representing the connection state.
    public func connection() async -> HealthCheckItem {
        async let activeConnections = getActiveConnections()
        async let version = getVersion()
        let (connections, resolvedVersion) = await (activeConnections, version)
        let isFailed = connections == .zero
        let connectionStatus = isFailed ? HealthCheckStatus.fail : HealthCheckStatus.pass
        return HealthCheckItem(
            componentId: app.mongoId,
            componentType: .datastore,
            status: connectionStatus,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: isFailed ? connections.description : nil,
            links: nil,
            node: nil,
            version: resolvedVersion
        )
    }

    /// Retrieves the MongoDB connection description.
    /// - Returns: A `String` describing the connection status.
    public func checkConnection() async -> String {
        guard let mongoRequest = app.mongoRequest else {
            app.logger.error("MongoRequest in app not set. Check your configuration, need to set `app.mongoRequest`")
            return "disconnected"
        }
        do {
            return try await mongoRequest.checkConnection()
        } catch {
            return "disconnected"
        }
    }
    
    /// Returns the total number of active MongoDB connections.
    /// - Returns: The number of active MongoDB connections,
    ///   or `0` if the value cannot be retrieved.
    public func getActiveConnections() async -> Int {
        guard let mongoRequest = app.mongoRequest else {
            app.logger.error("MongoRequest in app not set. Check your configuration, need to set `app.mongoRequest`")
            return .zero
        }
        do {
            return try await mongoRequest.getTotalConnection()
        } catch {
            return .zero
        }
    }
    
    /// Returns the MongoDB server version.
    /// - Returns: The MongoDB server version string,
    ///   or `"No version"` if unavailable.
    public func getVersion() async -> String {
        guard let mongoRequest = app.mongoRequest else {
            app.logger.error("MongoRequest in app not set. Check your configuration, need to set `app.mongoRequest`")
            return "No version"
        }
        do {
            return try await mongoRequest.getVersion()
        } catch {
            return "No version"
        }
    }

    /// Performs health checks for the given measurement types.
    /// - Parameter options: Array of `MeasurementType` specifying which metrics to check.
    /// - Returns: Dictionary mapping `"<ComponentName>:<MeasurementType>"` to `HealthCheckItem`.
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var results: [String: HealthCheckItem] = [:]
        let measurementTypes = Array(Set(options)) // Remove duplicates
        for type in measurementTypes {
            switch type {
            case .responseTime:
                results["\(ComponentName.mongo):\(MeasurementType.responseTime)"] = await responseTime()
            case .connections:
                results["\(ComponentName.mongo):\(MeasurementType.connections)"] = await connection()
            default:
                break
            }
        }
        return results
    }
}
