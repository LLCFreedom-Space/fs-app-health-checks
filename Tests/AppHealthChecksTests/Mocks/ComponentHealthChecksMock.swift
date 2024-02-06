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
//  ComponentHealthChecksMock.swift
//
//
//  Created by Mykola Buhaiov on 06.02.2024.
//

import Vapor
@testable import AppHealthChecks

public struct ComponentHealthChecksMock: ComponentHealthChecksProtocol {
    static let psqlId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
    static let healthCheckItem = HealthCheckItem(
        componentId: psqlId,
        componentType: .datastore,
        observedValue: 1,
        observedUnit: "s",
        status: .pass,
        affectedEndpoints: nil,
        time: "2024-02-01T11:11:59.364",
        output: "Ok",
        links: nil,
        node: nil
    )
    public func checkHealth(for components: [ComponentName]) async -> [String : [HealthCheckItem]] {
        var result = ["": [HealthCheckItem()]]
        for component in components {
            switch component {
            case .postgresql:
                if var key = result["postgresql:\(MeasurementType.connections)"] {
                    key.append(ComponentHealthChecksMock.healthCheckItem)
                } else {
                    result["postgresql:\(MeasurementType.connections)"] = [ComponentHealthChecksMock.healthCheckItem]
                }
                if var key = result["postgresql:\(MeasurementType.responseTime)"] {
                    key.append(ComponentHealthChecksMock.healthCheckItem)
                } else {
                    result["postgresql:\(MeasurementType.responseTime)"] = [ComponentHealthChecksMock.healthCheckItem]
                }
            default:
                break
            }
        }
        return result
    }
}
