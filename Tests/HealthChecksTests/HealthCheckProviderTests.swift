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
//  HealthCheckProviderTests.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 10.07.2026.
//

@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Health check provider tests")
struct HealthCheckProviderTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        defer {
            Task {
                try? await app.asyncShutdown()
            }
        }
        
        try await test(app)
    }
    
    @Test("Postgres returns OK when provider is registered")
    func checkPostgres() async throws {
        try await withApp { app in
            let provider = HealthCheckProvider(app: app)
            let postgresHealthChecksMock = PostgresHealthChecksMock()
            app.postgresHealthChecks = postgresHealthChecksMock
            
            let result = await provider.checkPostgres()
            
            #expect(result.status == .ok)
            #expect(!result.isUnavailable)
            #expect(result.items.count == 2)
            
            let connections = result.items["\(ComponentName.postgresql):\(MeasurementType.connections)"]
            #expect(connections?.count == 1)
            #expect(connections?.first == postgresHealthChecksMock.healthCheckItem)
            
            let responseTime = result.items["\(ComponentName.postgresql):\(MeasurementType.responseTime)"]
            #expect(responseTime?.count == 1)
            #expect(responseTime?.first == postgresHealthChecksMock.healthCheckItem)
        }
    }
    
    @Test("Redis returns OK when provider is registered")
    func checkRedis() async throws {
        try await withApp { app in
            let provider = HealthCheckProvider(app: app)
            let redisHealthChecksMock = RedisHealthChecksMock()
            app.redisHealthChecks = redisHealthChecksMock
            
            let result = await provider.checkRedis()
            
            #expect(result.status == .ok)
            #expect(!result.isUnavailable)
            #expect(result.items.count == 2)
            
            let connections = result.items["\(ComponentName.redis):\(MeasurementType.connections)"]
            #expect(connections?.count == 1)
            #expect(connections?.first == redisHealthChecksMock.healthCheckItem)
            
            let responseTime = result.items["\(ComponentName.redis):\(MeasurementType.responseTime)"]
            #expect(responseTime?.count == 1)
            #expect(responseTime?.first == redisHealthChecksMock.healthCheckItem)
        }
    }
    
    @Test("Mongo returns OK when provider is registered")
    func checkMongo() async throws {
        try await withApp { app in
            let provider = HealthCheckProvider(app: app)
            let mongoHealthChecksMock = MongoHealthChecksMock()
            app.mongoHealthChecks = mongoHealthChecksMock
            
            let result = await provider.checkMongo()
            
            #expect(result.status == .ok)
            #expect(!result.isUnavailable)
            #expect(result.items.count == 2)
            
            let connections = result.items["\(ComponentName.mongo):\(MeasurementType.connections)"]
            #expect(connections?.count == 1)
            #expect(connections?.first == mongoHealthChecksMock.healthCheckItem)
            
            let responseTime = result.items["\(ComponentName.mongo):\(MeasurementType.responseTime)"]
            #expect(responseTime?.count == 1)
            #expect(responseTime?.first == mongoHealthChecksMock.healthCheckItem)
        }
    }
    
    @Test("Consul returns OK when provider is registered")
    func checkConsul() async throws {
        try await withApp { app in
            let provider = HealthCheckProvider(app: app)
            let consulHealthChecksMock = ConsulHealthChecksMock()
            app.consulHealthChecks = consulHealthChecksMock
            
            let result = await provider.checkConsul()
            
            #expect(result.status == .ok)
            #expect(!result.isUnavailable)
            #expect(result.items.count == 2)
            
            let connections = result.items["\(ComponentName.consul):\(MeasurementType.connections)"]
            #expect(connections?.count == 1)
            #expect(connections?.first == consulHealthChecksMock.healthCheckItem)
        }
    }
    
    @Test("Application returns unavailable when provider is not registered")
    func checkApplicationUnavailable() async throws {
        try await withApp { app in
            let provider = HealthCheckProvider(app: app)
            
            let result = await provider.checkApplication()
            
            #expect(result.status == .serviceUnavailable)
            #expect(result.isUnavailable)
            #expect(result.items.isEmpty)
        }
    }
    
    @Test("Returns unavailable when service checks are nil")
    func buildResultWithNilChecks() async throws {
        try await withApp { app in
            let provider = HealthCheckProvider(app: app)
            
            let result = provider.buildResult(
                name: ComponentName.postgresql.rawValue,
                serviceChecks: nil
            )
            
            #expect(result.status == .serviceUnavailable)
            #expect(result.isUnavailable)
            #expect(result.items.isEmpty)
        }
    }
    
    @Test("Returns OK when all checks pass")
    func buildResultAllPassed() async throws {
        try await withApp { app in
            let provider = HealthCheckProvider(app: app)
            let checks: [String: HealthCheckItem] = [
                MeasurementType.connections.rawValue: HealthCheckItem(
                    observedValue: 10,
                    observedUnit: nil,
                    status: .pass,
                    time: nil,
                    output: nil
                ),
                MeasurementType.responseTime.rawValue: HealthCheckItem(
                    observedValue: 15,
                    observedUnit: "ms",
                    status: .pass,
                    time: nil,
                    output: nil
                )
            ]
            
            let result = provider.buildResult(
                name: ComponentName.postgresql.rawValue,
                serviceChecks: checks
            )
            
            #expect(result.status == .ok)
            #expect(!result.isUnavailable)
            #expect(result.items.count == 2)
            #expect(result.items[MeasurementType.connections.rawValue]?.count == 1)
            #expect(result.items[MeasurementType.responseTime.rawValue]?.count == 1)
        }
    }
    
    @Test("Returns service unavailable when any check fails")
    func buildResultWithFailedCheck() async throws {
        try await withApp { app in
            let provider = HealthCheckProvider(app: app)
            
            let checks: [String: HealthCheckItem] = [
                MeasurementType.connections.rawValue: HealthCheckItem(
                    observedValue: 10,
                    observedUnit: nil,
                    status: .pass,
                    time: nil,
                    output: nil
                ),
                MeasurementType.responseTime.rawValue: HealthCheckItem(
                    observedValue: 250,
                    observedUnit: "ms",
                    status: .fail,
                    time: nil,
                    output: "Too slow"
                )
            ]
            
            let result = provider.buildResult(
                name: ComponentName.postgresql.rawValue,
                serviceChecks: checks
            )
            
            #expect(result.status == .serviceUnavailable)
            #expect(result.isUnavailable)
            #expect(result.items.count == 2)
        }
    }
    
    @Test("Groups health check items by key")
    func buildResultGroupsItems() async throws {
        try await withApp { app in
            let provider = HealthCheckProvider(app: app)
            
            let checks: [String: HealthCheckItem] = [
                ComponentType.datastore.rawValue: HealthCheckItem(
                    observedValue: 10,
                    observedUnit: nil,
                    status: .pass,
                    time: nil,
                    output: nil
                )
            ]
            
            let result = provider.buildResult(
                name: ComponentName.postgresql.rawValue,
                serviceChecks: checks
            )
            
            #expect(result.items[ComponentType.datastore.rawValue]?.count == 1)
        }
    }
    
    @Test("Ignores health check items with empty keys")
    func buildResultIgnoresEmptyKeys() async throws {
        try await withApp { app in
            let provider = HealthCheckProvider(app: app)
            
            let checks: [String: HealthCheckItem] = [
                "": HealthCheckItem(
                    observedValue: 1,
                    observedUnit: nil,
                    status: .pass,
                    time: nil,
                    output: nil
                ),
                MeasurementType.connections.rawValue: HealthCheckItem(
                    observedValue: 2,
                    observedUnit: nil,
                    status: .pass,
                    time: nil,
                    output: nil
                )
            ]
            
            let result = provider.buildResult(
                name: ComponentName.postgresql.rawValue,
                serviceChecks: checks
            )
            
            #expect(result.items.count == 1)
            #expect(result.items[""] == nil)
            #expect(result.items[MeasurementType.connections.rawValue]?.count == 1)
        }
    }
}
