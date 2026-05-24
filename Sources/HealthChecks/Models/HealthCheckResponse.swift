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
//  HealthCheckResponse.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 23.05.2026.
//

import Vapor

/// Represents the complete health check response
/// including system information and dependency statuses.
public struct HealthCheckResponse: Content {
    /// General system and application runtime information.
    public var system: SystemInfo
    /// Health status of external and internal dependencies.
    public var dependencies: [ComponentName: DependenciesHealth]
    
    /// Creates a new `HealthCheckResponse` instance.
    ///
    /// - Parameters:
    ///   - system: System and application information.
    ///   - dependencies: Health statuses of application dependencies.
    init(
        system: SystemInfo,
        dependencies: [ComponentName: DependenciesHealth] = [:]
    ) {
        self.system = system
        self.dependencies = dependencies
    }
}
