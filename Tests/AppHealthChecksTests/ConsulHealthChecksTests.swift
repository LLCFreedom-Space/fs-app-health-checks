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
@testable import AppHealthChecks

final class ConsulHealthChecksTests: XCTestCase {
    func testCheckHealth() async {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.consulHealthChecks = ConsulHealthChecksMock()
        let consulConfig = ConsulConfig(
            id: UUID().uuidString,
            url: Constants.consulUrl,
            username: "username",
            password: "password"
        )
        app.consulConfig = consulConfig
        let result = await app.consulHealthChecks?.checkHealth(for: [MeasurementType.responseTime, MeasurementType.connections])
        let responseTimes = result?["\(ComponentName.consul):\(MeasurementType.responseTime)"]
        XCTAssertEqual(responseTimes, ConsulHealthChecksMock.healthCheckItem)
        XCTAssertEqual(app.consulConfig?.id, consulConfig.id)
        XCTAssertEqual(app.consulConfig?.url, consulConfig.url)
        XCTAssertEqual(app.consulConfig?.username, consulConfig.username)
        XCTAssertEqual(app.consulConfig?.password, consulConfig.password)
    }
}
