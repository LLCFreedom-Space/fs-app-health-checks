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
    /// Performs a health check and returns a normalized result.
    /// - Parameters:
    ///   - name: The component name.
    ///   - perform: Closure that executes the health check.
    /// - Returns: A normalized `CheckResult`.
    public func check(
        name: String,
        perform: () async -> [String: HealthCheckItem]?
    ) async -> CheckResult {
        guard let serviceChecks = await perform() else {
            app.logger.error("Health check failed. No connection.", metadata: [ "name": .string(name) ])
            return .unavailable()
        }
        let hasFailed = serviceChecks.values.contains { $0.status == .fail }
        if hasFailed {
            app.logger.error("Health check failed.", metadata: ["name": .string(name) ])
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
