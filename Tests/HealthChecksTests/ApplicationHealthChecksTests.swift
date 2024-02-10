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

    func testGetHealth() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.uptime = Date().timeIntervalSinceReferenceDate
        app.applicationHealthChecks = ApplicationHealthChecksMock()
        let result = await app.applicationHealthChecks?.checkHealth(for: [MeasurementType.uptime])
        let uptime = result?[MeasurementType.uptime.rawValue]
        XCTAssertEqual(uptime, ApplicationHealthChecksMock.healthCheckItem)
    }
}
