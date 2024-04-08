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
    
    /// Initializer for HealthCheckItem
    /// - Parameters:
    ///   - componentId: optional `String`
    ///   - componentType: optional `ComponentType`
    ///   - observedValue: optional `Double`
    ///   - observedUnit: optional `String`
    ///   - status: optional `HealthCheckStatus`
    ///   - affectedEndpoints: optional `[String]`
    ///   - time: optional `String`
    ///   - output: optional `String`
    ///   - links: optional `[String : String]`
    ///   - node: optional `Int`
    public init(
        componentId: String? = nil,
        componentType: ComponentType? = nil,
        observedValue: Double? = nil,
        observedUnit: String? = nil,
        status: HealthCheckStatus? = nil,
        affectedEndpoints: [String]? = nil,
        time: String? = nil,
        output: String? = nil,
        links: [String : String]? = nil,
        node: Int? = nil
    ) {
        self.componentId = componentId
        self.componentType = componentType
        self.observedValue = observedValue
        self.observedUnit = observedUnit
        self.status = status
        self.affectedEndpoints = affectedEndpoints
        self.time = time
        self.output = output
        self.links = links
        self.node = node
    }
    
    /// Example of `HealthCheckItem`
    public static var example: HealthCheckItem {
        HealthCheckItem(
            componentId: "6fd416e0-8920-410f-9c7b-c479000f7227",
            componentType: .component,
            observedValue: 1234,
            observedUnit: "s",
            status: .pass,
            affectedEndpoints: ["/users/{userId}"],
            time: "2018-01-17T03:36:48Z",
            output: "",
            links: ["self": "http://api.example.com/dbnode/dfd6cf2b/health"],
            node: 1
        )
    }
}
