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

import Vapor
import XCTest
@testable import AppHealthChecks

final class PostgresHealthChecksTests: XCTestCase {
    func testGetVersion() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.psqlHealthChecks = PostgresHealthChecksMock()
        let result = await app.psqlHealthChecks?.getVersion()
        XCTAssertEqual(result?.componentId, PostgresHealthChecksMock.healthCheckItem.componentId)
        XCTAssertEqual(result?.componentType, PostgresHealthChecksMock.healthCheckItem.componentType)
        XCTAssertEqual(result?.observedValue, PostgresHealthChecksMock.healthCheckItem.observedValue)
        XCTAssertEqual(result?.observedUnit, PostgresHealthChecksMock.healthCheckItem.observedUnit)
        XCTAssertEqual(result?.status, PostgresHealthChecksMock.healthCheckItem.status)
        XCTAssertEqual(result?.affectedEndpoints, PostgresHealthChecksMock.healthCheckItem.affectedEndpoints)
        XCTAssertEqual(result?.time, PostgresHealthChecksMock.healthCheckItem.time)
        XCTAssertEqual(result?.output, PostgresHealthChecksMock.healthCheckItem.output)
        XCTAssertEqual(result?.links, PostgresHealthChecksMock.healthCheckItem.links)
        XCTAssertEqual(result?.node, PostgresHealthChecksMock.healthCheckItem.node)
    }

    func testGetResponseTime() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        let dateFormat = app.dateTimeISOFormat
        app.psqlHealthChecks = PostgresHealthChecksMock()
        let result = await app.psqlHealthChecks?.getResponseTime()
        XCTAssertEqual(result?.componentId, PostgresHealthChecksMock.healthCheckItem.componentId)
        XCTAssertEqual(result?.componentType, PostgresHealthChecksMock.healthCheckItem.componentType)
        XCTAssertEqual(result?.observedValue, PostgresHealthChecksMock.healthCheckItem.observedValue)
        XCTAssertEqual(result?.observedUnit, PostgresHealthChecksMock.healthCheckItem.observedUnit)
        XCTAssertEqual(result?.status, PostgresHealthChecksMock.healthCheckItem.status)
        XCTAssertEqual(result?.affectedEndpoints, PostgresHealthChecksMock.healthCheckItem.affectedEndpoints)
        XCTAssertEqual(result?.time, PostgresHealthChecksMock.healthCheckItem.time)
        XCTAssertEqual(result?.output, PostgresHealthChecksMock.healthCheckItem.output)
        XCTAssertEqual(result?.links, PostgresHealthChecksMock.healthCheckItem.links)
        XCTAssertEqual(result?.node, PostgresHealthChecksMock.healthCheckItem.node)
    }
}
