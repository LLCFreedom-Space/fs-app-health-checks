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

    /// Get version from
    /// - Parameter serverVersion: `String`
    /// - Returns: `Int`
    public func getMajorVersion(from serverVersion: String) -> Int {
        let components = serverVersion.components(separatedBy: ".")
        guard let version = Int(components.first ?? "1") else {
            logger.error("In server version: \(serverVersion) not found first index")
            return 0
        }
        return version
    }
}
