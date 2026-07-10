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
//  CheckResult.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 10.07.2026.
//

import Vapor

/// Represents the result of a health check operation.
/// A `CheckResult` contains the overall HTTP status and the grouped
/// health check items for a component.
public struct CheckResult {
    /// The overall HTTP status of the health check.
    public let status: HTTPResponseStatus
    /// Health check items grouped by category.
    public let items: [String: [HealthCheckItem]]
    /// Indicates whether the component is unavailable.
    public var isUnavailable: Bool {
        status == .serviceUnavailable
    }
    /// Creates a result representing an unavailable component.
    /// - Returns: A `CheckResult` with status `503 Service Unavailable`
    ///   and no health check items.
    static func unavailable() -> CheckResult {
        CheckResult(status: .serviceUnavailable, items: [:])
    }
}
