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
//  ConsulHealthChecks.swift
//
//
//  Created by Mykola Buhaiov on 07.02.2024.
//

import Vapor

/// Provides health check functionality for a Consul service.
public struct ConsulHealthChecks: ConsulHealthChecksProtocol {
    /// The instance of the Vapor application.
    public let app: Application
    /// Initializes a new `ConsulHealthChecks` instance.
    /// - Parameter app: The Vapor `Application` instance.
    public init(app: Application) {
        self.app = app
    }

    /// Performs health checks for the specified measurement types.
    /// - Parameter options: An array of `MeasurementType` values specifying.
    /// - Returns: `[String: HealthCheckItem]`
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        let types = Set(options)
        async let responseTimeResult: HealthCheckItem? =
        types.contains(.connections) ? connection() : nil
        var results: [String: HealthCheckItem] = [:]
        if let item = await responseTimeResult {
            results["\(ComponentName.consul):\(MeasurementType.connections)"] = item
        }
        return results
    }

    /// Generates a `HealthCheckItem` representing the response time of the Consul service.
    /// - Parameters:
    ///   - response: The `ClientResponse` from the Consul status request.
    ///   - start: The start time used to calculate response duration.
    /// - Returns: `HealthCheckItem`
    func connection() async -> HealthCheckItem {
        let startTime: Date = .now
        var healthCheckItem = HealthCheckItem(
            componentId: app.consulConfig?.id,
            componentType: .component,
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
    
    /// Checks the connection for the PostgreSQL database.
    /// - Returns: A `String` describing the connection status.
    public func checkConnection() async throws {
        guard let consulRequest = app.consulRequest else {
            throw HealthCheckError.serviceNotSetup
        }
        return try await consulRequest.checkConnection()
    }
}
