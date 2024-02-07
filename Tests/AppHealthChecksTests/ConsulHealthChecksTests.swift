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
//  ConsulHealthChecksTests.swift
//
//
//  Created by Mykola Buhaiov on 07.02.2024.
//

import Vapor
import XCTest
@testable import AppHealthChecks

final class ConsulHealthChecksTests: XCTestCase {
    let url = "http://127.0.0.1:8500"
    let path = "/v1/status/leader"

    func testConnection() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.consulId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
        app.consulHealthChecks = ConsulHealthChecksMock()
        let result = await app.consulHealthChecks?.connection(by: url, and: path)
        XCTAssertEqual(result, ConsulHealthChecksMock.healthCheckItem)
    }

    func testGetResponseTime() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.consulId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
        app.consulHealthChecks = ConsulHealthChecksMock()
        let result = await app.consulHealthChecks?.getResponseTime(by: url, and: path)
        XCTAssertEqual(result, ConsulHealthChecksMock.healthCheckItem)
    }

    func testCheckHealth() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.consulId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
        app.consulHealthChecks = ConsulHealthChecksMock()
        let result = await app.consulHealthChecks?.checkHealth(by: url, and: path, for: [MeasurementType.responseTime, MeasurementType.connections])
        let psqlConnections = result?["\(ComponentName.consul):\(MeasurementType.connections)"]
        XCTAssertEqual(psqlConnections, ConsulHealthChecksMock.healthCheckItem)
        let psqlResponseTimes = result?["\(ComponentName.consul):\(MeasurementType.responseTime)"]
        XCTAssertEqual(psqlResponseTimes, ConsulHealthChecksMock.healthCheckItem)
    }

    func testGetStatus() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.consulHealthChecks = ConsulHealthChecksMock()
        let result = await app.consulHealthChecks?.getStatus(by: url, and: path)
        XCTAssertEqual(result, .ok)
    }
}
