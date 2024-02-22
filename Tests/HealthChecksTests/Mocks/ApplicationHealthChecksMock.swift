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
//  ApplicationHealthChecksMock.swift
//
//
//  Created by Mykola Buhaiov on 10.02.2024.
//

import Vapor
@testable import HealthChecks

public struct ApplicationHealthChecksMock: ApplicationHealthChecksProtocol {
    static let healthCheckItem = HealthCheckItem(
        componentType: .system,
        observedValue: 1,
        observedUnit: "s",
        status: .pass,
        time: "2024-02-01T11:11:59.364"
    )

    public func uptime() -> HealthCheckItem {
        ApplicationHealthChecksMock.healthCheckItem
    }

    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        let result = [
            MeasurementType.uptime.rawValue: ApplicationHealthChecksMock.healthCheckItem
        ]
        return result
    }
}
