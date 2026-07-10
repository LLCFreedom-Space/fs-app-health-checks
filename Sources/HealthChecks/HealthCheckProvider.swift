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
//  HealthCheckProvider.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 10.07.2026.
//

import Vapor

/// Provides health checks for application components.
public struct HealthCheckProvider: @unchecked Sendable {
    /// The Vapor application instance.
    public let app: Application

    /// Creates a new health check provider.
    /// - Parameter app: The Vapor application instance.
    public init(app: Application) {
        self.app = app
    }

    /// Performs health checks for PostgreSQL.
    /// - Returns: A `CheckResult` containing the PostgreSQL health status.
    public func checkPostgres() async -> CheckResult {
        let serviceChecks = await app.postgresHealthChecks?.check(for: [.connections, .responseTime])
        return buildResult(name: ComponentName.postgresql.rawValue, serviceChecks: serviceChecks)
    }

    /// Performs health checks for Redis.
    /// - Returns: A `CheckResult` containing the Redis health status.
    public func checkRedis() async -> CheckResult {
        let serviceChecks = await app.redisHealthChecks?.check(for: [.connections, .responseTime])
        return buildResult(name: ComponentName.redis.rawValue, serviceChecks: serviceChecks)
    }

    /// Performs health checks for Consul.
    /// - Returns: A `CheckResult` containing the Consul health status.
    public func checkConsul() async -> CheckResult {
        let serviceChecks = await app.consulHealthChecks?.check(for: [.connections])
        return buildResult(name: ComponentName.consul.rawValue, serviceChecks: serviceChecks)
    }

    /// Performs health checks for MongoDB.
    /// - Returns: A `CheckResult` containing the MongoDB health status.
    public func checkMongo() async -> CheckResult {
        let serviceChecks = await app.mongoHealthChecks?.check(for: [.connections, .responseTime])
        return buildResult(name: ComponentName.mongo.rawValue, serviceChecks: serviceChecks)
    }

    /// Performs health checks for the application itself.
    /// - Returns: A `CheckResult` containing the application health status.
    public func checkApplication() async -> CheckResult {
        let serviceChecks = await app.applicationHealthChecks?.check(for: [.uptime, .utilization])
        return buildResult(name: "application", serviceChecks: serviceChecks)
    }

    /// Builds a unified health check result.
    /// - Parameters:
    ///   - name: The name of the component being checked.
    ///   - serviceChecks: The raw health check results.
    /// - Returns: A normalized `CheckResult`.
    func buildResult(
        name: String,
        serviceChecks: [String: HealthCheckItem]?
    ) -> CheckResult {
        guard let serviceChecks else {
            app.logger.error("Health check failed. No connection to \(name).")
            return .unavailable()
        }
        let hasFailed = serviceChecks.values.contains { $0.status == .fail }
        if hasFailed {
            app.logger.error("Health check failed: \(name) reported failure.")
        }
        let items = serviceChecks.reduce(into: [String: [HealthCheckItem]]()) { dict, pair in
            guard !pair.key.isEmpty else {
                return
            }
            dict[pair.key, default: []].append(pair.value)
        }
        return CheckResult(
            status: hasFailed ? .serviceUnavailable : .ok,
            items: items
        )
    }
}
