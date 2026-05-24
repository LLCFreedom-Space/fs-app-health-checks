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
//  Created by Mykola Buhaiov on 23.05.2026.
//

@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Postgres Request tests")
struct PostgresRequestTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Get connection")
    func getConnection() async throws {
        try await withApp { app in
            app.psqlRequest = PsqlRequestMock()
            let result = try await app.psqlRequest?.checkConnection()
            #expect(result == "connected")
        }
    }
    
    @Test("Get total connection")
    func getTotalConnection() async throws {
        try await withApp { app in
            app.psqlRequest = PsqlRequestMock()
            let result = try await app.psqlRequest?.getTotalConnection()
            #expect(result == 99)
        }
    }
    
    @Test("Get version")
    func getVersion() async throws {
        try await withApp { app in
            app.psqlRequest = PsqlRequestMock()
            let result = try await app.psqlRequest?.getVersion()
            #expect(result == "34.0")
        }
    }
}
