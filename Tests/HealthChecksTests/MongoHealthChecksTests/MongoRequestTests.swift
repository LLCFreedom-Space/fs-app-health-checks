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
//  MongoRequestTests.swift
//
//
//  Created by Mykola Buhaiov on 15.03.2024.
//

@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Mongo Request tests")
struct MongoRequestTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        defer {
            Task {
                try? await app.asyncShutdown()
            }
        }
        try await test(app)
    }

    private static func connectionString() -> String {
        guard let host = ProcessInfo.processInfo.environment["MONGO_HOST"] else {
            return ""
        }
        let db = ProcessInfo.processInfo.environment["MONGO_DB"] ?? "vapor_test"
        return "mongodb://\(host):27017/\(db)"
    }

    @Test("Check connection", .enabled(if: ProcessInfo.processInfo.environment["MONGO_HOST"] != nil))
    func checkConnection() async throws {
        try await withApp { app in
            try await app.initializeMongo(connectionString: Self.connectionString())
            let request = MongoRequest(app: app)
            try await request.checkConnection()
        }
    }
    
    @Test("Check connection with error", .enabled(if: ProcessInfo.processInfo.environment["MONGO_HOST"] != nil))
    func checkConnectionWithError() async throws {
        try await withApp { app in
            let request = MongoRequest(app: app)
            await #expect(throws: HealthCheckError.databaseNotSetup(name: ComponentName.mongo.rawValue).self) {
                try await request.checkConnection()
            }
        }
    }

    @Test("Get active connections", .enabled(if: ProcessInfo.processInfo.environment["MONGO_HOST"] != nil))
    func getActiveConnections() async throws {
        try await withApp { app in
            try await app.initializeMongo(connectionString: Self.connectionString())
            let request = MongoRequest(app: app)
            let count = try await request.getActiveConnections()
            #expect(count > .zero)
        }
    }
    
    @Test("Get active connections with error", .enabled(if: ProcessInfo.processInfo.environment["MONGO_HOST"] != nil))
    func getActiveConnectionsWithError() async throws {
        try await withApp { app in
            let request = MongoRequest(app: app)
            await #expect(throws: HealthCheckError.databaseNotSetup(name: ComponentName.mongo.rawValue).self) {
                try await request.getActiveConnections()
            }
        }
    }

    @Test("Get version", .enabled(if: ProcessInfo.processInfo.environment["MONGO_HOST"] != nil))
    func getVersion() async throws {
        try await withApp { app in
            try await app.initializeMongo(connectionString: Self.connectionString())
            let request = MongoRequest(app: app)
            let version = try await request.getVersion()
            #expect(!version.isEmpty)
        }
    }
    
    @Test("Get version with error", .enabled(if: ProcessInfo.processInfo.environment["MONGO_HOST"] != nil))
    func getVersionWithError() async throws {
        try await withApp { app in
            let request = MongoRequest(app: app)
            await #expect(throws: HealthCheckError.databaseNotSetup(name: ComponentName.mongo.rawValue).self) {
                try await request.getVersion()
            }
        }
    }
}
