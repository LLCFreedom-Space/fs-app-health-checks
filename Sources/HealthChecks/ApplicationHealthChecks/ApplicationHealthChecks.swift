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
    /// The instance of the Vapor application.
    public let app: Application
    /// Initializes a new `ApplicationHealthChecks` instance.
    /// - Parameter app: The Vapor `Application` instance.
    public init(app: Application) {
        self.app = app
    }

    /// Provides the application uptime as a health check item.
    /// - Returns: `HealthCheckItem`
    public func uptime() -> HealthCheckItem {
        let processInfo = ProcessInfo.processInfo
        return HealthCheckItem(
            componentType: .system,
            observedValue: processInfo.systemUptime,
            observedUnit: "s",
            status: .pass,
            time: app.dateTimeISOFormat.string(from: Date()),
            version: processInfo.operatingSystemVersionString
        )
    }
    
    /// Provides the number of active CPU cores available to the process.
    /// - Returns: `HealthCheckItem`
    public func cpu() -> HealthCheckItem {
        let processInfo = ProcessInfo.processInfo
        return HealthCheckItem(
            componentType: .system,
            observedValue: Double(processInfo.activeProcessorCount),
            observedUnit: "cores",
            status: .pass,
            time: app.dateTimeISOFormat.string(from: Date())
        )
    }
    
    /// Provides the total physical memory available on the host machine.
    /// - Returns: `HealthCheckItem`
    public func memory() -> HealthCheckItem {
        let processInfo = ProcessInfo.processInfo
        let bytesInGiB: Double = 1024 * 1024 * 1024
        let physicalMemoryGiB = Double(processInfo.physicalMemory) / bytesInGiB
        return HealthCheckItem(
            componentType: .system,
            observedValue: physicalMemoryGiB,
            observedUnit: "GiB",
            status: .pass,
            time: app.dateTimeISOFormat.string(from: Date())
        )
    }
    
    /// Executes selected health check measurements and returns their results.
    /// - Parameter options: An array of `MeasurementType` values specifying.
    /// - Returns: A dictionary where:
    ///   - Key: `String` representation of the `MeasurementType`
    ///   - Value: Corresponding `HealthCheckItem` result
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        let types = Set(options)
        var results: [String: HealthCheckItem] = [:]
        if types.contains(.uptime) {
            results[MeasurementType.uptime.rawValue] = uptime()
        }
        if types.contains(.utilization) {
            results["\(ComponentName.memory.rawValue):\(MeasurementType.utilization.rawValue)"] = memory()
            results["\(ComponentName.cpu.rawValue):\(MeasurementType.utilization.rawValue)"] = cpu()
        }
        return results
    }
}
