//
//  HealthCheck.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor

/// A generic `HealthCheck` data that can be sent in response.
public struct HealthCheck: Content {
    /// Indicates whether the service status is acceptable or not. API publishers SHOULD use following values for the field:
    public var status: HealthCheckStatus?

    /// Public version of the service
    /// Example: `1`
    public var version: Int?
    
    /// Release id of the service
    /// Example: `1.0.0`
    public var releaseId: String?
    
    /// Array of notes relevant to current state of health
    public var notes: [String]?
    
    /// Raw error output, in case of `fail` or `warn` states. This field SHOULD be omitted for `pass` state.
    public var output: String?
    
    /// Is an object that provides detailed health statuses of additional downstream systems and endpoints which can affect the overall health of the main API.
    /// Please refer to the `The Checks Object` section for more information
    public var checks: [String: [HealthCheckItem]]?
    
    /// Is an object containing link relations and URIs [RFC3986] for external links that MAY contain more information about the health of the endpoint.
    public var links: [String: String]?
    
    /// Is a unique identifier of the service, in the application scope
    /// Example: `43119325-63f5-4e14-9175-84e0e296c527`
    public var serviceId: UUID?
    
    /// Is a human-friendly description of the service
    public var description: String?
}
