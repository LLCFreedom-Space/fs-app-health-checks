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

/// The protocol defines a basic interface for performing health checks against different systems or services.
public protocol ChecksProtocol {
    /// Performs health checks, returning a dictionary of `HealthCheckItem`s for the specified components.
    ///
    /// - Parameter options: An array of `MeasurementType`s indicating which checks to perform.
    /// - Returns: A dictionary of `HealthCheckItem`s, keyed by component ID and measurement type.
    func check(for options: [MeasurementType]) async -> [String: HealthCheckItem]
}
