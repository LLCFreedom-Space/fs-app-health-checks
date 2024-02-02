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
//  PsqlHealthChecksTests.swift
//
//
//  Created by Mykola Buhaiov on 09.03.2023.
//

import Vapor
import XCTest
@testable import AppHealthChecks

final class PsqlHealthChecksTests: XCTestCase {
    let defaultPort = 5432
    func testGetHealthUsingParameters() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.psqlId = PsqlHealthChecksMock.psqlId
        app.psqlHealthChecks = PsqlHealthChecksMock()
        let result = await app.psqlHealthChecks?.checkConnection(
            hostname: "localhost",
            port: defaultPort,
            username: "test",
            password: "password",
            database: "test",
            tls: nil
        )
        XCTAssertEqual(result?.componentId, PsqlHealthChecksMock.healthCheckItem.componentId)
        XCTAssertEqual(result?.componentType, PsqlHealthChecksMock.healthCheckItem.componentType)
        XCTAssertEqual(result?.observedValue, PsqlHealthChecksMock.healthCheckItem.observedValue)
        XCTAssertEqual(result?.observedUnit, PsqlHealthChecksMock.healthCheckItem.observedUnit)
        XCTAssertEqual(result?.status, PsqlHealthChecksMock.healthCheckItem.status)
        XCTAssertEqual(result?.affectedEndpoints, PsqlHealthChecksMock.healthCheckItem.affectedEndpoints)
        XCTAssertEqual(result?.time, PsqlHealthChecksMock.healthCheckItem.time)
        XCTAssertEqual(result?.output, PsqlHealthChecksMock.healthCheckItem.output)
        XCTAssertEqual(result?.links, PsqlHealthChecksMock.healthCheckItem.links)
        XCTAssertEqual(result?.node, PsqlHealthChecksMock.healthCheckItem.node)
    }

    func testGetHealthByUrl() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.psqlId = PsqlHealthChecksMock.psqlId
        app.psqlHealthChecks = PsqlHealthChecksMock()
        let url = "postgres://username:password@hostname:port/database?tlsmode=mode"
        let result = try await app.psqlHealthChecks?.checkConnection(by: url)
        XCTAssertEqual(result?.componentId, app.psqlId)
        XCTAssertEqual(result?.componentType, PsqlHealthChecksMock.healthCheckItem.componentType)
        XCTAssertEqual(result?.observedValue, PsqlHealthChecksMock.healthCheckItem.observedValue)
        XCTAssertEqual(result?.observedUnit, PsqlHealthChecksMock.healthCheckItem.observedUnit)
        XCTAssertEqual(result?.status, PsqlHealthChecksMock.healthCheckItem.status)
        XCTAssertEqual(result?.affectedEndpoints, PsqlHealthChecksMock.healthCheckItem.affectedEndpoints)
        XCTAssertEqual(result?.time, PsqlHealthChecksMock.healthCheckItem.time)
        XCTAssertEqual(result?.output, PsqlHealthChecksMock.healthCheckItem.output)
        XCTAssertEqual(result?.links, PsqlHealthChecksMock.healthCheckItem.links)
        XCTAssertEqual(result?.node, PsqlHealthChecksMock.healthCheckItem.node)
    }

    func testCheckConnection() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        let dateFormat = app.dateTimeISOFormat
        app.psqlHealthChecks = PsqlHealthChecksMock()
        let result = await app.psqlHealthChecks?.checkConnection()
        XCTAssertEqual(result, "Ok")
    }
}
