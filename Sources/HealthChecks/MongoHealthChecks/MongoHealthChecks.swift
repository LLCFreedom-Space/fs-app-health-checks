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
        let startTime: Date = .now
        var healthCheckItem = HealthCheckItem(
            componentId: app.mongoId,
            componentType: .datastore,
            status: .pass,
            links: nil,
            node: nil
        )
        do {
            try await checkConnection()
            healthCheckItem.observedValue = Date().timeIntervalSince(startTime)
            healthCheckItem.observedUnit = "s"
            healthCheckItem.time = app.dateTimeISOFormat.string(from: .now)
            return healthCheckItem
        } catch {
            healthCheckItem.status = .fail
            healthCheckItem.output = "\(error)"
            return healthCheckItem
        }
    }
    
    /// Checks the MongoDB connection status.
    /// - Returns: A `HealthCheckItem` representing the connection state.
    public func connection() async -> HealthCheckItem {
        var healthCheckItem = HealthCheckItem(
            componentId: app.mongoId,
            componentType: .datastore,
            status: .pass,
            links: nil,
            node: nil
        )
        do {
            async let activeConnections = getActiveConnections()
            async let version = getVersion()
            let (connections, resolvedVersion) = try await (activeConnections, version)
            let activeConnsections = connections
            healthCheckItem.observedValue = Double(activeConnsections)
            healthCheckItem.observedUnit = "number"
            healthCheckItem.time = app.dateTimeISOFormat.string(from: .now)
            healthCheckItem.version = resolvedVersion
            return healthCheckItem
        } catch {
            healthCheckItem.status = .fail
            healthCheckItem.output = "\(error)"
            return healthCheckItem
        }
    }
    
    /// Retrieves the MongoDB connection description.
    /// - Returns: A `String` describing the connection status.
    /// - Throws:
    ///   - `HealthCheckError.serviceNotSetup` if `mongoRequest` is not configured.
    ///   - Any error thrown by the underlying MongoDB client.
    public func checkConnection() async throws {
        guard let mongoRequest = app.mongoRequest else {
            throw HealthCheckError.serviceNotSetup
        }
        return try await mongoRequest.checkConnection()
    }
    
    /// Returns the total number of active MongoDB connections.
    /// - Returns: The number of active MongoDB connections.
    /// - Throws:
    ///   - `HealthCheckError.serviceNotSetup` if `mongoRequest` is not configured.
    ///   - Any error thrown by the underlying MongoDB client.
    public func getActiveConnections() async throws -> Int {
        guard let mongoRequest = app.mongoRequest else {
            throw HealthCheckError.serviceNotSetup
        }
        return try await mongoRequest.getActiveConnections()
    }
    
    /// Returns the MongoDB server version.
    /// - Returns: The MongoDB server version string.
    /// - Throws:
    ///   - `HealthCheckError.serviceNotSetup` if `mongoRequest` is not configured.
    ///   - Any error thrown by the underlying MongoDB client.
    public func getVersion() async throws -> String {
        guard let mongoRequest = app.mongoRequest else {
            throw HealthCheckError.serviceNotSetup
        }
        return try await mongoRequest.getVersion()
    }
    
    /// Performs health checks for the given measurement types.
    /// - Parameter options: Array of `MeasurementType` specifying which metrics to check.
    /// - Returns: Dictionary mapping `"<ComponentName>:<MeasurementType>"` to `HealthCheckItem`.
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        let types = Set(options)
        async let responseTimeResult: HealthCheckItem? =
        types.contains(.responseTime) ? responseTime() : nil
        async let connectionsResult: HealthCheckItem? =
        types.contains(.connections) ? connection() : nil
        var results: [String: HealthCheckItem] = [:]
        if let item = await responseTimeResult {
            results["\(ComponentName.mongo):\(MeasurementType.responseTime)"] = item
        }
        if let item = await connectionsResult {
            results["\(ComponentName.mongo):\(MeasurementType.connections)"] = item
        }
        return results
    }
}
