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

@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Mongo health checks tests")
struct MongoHealthChecksTests {
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
            let mongoId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
            app.mongoId = mongoId
            app.mongoHealthChecks = MongoHealthChecksMock()
            let mockResult = await app.mongoHealthChecks?.connection()
            #expect(mockResult == MongoHealthChecksMock.healthCheckItem)
            #expect(app.mongoId == mongoId)

            app.mongoRequest = MongoRequestMock()
            app.mongoHealthChecks = MongoHealthChecks(app: app, url: "url")
            let result = await app.mongoHealthChecks?.connection()
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
            app.mongoHealthChecks = MongoHealthChecksMock()
            let resultMock = await app.mongoHealthChecks?.responseTime()
            #expect(resultMock == MongoHealthChecksMock.healthCheckItem)

            app.mongoRequest = MongoRequestMock()
            app.mongoHealthChecks = MongoHealthChecks(app: app, url: "url")
            let result = await app.mongoHealthChecks?.responseTime()
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
            app.mongoId = UUID().uuidString
            app.mongoHealthChecks = MongoHealthChecksMock()
            let mock = await app.mongoHealthChecks?.check(
                for: [
                    MeasurementType.responseTime,
                    MeasurementType.connections,
                    MeasurementType.utilization
                ]
            )
            let mockMongoConnections = mock?["\(ComponentName.mongo):\(MeasurementType.connections)"]
            #expect(mockMongoConnections == MongoHealthChecksMock.healthCheckItem)
            let mockMongoResponseTimes = mock?["\(ComponentName.mongo):\(MeasurementType.responseTime)"]
            #expect(mockMongoResponseTimes == MongoHealthChecksMock.healthCheckItem)

            app.mongoRequest = MongoRequestMock()
            app.mongoHealthChecks = MongoHealthChecks(app: app, url: "url")
            let result = await app.mongoHealthChecks?.check(
                for: [
                    MeasurementType.responseTime,
                    MeasurementType.connections,
                    MeasurementType.utilization
                ]
            )
            let mongoConnections = result?["\(ComponentName.mongo):\(MeasurementType.connections)"]
            #expect(mongoConnections?.componentType == .datastore)
            #expect(mongoConnections?.observedValue != 1.0)
            #expect(mongoConnections?.status == .pass)
            #expect(mongoConnections?.affectedEndpoints == nil)
            #expect(mongoConnections?.output == nil)
            #expect(mongoConnections?.links == nil)
            #expect(mongoConnections?.node == nil)
            let mongoResponseTimes = mock?["\(ComponentName.mongo):\(MeasurementType.responseTime)"]
            #expect(mongoResponseTimes == MongoHealthChecksMock.healthCheckItem)
            #expect(mongoResponseTimes == MongoHealthChecksMock.healthCheckItem)
            #expect(mongoResponseTimes?.componentType == .datastore)
            #expect(mongoResponseTimes?.observedValue == 1.0)
            #expect(mongoResponseTimes?.observedUnit == "s")
            #expect(mongoResponseTimes?.status == .pass)
            #expect(mongoResponseTimes?.affectedEndpoints == nil)
            #expect(mongoResponseTimes?.output == "Ok")
            #expect(mongoResponseTimes?.links == nil)
            #expect(mongoResponseTimes?.node == nil)
        }
    }

    @Test("Get connection")
    func getConnection() async throws {
        try await withApp { app in
            app.mongoHealthChecks = MongoHealthChecksMock()
            let resultMock = await app.mongoHealthChecks?.getConnection()
            #expect(resultMock == "connecting")

            app.mongoRequest = MongoRequestMock()
            app.mongoHealthChecks = MongoHealthChecks(app: app, url: "url")
            let result = await app.mongoHealthChecks?.getConnection()
            #expect(result == "connecting")
        }
    }
}
