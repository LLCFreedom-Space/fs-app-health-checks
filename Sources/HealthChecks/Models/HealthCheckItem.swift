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

/// Represents the health check data of a specific sub-component or dependency within a service.
public struct HealthCheckItem: Content {
    /// Unique identifier of an instance of a specific sub-component or dependency.
    public var componentId: String?
    /// Type of the component.
    public var componentType: ComponentType?
    /// Observed numeric value for the component (could be any valid measurement).
    public var observedValue: Double?
    /// Unit of the observed value (important to know whether in seconds, minutes, etc.).
    public var observedUnit: String?
    /// Status of this health check.
    public var status: HealthCheckStatus?
    /// ISO8601 timestamp at which the observed value was recorded.
    public var time: String?
    /// Array of affected endpoints.
    public var affectedEndpoints: [String]?
    /// Raw error output in case of `fail` or `warn` states.
    public var output: String?
    /// Dictionary of links with more information about this health check item.
    public var links: [String: String]?
    /// Node number of the component instance.
    public var node: Int?

    /// Initializes a new `HealthCheckItem`.
    /// - Parameters:
    ///   - componentId: Optional unique identifier of the component.
    ///   - componentType: Optional type of the component.
    ///   - observedValue: Optional numeric value observed.
    ///   - observedUnit: Optional unit for the observed value.
    ///   - status: Optional health status.
    ///   - affectedEndpoints: Optional list of affected endpoints.
    ///   - time: Optional ISO8601 timestamp.
    ///   - output: Optional raw output for errors/warnings.
    ///   - links: Optional dictionary of related links.
    ///   - node: Optional node number.
    public init(
        componentId: String? = nil,
        componentType: ComponentType? = nil,
        observedValue: Double? = nil,
        observedUnit: String? = nil,
        status: HealthCheckStatus? = nil,
        affectedEndpoints: [String]? = nil,
        time: String? = nil,
        output: String? = nil,
        links: [String: String]? = nil,
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
}

extension HealthCheckItem {
    // MARK: - Example
    /// Example instance of `HealthCheckItem` for testing or documentation purposes.
    public static var example: HealthCheckItem {
        let observedValue: Double = 1234
        return HealthCheckItem(
            componentId: "6fd416e0-8920-410f-9c7b-c479000f7227",
            componentType: .component,
            observedValue: observedValue,
            observedUnit: "ms",
            status: .pass,
            affectedEndpoints: ["/users/{userId}"],
            time: "2018-01-17T03:36:48Z",
            output: "",
            links: ["self": "http://api.example.com/dbnode/dfd6cf2b/health"],
            node: 1
        )
    }
}
