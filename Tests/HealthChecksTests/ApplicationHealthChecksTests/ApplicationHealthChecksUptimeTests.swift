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
//  ApplicationHealthChecksUptimeTests.swift
//  
//
//  Created by Mykhailo Bondarenko on 07.03.2024.
//

import XCTVapor
@testable import HealthChecks

/// Unit tests for the uptime functionality in ApplicationHealthChecks.
final class ApplicationHealthChecksUptimeTests: XCTestCase {
    /// Tests the correctness of the uptime method.
    func testUptime() {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.applicationHealthChecks = ApplicationHealthChecksMock()
        let response = app.applicationHealthChecks?.uptime()
        XCTAssertEqual(response, ApplicationHealthChecksMock.healthCheckItem)
    }
    
    /// Tests if the uptime method returns a valid item.
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
        let expectedUptime = Date().timeIntervalSince1970 - app.launchTime
        guard let value = item.observedValue else {
            return XCTFail("no have observed value")
        }
        XCTAssertTrue(abs(value - expectedUptime) < 1.0)
    }
}
