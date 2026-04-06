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
//  HealthCheck.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//

import Vapor

/// A generic `HealthCheck` data that can be sent in response.
public struct HealthCheck: Content {
    /// Indicates whether the service status is acceptable or not.
    public var status: HealthCheckStatus?
    /// Public version of the service.
    public var version: String?
    /// Release identifier of the service.
    public var releaseId: String?
    /// Array of notes relevant to the current state of health.
    public var notes: [String]?
    /// Raw error output, in case of `fail` or `warn` states.
    public var output: String?
    /// Dictionary of arrays that provides all health check items.
    public var checks: [String: [HealthCheckItem]]?
    /// Dictionary of links for more information.
    public var links: [String: String]?
    /// Unique identifier of the service, within the application scope.
    public var serviceId: UUID?
    /// Human-friendly description of the service.
    public var description: String?
    
    /// Initializes a new `HealthCheck`.
    /// - Parameters:
    ///   - status: Optional health status of the service.
    ///   - version: Optional public version string.
    ///   - releaseId: Optional release identifier.
    ///   - notes: Optional array of notes.
    ///   - output: Optional raw error output.
    ///   - checks: Optional dictionary of health check items.
    ///   - links: Optional dictionary of links.
    ///   - serviceId: Optional service UUID.
    ///   - description: Optional human-friendly description.
    public init(
        status: HealthCheckStatus? = nil,
        version: String? = nil,
        releaseId: String? = nil,
        notes: [String]? = nil,
        output: String? = nil,
        checks: [String: [HealthCheckItem]]? = nil,
        links: [String: String]? = nil,
        serviceId: UUID? = nil,
        description: String? = nil
    ) {
        self.status = status
        self.version = version
        self.releaseId = releaseId
        self.notes = notes
        self.output = output
        self.checks = checks
        self.links = links
        self.serviceId = serviceId
        self.description = description
    }
}

extension HealthCheck {
    // MARK: - Example
    /// Example instance of `HealthCheck` for testing or documentation purposes.
    public static var example: HealthCheck {
        HealthCheck(
            status: .pass,
            version: "1",
            releaseId: "1.0.0",
            notes: ["All systems operational"],
            output: "",
            checks: ["component": [HealthCheckItem.example]],
            links: ["about": "http://api.example.com/about/authz"],
            serviceId: UUID(),
            description: "Health of authz service"
        )
    }
}
