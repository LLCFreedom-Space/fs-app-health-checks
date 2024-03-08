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
//  ConsulHealthChecksCheckTests.swift
//
//
//  Created by Mykola Buhaiov on 07.02.2024.
//

import XCTVapor
@testable import HealthChecks

/// Integration tests for overall check functionality in ConsulHealthChecks.
final class ConsulHealthChecksCheckTests: XCTestCase {
    /// Additional test related to health check functionality in ConsulHealthChecks.
    func testHealthCheck() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.consulHealthChecks = ConsulHealthChecksMock()
        let consulConfig = ConsulConfig(
            id: UUID().uuidString,
            url: Constants.consulUrl
        )
        app.consulConfig = consulConfig
        let result = await app.consulHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
        let responseTimes = result?["\(ComponentName.consul):\(MeasurementType.responseTime)"]
        XCTAssertEqual(responseTimes, ConsulHealthChecksMock.healthCheckItem)
        XCTAssertEqual(app.consulConfig?.id, consulConfig.id)
        XCTAssertEqual(app.consulConfig?.url, consulConfig.url)
        XCTAssertEqual(app.consulConfig?.username, consulConfig.username)
        XCTAssertEqual(app.consulConfig?.password, consulConfig.password)
    }
    
    /// Tests the overall check functionality for ConsulHealthChecks.
    func testCheckForBothSuccess() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.consulConfig = ConsulConfig(
            id: String(UUID()),
            url: "consul-url"
        )
        let clientResponse = ClientResponse(status: .ok)
        app.clients.use { app in
            MockClient(eventLoop: app.eventLoopGroup.next(), clientResponse: clientResponse)
        }
        let healthChecks = ConsulHealthChecks(app: app)
        let check = await healthChecks.check(for: [.responseTime, .connections])
        XCTAssertEqual(check.count, 2)
        
        // Response time check
        guard let responseTimeCheck = check["\(ComponentName.consul):\(MeasurementType.responseTime)"] else {
            return XCTFail("no have key for response time")
        }
        XCTAssertEqual(responseTimeCheck.status, .pass)
        guard let observedValue = responseTimeCheck.observedValue else {
            return XCTFail("no have observed value")
        }
        XCTAssertGreaterThan(observedValue, 0)
        XCTAssertNil(responseTimeCheck.output)
        
        // Connections check
        guard let connectionsCheck = check["\(ComponentName.consul):\(MeasurementType.connections)"] else {
            return XCTFail("no have key for connections")
        }
        XCTAssertEqual(connectionsCheck.status, .pass)
        XCTAssertNil(connectionsCheck.observedValue)
        XCTAssertNil(connectionsCheck.output)
    }
    
    /// Tests the handling of unsupported types in ConsulHealthChecks.
    func testCheckHandlesUnsupportedTypes() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let healthChecks = ConsulHealthChecks(app: app)
        let checks = await healthChecks.check(for: [.uptime])
        XCTAssertEqual(checks.count, 0)  // Expect empty result, as .memory is not supported
    }
}
