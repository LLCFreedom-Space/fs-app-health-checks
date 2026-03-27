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
//  ApplicationHealthChecks.swift
//
//
//  Created by Mykola Buhaiov on 10.02.2024.
//

import Vapor

/// Provides health check functionality for the application.
///
/// `ApplicationHealthChecks` implements `ApplicationHealthChecksProtocol`
/// and offers system-level health checks, such as uptime monitoring.
/// It serves as the central point for gathering application health metrics
/// in a Vapor-based project.
///
/// - Properties:
///   - `app`: The `Application` instance used to access configuration, logging, and runtime data.
///
/// - Usage:
/// Initialize with a Vapor `Application` instance and call the methods
/// defined in `ApplicationHealthChecksProtocol` to perform health checks.
public struct ApplicationHealthChecks: ApplicationHealthChecksProtocol {
    /// The instance of the Vapor application.
    public let app: Application
    /// Initializes a new `ApplicationHealthChecks` instance.
    ///
    /// - Parameter app: The Vapor `Application` instance.
    public init(app: Application) {
        self.app = app
    }

    /// Provides the application uptime as a health check item.
    ///
    /// This method calculates the uptime of the application by measuring
    /// the time interval (in seconds) since the app was launched.
    /// It returns the result formatted as a `HealthCheckItem`.
    ///
    /// - Returns: A `HealthCheckItem` containing:
    ///   - `componentType`: `.system`
    ///   - `observedValue`: The uptime in seconds
    ///   - `observedUnit`: `"s"` (seconds)
    ///   - `status`: `.pass` (always assumed healthy)
    ///   - `time`: The current timestamp in ISO 8601 format
    ///
    /// - Note:
    /// The uptime is derived from `app.launchTime`, so it is important
    /// that this value is correctly set during application startup.
    public func uptime() -> HealthCheckItem {
        let uptime = Date().timeIntervalSince1970 - app.launchTime
        return HealthCheckItem(
            componentType: .system,
            observedValue: uptime,
            observedUnit: "s",
            status: .pass,
            time: app.dateTimeISOFormat.string(from: Date())
        )
    }
    
    /// Executes selected health check measurements and returns their results.
    ///
    /// This method iterates over the provided `MeasurementType` options,
    /// removes duplicates, and runs the corresponding health checks.
    /// Each result is stored in a dictionary keyed by the measurement type name.
    ///
    /// - Parameter options: An array of `MeasurementType` values specifying
    ///   which health checks should be performed.
    ///
    /// - Returns: A dictionary where:
    ///   - Key: `String` representation of the `MeasurementType`
    ///   - Value: Corresponding `HealthCheckItem` result
    ///
    /// - Behavior:
    ///   - Duplicate measurement types are ignored
    ///   - Unsupported or unhandled types are skipped
    ///   - Currently supports:
    ///     - `.uptime` → returns application uptime
    ///
    /// - Note:
    /// An empty key is temporarily used during initialization and removed before returning the final result.
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var result = ["": HealthCheckItem()]
        let measurementTypes = Array(Set(options))
        for type in measurementTypes {
            switch type {
            case .uptime:
                result["\(MeasurementType.uptime)"] = uptime()
            default:
                break
            }
        }
        result[""] = nil
        return result
    }
}
