//
//  HealthCheck+Extensions.swift
//
//
//  Created by Mykola Buhaiov on 01.02.2024.
//

import Vapor

extension HealthCheck: Equatable {
    /// Check for equal model
    /// - Parameters:
    ///   - lhs: `HealthCheck`
    ///   - rhs: `HealthCheck`
    /// - Returns: `Bool`
    public static func == (lhs: HealthCheck, rhs: HealthCheck) -> Bool {
        return lhs.status == rhs.status &&
        lhs.version == rhs.version &&
        lhs.releaseId == rhs.releaseId &&
        lhs.notes == rhs.notes &&
        lhs.output == rhs.output &&
        lhs.checks == rhs.checks &&
        lhs.links == rhs.links &&
        lhs.serviceId == rhs.serviceId &&
        lhs.description == rhs.description
    }
}
