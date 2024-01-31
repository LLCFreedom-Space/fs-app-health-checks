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

import Vapor
import XCTest
@testable import AppHealthChecks

final class AppHealthChecksTests: XCTestCase {
    let serviceId = UUID()
    let releaseId = "1.0.0"

    func testGetMajorVersion() {
        let app = Application(.testing)
        defer { app.shutdown() }
        let version = AppHealthChecks().getPublicVersion(from: releaseId)
        XCTAssertEqual(version, 1)
    }

    func testGetMajorVersionForDefaultVersion() {
        let app = Application(.testing)
        defer { app.shutdown() }
        let version = AppHealthChecks().getPublicVersion(from: "1-0-0")
        XCTAssertEqual(version, 0)
    }

    func testGetHealth() {
        let app = Application(.testing)
        defer { app.shutdown() }
        app.serviceId = serviceId
        app.releaseId = releaseId
        let response = AppHealthChecks().getHealth(from: app)
        XCTAssertEqual(response.version, 1)
        XCTAssertEqual(response.releaseId, releaseId)
        XCTAssertEqual(response.serviceId, serviceId)
    }
}
