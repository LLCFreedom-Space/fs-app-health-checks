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
//  ApplicationHealthChecksCheckTests.swift
//
//
//  Created by Mykola Buhaiov on 10.02.2024.
//

@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Application health checks check tests")
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
            app.launchTime = Date().timeIntervalSince1970
            app.applicationHealthChecks = ApplicationHealthChecksMock()
            let result = await app.applicationHealthChecks?.check(for: [MeasurementType.uptime])
            let uptime = result?[MeasurementType.uptime.rawValue]
            #expect(uptime == ApplicationHealthChecksMock.healthCheckItem)
        }
    }

    @Test("Check returns valid items")
    func checkReturnsValidItems() async throws {
        try await withApp { app in
            let healthChecks = ApplicationHealthChecks(app: app)
            let checks = await healthChecks.check(for: [.uptime])
            #expect(checks.count == 1)
            #expect(checks.keys.contains("uptime"))
            guard let uptimeItem = checks["uptime"] else {
                Issue.record("no have uptime")
                return
            }
            #expect(uptimeItem.componentType == .system)
            #expect(uptimeItem.observedUnit == "s")
            #expect(uptimeItem.status == .pass)
            guard let observedValue = uptimeItem.observedValue else {
                Issue.record("No have observed value")
                return
            }
            let expectedUptime = Date().timeIntervalSince1970 - app.launchTime
            #expect(abs(observedValue - expectedUptime) < 1.0)
        }
    }

    @Test("Check handles unsupported types")
    func testCheckHandlesUnsupportedTypes() async throws {
        try await withApp { app in
            let healthChecks = ApplicationHealthChecks(app: app)
            let checks = await healthChecks.check(for: [.connections])
            #expect(checks.count == 0)  // Expect empty result, as .memory is not supported
        }
    }
}
