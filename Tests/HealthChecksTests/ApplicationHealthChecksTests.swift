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
//  ApplicationHealthChecksTests.swift
//
//
//  Created by Mykola Buhaiov on 10.02.2024.
//

import Vapor
import XCTest
@testable import HealthChecks

final class ApplicationHealthChecksTests: XCTestCase {
    func testUptime() {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.applicationHealthChecks = ApplicationHealthChecksMock()
        let response = app.applicationHealthChecks?.uptime()
        XCTAssertEqual(response, ApplicationHealthChecksMock.healthCheckItem)
    }
    
    func testUptimeReturnsValidItem() {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let healthChecks = ApplicationHealthChecks(app: app)
        let item = healthChecks.uptime()
        
        XCTAssertNotNil(item)
        XCTAssertEqual(item.componentType, .system)
        XCTAssertEqual(item.observedUnit, "s")
        XCTAssertEqual(item.status, .pass)
        
        // Assert time is within a reasonable range of actual uptime
        let expectedUptime = Date().timeIntervalSinceReferenceDate - app.launchTime
        guard let value = item.observedValue else {
            return XCTFail()
        }
        XCTAssertTrue(abs(value - expectedUptime) < 1.0)
    }
    
    func testCheck() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.launchTime = Date().timeIntervalSinceReferenceDate
        app.applicationHealthChecks = ApplicationHealthChecksMock()
        let result = await app.applicationHealthChecks?.check(for: [MeasurementType.uptime])
        let uptime = result?[MeasurementType.uptime.rawValue]
        XCTAssertEqual(uptime, ApplicationHealthChecksMock.healthCheckItem)
    }
    
    func testCheckReturnsValidItems() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let healthChecks = ApplicationHealthChecks(app: app)
        let checks = await healthChecks.check(for: [.uptime])
        
        XCTAssertNotNil(checks)
        XCTAssertTrue(checks.keys.contains("uptime"))
        guard let uptimeItem = checks["uptime"] else {
            return XCTFail()
        }
        XCTAssertEqual(uptimeItem.componentType, .system)
        XCTAssertEqual(uptimeItem.observedUnit, "s")
        XCTAssertEqual(uptimeItem.status, .pass)
        guard let observedValue = uptimeItem.observedValue else {
            return XCTFail()
        }
        let expectedUptime = Date().timeIntervalSinceReferenceDate - app.launchTime
        XCTAssertTrue(abs(observedValue - expectedUptime) < 1.0)
    }
    
    func testCheckHandlesUnsupportedTypes() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let healthChecks = ApplicationHealthChecks(app: app)
        let checks = await healthChecks.check(for: [.connections])
        let expectedResult = [
            "": HealthCheckItem(
                componentId: nil,
                componentType: nil,
                observedValue: nil,
                observedUnit: nil,
                status: nil,
                affectedEndpoints: nil,
                time: nil,
                output: nil,
                links: nil,
                node: nil
            )
        ]
        XCTAssertEqual(checks, expectedResult)  // Expect empty result, as .memory is not supported
    }
}
