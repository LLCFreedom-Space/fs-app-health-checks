//
//  HealthCheckStatus.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor

/// Indicates whether the service status is acceptable or not. API publishers SHOULD use following values for the field:
public enum HealthCheckStatus: String {
    /// Unhealthy (acceptable aliases: `error` to support Node's Terminus and `down` for Java's SpringBoot)
    case fail
    /// Healthy, with some concerns
    case warm
    /// Healthy (acceptable aliases: `ok` to support Node's Terminus and `up` for Java's SpringBoot)
    case pass
}

extension HealthCheckStatus: Content {}

extension HealthCheckStatus: CaseIterable {}
