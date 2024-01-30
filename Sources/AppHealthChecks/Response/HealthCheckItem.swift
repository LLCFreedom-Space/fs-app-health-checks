//
//  HealthCheckItem.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor

/// The `checks` object MAY have a number of unique keys, one for each logical downstream dependency or sub-component.
/// Since each sub-component may be backed by several nodes with varying health statuses, these keys point to arrays of objects.
/// The key identifying an element in the object SHOULD be a unique string within the details section.
/// It MAY have two parts: `{componentName}:{measurementName}`, in which case the meaning of the parts SHOULD be as follows:
public struct HealthCheckItem: Content {
    /// Is a unique identifier of an instance of a specific sub-component/dependency of a service.
    /// Multiple objects with the same componentID MAY appear in the details, if they are from different nodes
    /// Example: `43119325-63f5-4e14-9175-84e0e296c527`
    public var componentId: String?
  
    /// SHOULD be present if componentName is present. It's a type of the component and could be one of:
    /// Example: `component`
    public var componentType: ComponentType?
    
    /// Could be any valid JSON value, such as: string, number, object, array or literal
    /// Example: `100`
    public var observedValue: Double?
    
    /// SHOULD be present if observedValue is present.
    /// Time-based value it is important to know whether the time is reported in seconds, minutes, hours or something else.
    /// Example: `ms`
    public var observedUnit: String?
    
    /// Has the exact same meaning as the top-level `output` element, but for the sub-component/downstream dependency represented by the details object
    public var status: HealthCheckStatus?
    
    /// Is a JSON array containing URI Templates as defined by [RFC6570]. This field SHOULD be omitted if the `status` field is present and has value equal to `pass`.
    /// Example: `pass`
    public var affectedEndpoints: [String]?
    
    /// Is the date-time, in ISO8601 format, at which the reading of the observedValue was recorded.
    /// This assumes that the value can be cached and the reading typically doesn't happen in real time, for performance and scalability purposes
    /// Example: `2024-01-17T03:36:48Z`
    public var time: String?
    
    /// Has the exact same meaning as the top-level `output` element, but for the sub-component/downstream dependency represented by the details object.
    /// As is the case for the top-level element, this field SHOULD be omitted for `pass` state of a downstream dependency
    public var output: String?
    
    /// Has the exact same meaning as the top-level `output` element, but for the sub-component/downstream dependency represented by the details object
    /// Example: `["about": "http://api.example.com/about/authz"]`
    public var links: [String: String]?
    
    /// Number of node
    /// Example: `1`
    public var node: Int?
}
