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

        app.psqlRequest = PsqlRequestMock()
        app.psqlHealthChecks = PostgresHealthChecks(app: app, postgresDatabase: "test")
        let result = await app.psqlHealthChecks?.connection()
        XCTAssertEqual(result?.componentType, .datastore)
        XCTAssertEqual(result?.observedValue, 1.0)
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

        app.psqlRequest = PsqlRequestMock()
        app.psqlHealthChecks = PostgresHealthChecks(app: app, postgresDatabase: "test")
        let result = await app.psqlHealthChecks?.responseTime()
        XCTAssertEqual(result?.componentType, .datastore)
        XCTAssertNotEqual(result?.observedValue, 1.0)
        XCTAssertEqual(result?.observedUnit, "ms")
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
        let mockResult = await app.psqlHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
        let mockPsqlConnections = mockResult?["\(ComponentName.postgresql):\(MeasurementType.connections)"]
        XCTAssertEqual(mockPsqlConnections, PostgresHealthChecksMock.healthCheckItem)
        let mockPsqlResponseTimes = mockResult?["\(ComponentName.postgresql):\(MeasurementType.responseTime)"]
        XCTAssertEqual(mockPsqlResponseTimes, PostgresHealthChecksMock.healthCheckItem)

        app.psqlRequest = PsqlRequestMock()
        app.psqlHealthChecks = PostgresHealthChecks(app: app, postgresDatabase: "test")
        let result = await app.psqlHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
        let psqlConnections = result?["\(ComponentName.postgresql):\(MeasurementType.connections)"]
        XCTAssertEqual(psqlConnections?.componentType, .datastore)
        XCTAssertEqual(psqlConnections?.observedValue, 1.0)
        XCTAssertEqual(psqlConnections?.status, .pass)
        XCTAssertNil(psqlConnections?.affectedEndpoints)
        XCTAssertNil(psqlConnections?.output)
        XCTAssertNil(psqlConnections?.links)
        XCTAssertNil(psqlConnections?.node)
        let psqlResponseTimes = mockResult?["\(ComponentName.postgresql):\(MeasurementType.responseTime)"]
        XCTAssertEqual(psqlResponseTimes, PostgresHealthChecksMock.healthCheckItem)
        XCTAssertEqual(psqlResponseTimes, PostgresHealthChecksMock.healthCheckItem)
        XCTAssertEqual(psqlResponseTimes?.componentType, .datastore)
        XCTAssertEqual(psqlResponseTimes?.observedValue, 1.0)
        XCTAssertEqual(psqlResponseTimes?.observedUnit, "s")
        XCTAssertEqual(psqlResponseTimes?.status, .pass)
        XCTAssertNil(psqlResponseTimes?.affectedEndpoints)
        XCTAssertEqual(psqlResponseTimes?.output, "Ok")
        XCTAssertNil(psqlResponseTimes?.links)
        XCTAssertNil(psqlResponseTimes?.node)
    }

    func testGetVersion() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.psqlId = UUID().uuidString
        app.psqlHealthChecks = PostgresHealthChecksMock()
        let resultMock = await app.psqlHealthChecks?.getVersion()
        XCTAssertEqual(resultMock, PostgresHealthChecksMock.version)

        app.psqlRequest = PsqlRequestMock()
        app.psqlHealthChecks = PostgresHealthChecks(app: app, postgresDatabase: "test")
        let result = await app.psqlHealthChecks?.getVersion()
        XCTAssertEqual(result, Constants.psqlVersionDescription)
    }

    func testCheckConnection() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.psqlId = UUID().uuidString
        app.psqlHealthChecks = PostgresHealthChecksMock()
        let resultMock = await app.psqlHealthChecks?.checkConnection()
        XCTAssertEqual(resultMock, "active")

        app.psqlRequest = PsqlRequestMock()
        app.psqlHealthChecks = PostgresHealthChecks(app: app, postgresDatabase: "test")
        let result = await app.psqlHealthChecks?.checkConnection()
        XCTAssertEqual(resultMock, "active")
    }
}
