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
//  ChecksProtocol.swift
//
//
//  Created by Mykola Buhaiov on 06.02.2024.
//

import Vapor

/// Protocol defining generic health check functionality for application components.
///
/// `ChecksProtocol` provides a standard interface for performing health checks
/// across various components or services. It allows implementers to define
/// custom checks and return structured results for monitoring purposes.
///
/// - Note:
/// All methods are asynchronous to support network calls, database checks, or other I/O operations.
public protocol ChecksProtocol {
    /// Performs health checks for the specified measurement types.
    ///
    /// - Parameter options: An array of `MeasurementType` values indicating
    ///   which checks should be performed (e.g., uptime, response time, connections).
    /// - Returns: A dictionary mapping component IDs and measurement types
    ///   to their corresponding `HealthCheckItem` results.
    ///
    /// - Important:
    /// Implementers should ensure that the dictionary keys are unique
    /// and clearly identify the component and measurement type.
    func check(for options: [MeasurementType]) async -> [String: HealthCheckItem]
}
