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
//  ComponentHealthChecksTest.swift
//
//
//  Created by Mykola Buhaiov on 06.02.2024.
//

import Vapor
import XCTest
@testable import AppHealthChecks

final class ComponentHealthChecksTest: XCTestCase {
    func testGetVersion() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.componentHealthChecks = ComponentHealthChecksMock()
        let result = await app.componentHealthChecks?.checkHealth(for: [.postgresql])
        let psqlConnections = result?["postgresql:\(MeasurementType.connections)"]
        XCTAssertEqual(psqlConnections?.first?.componentId, PostgresHealthChecksMock.healthCheckItem.componentId)
        XCTAssertEqual(psqlConnections?.first?.componentType, PostgresHealthChecksMock.healthCheckItem.componentType)
        XCTAssertEqual(psqlConnections?.first?.observedValue, PostgresHealthChecksMock.healthCheckItem.observedValue)
        XCTAssertEqual(psqlConnections?.first?.observedUnit, PostgresHealthChecksMock.healthCheckItem.observedUnit)
        XCTAssertEqual(psqlConnections?.first?.status, PostgresHealthChecksMock.healthCheckItem.status)
        XCTAssertEqual(psqlConnections?.first?.affectedEndpoints, PostgresHealthChecksMock.healthCheckItem.affectedEndpoints)
        XCTAssertEqual(psqlConnections?.first?.time, PostgresHealthChecksMock.healthCheckItem.time)
        XCTAssertEqual(psqlConnections?.first?.output, PostgresHealthChecksMock.healthCheckItem.output)
        XCTAssertEqual(psqlConnections?.first?.links, PostgresHealthChecksMock.healthCheckItem.links)
        XCTAssertEqual(psqlConnections?.first?.node, PostgresHealthChecksMock.healthCheckItem.node)
        let psqlResponseTimes = result?["postgresql:\(MeasurementType.responseTime)"]
        XCTAssertEqual(psqlResponseTimes?.first?.componentId, PostgresHealthChecksMock.healthCheckItem.componentId)
        XCTAssertEqual(psqlResponseTimes?.first?.componentType, PostgresHealthChecksMock.healthCheckItem.componentType)
        XCTAssertEqual(psqlResponseTimes?.first?.observedValue, PostgresHealthChecksMock.healthCheckItem.observedValue)
        XCTAssertEqual(psqlResponseTimes?.first?.observedUnit, PostgresHealthChecksMock.healthCheckItem.observedUnit)
        XCTAssertEqual(psqlResponseTimes?.first?.status, PostgresHealthChecksMock.healthCheckItem.status)
        XCTAssertEqual(psqlResponseTimes?.first?.affectedEndpoints, PostgresHealthChecksMock.healthCheckItem.affectedEndpoints)
        XCTAssertEqual(psqlResponseTimes?.first?.time, PostgresHealthChecksMock.healthCheckItem.time)
        XCTAssertEqual(psqlResponseTimes?.first?.output, PostgresHealthChecksMock.healthCheckItem.output)
        XCTAssertEqual(psqlResponseTimes?.first?.links, PostgresHealthChecksMock.healthCheckItem.links)
        XCTAssertEqual(psqlResponseTimes?.first?.node, PostgresHealthChecksMock.healthCheckItem.node)
    }
}
