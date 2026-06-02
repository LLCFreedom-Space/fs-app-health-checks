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
//  MongoHealthChecksTests.swift
//
//
//  Created by Mykola Buhaiov on 15.03.2024.
//

@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Mongo health checks tests")
struct MongoHealthChecksTests {
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
            let mongoId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
            app.mongoId = mongoId
            app.mongoHealthChecks = MongoHealthChecksMock()
            let mockResult = await app.mongoHealthChecks?.connection()
            #expect(mockResult == MongoHealthChecksMock.healthCheckItem)
            #expect(app.mongoId == mongoId)

            app.mongoRequest = MongoRequestMock()
            app.mongoHealthChecks = MongoHealthChecks(app: app)
            let result = await app.mongoHealthChecks?.connection()
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
            app.mongoHealthChecks = MongoHealthChecksMock()
            let resultMock = await app.mongoHealthChecks?.responseTime()
            #expect(resultMock == MongoHealthChecksMock.healthCheckItem)

            app.mongoRequest = MongoRequestMock()
            app.mongoHealthChecks = MongoHealthChecks(app: app)
            let result = await app.mongoHealthChecks?.responseTime()
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
            app.mongoId = UUID().uuidString
            app.mongoHealthChecks = MongoHealthChecksMock()
            let mock = await app.mongoHealthChecks?.check(
                for: [.responseTime, .connections, .utilization]
            )
            #expect(mock?["\(ComponentName.mongo):\(MeasurementType.connections)"] == MongoHealthChecksMock.healthCheckItem)
            #expect(mock?["\(ComponentName.mongo):\(MeasurementType.responseTime)"] == MongoHealthChecksMock.healthCheckItem)

            app.mongoRequest = MongoRequestMock()
            app.mongoHealthChecks = MongoHealthChecks(app: app)
            let result = await app.mongoHealthChecks?.check(
                for: [.responseTime, .connections, .utilization]
            )
            let connections = result?["\(ComponentName.mongo):\(MeasurementType.connections)"]
            #expect(connections?.componentType == .datastore)
            #expect(connections?.observedUnit == "number")
            #expect(connections?.status == .pass)
            #expect(connections?.output == nil)
            #expect(connections?.links == nil)
            #expect(connections?.node == nil)

            let responseTime = result?["\(ComponentName.mongo):\(MeasurementType.responseTime)"]
            #expect(responseTime?.componentType == .datastore)
            #expect(responseTime?.observedUnit == "s")
            #expect(responseTime?.status == .pass)
            #expect(responseTime?.output == nil)
            #expect(responseTime?.links == nil)
            #expect(responseTime?.node == nil)

            #expect(result?["\(ComponentName.mongo):\(MeasurementType.utilization)"] == nil)
        }
    }

    @Test("Check connection")
    func checkConnection() async throws {
        try await withApp { app in
            app.mongoRequest = MongoRequestMock()
            let checks = MongoHealthChecks(app: app)
            try await checks.checkConnection()
            
            app.mongoHealthChecks = MongoHealthChecksMock()
            await #expect(throws: Never.self) { try await app.mongoHealthChecks?.checkConnection() }
        }
    }

    @Test("Check connection - service not setup")
    func checkConnectionNotSetup() async throws {
        try await withApp { app in
            let checks = MongoHealthChecks(app: app)
            await #expect(throws: HealthCheckError.serviceNotSetup) {
                try await checks.checkConnection()
            }
        }
    }

    @Test("Get active connections")
    func getActiveConnections() async throws {
        try await withApp { app in
            app.mongoRequest = MongoRequestMock()
            let checks = MongoHealthChecks(app: app)
            let count = try await checks.getActiveConnections()
            #expect(count > .zero)
        }
    }

    @Test("Get active connections - service not setup")
    func getActiveConnectionsNotSetup() async throws {
        try await withApp { app in
            let checks = MongoHealthChecks(app: app)
            await #expect(throws: HealthCheckError.serviceNotSetup) { try await checks.getActiveConnections() }
            
            app.mongoHealthChecks = MongoHealthChecksMock()
            let mockResult = try await app.mongoHealthChecks?.getActiveConnections()
            #expect(mockResult == MongoHealthChecksMock.activeConnections)
        }
    }

    @Test("Get version")
    func getVersion() async throws {
        try await withApp { app in
            app.mongoRequest = MongoRequestMock()
            let checks = MongoHealthChecks(app: app)
            let version = try await checks.getVersion()
            #expect(!version.isEmpty)
            
            app.mongoHealthChecks = MongoHealthChecksMock()
            let mockResult = try await app.mongoHealthChecks?.getVersion()
            #expect(mockResult == MongoHealthChecksMock.version)
        }
    }

    @Test("Get version - service not setup")
    func getVersionNotSetup() async throws {
        try await withApp { app in
            let checks = MongoHealthChecks(app: app)
            await #expect(throws: HealthCheckError.serviceNotSetup) {
                try await checks.getVersion()
            }
        }
    }
}
