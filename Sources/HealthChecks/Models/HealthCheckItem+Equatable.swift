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
//  HealthCheckItem+Equatable.swift
//
//
//  Created by Mykola Buhaiov on 06.02.2024.
//

import Vapor

/// Equatable protocol implementation for `HealthCheckItem` struct.
///
/// Two `HealthCheckItem` structs are considered equal if they have the same:
///
/// - componentId
/// - componentType
/// - observedValue
/// - observedUnit
/// - status
/// - affectedEndpoints
/// - time
/// - output
/// - links
/// - node
extension HealthCheckItem: Equatable {
    /// Conform `HealthCheckItem` to `Equatable` protocol
    /// - Parameters:
    ///   - lhs: `HealthCheckItem`
    ///   - rhs: `HealthCheckItem`
    /// - Returns: `Bool`
    public static func == (lhs: HealthCheckItem, rhs: HealthCheckItem) -> Bool {
        return lhs.componentId == rhs.componentId &&
        lhs.componentType == rhs.componentType &&
        lhs.observedValue == rhs.observedValue &&
        lhs.observedUnit == rhs.observedUnit &&
        lhs.status == rhs.status &&
        lhs.affectedEndpoints == rhs.affectedEndpoints &&
        lhs.time == rhs.time &&
        lhs.output == rhs.output &&
        lhs.links == rhs.links &&
        lhs.node == rhs.node
    }
}
