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
//  RedisHealthChecksTests.swift
//  
//
//  Created by Mykola Buhaiov on 21.02.2024.
//

import Vapor
import XCTest
@testable import HealthChecks

final class RedisHealthChecksTests: XCTestCase {
    func testConnection() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.redisId = UUID().uuidString
        app.redisHealthChecks = RedisHealthChecksMock()
        let result = await app.redisHealthChecks?.connection()
        XCTAssertEqual(result, RedisHealthChecksMock.healthCheckItem)
    }

    func testResponseTime() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        let redisId = UUID().uuidString
        app.redisId = redisId
        app.redisHealthChecks = RedisHealthChecksMock()
        let result = await app.redisHealthChecks?.responseTime()
        XCTAssertEqual(result, RedisHealthChecksMock.healthCheckItem)
        XCTAssertEqual(app.redisId, redisId)
    }

    func testHealthCheck() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.redisHealthChecks = RedisHealthChecksMock()
        let result = await app.redisHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
        let redisConnections = result?["\(ComponentName.redis):\(MeasurementType.connections)"]
        XCTAssertEqual(redisConnections, RedisHealthChecksMock.healthCheckItem)
        let redisResponseTimes = result?["\(ComponentName.redis):\(MeasurementType.responseTime)"]
        XCTAssertEqual(redisResponseTimes, RedisHealthChecksMock.healthCheckItem)
    }

    func testPing() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.redisHealthChecks = RedisHealthChecksMock()
        let result = await app.redisHealthChecks?.ping()
        XCTAssertEqual(result, "PONG")
    }
}
