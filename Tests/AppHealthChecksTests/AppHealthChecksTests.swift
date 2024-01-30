//
//  AppHealthChecksTests.swift
//
//
//  Created by Mykola Buhaiov on 09.03.2023.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor
import XCTest
@testable import AppHealthChecks

final class AppHealthChecksTests: XCTestCase {
    //  swiftlint:disable implicitly_unwrapped_optional
    var app: Application!
    //  swiftlint:enable implicitly_unwrapped_optional

    override func setUpWithError() throws {
        app = Application(.testing)
    }

    override func tearDown() {
        app.shutdown()
    }

    func testGetMajorVersion() throws {
        let version = AppHealthChecks().getPublicVersion(from: "1.0.0")
        XCTAssertEqual(version, 1)
    }

    func testGetMajorVersionForDefaultVersion() throws {
        let version = AppHealthChecks().getPublicVersion(from: "1-0-0")
        XCTAssertEqual(version, 0)
    }
}
