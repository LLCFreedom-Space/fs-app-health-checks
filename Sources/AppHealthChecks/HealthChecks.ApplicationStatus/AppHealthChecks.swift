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

    /// Get app major version
    /// - Parameter serverVersion: `String`
    /// - Returns: `Int`
    public func getPublicVersion(from version: String) -> Int {
        let components = version.components(separatedBy: ".")
        guard let version = Int(components.first ?? "0") else {
            logger.error("In version: \(version) not found first index")
            return 0
        }
        return version
    }
}
