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
        do {
            try await test(app)
        } catch {
            throw error
        }
        try await app.asyncShutdown()
    }

    private static func connectionString() -> String {
        guard let host = ProcessInfo.processInfo.environment["MONGO_HOST"] else {
            return ""
        }
        let user = ProcessInfo.processInfo.environment["MONGO_USER"] ?? "vapor"
        let password = ProcessInfo.processInfo.environment["MONGO_PASSWORD"] ?? "vapor"
        return "mongodb://\(user):\(password)@\(host):27017"
    }

    // MARK: - Unit (no connection needed)

    @Test("Check connection - database not setup")
    func checkConnectionNotSetup() async throws {
        try await withApp { app in
            let request = MongoRequest(app: app)
            await #expect(throws: HealthCheckError.databaseNotSetup) {
                try await request.checkConnection()
            }
        }
    }

    @Test("Get active connections - database not setup")
    func getActiveConnectionsNotSetup() async throws {
        try await withApp { app in
            let request = MongoRequest(app: app)
            await #expect(throws: HealthCheckError.databaseNotSetup) {
                try await request.getActiveConnections()
            }
        }
    }

    @Test("Get version - database not setup")
    func getVersionNotSetup() async throws {
        try await withApp { app in
            let request = MongoRequest(app: app)
            await #expect(throws: HealthCheckError.databaseNotSetup) {
                try await request.getVersion()
            }
        }
    }

    // MARK: - Integration (requires MONGO_HOST env)

    @Test("Check connection", .enabled(if: ProcessInfo.processInfo.environment["MONGO_HOST"] != nil))
    func checkConnection() async throws {
        try await withApp { app in
            try await app.initializeMongo(connectionString: Self.connectionString())
            let request = MongoRequest(app: app)
            try await request.checkConnection()
        }
    }

    @Test("Get active connections", .enabled(if: ProcessInfo.processInfo.environment["MONGO_HOST"] != nil))
    func getActiveConnections() async throws {
        try await withApp { app in
            try await app.initializeMongo(connectionString: Self.connectionString())
            let request = MongoRequest(app: app)
            let count = try await request.getActiveConnections()
            #expect(count >= 0)
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
}
