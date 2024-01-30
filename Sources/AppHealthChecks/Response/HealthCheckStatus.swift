//
//  HealthCheckStatus.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor

/// Indicates whether the service status is acceptable or not
public enum HealthCheckStatus: String {
    /// Unhealthy
    case fail
    /// Healthy, with some concerns
    case warm
    /// Healthy, without concerns
    case pass
}

extension HealthCheckStatus: Content {}

extension HealthCheckStatus: CaseIterable {}
