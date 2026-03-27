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
//  AppHealthChecksTests.swift
//
//
//  Created by Mykola Buhaiov on 09.03.2023.
//

@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Health checks tests")
struct HealthChecksTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await test(app)
        } catch {
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Get public version")
    func getPublicVersion() async throws {
        try await withApp { app in
            let releaseId = "1.0.0"
            let version = HealthChecks().getPublicVersion(from: releaseId)
            #expect(version == "1")
            let invalidVersion = HealthChecks().getPublicVersion(from: "invalidVersion")
            #expect(invalidVersion == nil)
            let versionWithoutDots = HealthChecks().getPublicVersion(from: "12345")
            #expect(versionWithoutDots == nil)
            let versionWithLettersAndDots = HealthChecks().getPublicVersion(from: "1a.b.c")
            #expect(versionWithLettersAndDots == nil)
        }
    }

    @Test("Get health")
    func getHealth() async throws {
        try await withApp { app in
            let serviceId = UUID()
            let releaseId = "1.0.0"
            app.serviceId = serviceId
            app.releaseId = releaseId
            let response = HealthChecks().getHealth(from: app)
            #expect(response.version == "1")
            #expect(response.releaseId == releaseId)
            #expect(response.serviceId == serviceId)
        }
    }
}
