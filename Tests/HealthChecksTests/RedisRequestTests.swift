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
//  RedisRequestTests.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 23.05.2026.
//

@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Redis Request tests")
struct RedisRequestTests {
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
            app.redisRequest = RedisRequestMock()
            let result = try await app.redisRequest?.getPong()
            #expect(result == "PONG")
            
//            app.redisRequest = RedisRequest(app: app)
//            let error = await #expect(throws: HealthCheckError.self) { try await app.redisRequest?.getPong() }
//            #expect(error?.kind == .cannotConnect)
//            #expect(error?.reason == .databaseNotFound)
        }
    }
    
    @Test("Get total connection")
    func getTotalConnection() async throws {
        try await withApp { app in
            app.redisRequest = RedisRequestMock()
            let result = try await app.redisRequest?.getTotalConnection()
            #expect(result == 400)
        }
    }
    
    @Test("Get version")
    func getVersion() async throws {
        try await withApp { app in
            app.redisRequest = RedisRequestMock()
            let result = try await app.redisRequest?.getVersion()
            #expect(result == "34")
        }
    }
}
