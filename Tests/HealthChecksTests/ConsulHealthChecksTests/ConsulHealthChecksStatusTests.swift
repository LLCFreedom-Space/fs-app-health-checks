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
//  ConsulHealthChecksStatusTests.swift
//
//
//  Created by Mykhailo Bondarenko on 08.03.2024.
//

import XCTVapor
@testable import HealthChecks

/// Unit tests for status-related functionality in ConsulHealthChecks.
final class ConsulHealthChecksStatusTests: XCTestCase {
    /// Tests the creation of HealthCheckItem based on successful status response.
    func testCheckStatusSuccess() async {
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
        let result = healthChecks.status(response)
        
        XCTAssertEqual(result.status, .pass)
        XCTAssertNil(result.observedValue)
        XCTAssertNil(result.output)
    }
    
    /// Tests the creation of HealthCheckItem based on unsuccessful status response.
    func testCheckStatusFail() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        let clientResponse = ClientResponse(status: .badRequest)
        let healthChecks = ConsulHealthChecks(app: app)
        let result = healthChecks.status(clientResponse)
        
        XCTAssertEqual(result.status, .fail)
        XCTAssertNil(result.observedValue)
        XCTAssertNotNil(result.output)
    }
    
    /// Tests the retrieval of status from ConsulHealthChecks.
    func testGetStatusSuccessWithAuth() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.consulConfig = ConsulConfig(
            id: String(UUID()),
            url: "https://example.com/status",
            username: "user",
            password: "password"
        )
        let clientResponse = ClientResponse(status: .ok)
        app.clients.use { app in
            MockClient(eventLoop: app.eventLoopGroup.next(), clientResponse: clientResponse)
        }
        let healthChecks = ConsulHealthChecks(app: app)
        let response = await healthChecks.getStatus()
        
        XCTAssertEqual(response.status, .ok)
    }
}
