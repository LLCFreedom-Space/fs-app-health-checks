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
//  PostgresRequestTests.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 01.06.2026.
//

@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing
import FluentPostgresDriver

@Suite("Postgres Request tests")
struct PostgresRequestTests {
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
        guard let host = ProcessInfo.processInfo.environment["POSTGRES_HOST"] else {
            return ""
        }
        let db = ProcessInfo.processInfo.environment["POSTGRES_DB"] ?? "vapor_test"
        return "postgres://\(host):5432/\(db)"
    }

    @Test("Get database health metrics", .enabled(if: ProcessInfo.processInfo.environment["POSTGRES_HOST"] != nil))
    func getDatabaseHealthMetrics() async throws {
        try await withApp { app in
            let sqlPostgresConfiguration = try SQLPostgresConfiguration(url: PostgresRequestTests.connectionString())
            app.databases.use(DatabaseConfigurationFactory.postgres(configuration: sqlPostgresConfiguration), as: .psql)

            let request = PostgresRequest(app: app)
            let (activeConnections, version) = try await request.getDatabaseHealthMetrics()

            #expect(activeConnections > .zero)
            #expect(version.isEmpty == false)
        }
    }
}
