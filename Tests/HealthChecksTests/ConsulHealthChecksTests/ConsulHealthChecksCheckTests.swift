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
        defer {
            Task {
                try? await app.asyncShutdown()
            }
        }
        try await test(app)
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
    
    @Test("Health check with errors")
    func healthCheckWithErrors() async throws {
        try await withApp { app in
            app.consulRequest = ConsulRequest(app: app)
            app.consulHealthChecks = ConsulHealthChecks(app: app)
            var result = await app.consulHealthChecks?.check(for: [MeasurementType.connections])
            #expect(result?.count == 1)
            var connections = try #require(result?["\(ComponentName.consul):\(MeasurementType.connections)"])
            #expect(connections.componentId == nil)
            #expect(connections.componentType == .component)
            #expect(connections.status == .fail)
            #expect(connections.output == HealthCheckError.urlNotConfigured.errorDescription)
            
            let consulConfig = ConsulConfig(id: UUID().uuidString, url: Constants.consulUrl)
            app.consulConfig = consulConfig
            let clientResponse = ClientResponse(status: .notFound)
            app.clients.use { app in
                MockClient(eventLoop: app.eventLoopGroup.next(), clientResponse: clientResponse)
            }
            result = await app.consulHealthChecks?.check(for: [MeasurementType.connections])
            #expect(result?.count == 1)
            connections = try #require(result?["\(ComponentName.consul):\(MeasurementType.connections)"])
            #expect(connections.componentId == consulConfig.id)
            #expect(connections.componentType == .component)
            #expect(connections.status == .fail)
            #expect(connections.output == HealthCheckError.unexpectedStatusCode.errorDescription)
        }
    }

    @Test("Connections")
    func connections() async throws {
        try await withApp { app in
            app.consulRequest = MockConsulRequest()
            let healthChecks = ConsulHealthChecks(app: app)
            let result = await healthChecks.check(for: [.connections, .uptime])
            #expect(result.count == 1)
            let connections = try #require(result["\(ComponentName.consul):\(MeasurementType.connections)"])
            #expect(connections.componentType == .component)
            #expect(connections.status == .pass)
            let observedValue = try #require(connections.observedValue)
            #expect(observedValue < 1.0)
            #expect(connections.observedUnit == "s")
            #expect(connections.output == nil)
        }
    }
    
    @Test("Check connection")
    func checkConnection() async throws {
        try await withApp { app in
            app.consulRequest = MockConsulRequest()
            let checks = ConsulHealthChecks(app: app)
            try await checks.checkConnection()
            
            app.consulHealthChecks = ConsulHealthChecksMock()
            await #expect(throws: Never.self) { try await app.consulHealthChecks?.checkConnection() }
        }
    }

    @Test("Check connection - service not setup")
    func checkConnectionNotSetup() async throws {
        try await withApp { app in
            let checks = ConsulHealthChecks(app: app)
            await #expect(throws: HealthCheckError.serviceNotSetup(name: ComponentName.consul.rawValue)) {
                try await checks.checkConnection()
            }
        }
    }
    
    @Test("Connection")
    func connection() async throws {
        try await withApp { app in
            let consulConfig = ConsulConfig(
                id: UUID().uuidString,
                url: Constants.consulUrl
            )
            app.consulConfig = consulConfig
            app.consulHealthChecks = ConsulHealthChecksMock()
            let mockResult = await app.consulHealthChecks?.connection()
            #expect(mockResult == ConsulHealthChecksMock.healthCheckItem)
            #expect(app.consulConfig?.id == consulConfig.id)

            app.consulRequest = MockConsulRequest()
            app.consulHealthChecks = ConsulHealthChecks(app: app)
            let result = await app.consulHealthChecks?.connection()
            #expect(result?.componentType == .component)
            #expect(result?.observedValue != nil)
            #expect(result?.observedUnit == "s")
            #expect(result?.status == .pass)
            #expect(result?.output == nil)
            #expect(result?.links == nil)
            #expect(result?.node == nil)
        }
    }
    
    @Test("Connection with error")
    func connectionWithError() async throws {
        try await withApp { app in
            app.consulHealthChecks = ConsulHealthChecks(app: app)
            let result = await app.consulHealthChecks?.connection()
            #expect(result?.componentType == .component)
            #expect(result?.observedValue == nil)
            #expect(result?.observedUnit == nil)
            #expect(result?.status == .fail)
            #expect(result?.output == HealthCheckError.serviceNotSetup(name: ComponentName.consul.rawValue).errorDescription)
            #expect(result?.links == nil)
            #expect(result?.node == nil)
        }
    }
}
