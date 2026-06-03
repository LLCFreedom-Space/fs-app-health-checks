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
//  PostgresHealthChecksTests.swift
//
//
//  Created by Mykola Buhaiov on 09.03.2023.
//
@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Postgres health checks tests")
struct PostgresHealthChecksTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        defer {
            Task {
                try? await app.asyncShutdown()
            }
        }
        try await test(app)
    }

    @Test("Connection")
    func connection() async throws {
        try await withApp { app in
            let postgresId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
            app.postgresId = postgresId
            app.postgresHealthChecks = PostgresHealthChecksMock()
            let mockResult = await app.postgresHealthChecks?.connection()
            #expect(mockResult == PostgresHealthChecksMock.healthCheckItem)
            #expect(app.postgresId == postgresId)

            app.postgresRequest = PostgresRequestMock()
            app.postgresHealthChecks = PostgresHealthChecks(app: app)
            let result = await app.postgresHealthChecks?.connection()
            #expect(result?.componentType == .datastore)
            #expect(result?.observedValue != nil)
            #expect(result?.observedUnit == "number")
            #expect(result?.status == .pass)
            #expect(result?.output == nil)
            #expect(result?.links == nil)
            #expect(result?.node == nil)
        }
    }
    
    @Test("Connection with error")
    func connectionWithError() async throws {
        try await withApp { app in
            app.postgresHealthChecks = PostgresHealthChecks(app: app)
            let result = await app.postgresHealthChecks?.connection()
            #expect(result?.componentType == .datastore)
            #expect(result?.observedValue == nil)
            #expect(result?.observedUnit == nil)
            #expect(result?.status == .fail)
            #expect(result?.output == HealthCheckError.serviceNotSetup(name: ComponentName.postgresql.rawValue).errorDescription)
            #expect(result?.links == nil)
            #expect(result?.node == nil)
        }
    }

    @Test("Response time")
    func responseTime() async throws {
        try await withApp { app in
            app.postgresHealthChecks = PostgresHealthChecksMock()
            let resultMock = await app.postgresHealthChecks?.responseTime()
            #expect(resultMock == PostgresHealthChecksMock.healthCheckItem)

            app.postgresRequest = PostgresRequestMock()
            app.postgresHealthChecks = PostgresHealthChecks(app: app)
            let result = await app.postgresHealthChecks?.responseTime()
            #expect(result?.componentType == .datastore)
            #expect(result?.observedValue != nil)
            #expect(result?.observedUnit == "s")
            #expect(result?.status == .pass)
            #expect(result?.output == nil)
            #expect(result?.links == nil)
            #expect(result?.node == nil)
        }
    }
    
    @Test("Response time with error")
    func responseTimeWithError() async throws {
        try await withApp { app in
            app.postgresHealthChecks = PostgresHealthChecks(app: app)
            let result = await app.postgresHealthChecks?.responseTime()
            #expect(result?.componentType == .datastore)
            #expect(result?.observedValue == nil)
            #expect(result?.observedUnit == nil)
            #expect(result?.status == .fail)
            #expect(result?.output == HealthCheckError.serviceNotSetup(name: ComponentName.postgresql.rawValue).errorDescription)
            #expect(result?.links == nil)
            #expect(result?.node == nil)
        }
    }

    @Test("Check")
    func check() async throws {
        try await withApp { app in
            app.postgresId = UUID().uuidString
            app.postgresHealthChecks = PostgresHealthChecksMock()
            let mock = await app.postgresHealthChecks?.check(
                for: [.responseTime, .connections, .utilization]
            )
            #expect(mock?["\(ComponentName.postgresql):\(MeasurementType.connections)"] == PostgresHealthChecksMock.healthCheckItem)
            #expect(mock?["\(ComponentName.postgresql):\(MeasurementType.responseTime)"] == PostgresHealthChecksMock.healthCheckItem)

            app.postgresRequest = PostgresRequestMock()
            app.postgresHealthChecks = PostgresHealthChecks(app: app)
            let result = await app.postgresHealthChecks?.check(
                for: [.responseTime, .connections, .utilization]
            )
            let connections = result?["\(ComponentName.postgresql):\(MeasurementType.connections)"]
            #expect(connections?.componentType == .datastore)
            #expect(connections?.observedUnit == "number")
            #expect(connections?.status == .pass)
            #expect(connections?.output == nil)
            #expect(connections?.links == nil)
            #expect(connections?.node == nil)

            let responseTime = result?["\(ComponentName.postgresql):\(MeasurementType.responseTime)"]
            #expect(responseTime?.componentType == .datastore)
            #expect(responseTime?.observedUnit == "s")
            #expect(responseTime?.status == .pass)
            #expect(responseTime?.output == nil)
            #expect(responseTime?.links == nil)
            #expect(responseTime?.node == nil)

            #expect(result?["\(ComponentName.postgresql):\(MeasurementType.utilization)"] == nil)
        }
    }

    @Test("Get database health metrics")
    func getDatabaseHealthMetrics() async throws {
        try await withApp { app in
            app.postgresRequest = PostgresRequestMock()
            let checks = PostgresHealthChecks(app: app)
            let (activeConnections, version) = try await checks.getDatabaseHealthMetrics()
            #expect(activeConnections > .zero)
            #expect(!version.isEmpty)
            
            app.postgresHealthChecks = PostgresHealthChecksMock()
            let mockResult = try await app.postgresHealthChecks?.getDatabaseHealthMetrics()
            #expect(mockResult?.activeConnections == PostgresHealthChecksMock.activeConnections)
            #expect(mockResult?.version == PostgresHealthChecksMock.version)
        }
    }
    
    @Test("Get database health metrics with error")
    func getDatabaseHealthMetricsWithError() async throws {
        try await withApp { app in
            let checks = PostgresHealthChecks(app: app)
            await #expect(throws: HealthCheckError.serviceNotSetup(name: ComponentName.postgresql.rawValue).self) {
                try await checks.getDatabaseHealthMetrics()
            }
        }
    }
}
