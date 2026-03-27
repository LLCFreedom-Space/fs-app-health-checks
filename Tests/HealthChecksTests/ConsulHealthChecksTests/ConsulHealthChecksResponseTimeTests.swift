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
//  ConsulHealthChecksResponseTimeTests.swift
//  
//
//  Created by Mykhailo Bondarenko on 08.03.2024.
//

@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Consul health checks response time tests")
struct ConsulHealthChecksResponseTimeTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Check response time success")
    func checkResponseTimeSuccess() async throws {
        try await withApp { app in
            app.consulConfig = ConsulConfig(
                id: String(UUID()),
                url: "consul-url"
            )
            let clientResponse = ClientResponse(status: .ok)
            app.clients.use { app in
                MockClient(eventLoop: app.eventLoopGroup.next(), clientResponse: clientResponse)
            }
            let healthChecks = ConsulHealthChecks(app: app)
            let response = await healthChecks.getStatus()

            let result = healthChecks.responseTime(from: response, Date().timeIntervalSince1970)
            #expect(result.status == .pass)
            guard let observedValue = result.observedValue else {
                Issue.record("No have observed value")
                return
            }
            #expect(observedValue > 0)
            #expect(result.output == nil)
        }
    }
    
    @Test("Check response time fail")
    func checkResponseTimeFail() async throws {
        try await withApp { app in
            let clientResponse = ClientResponse(status: .badRequest)
            let healthChecks = ConsulHealthChecks(app: app)

            let result = healthChecks.responseTime(from: clientResponse, Date().timeIntervalSince1970)
            #expect(result.status == .fail)
            guard let observedValue = result.observedValue else {
                Issue.record("No have observed value")
                return
            }
            #expect(observedValue == 0)
            #expect(result.output != nil)
        }
    }
}
