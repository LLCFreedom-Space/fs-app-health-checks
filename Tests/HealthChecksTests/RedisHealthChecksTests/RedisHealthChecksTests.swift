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

@testable import HealthChecksMocks
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
            let redisId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
            app.redisId = redisId
            app.redisHealthChecks = RedisHealthChecksMock()
            let mockResult = await app.redisHealthChecks?.connection()
            #expect(mockResult == RedisHealthChecksMock.healthCheckItem)
            #expect(app.redisId == redisId)

            app.redisRequest = RedisRequestMock()
            app.redisHealthChecks = RedisHealthChecks(app: app)
            let result = await app.redisHealthChecks?.connection()
            #expect(result?.componentType == .datastore)
            #expect(result?.observedValue != nil)
            #expect(result?.observedUnit == "number")
            #expect(result?.status == .pass)
            #expect(result?.output == nil)
            #expect(result?.links == nil)
            #expect(result?.node == nil)
        }
    }

    @Test("Response time")
    func responseTime() async throws {
        try await withApp { app in
            app.redisHealthChecks = RedisHealthChecksMock()
            let resultMock = await app.redisHealthChecks?.responseTime()
            #expect(resultMock == RedisHealthChecksMock.healthCheckItem)

            app.redisRequest = RedisRequestMock()
            app.redisHealthChecks = RedisHealthChecks(app: app)
            let result = await app.redisHealthChecks?.responseTime()
            #expect(result?.componentType == .datastore)
            #expect(result?.observedValue != nil)
            #expect(result?.observedUnit == "s")
            #expect(result?.status == .pass)
            #expect(result?.output == nil)
            #expect(result?.links == nil)
            #expect(result?.node == nil)
        }
    }

    @Test("Check")
    func check() async throws {
        try await withApp { app in
            app.redisId = UUID().uuidString
            app.redisHealthChecks = RedisHealthChecksMock()
            let mock = await app.redisHealthChecks?.check(
                for: [.responseTime, .connections, .utilization]
            )
            #expect(mock?["\(ComponentName.redis):\(MeasurementType.connections)"] == RedisHealthChecksMock.healthCheckItem)
            #expect(mock?["\(ComponentName.redis):\(MeasurementType.responseTime)"] == RedisHealthChecksMock.healthCheckItem)

            app.redisRequest = RedisRequestMock()
            app.redisHealthChecks = RedisHealthChecks(app: app)
            let result = await app.redisHealthChecks?.check(
                for: [.responseTime, .connections, .utilization]
            )
            let connections = result?["\(ComponentName.redis):\(MeasurementType.connections)"]
            #expect(connections?.componentType == .datastore)
            #expect(connections?.observedUnit == "number")
            #expect(connections?.status == .pass)
            #expect(connections?.output == nil)
            #expect(connections?.links == nil)
            #expect(connections?.node == nil)

            let responseTime = result?["\(ComponentName.redis):\(MeasurementType.responseTime)"]
            #expect(responseTime?.componentType == .datastore)
            #expect(responseTime?.observedUnit == "s")
            #expect(responseTime?.status == .pass)
            #expect(responseTime?.output == nil)
            #expect(responseTime?.links == nil)
            #expect(responseTime?.node == nil)

            #expect(result?["\(ComponentName.redis):\(MeasurementType.utilization)"] == nil)
        }
    }

    @Test("Get database health metrics")
    func getDatabaseHealthMetrics() async throws {
        try await withApp { app in
            app.redisRequest = RedisRequestMock()
            let checks = RedisHealthChecks(app: app)
            let (activeConnections, version) = try await checks.getDatabaseHealthMetrics()
            #expect(activeConnections > .zero)
            #expect(!version.isEmpty)
        }
    }
}
