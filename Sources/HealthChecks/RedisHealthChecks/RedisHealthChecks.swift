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
//  RedisHealthChecks.swift
//  
//
//  Created by Mykola Buhaiov on 21.02.2024.
//

import Vapor

/// Service that provides redis health check functionality
public struct RedisHealthChecks: RedisHealthChecksProtocol {
    /// Instance of the application.
    public let app: Application
    /// Initializes a new `RedisHealthChecks` instance.
    /// - Parameter app: The `Application` instance.
    public init(app: Application) {
        self.app = app
    }

    /// Retrieves the Redis connection status.
    /// - Returns: A `HealthCheckItem` representing the current connection state.
    public func connection() async -> HealthCheckItem {
        var healthCheckItem = HealthCheckItem(
            componentId: app.redisId,
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

    /// Measures the Redis response time.
    /// - Returns: A `HealthCheckItem` containing the response time in milliseconds.
    public func responseTime() async -> HealthCheckItem {
        let startTime: Date = .now
        var healthCheckItem = HealthCheckItem(
            componentId: app.redisId,
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

    /// Sends a ping to Redis and returns the response.
    /// - Returns: A `String` representing the Redis ping response or an error message if not connected.
    @discardableResult public func getDatabaseHealthMetrics() async throws -> (connectedClients: Int, version: String) {
        guard let redisRequest = app.redisRequest else {
            throw HealthCheckError.serviceNotSetup(name: ComponentName.redis.rawValue)
        }
        return try await redisRequest.getDatabaseHealthMetrics()
    }

    /// Performs health checks based on the provided measurement types.
    /// - Parameter options: An array of `MeasurementType` specifying which checks to perform.
    /// - Returns: A dictionary mapping a string key to the resulting `HealthCheckItem`.
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        let types = Set(options)
        async let responseTimeResult: HealthCheckItem? =
        types.contains(.responseTime) ? responseTime() : nil
        async let connectionsResult: HealthCheckItem? =
        types.contains(.connections) ? connection() : nil
        var results: [String: HealthCheckItem] = [:]
        if let item = await responseTimeResult {
            results["\(ComponentName.redis):\(MeasurementType.responseTime)"] = item
        }
        if let item = await connectionsResult {
            results["\(ComponentName.redis):\(MeasurementType.connections)"] = item
        }
        return results
    }
}
