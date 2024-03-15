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
//  MongoDBRequestTests.swift
//
//
//  Created by Mykola Buhaiov on 15.03.2024.
//

import XCTVapor
@testable import HealthChecks

final class MongoDBRequestTests: XCTestCase {
    func testConnection() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        let mongoId = "adca7c3d-55f4-4ab3-a842-18b35f50cb0f"
        app.mongoId = mongoId
        app.mongoDBHealthChecks = MongoDBHealthChecksMock()
        let mockResult = await app.mongoDBHealthChecks?.connection()
        XCTAssertEqual(mockResult, MongoDBHealthChecksMock.healthCheckItem)
        XCTAssertEqual(app.mongoId, mongoId)

        app.mongoDBRequest = MongoDBRequestMock()
        app.mongoDBHealthChecks = MongoDBHealthChecks(app: app, url: "url")
        let result = await app.mongoDBHealthChecks?.connection()
        XCTAssertEqual(result?.componentType, .datastore)
        XCTAssertNotEqual(result?.observedValue, 1.0)
        XCTAssertEqual(result?.observedUnit, "s")
        XCTAssertEqual(result?.status, .pass)
        XCTAssertNil(result?.affectedEndpoints)
        XCTAssertNil(result?.output)
        XCTAssertNil(result?.links)
        XCTAssertNil(result?.node)
    }

    func testResponseTime() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.mongoDBHealthChecks = MongoDBHealthChecksMock()
        let resultMock = await app.mongoDBHealthChecks?.responseTime()
        XCTAssertEqual(resultMock, MongoDBHealthChecksMock.healthCheckItem)

        app.mongoDBRequest = MongoDBRequestMock()
        app.mongoDBHealthChecks = MongoDBHealthChecks(app: app, url: "url")
        let result = await app.mongoDBHealthChecks?.responseTime()
        XCTAssertEqual(result?.componentType, .datastore)
        XCTAssertNotEqual(result?.observedValue, 1.0)
        XCTAssertEqual(result?.observedUnit, "s")
        XCTAssertEqual(result?.status, .pass)
        XCTAssertNil(result?.affectedEndpoints)
        XCTAssertNil(result?.output)
        XCTAssertNil(result?.links)
        XCTAssertNil(result?.node)
    }

    func testHealthCheck() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.mongoId = UUID().uuidString
        app.mongoDBHealthChecks = MongoDBHealthChecksMock()
        let mockResult = await app.mongoDBHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
        let mockMongoConnections = mockResult?["\(ComponentName.mongo):\(MeasurementType.connections)"]
        XCTAssertEqual(mockMongoConnections, MongoDBHealthChecksMock.healthCheckItem)
        let mockMongoResponseTimes = mockResult?["\(ComponentName.mongo):\(MeasurementType.responseTime)"]
        XCTAssertEqual(mockMongoResponseTimes, MongoDBHealthChecksMock.healthCheckItem)

        app.mongoDBRequest = MongoDBRequestMock()
        app.mongoDBHealthChecks = MongoDBHealthChecks(app: app, url: "url")
        let result = await app.mongoDBHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
        let mongoConnections = result?["\(ComponentName.mongo):\(MeasurementType.connections)"]
        XCTAssertEqual(mongoConnections?.componentType, .datastore)
        XCTAssertNotEqual(mongoConnections?.observedValue, 1.0)
        XCTAssertEqual(mongoConnections?.observedUnit, "s")
        XCTAssertEqual(mongoConnections?.status, .pass)
        XCTAssertNil(mongoConnections?.affectedEndpoints)
        XCTAssertNil(mongoConnections?.output)
        XCTAssertNil(mongoConnections?.links)
        XCTAssertNil(mongoConnections?.node)
        let mongoResponseTimes = mockResult?["\(ComponentName.mongo):\(MeasurementType.responseTime)"]
        XCTAssertEqual(mongoResponseTimes, MongoDBHealthChecksMock.healthCheckItem)
        XCTAssertEqual(mongoResponseTimes, MongoDBHealthChecksMock.healthCheckItem)
        XCTAssertEqual(mongoResponseTimes?.componentType, .datastore)
        XCTAssertEqual(mongoResponseTimes?.observedValue, 1.0)
        XCTAssertEqual(mongoResponseTimes?.observedUnit, "s")
        XCTAssertEqual(mongoResponseTimes?.status, .pass)
        XCTAssertNil(mongoResponseTimes?.affectedEndpoints)
        XCTAssertEqual(mongoResponseTimes?.output, "Ok")
        XCTAssertNil(mongoResponseTimes?.links)
        XCTAssertNil(mongoResponseTimes?.node)
    }

    func testGetConnection() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.mongoDBHealthChecks = MongoDBHealthChecksMock()
        let resultMock = await app.mongoDBHealthChecks?.getConnection()
        XCTAssertEqual(resultMock, "connecting")

        app.mongoDBRequest = MongoDBRequestMock()
        app.mongoDBHealthChecks = MongoDBHealthChecks(app: app, url: "url")
        let result = await app.mongoDBHealthChecks?.getConnection()
        XCTAssertEqual(result, "connecting")
    }
}
