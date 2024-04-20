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

import XCTVapor
@testable import HealthChecks

final class RedisHealthChecksTests: XCTestCase {
    func testConnection() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.redisId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
        app.redisHealthChecks = RedisHealthChecksMock()
        let mockResult = await app.redisHealthChecks?.connection()
        XCTAssertEqual(mockResult, RedisHealthChecksMock.healthCheckItem)

        app.redisRequest = RedisRequestMock()
        app.redisHealthChecks = RedisHealthChecks(app: app)
        let result = await app.redisHealthChecks?.connection()
        XCTAssertEqual(result?.componentType, .datastore)
        XCTAssertNotEqual(result?.observedValue, 1.0)
        XCTAssertEqual(result?.status, .pass)
        XCTAssertNil(result?.affectedEndpoints)
        XCTAssertNil(result?.output)
        XCTAssertNil(result?.links)
        XCTAssertNil(result?.node)
    }
    
    func testResponseTime() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        let redisId = UUID().uuidString
        app.redisId = redisId
        app.redisHealthChecks = RedisHealthChecksMock()
        let mockResult = await app.redisHealthChecks?.responseTime()
        XCTAssertEqual(mockResult, RedisHealthChecksMock.healthCheckItem)
        XCTAssertEqual(app.redisId, redisId)

        app.redisRequest = RedisRequestMock()
        app.redisHealthChecks = RedisHealthChecks(app: app)
        let result = await app.redisHealthChecks?.responseTime()
        XCTAssertEqual(result?.componentType, .datastore)
        XCTAssertNotEqual(result?.observedValue, 1.0)
        XCTAssertEqual(result?.observedUnit, "ms")
        XCTAssertEqual(result?.status, .pass)
        XCTAssertNil(result?.affectedEndpoints)
        XCTAssertNil(result?.output)
        XCTAssertNil(result?.links)
        XCTAssertNil(result?.node)
    }
    
    func testHealthCheck() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.redisHealthChecks = RedisHealthChecksMock()
        let mockResult = await app.redisHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
        let mockRedisConnections = mockResult?["\(ComponentName.redis):\(MeasurementType.connections)"]
        XCTAssertEqual(mockRedisConnections, RedisHealthChecksMock.healthCheckItem)
        let mockRedisResponseTimes = mockResult?["\(ComponentName.redis):\(MeasurementType.responseTime)"]
        XCTAssertEqual(mockRedisResponseTimes, RedisHealthChecksMock.healthCheckItem)

        app.redisRequest = RedisRequestMock()
        app.redisHealthChecks = RedisHealthChecks(app: app)
        let result = await app.redisHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
        let redisConnections = result?["\(ComponentName.redis):\(MeasurementType.connections)"]
        XCTAssertEqual(redisConnections?.componentType, .datastore)
        XCTAssertNotEqual(redisConnections?.observedValue, 1.0)
        XCTAssertEqual(redisConnections?.status, .pass)
        XCTAssertNil(redisConnections?.affectedEndpoints)
        XCTAssertNil(redisConnections?.output)
        XCTAssertNil(redisConnections?.links)
        XCTAssertNil(redisConnections?.node)
        let redisResponseTimes = mockResult?["\(ComponentName.redis):\(MeasurementType.responseTime)"]
        XCTAssertEqual(redisResponseTimes, PostgresHealthChecksMock.healthCheckItem)
        XCTAssertEqual(redisResponseTimes, PostgresHealthChecksMock.healthCheckItem)
        XCTAssertEqual(redisResponseTimes?.componentType, .datastore)
        XCTAssertEqual(redisResponseTimes?.observedValue, 1.0)
        XCTAssertEqual(redisResponseTimes?.observedUnit, "s")
        XCTAssertEqual(redisResponseTimes?.status, .pass)
        XCTAssertNil(redisResponseTimes?.affectedEndpoints)
        XCTAssertEqual(redisResponseTimes?.output, "Ok")
        XCTAssertNil(redisResponseTimes?.links)
        XCTAssertNil(redisResponseTimes?.node)
    }
    
    func testPing() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.redisHealthChecks = RedisHealthChecksMock()
        let mockResult = await app.redisHealthChecks?.ping()
        XCTAssertEqual(mockResult, "PONG")

        app.redisRequest = RedisRequestMock()
        app.redisHealthChecks = RedisHealthChecks(app: app)
        let result = await app.redisHealthChecks?.ping()
        XCTAssertEqual(result, "PONG")
    }
}
