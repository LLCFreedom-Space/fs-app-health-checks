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
//   ApplicationChecksProtocol.swift
//
//
//  Created by Mykola Buhaiov on 10.02.2024.
//

import Vapor

/// Protocol for performing application-level health checks.
///
/// `ApplicationChecksProtocol` defines the contract for basic system-level
/// health checks, such as monitoring application uptime. Implementers can
/// extend this protocol to include more detailed or platform-specific checks.
///
/// - Note:
/// This protocol focuses on runtime and system metrics that reflect the
/// application's overall health and availability.
public protocol ApplicationChecksProtocol {
    /// Retrieves the uptime of the application as a health check item.
    ///
    /// This method provides a basic indication of the application's system-level health
    /// by reporting how long the application has been running since startup.
    ///
    /// - Returns: A `HealthCheckItem` containing:
    ///   - `componentType`: Typically `.system`
    ///   - `observedValue`: Uptime in seconds
    ///   - `observedUnit`: `"s"` (seconds)
    ///   - `status`: Health status (usually `.pass`)
    ///   - `time`: Timestamp of when the measurement was taken
    ///
    /// - Important:
    /// The uptime calculation depends on a correctly initialized
    /// application launch time.
    func uptime() -> HealthCheckItem
}
