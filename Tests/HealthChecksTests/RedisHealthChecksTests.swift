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

@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Redis health checks tests")
struct RedisHealthChecksTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Connection")
    func connection() async throws {
        try await withApp { app in
            app.redisId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
            app.redisHealthChecks = RedisHealthChecksMock()
            let mockResult = await app.redisHealthChecks?.connection()
            #expect(mockResult == RedisHealthChecksMock.healthCheckItem)

            app.redisRequest = RedisRequestMock()
            app.redisHealthChecks = RedisHealthChecks(app: app)
            let result = await app.redisHealthChecks?.connection()
            #expect(result?.componentType == .datastore)
            #expect(result?.observedValue != 1.0)
            #expect(result?.status == .pass)
            #expect(result?.affectedEndpoints == nil)
            #expect(result?.output == nil)
            #expect(result?.links == nil)
            #expect(result?.node == nil)
        }
    }

    @Test("Response time")
    func responseTime() async throws {
        try await withApp { app in
            let redisId = UUID().uuidString
            app.redisId = redisId
            app.redisHealthChecks = RedisHealthChecksMock()
            let mockResult = await app.redisHealthChecks?.responseTime()
            #expect(mockResult == RedisHealthChecksMock.healthCheckItem)
            #expect(app.redisId == redisId)

            app.redisRequest = RedisRequestMock()
            app.redisHealthChecks = RedisHealthChecks(app: app)
            let result = await app.redisHealthChecks?.responseTime()
            #expect(result?.componentType == .datastore)
            #expect(result?.observedValue != 1.0)
            #expect(result?.observedUnit == "ms")
            #expect(result?.status == .pass)
            #expect(result?.affectedEndpoints == nil)
            #expect(result?.output == nil)
            #expect(result?.links == nil)
            #expect(result?.node == nil)
        }
    }

    @Test("Health check")
    func healthCheck() async throws {
        try await withApp { app in
            app.redisHealthChecks = RedisHealthChecksMock()
            let mockResult = await app.redisHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
            let mockRedisConnections = mockResult?["\(ComponentName.redis):\(MeasurementType.connections)"]
            #expect(mockRedisConnections == RedisHealthChecksMock.healthCheckItem)
            let mockRedisResponseTimes = mockResult?["\(ComponentName.redis):\(MeasurementType.responseTime)"]
            #expect(mockRedisResponseTimes == RedisHealthChecksMock.healthCheckItem)

            app.redisRequest = RedisRequestMock()
            app.redisHealthChecks = RedisHealthChecks(app: app)
            let result = await app.redisHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
            let redisConnections = result?["\(ComponentName.redis):\(MeasurementType.connections)"]
            #expect(redisConnections?.componentType == .datastore)
            #expect(redisConnections?.observedValue != 1.0)
            #expect(redisConnections?.status == .pass)
            #expect(redisConnections?.affectedEndpoints == nil)
            #expect(redisConnections?.output == nil)
            #expect(redisConnections?.links == nil)
            #expect(redisConnections?.node == nil)
            let redisResponseTimes = mockResult?["\(ComponentName.redis):\(MeasurementType.responseTime)"]
            #expect(redisResponseTimes == PostgresHealthChecksMock.healthCheckItem)
            #expect(redisResponseTimes == PostgresHealthChecksMock.healthCheckItem)
            #expect(redisResponseTimes?.componentType == .datastore)
            #expect(redisResponseTimes?.observedValue == 1.0)
            #expect(redisResponseTimes?.observedUnit == "s")
            #expect(redisResponseTimes?.status == .pass)
            #expect(redisResponseTimes?.affectedEndpoints == nil)
            #expect(redisResponseTimes?.output == "Ok")
            #expect(redisResponseTimes?.links == nil)
            #expect(redisResponseTimes?.node == nil)
        }
    }

    @Test("Ping")
    func ping() async throws {
        try await withApp { app in
            app.redisHealthChecks = RedisHealthChecksMock()
            let mockResult = await app.redisHealthChecks?.ping()
            #expect(mockResult == "PONG")

            app.redisRequest = RedisRequestMock()
            app.redisHealthChecks = RedisHealthChecks(app: app)
            let result = await app.redisHealthChecks?.ping()
            #expect(result == "PONG")
        }
    }
}
