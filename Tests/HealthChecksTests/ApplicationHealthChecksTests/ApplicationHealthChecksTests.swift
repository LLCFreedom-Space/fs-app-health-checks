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
//  ApplicationHealthChecksTests.swift
//
//
//  Created by Mykola Buhaiov on 10.02.2024.
//

@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Application health checks tests")
struct ApplicationHealthChecksCheckTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Check")
    func check() async throws {
        try await withApp { app in
            app.applicationHealthChecks = ApplicationHealthChecksMock()
            let result = await app.applicationHealthChecks?.check(for: [.uptime, .utilization])
            let uptime = result?[MeasurementType.uptime.rawValue]
            let memory = result?["\(ComponentName.memory.rawValue):\(MeasurementType.utilization.rawValue)"]
            let cpu = result?["\(ComponentName.cpu.rawValue):\(MeasurementType.utilization.rawValue)"]
            #expect(uptime == ApplicationHealthChecksMock.uptimeHealthCheckItem)
            #expect(memory == ApplicationHealthChecksMock.memoryHealthCheckItem)
            #expect(cpu == ApplicationHealthChecksMock.cpuHealthCheckItem)
        }
    }

    @Test("Check returns valid items")
    func checkReturnsValidItems() async throws {
        let processInfo = ProcessInfo.processInfo
        try await withApp { app in
            let healthChecks = ApplicationHealthChecks(app: app)
            let checks = await healthChecks.check(for: [.uptime, .utilization])
            #expect(checks.count == 3)
            #expect(checks.keys.contains(MeasurementType.uptime.rawValue))
            guard let uptimeItem = checks[MeasurementType.uptime.rawValue] else {
                Issue.record("No have uptime")
                return
            }
            #expect(uptimeItem.componentType == .system)
            #expect(uptimeItem.observedUnit == "s")
            #expect(uptimeItem.status == .pass)
            #expect(uptimeItem.version != nil)
            guard let observedValue = uptimeItem.observedValue else {
                Issue.record("No have observed value")
                return
            }
            let expectedUptime = processInfo.systemUptime
            #expect(abs(observedValue - expectedUptime) < 1.0)
            let cpuKey = "\(ComponentName.cpu):\(MeasurementType.utilization)"
            guard let cpuItem = checks[cpuKey] else {
                Issue.record("No have cpu")
                return
            }
            #expect(cpuItem.componentType == .system)
            #expect(cpuItem.observedUnit == "cores")
            #expect(cpuItem.status == .pass)
            let memoryKey = "\(ComponentName.memory):\(MeasurementType.utilization)"
            guard let memoryItem = checks[memoryKey] else {
                Issue.record("No have memory")
                return
            }
            #expect(memoryItem.componentType == .system)
            #expect(memoryItem.observedUnit == "GiB")
            #expect(memoryItem.status == .pass)
        }
    }

    @Test("Check handles unsupported types")
    func testCheckHandlesUnsupportedTypes() async throws {
        try await withApp { app in
            let healthChecks = ApplicationHealthChecks(app: app)
            let checks = await healthChecks.check(for: [.connections])
            #expect(checks.count == .zero)
        }
    }
    
    @Test("Uptime")
    func uptime() async throws {
        try await withApp { app in
            app.applicationHealthChecks = ApplicationHealthChecksMock()
            let response = app.applicationHealthChecks?.uptime()
            #expect(response == ApplicationHealthChecksMock.uptimeHealthCheckItem)
        }
    }

    @Test("Uptime returns valid item")
    func uptimeReturnsValidItem() async throws {
        let processInfo = ProcessInfo.processInfo
        try await withApp { app in
            let healthChecks = ApplicationHealthChecks(app: app)
            let item = healthChecks.uptime()
            #expect(item.componentType == .system)
            #expect(item.observedUnit == "s")
            #expect(item.status == .pass)
            #expect(item.version != nil)

            // Assert time is within a reasonable range of actual uptime
            let expectedUptime = processInfo.systemUptime
            guard let value = item.observedValue else {
                Issue.record("No observed value")
                return
            }
            #expect(abs(value - expectedUptime) < 1.0)
        }
    }
    
    @Test("CPU")
    func cpu() async throws {
        try await withApp { app in
            app.applicationHealthChecks = ApplicationHealthChecksMock()
            let response = app.applicationHealthChecks?.cpu()
            #expect(response == ApplicationHealthChecksMock.cpuHealthCheckItem)
        }
    }
    
    @Test("CPU returns valid item")
    func cpuReturnsValidItem() async throws {
        try await withApp { app in
            let healthChecks = ApplicationHealthChecks(app: app)
            let item = healthChecks.cpu()
            #expect(item.componentType == .system)
            #expect(item.observedUnit == "cores")
            #expect(item.status == .pass)
            #expect(item.version == nil)
        }
    }
    
    @Test("Memory")
    func memory() async throws {
        try await withApp { app in
            app.applicationHealthChecks = ApplicationHealthChecksMock()
            let response = app.applicationHealthChecks?.memory()
            #expect(response == ApplicationHealthChecksMock.memoryHealthCheckItem)
        }
    }
    
    @Test("Memory returns valid item")
    func memoryReturnsValidItem() async throws {
        try await withApp { app in
            let healthChecks = ApplicationHealthChecks(app: app)
            let item = healthChecks.memory()
            #expect(item.componentType == .system)
            #expect(item.observedUnit == "GiB")
            #expect(item.status == .pass)
            #expect(item.version == nil)
        }
    }
}
