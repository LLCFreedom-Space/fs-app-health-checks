//
//  HealthCheckItem.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor

/// A generic `HealthCheckItem` data that can be sent in response.
public struct HealthCheckItem: Content {
    /// Is a unique identifier of an instance of a specific sub-component/dependency of a service.
    /// Example: `43119325-63f5-4e14-9175-84e0e296c527`
    public var componentId: String?
  
    /// It's a type of the component
    /// Example: `component`
    public var componentType: ComponentType?
    
    /// Could be any valid JSON value, such as: `string`, `number`, object, array or literal
    /// Example: `100`
    public var observedValue: Double?
    
    /// Time-based value it is important to know whether the time is reported in seconds, minutes, hours or something else.
    /// Example: `ms`
    public var observedUnit: String?
    
    /// Has the exact same meaning as the top-level `output` element, but for the sub-component/downstream dependency represented by the details object
    public var status: HealthCheckStatus?
    
    /// Is a JSON array containing URI Templates as defined by [RFC6570]. This field SHOULD be omitted if the `status` field is present and has value equal to `pass`.
    /// Example: `http://example.com/pass/endpoints`
    public var affectedEndpoints: [String]?
    
    /// Is the date-time, in ISO8601 format, at which the reading of the observedValue was recorded.
    /// Example: `2024-01-17T03:36:48Z`
    public var time: String?
    
    /// As is the case for the top-level element, this field SHOULD be omitted for `pass` state of a downstream dependency
    public var output: String?
    
    /// Has the exact same meaning as the top-level `output` element, but for the sub-component/downstream dependency represented by the details object
    /// Example: `["about": "http://api.example.com/about/authz"]`
    public var links: [String: String]?
    
    /// Number of node
    /// Example: `1`
    public var node: Int?
}
