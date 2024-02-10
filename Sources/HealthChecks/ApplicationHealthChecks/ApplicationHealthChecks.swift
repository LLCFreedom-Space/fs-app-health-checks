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

/// Service that provides app health check functionality
public struct ApplicationHealthChecks: ApplicationHealthChecksProtocol {
    /// Instance of app as `Application`
    public let app: Application

    /// Get uptime of system
    /// - Returns: `HealthCheckItem`
    public func uptime() -> HealthCheckItem {
        let uptime = Date().timeIntervalSinceReferenceDate - app.launchTime
        return HealthCheckItem(
            componentType: .system,
            observedValue: uptime,
            observedUnit: "s",
            status: .pass,
            time: app.dateTimeISOFormat.string(from: Date())
        )
    }

    /// Check with setup options
    /// - Parameter options: array of `MeasurementType`
    /// - Returns: dictionary `[String: HealthCheckItem]`
    public func checkHealth(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
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
        return result
    }
}
