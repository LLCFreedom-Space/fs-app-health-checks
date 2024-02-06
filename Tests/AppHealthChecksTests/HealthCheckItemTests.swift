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
//  HealthCheckItemTests.swift
//
//
//  Created by Mykola Buhaiov on 06.02.2024.
//

import Vapor
import XCTest
@testable import AppHealthChecks

final class HealthCheckItemTests: XCTestCase {
    func testPublicKeyEquatable() {
        let firstHealthCheckItem = HealthCheckItem(
            componentId: "adca7c3d-55f4-4ab3-a842-18b35f50cb0f",
            componentType: .datastore,
            observedValue: 1,
            observedUnit: "s",
            status: .pass,
            affectedEndpoints: nil,
            time: "2024-02-01T11:11:59.364",
            output: "Ok",
            links: nil,
            node: nil
        )
        var secondHealthCheckItem = HealthCheckItem(
            componentId: "adca7c3d-55f4-4ab3-a842-18b35f50cb0f",
            componentType: .datastore,
            observedValue: 1,
            observedUnit: "s",
            status: .pass,
            affectedEndpoints: nil,
            time: "2024-02-01T11:11:59.364",
            output: "Ok",
            links: nil,
            node: nil
        )
        XCTAssertEqual(firstHealthCheckItem, secondHealthCheckItem)
        secondHealthCheckItem.observedValue = 4
        XCTAssertNotEqual(firstHealthCheckItem, secondHealthCheckItem)
    }
}
