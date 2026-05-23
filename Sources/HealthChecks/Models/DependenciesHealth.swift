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
//  DependenciesHealth.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 23.05.2026.
//

import Vapor

/// Represents the health status information
/// for an application dependency or external service.
public struct DependenciesHealth: Content {
    /// Current health check status of the dependency.
    public var status: HealthCheckStatus
    /// Optional dependency version information.
    public var version: String?
    /// Optional error description if the dependency check failed.
    public var error: String?
    
    /// Creates a new `DependenciesHealth` instance.
    ///
    /// - Parameters:
    ///   - status: Current dependency health status.
    ///   - version: Optional dependency version.
    ///   - error: Optional error description.
    init(
        status: HealthCheckStatus,
        version: String? = nil,
        error: String? = nil
    ) {
        self.status = status
        self.version = version
        self.error = error
    }
}
