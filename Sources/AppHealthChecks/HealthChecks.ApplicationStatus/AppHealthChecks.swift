//
//  AppHealthChecks.swift
//
//
//  Created by Mykola Buhaiov on 30.01.2024.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor

/// Service that provides app health check functionality
public struct AppHealthChecks {
    private let logger = Logger(label: "AppHealthChecks")

    public var status: HealthCheckStatus?

    public var releaseId: String?

    public var notes: [String]?

    public var output: String?

    public var checks: [String: [HealthCheckItem]]?

    public var links: [String: String]?

    public var serviceId: UUID?

    public var description: String?

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
    
    /// Get application health check
    /// - Returns: `HealthCheck`
    public func getAppHealthCheck() -> HealthCheck {
        let healthCheck = HealthCheck(
            status: self.status,
            version: self.getPublicVersion(from: releaseId),
            releaseId: self.releaseId,
            notes: self.notes,
            output: self.output,
            checks: self.checks,
            links: self.links,
            serviceId: self.serviceId,
            description: self.description
        )
        return healthCheck
    }
}
