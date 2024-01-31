// FS Dependency Injection
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
//  HealthCheck.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//

import Vapor

/// A generic `HealthCheck` data that can be sent in response.
public struct HealthCheck: Content {
    /// Indicates whether the service status is acceptable or not
    /// Example: one of the enumeration:`pass` or `warm` or `fail`
    public var status: HealthCheckStatus?

    /// Public version of the service
    /// Example: `1`
    public var version: Int?
    
    /// Release id of the service
    /// Example: `1.0.0`
    public var releaseId: String?
    
    /// Array of notes relevant to current state of health
    /// Example: `["All ok"]`
    public var notes: [String]?
    
    /// Raw error output, in case of `fail` or `warn` states
    /// Example: `"Redis database not exist"`
    public var output: String?
    
    /// Is an object that provides detailed health statuses of additional downstream systems and endpoints which can affect the overall health of the main API.
    public var checks: [String: [HealthCheckItem]]?

    /// Is an object containing link relations and URIs [RFC3986] for external links that MAY contain more information about the health of the endpoint.
    /// Example: `["about": "https://example.com/about/service"]`
    public var links: [String: String]?
    
    /// Is a unique identifier of the service, in the application scope
    /// Example: `43119325-63f5-4e14-9175-84e0e296c527`
    public var serviceId: UUID?
    
    /// Is a human-friendly description of the service
    /// Example: `"This service use for get application health"`
    public var description: String?
}
