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
//  ComponentHealthChecks.swift
//
//
//  Created by Mykola Buhaiov on 06.02.2024.
//

import Vapor

/// Service that provides component health check functionality
public struct ComponentHealthChecks: ComponentHealthChecksProtocol {
    /// Instance of app as `Application`
    public let app: Application
    
    /// Check health for components
    /// - Parameter components: array `ComponentName`
    /// - Returns: `[String: [HealthCheckItem]]`
    public func checkHealth(for components: [ComponentName]) async -> [String: [HealthCheckItem]] {
        var result = ["": [HealthCheckItem()]]
        for component in components {
            switch component {
            case .postgresql:
                if let response = await app.psqlHealthChecks?.getVersion() {
                    result["postgresql:\(MeasurementType.connections)"]?.append(response)
                }
                if let response = await app.psqlHealthChecks?.getResponseTime() {
                    result["postgresql:\(MeasurementType.responseTime)"]?.append(response)
                }
            default:
                break
            }
        }
        return result
    }
}