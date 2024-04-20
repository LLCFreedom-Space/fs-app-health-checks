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

/// Service that provides functionality to check the health of an application.
///
/// This struct implements the `ApplicationHealthChecksProtocol`, allowing you to perform various checks on your application's health.
public struct ApplicationHealthChecks: ApplicationHealthChecksProtocol {
    /// Reference to the application instance.
    public let app: Application
    
    /// Initializer for ApplicationHealthChecks
    /// - Parameter app: `Application`
    public init(app: Application) {
        self.app = app
    }

    /// Get uptime of the system.
    /// - Returns: A `HealthCheckItem` representing the application's uptime.
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
    
    /// Performs health checks based on the specified `MeasurementType` options.
    /// - Parameter options: An array of `MeasurementType` values indicating which checks to perform.
    /// - Returns: A dictionary mapping each `MeasurementType` to a corresponding `HealthCheckItem` representing the result of the check.
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
