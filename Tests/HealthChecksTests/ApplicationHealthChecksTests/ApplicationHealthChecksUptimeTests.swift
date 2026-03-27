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
//  ApplicationHealthChecksUptimeTests.swift
//  
//
//  Created by Mykhailo Bondarenko on 07.03.2024.
//

@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Application health checks uptime tests")
struct ApplicationHealthChecksUptimeTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Uptime")
    func uptime() async throws {
        try await withApp { app in
            app.applicationHealthChecks = ApplicationHealthChecksMock()
            let response = app.applicationHealthChecks?.uptime()
            #expect(response == ApplicationHealthChecksMock.healthCheckItem)
        }
    }

    @Test("Uptime returns valid item")
    func uptimeReturnsValidItem() async throws {
        try await withApp { app in
            let healthChecks = ApplicationHealthChecks(app: app)
            let item = healthChecks.uptime()
            #expect(item.componentType == .system)
            #expect(item.observedUnit == "s")
            #expect(item.status == .pass)

            // Assert time is within a reasonable range of actual uptime
            let expectedUptime = Date().timeIntervalSince1970 - app.launchTime
            guard let value = item.observedValue else {
                Issue.record("No have observed value")
                return
            }
            #expect(abs(value - expectedUptime) < 1.0)
        }
    }
}
