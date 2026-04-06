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
//  ConsulHealthChecksCheckTests.swift
//
//
//  Created by Mykola Buhaiov on 07.02.2024.
//

@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Consul health checks check tests")
struct ConsulHealthChecksCheckTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Health check")
    func healthCheck() async throws {
        try await withApp { app in
            app.consulHealthChecks = ConsulHealthChecksMock()
            let consulConfig = ConsulConfig(
                id: UUID().uuidString,
                url: Constants.consulUrl
            )
            app.consulConfig = consulConfig
            let result = await app.consulHealthChecks?.check(for: [MeasurementType.responseTime, MeasurementType.connections])
            let responseTimes = result?["\(ComponentName.consul):\(MeasurementType.responseTime)"]
            #expect(responseTimes == ConsulHealthChecksMock.healthCheckItem)
            #expect(app.consulConfig?.id == consulConfig.id)
            #expect(app.consulConfig?.url == consulConfig.url)
            #expect(app.consulConfig?.username == consulConfig.username)
            #expect(app.consulConfig?.password == consulConfig.password)
        }
    }

    @Test("Check for both success")
    func checkForBothSuccess() async throws {
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
            let check = await healthChecks.check(for: [.responseTime, .connections])
            #expect(check.count == 2)
            guard let responseTimeCheck = check["\(ComponentName.consul):\(MeasurementType.responseTime)"] else {
                Issue.record("No have key for response time")
                return
            }
            #expect(responseTimeCheck.status == .pass)
            guard let observedValue = responseTimeCheck.observedValue else {
                Issue.record("No have observed value")
                return
            }
            #expect(observedValue > .zero)
            #expect(responseTimeCheck.output == nil)
            guard let connectionsCheck = check["\(ComponentName.consul):\(MeasurementType.connections)"] else {
                Issue.record("No have key for connections")
                return
            }
            #expect(connectionsCheck.status == .pass)
            #expect(connectionsCheck.observedValue == nil)
            #expect(connectionsCheck.output == nil)
        }
    }

    @Test("Check handles unsupported types")
    func checkHandlesUnsupportedTypes() async throws {
        try await withApp { app in
            let healthChecks = ConsulHealthChecks(app: app)
            let checks = await healthChecks.check(for: [.uptime])
            #expect(checks.count == .zero)  // Expect empty result, as .memory is not supported
        }
    }
}
