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
public struct ApplicationHealthChecks: ApplicationHealthChecksProtocol {
    public let app: Application

    public init(app: Application) {
        self.app = app
    }

    // MARK: - Public

    /// Provides the application uptime in seconds as a health check item.
    /// - Returns: A `HealthCheckItem` with `componentType: .system` and `observedUnit: "s"`.
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

    public func cpu() -> HealthCheckItem {
        let processInfo = ProcessInfo.processInfo
        return HealthCheckItem(
            componentType: .system,
            observedValue: Double(processInfo.activeProcessorCount),
            observedUnit: "cores",
            status: .pass,
            time: app.dateTimeISOFormat.string(from: Date()),
            version: processInfo.operatingSystemVersionString
        )
    }

    public func memory() -> HealthCheckItem {
        let processInfo = ProcessInfo.processInfo
        let bytesInGiB: Double = 1024 * 1024 * 1024
        let physicalMemoryGiB = Double(processInfo.physicalMemory) / bytesInGiB
        return HealthCheckItem(
            componentType: .system,
            observedValue: physicalMemoryGiB,
            observedUnit: "GiB",
            status: .pass,
            time: app.dateTimeISOFormat.string(from: Date()),
            version: processInfo.operatingSystemVersionString
        )
    }
    
    /// Executes selected health check measurements and returns their results.
    /// - Parameter options: An array of `MeasurementType` values specifying which checks to run.
    ///   Duplicate values are ignored.
    /// - Returns: A dictionary keyed by the `MeasurementType` raw value,
    ///   with the corresponding `HealthCheckItem` as the value.
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var results: [String: HealthCheckItem] = [:]
        for type in Set(options) {
            switch type {
            case .uptime:
                results[MeasurementType.uptime.rawValue] = uptime()
            case .utilization:
                results["\(ComponentName.memory.rawValue):\(MeasurementType.utilization.rawValue)"] = memory()
                results["\(ComponentName.cpu.rawValue):\(MeasurementType.utilization.rawValue)"] = cpu()
            default:
                break
            }
        }
        return results
    }
}
