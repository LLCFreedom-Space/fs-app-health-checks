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

import XCTVapor
@testable import HealthChecks

/// Unit tests for the HealthChecks service.
final class HealthChecksTests: XCTestCase {
    let serviceId = UUID()
    let releaseId = "1.0.0"
    
    func testGetPublicVersion() {
        // Simulate retrieving the major version from a valid release version string.
        let version = HealthChecks().getPublicVersion(from: releaseId)
        XCTAssertEqual(version, "1")
        
        // Simulate retrieving the major version from an invalid release version string.
        let invalidVersion = HealthChecks().getPublicVersion(from: "invalidVersion")
        XCTAssertNil(invalidVersion)
        
        // Simulate retrieving the major version from a version string without dots.
        let versionWithoutDots = HealthChecks().getPublicVersion(from: "12345")
        XCTAssertNil(versionWithoutDots)
        
        // Simulate retrieving the major version from a version string with letters and dots.
        let versionWithLettersAndDots = HealthChecks().getPublicVersion(from: "1a.b.c")
        XCTAssertNil(versionWithLettersAndDots)
    }
    
    /// Tests the `getHealth(from:)` method of the `HealthChecks` service.
    func testGetHealth() {
        let app = Application(.testing)
        defer { app.shutdown() }
        // Set up the application with a service ID and release version.
        app.serviceId = serviceId
        app.releaseId = releaseId
        // Retrieve the health information using the `getHealth` method.
        let response = HealthChecks().getHealth(from: app)
        // Assert that the health information matches the expected values.
        XCTAssertEqual(response.version, "1")
        XCTAssertEqual(response.releaseId, releaseId)
        XCTAssertEqual(response.serviceId, serviceId)
    }
}
