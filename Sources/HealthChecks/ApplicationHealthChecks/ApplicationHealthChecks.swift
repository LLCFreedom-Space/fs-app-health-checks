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
        return HealthCheckItem(
            componentType: .system,
            observedValue: Double(ProcessInfo.processInfo.activeProcessorCount),
            observedUnit: "int",
            status: .pass,
            time: app.dateTimeISOFormat.string(from: Date())
        )
    }
    
    public func memory() -> HealthCheckItem {
        let processInfo = ProcessInfo.processInfo
        let bytesInGB: Double = 1024 * 1024 * 1024
        let physicalMemoryGB = Double(processInfo.physicalMemory) / bytesInGB
        return HealthCheckItem(
            componentType: .system,
            observedValue: Double(physicalMemoryGB),
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
        var result = ["": HealthCheckItem()]
        let measurementTypes = Array(Set(options))
        for type in measurementTypes {
            switch type {
            case .uptime:
                result["\(MeasurementType.uptime)"] = uptime()
            case .utilization:
                result["\(ComponentName.cpu):\(MeasurementType.utilization)"] = cpu()
                result["\(ComponentName.memory):\(MeasurementType.utilization)"] = memory()
            default:
                break
            }
        }
        result[""] = nil
        return result
    }
}
