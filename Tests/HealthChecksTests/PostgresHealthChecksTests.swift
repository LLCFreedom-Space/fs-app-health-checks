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

@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Postgres health checks tests")
struct PostgresHealthChecksTests {
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
            app.psqlId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
            app.psqlHealthChecks = PostgresHealthChecksMock()
            let mockResult = await app.psqlHealthChecks?.connection()
            #expect(mockResult == PostgresHealthChecksMock.healthCheckItem)

            app.psqlRequest = PsqlRequestMock()
            app.psqlHealthChecks = PostgresHealthChecks(app: app, postgresDatabase: "test")
            let result = await app.psqlHealthChecks?.connection()
            #expect(result?.componentType == .datastore)
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
            app.psqlHealthChecks = PostgresHealthChecksMock()
            let resultMock = await app.psqlHealthChecks?.responseTime()
            #expect(resultMock == PostgresHealthChecksMock.healthCheckItem)

            app.psqlRequest = PsqlRequestMock()
            app.psqlHealthChecks = PostgresHealthChecks(app: app, postgresDatabase: "test")
            let result = await app.psqlHealthChecks?.responseTime()
            #expect(result?.componentType == .datastore)
            #expect(result?.observedValue != 1)
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
            app.psqlId = UUID().uuidString
            app.psqlHealthChecks = PostgresHealthChecksMock()
            let mockResult = await app.psqlHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
            let mockPsqlConnections = mockResult?["\(ComponentName.postgresql):\(MeasurementType.connections)"]
            #expect(mockPsqlConnections == PostgresHealthChecksMock.healthCheckItem)
            let mockPsqlResponseTimes = mockResult?["\(ComponentName.postgresql):\(MeasurementType.responseTime)"]
            #expect(mockPsqlResponseTimes == PostgresHealthChecksMock.healthCheckItem)

            app.psqlRequest = PsqlRequestMock()
            app.psqlHealthChecks = PostgresHealthChecks(app: app, postgresDatabase: "test")
            let result = await app.psqlHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
            let psqlConnections = result?["\(ComponentName.postgresql):\(MeasurementType.connections)"]
            #expect(psqlConnections?.componentType == .datastore)
            #expect(psqlConnections?.status == .pass)
            #expect(psqlConnections?.affectedEndpoints == nil)
            #expect(psqlConnections?.output == nil)
            #expect(psqlConnections?.links == nil)
            #expect(psqlConnections?.node == nil)
            let psqlResponseTimes = mockResult?["\(ComponentName.postgresql):\(MeasurementType.responseTime)"]
            #expect(psqlResponseTimes == PostgresHealthChecksMock.healthCheckItem)
            #expect(psqlResponseTimes == PostgresHealthChecksMock.healthCheckItem)
            #expect(psqlResponseTimes?.componentType == .datastore)
            #expect(psqlResponseTimes?.observedValue == 1)
            #expect(psqlResponseTimes?.observedUnit == "s")
            #expect(psqlResponseTimes?.status == .pass)
            #expect(psqlResponseTimes?.affectedEndpoints == nil)
            #expect(psqlResponseTimes?.output == "Ok")
            #expect(psqlResponseTimes?.links == nil)
            #expect(psqlResponseTimes?.node == nil)
        }
    }

    @Test("Get version")
    func getVersion() async throws {
        try await withApp { app in
            app.psqlId = UUID().uuidString
            app.psqlHealthChecks = PostgresHealthChecksMock()
            let resultMock = await app.psqlHealthChecks?.getVersion()
            #expect(resultMock == PostgresHealthChecksMock.version)

            app.psqlRequest = PsqlRequestMock()
            app.psqlHealthChecks = PostgresHealthChecks(app: app, postgresDatabase: "test")
            let result = await app.psqlHealthChecks?.getVersion()
            #expect(result == Constants.psqlVersionDescription)
        }
    }

    @Test("Check connection")
    func checkConnection() async throws {
        try await withApp { app in
            app.psqlId = UUID().uuidString
            app.psqlHealthChecks = PostgresHealthChecksMock()
            let resultMock = await app.psqlHealthChecks?.checkConnection()
            #expect(resultMock == "active")

            app.psqlRequest = PsqlRequestMock()
            app.psqlHealthChecks = PostgresHealthChecks(app: app, postgresDatabase: "test")
            let result = await app.psqlHealthChecks?.checkConnection()
            #expect(result == "active")
        }
    }
}
