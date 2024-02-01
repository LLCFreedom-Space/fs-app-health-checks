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
//  AppHealthChecks.swift
//
//
//  Created by Mykola Buhaiov on 30.01.2024.
//

import Vapor

/// Service that provides app health check functionality
public struct AppHealthChecks {
    /// Get app major version
    /// - Parameter serverVersion: `String`
    /// - Returns: `Int`
    public func getPublicVersion(from version: String?) -> String? {
        let components = version?.components(separatedBy: ".")
        return components?.first
    }
    
    /// Get health for application
    /// - Parameter app: `Application`
    /// - Returns: `HealthCheck`
    public func getHealth(from app: Application) -> HealthCheck {
        let healthCheck = HealthCheck(
            version: self.getPublicVersion(from: app.releaseId),
            releaseId: app.releaseId,
            serviceId: app.serviceId
        )
        return healthCheck
    }
}
