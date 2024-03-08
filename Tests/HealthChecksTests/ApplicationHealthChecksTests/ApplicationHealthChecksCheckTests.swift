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
//  ApplicationHealthChecksCheckTests.swift
//
//
//  Created by Mykola Buhaiov on 10.02.2024.
//

import XCTVapor
@testable import HealthChecks

/// Integration tests for the check functionality in ApplicationHealthChecks.
final class ApplicationHealthChecksCheckTests: XCTestCase {
    /// Tests the interaction of multiple components during the check operation.
    func testCheck() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.launchTime = Date().timeIntervalSinceReferenceDate
        app.applicationHealthChecks = ApplicationHealthChecksMock()
        let result = await app.applicationHealthChecks?.check(for: [MeasurementType.uptime])
        let uptime = result?[MeasurementType.uptime.rawValue]
        XCTAssertEqual(uptime, ApplicationHealthChecksMock.healthCheckItem)
    }
    
    /// Tests if the check operation returns valid items.
    func testCheckReturnsValidItems() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let healthChecks = ApplicationHealthChecks(app: app)
        let checks = await healthChecks.check(for: [.uptime])
        XCTAssertEqual(checks.count, 1)
        XCTAssertNotNil(checks)
        XCTAssertTrue(checks.keys.contains("uptime"))
        guard let uptimeItem = checks["uptime"] else {
            return XCTFail("no have uptime")
        }
        XCTAssertEqual(uptimeItem.componentType, .system)
        XCTAssertEqual(uptimeItem.observedUnit, "s")
        XCTAssertEqual(uptimeItem.status, .pass)
        guard let observedValue = uptimeItem.observedValue else {
            return XCTFail("no have observed value")
        }
        let expectedUptime = Date().timeIntervalSinceReferenceDate - app.launchTime
        XCTAssertTrue(abs(observedValue - expectedUptime) < 1.0)
    }
    
    /// Tests how the check operation handles unsupported types.
    func testCheckHandlesUnsupportedTypes() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        
        let healthChecks = ApplicationHealthChecks(app: app)
        let checks = await healthChecks.check(for: [.connections])
        XCTAssertEqual(checks.count, 0)  // Expect empty result, as .memory is not supported
    }
}

