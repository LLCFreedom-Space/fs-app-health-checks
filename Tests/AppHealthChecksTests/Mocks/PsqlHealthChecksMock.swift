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
//  PsqlHealthChecksMock.swift
//
//
//  Created by Mykola Buhaiov on 31.01.2024.
//

import Vapor
@testable import AppHealthChecks

public struct PsqlHealthChecksMock: PsqlHealthChecksProtocol {
    static let healthCheckItem = HealthCheckItem(
        componentId: UUID().uuidString,
        componentType: .datastore,
        observedValue: 1,
        observedUnit: "s",
        status: .pass,
        affectedEndpoints: nil,
        time: Date().formatted(.iso8601),
        output: "Ok",
        links: nil,
        node: nil
    )

    public func getHealth(
        hostname: String,
        port: Int,
        username: String,
        password: String,
        database: String
    ) async -> (String, HealthCheckItem) {
        return ("\(ComponentName.postgresql):\(MeasurementType.connections)", PsqlHealthChecksMock.healthCheckItem)
    }

    public func getHealth(url: String) async -> (String, HealthCheckItem) {
        return ("\(ComponentName.postgresql):\(MeasurementType.connections)", PsqlHealthChecksMock.healthCheckItem)
    }
}
