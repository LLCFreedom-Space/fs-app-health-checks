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

/// Concrete implementation of `PostgresHealthChecksProtocol` for monitoring PostgreSQL health.
public struct PostgresHealthChecks: PostgresHealthChecksProtocol {
    /// Instance of the application.
    public let app: Application
    /// Initializes a new `PostgresHealthChecks` instance.
    /// - Parameters:
    ///   - app: The `Application` instance.
    public init(app: Application) {
        self.app = app
    }

    /// Checks the PostgreSQL connection status.
    /// - Returns: A `HealthCheckItem` representing the connection state.
    public func connection() async -> HealthCheckItem {
        var healthCheckItem = HealthCheckItem(
            componentId: app.postgresId,
            componentType: .datastore,
            status: .pass,
            links: nil,
            node: nil
        )
        do {
            let (connections, version) = try await getDatabaseHealthMetrics()
            let activeConnsections = connections
            healthCheckItem.observedValue = Double(activeConnsections)
            healthCheckItem.observedUnit = "number"
            healthCheckItem.time = app.dateTimeISOFormat.string(from: .now)
            healthCheckItem.version = version
            return healthCheckItem
        } catch {
            healthCheckItem.status = .fail
            healthCheckItem.output = error.localizedDescription
            return healthCheckItem
        }
    }

    /// Measures the PostgreSQL response time.
    /// - Returns: A `HealthCheckItem` containing the response time in milliseconds.
    public func responseTime() async -> HealthCheckItem {
        let startTime: Date = .now
        var healthCheckItem = HealthCheckItem(
            componentId: app.postgresId,
            componentType: .datastore,
            status: .pass,
            links: nil,
            node: nil
        )
        do {
            try await getDatabaseHealthMetrics()
            healthCheckItem.observedValue = Date().timeIntervalSince(startTime)
            healthCheckItem.observedUnit = "s"
            healthCheckItem.time = app.dateTimeISOFormat.string(from: .now)
            return healthCheckItem
        } catch {
            healthCheckItem.status = .fail
            healthCheckItem.output = error.localizedDescription
            return healthCheckItem
        }
    }

    /// Retrieves PostgreSQL connection statistics and server version.
    /// - Returns: A tuple containing:
    ///   - `activeConnections`: Number of currently active database connections (Int)
    ///   - `version`: PostgreSQL server version string
    /// - Throws: `HealthCheckError`
    @discardableResult public func getDatabaseHealthMetrics() async throws -> (activeConnections: Int, version: String) {
        guard let postgresRequest = app.postgresRequest else {
            throw HealthCheckError.serviceNotSetup(name: ComponentName.postgresql.rawValue)
        }
        return try await postgresRequest.getDatabaseHealthMetrics()
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
            results["\(ComponentName.postgresql):\(MeasurementType.responseTime)"] = item
        }
        if let item = await connectionsResult {
            results["\(ComponentName.postgresql):\(MeasurementType.connections)"] = item
        }
        return results
    }
}
