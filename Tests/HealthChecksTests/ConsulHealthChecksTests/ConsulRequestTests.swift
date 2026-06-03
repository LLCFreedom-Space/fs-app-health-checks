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
//  ConsulRequestTests.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 29.05.2026.
//

@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Consul request tests")
struct ConsulRequestTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        defer {
            Task {
                try? await app.asyncShutdown()
            }
        }
        try await test(app)
    }

    @Test("Check connection with errors")
    func checkConnectionWithErros() async throws {
        try await withApp { app in
            app.consulRequest = ConsulRequest(app: app)
            var error = await #expect(throws: HealthCheckError.self) { try await app.consulRequest?.checkConnection() }
            #expect(error == HealthCheckError.urlNotConfigured)
            
            app.consulConfig = ConsulConfig(url: Constants.consulUrl)
            let clientResponse = ClientResponse(status: .notFound)
            app.clients.use { app in
                MockClient(eventLoop: app.eventLoopGroup.next(), clientResponse: clientResponse)
            }
            error = await #expect(throws: HealthCheckError.self) { try await app.consulRequest?.checkConnection() }
            #expect(error == HealthCheckError.unexpectedStatusCode)
        }
    }
}
