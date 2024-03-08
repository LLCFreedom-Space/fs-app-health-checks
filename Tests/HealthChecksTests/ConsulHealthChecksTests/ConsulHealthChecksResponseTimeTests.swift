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
//  ConsulHealthChecksResponseTimeTests.swift
//  
//
//  Created by Mykhailo Bondarenko on 08.03.2024.
//

import XCTVapor
@testable import HealthChecks

/// Unit tests for response time functionality in ConsulHealthChecks.
final class ConsulHealthChecksResponseTimeTests: XCTestCase {
    /// Tests the creation of HealthCheckItem based on successful response time measurement.
    func testCheckResponseTimeSuccess() async {
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
        let response = await healthChecks.getStatus()
        
        let result = healthChecks.responseTime(from: response, Date().timeIntervalSinceReferenceDate)
        XCTAssertEqual(result.status, .pass)
        guard let observedValue = result.observedValue else {
            return XCTFail("no have observed value")
        }
        XCTAssertGreaterThan(observedValue, 0)
        XCTAssertNil(result.output)
    }
    
    /// Tests the creation of HealthCheckItem based on unsuccessful response time measurement.
    func testCheckResponseTimeFail() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        let clientResponse = ClientResponse(status: .badRequest)
        let healthChecks = ConsulHealthChecks(app: app)
        
        let result = healthChecks.responseTime(from: clientResponse, Date().timeIntervalSinceReferenceDate)
        XCTAssertEqual(result.status, .fail)
        guard let observedValue = result.observedValue else {
            return XCTFail("no have observed value")
        }
        XCTAssertEqual(observedValue, 0)
        XCTAssertNotNil(result.output)
    }
}
