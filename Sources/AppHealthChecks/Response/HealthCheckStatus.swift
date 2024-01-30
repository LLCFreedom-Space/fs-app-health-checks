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
public enum HealthCheckStatus: String, Content, CaseIterable {
    /// Unhealthy (acceptable aliases: `error` to support Node's Terminus and `down` for Java's SpringBoot)
    case fail
    /// Healthy, with some concerns
    case warm
    /// Healthy (acceptable aliases: `ok` to support Node's Terminus and `up` for Java's SpringBoot)
    case pass

    public init(rawValue: Int?) {
        switch rawValue {
        case 0: self = .fail
        case 1: self = .warm
        case 2: self = .pass
        default: self = .fail
        }
    }

    var protoValue: Int {
        switch self {
        case .fail: return 0
        case .warm: return 1
        case .pass: return 2
        }
    }
}
