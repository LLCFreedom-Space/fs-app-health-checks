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
//  PostgresHealthChecksMock.swift
//
//
//  Created by Mykola Buhaiov on 31.01.2024.
//

import Vapor
@testable import HealthChecks

public struct PostgresHealthChecksMock: PostgresHealthChecksProtocol {
    static let psqlId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
    static let version = Constants.psqlVersionDescription
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

    public func connection() async -> HealthCheckItem {
        PostgresHealthChecksMock.healthCheckItem
    }

    public func responseTime() async -> HealthCheckItem {
        PostgresHealthChecksMock.healthCheckItem
    }

    public func getVersion() async -> String {
        PostgresHealthChecksMock.version
    }

    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        let result = [
            "\(ComponentName.postgresql):\(MeasurementType.responseTime)": PostgresHealthChecksMock.healthCheckItem,
            "\(ComponentName.postgresql):\(MeasurementType.connections)": PostgresHealthChecksMock.healthCheckItem
        ]
        return result
    }

    public func checkConnection() async -> String {
        "active"
    }
}
