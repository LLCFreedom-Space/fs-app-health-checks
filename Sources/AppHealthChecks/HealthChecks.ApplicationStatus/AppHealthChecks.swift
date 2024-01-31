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
//  AppHealthChecks.swift
//
//
//  Created by Mykola Buhaiov on 30.01.2024.
//

import Vapor

/// Service that provides app health check functionality
public struct AppHealthChecks {
    private let logger = Logger(label: "AppHealthChecks")


    /// Get app major version
    /// - Parameter serverVersion: `String`
    /// - Returns: `Int`
    public func getPublicVersion(from version: String?) -> Int {
        let components = version?.components(separatedBy: ".")
        guard let version = Int(components?.first ?? "0") else {
            logger.error("In version: \(String(describing: version)) not found first index")
            return 0
        }
        return version
    }
    
    /// Get application health
    /// - Parameter appInformation: `AppInformationDTO`
    /// - Returns: `HealthCheck`
    public func getApplicationHealth(from appInformation: AppInformationDTO) -> HealthCheck {
        let healthCheck = HealthCheck(
            status: appInformation.status,
            version: appInformation.version,
            releaseId: appInformation.releaseId,
            notes: appInformation.notes,
            output: appInformation.output,
            checks: appInformation.checks,
            links: appInformation.links,
            serviceId: appInformation.serviceId,
            description: appInformation.description
        )
        return healthCheck
    }
}

public struct AppInformationDTO: Content {
    public var status: HealthCheckStatus?

    public var version: Int?

    public var releaseId: String?

    public var notes: [String]?

    public var output: String?

    public var checks: [String: [HealthCheckItem]]?

    public var links: [String: String]?

    public var serviceId: UUID?

    public var description: String?
}
