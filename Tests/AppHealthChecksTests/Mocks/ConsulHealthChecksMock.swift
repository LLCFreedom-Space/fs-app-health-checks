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
//  ConsulHealthChecksMock.swift
//
//
//  Created by Mykola Buhaiov on 07.02.2024.
//

import Vapor
@testable import AppHealthChecks

public struct ConsulHealthChecksMock: ConsulHealthChecksProtocol {
    static let consulId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
    static let healthCheckItem = HealthCheckItem(
        componentId: consulId,
        componentType: .component,
        observedValue: 1,
        observedUnit: "s",
        status: .pass,
        affectedEndpoints: nil,
        time: "2024-02-01T11:11:59.364",
        output: "Ok",
        links: nil,
        node: nil
    )

    static let healthCheckItemFail = HealthCheckItem(
        componentId: consulId,
        componentType: .component,
        observedValue: 1,
        observedUnit: "s",
        status: .fail,
        affectedEndpoints: nil,
        time: "2024-02-01T11:11:59.364",
        output: "Error response from url - http://127.0.0.1:8500/v1/status/leader, with http status - 400 Bad Request",
        links: nil,
        node: nil
    )

    public func checkHealth(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        let result = [
            "\(ComponentName.consul):\(MeasurementType.responseTime)": ConsulHealthChecksMock.healthCheckItem,
            "\(ComponentName.consul):\(MeasurementType.connections)": ConsulHealthChecksMock.healthCheckItem
        ]
        return result
    }

    public func getStatus() async -> ClientResponse {
        ClientResponse(status: .ok)
    }

    public func status(_ response: ClientResponse) -> HealthCheckItem {
        ConsulHealthChecksMock.healthCheckItem
    }

    public func responseTime(from response: ClientResponse, _ start: TimeInterval) -> HealthCheckItem {
        let url = Constants.consulUrl
        let path = Constants.consulStatusPath
        if response.status == .ok {
            return ConsulHealthChecksMock.healthCheckItem
        } else {
            return ConsulHealthChecksMock.healthCheckItemFail
        }
    }
}
