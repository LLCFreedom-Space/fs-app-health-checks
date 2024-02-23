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
@testable import HealthChecks

final class ConsulHealthChecksTests: XCTestCase {
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
        let responseTimeCheck = check["\(ComponentName.consul):\(MeasurementType.responseTime)"]!
        XCTAssertEqual(responseTimeCheck.status, .pass)
        guard let observedValue = responseTimeCheck.observedValue else {
            return XCTFail("no have observed value")
        }
        XCTAssertGreaterThan(observedValue, 0)
        XCTAssertNil(responseTimeCheck.output)
        
        // Connections check
        let connectionsCheck = check["\(ComponentName.consul):\(MeasurementType.connections)"]!
        XCTAssertEqual(connectionsCheck.status, .pass)
        XCTAssertNil(connectionsCheck.observedValue)
        XCTAssertNil(connectionsCheck.output)
    }
    
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
    
    func testCheckStatusFail() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        let clientResponse = ClientResponse(status: .badRequest)
        app.clients.use { app in
            MockClient(eventLoop: app.eventLoopGroup.next(), clientResponse: clientResponse)
        }
        let healthChecks = ConsulHealthChecks(app: app)
        let response = await healthChecks.getStatus()
        let result = healthChecks.status(response)
        
        XCTAssertEqual(result.status, .fail)
        XCTAssertNil(result.observedValue)
        XCTAssertNotNil(result.output)
    }
    
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
    
    func testCheckResponseTimeFail() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.consulConfig = ConsulConfig(
            id: String(UUID()),
            url: "consul-url"
        )
        let clientResponse = ClientResponse(status: .badRequest)
        app.clients.use { app in
            MockClient(eventLoop: app.eventLoopGroup.next(), clientResponse: clientResponse)
        }
        let healthChecks = ConsulHealthChecks(app: app)
        let response = await healthChecks.getStatus()
        
        let result = healthChecks.responseTime(from: response, Date().timeIntervalSinceReferenceDate)
        XCTAssertEqual(result.status, .fail)
        guard let observedValue = result.observedValue else {
            return XCTFail("no have observed value")
        }
        XCTAssertEqual(observedValue, 0)
        XCTAssertNotNil(result.output)
    }
    
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
    
    func testCheckHandlesUnsupportedTypes() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let healthChecks = ConsulHealthChecks(app: app)
        let checks = await healthChecks.check(for: [.uptime])
        XCTAssertEqual(checks.count, 0)  // Expect empty result, as .memory is not supported
    }
}
