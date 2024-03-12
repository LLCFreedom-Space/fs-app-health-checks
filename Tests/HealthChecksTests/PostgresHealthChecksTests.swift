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
//  PostgresHealthChecksTests.swift
//
//
//  Created by Mykola Buhaiov on 09.03.2023.
//

import XCTVapor
@testable import HealthChecks

final class PostgresHealthChecksTests: XCTestCase {
    func testConnection() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.psqlId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
        app.psqlHealthChecks = PostgresHealthChecksMock()
        let mockResult = await app.psqlHealthChecks?.connection()
        XCTAssertEqual(mockResult, PostgresHealthChecksMock.healthCheckItem)

        app.psqlHealthChecks = PostgresHealthChecks(app: app)
        let result = await app.psqlHealthChecks?.connection()
        XCTAssertEqual(result?.componentType, .datastore)
        XCTAssertNotEqual(result?.observedValue, 1.0)
        XCTAssertEqual(result?.observedUnit, "s")
        XCTAssertEqual(result?.status, .pass)
        XCTAssertNil(result?.affectedEndpoints)
        XCTAssertNil(result?.output)
        XCTAssertNil(result?.links)
        XCTAssertNil(result?.node)
    }

    func testResponseTime() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.psqlHealthChecks = PostgresHealthChecksMock()
        let resultMock = await app.psqlHealthChecks?.responseTime()
        XCTAssertEqual(resultMock, PostgresHealthChecksMock.healthCheckItem)

        app.psqlHealthChecks = PostgresHealthChecks(app: app)
        let result = await app.psqlHealthChecks?.responseTime()
        XCTAssertEqual(result?.componentType, .datastore)
        XCTAssertNotEqual(result?.observedValue, 1.0)
        XCTAssertEqual(result?.observedUnit, "s")
        XCTAssertEqual(result?.status, .pass)
        XCTAssertNil(result?.affectedEndpoints)
        XCTAssertNil(result?.output)
        XCTAssertNil(result?.links)
        XCTAssertNil(result?.node)
    }

    func testHealthCheck() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.psqlId = UUID().uuidString
        app.psqlHealthChecks = PostgresHealthChecksMock()
        let result = await app.psqlHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
        let psqlConnections = result?["\(ComponentName.postgresql):\(MeasurementType.connections)"]
        XCTAssertEqual(psqlConnections, PostgresHealthChecksMock.healthCheckItem)
        let psqlResponseTimes = result?["\(ComponentName.postgresql):\(MeasurementType.responseTime)"]
        XCTAssertEqual(psqlResponseTimes, PostgresHealthChecksMock.healthCheckItem)
    }

    func testGetVersion() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.psqlId = UUID().uuidString
        app.psqlHealthChecks = PostgresHealthChecksMock()
        let resultMock = await app.psqlHealthChecks?.getVersion()
        XCTAssertEqual(resultMock, PostgresHealthChecksMock.version)

        app.psqlHealthChecks = PostgresHealthChecks(app: app)
        let result = await app.psqlHealthChecks?.getVersion()
        XCTAssertEqual(result, "PostgreSQL 14.10 on x86_64-pc-linux-musl, compiled by gcc (Alpine 13.2.1_git20231014) 13.2.1 20231014, 64-bit")
    }
}
