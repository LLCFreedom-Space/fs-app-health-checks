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

@testable import HealthChecksMocks
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
            let result = await app.consulHealthChecks?.check(
                for: [MeasurementType.responseTime, MeasurementType.connections]
            )
            let connections = result?["\(ComponentName.consul):\(MeasurementType.connections)"]
            #expect(connections == ConsulHealthChecksMock.healthCheckItem)
            #expect(app.consulConfig?.id == consulConfig.id)
            #expect(app.consulConfig?.url == consulConfig.url)
            
            #expect(result?["\(ComponentName.consul):\(MeasurementType.uptime)"] == nil)
        }
    }

    @Test("Connections")
    func connections() async throws {
        try await withApp { app in
            app.consulRequest = MockConsulRequest()
            let healthChecks = ConsulHealthChecks(app: app)
            let result = await healthChecks.check(for: [.connections, .uptime])
            #expect(result.count == 1)
            guard let connections = result["\(ComponentName.consul):\(MeasurementType.connections)"] else {
                Issue.record("No have key for connections")
                return
            }
            #expect(connections.componentType == .component)
            #expect(connections.status == .pass)
            let observedValue = try #require(connections.observedValue)
            #expect(observedValue < 1.0)
            #expect(connections.observedUnit == "s")
            #expect(connections.output == nil)
        }
    }
}
