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
//  HealthCheckItem.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//

import Vapor

/// A generic `HealthCheckItem` data that can be sent in response.
public struct HealthCheckItem: Content {
    /// Is a unique identifier of an instance of a specific sub-component/dependency of a service.
    /// Example: `43119325-63f5-4e14-9175-84e0e296c527`
    public var componentId: String?
  
    /// It's a type of the component
    /// Example: one of the enumeration:`component` or `datastore` or `system`
    public var componentType: ComponentType?
    
    /// Could be any valid JSON value, such as: `string`, `number`, object, array or literal
    /// Example: `100`
    public var observedValue: Double?
    
    /// Time-based value it is important to know whether the time is reported in seconds, minutes, hours or something else.
    /// Example: `ms`
    public var observedUnit: String?
    
    /// It's a status of the health check
    public var status: HealthCheckStatus?
    
    /// Array of affected endpoints
    /// Example: `http://example.com/pass/endpoints`
    public var affectedEndpoints: [String]?
    
    /// Is the date-time, in ISO8601 format, at which the reading of the observedValue was recorded.
    /// Example: `2024-01-17T03:36:48Z`
    public var time: String?
    
    /// Raw error output, in case of `fail` or `warn` states
    /// Example: `"Redis database not exist"`
    public var output: String?
    
    /// Dictionary of links for show more information about health check item
    /// Example: `["about": "http://api.example.com/about/authz"]`
    public var links: [String: String]?
    
    /// Number of node
    /// Example: `1`
    public var node: Int?
}

extension HealthCheckItem: Equatable {
    /// Check for equal model
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
