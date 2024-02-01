//
//  HealthCheckItem+Extensions.swift
//  
//
//  Created by Mykola Buhaiov on 01.02.2024.
//

import Vapor

extension HealthCheckItem: Equatable {
    /// Check for equal model
    /// - Parameters:
    ///   - lhs: `HealthCheckItem`
    ///   - rhs: `HealthCheckItem`
    /// - Returns: `Bool`
    public static func == (lhs: HealthCheckItem, rhs: HealthCheckItem) -> Bool {
        return lhs.componentId == rhs.componentId &&
        lhs.componentType == rhs.componentType &&
        lhs.observedValue == rhs.observedValue &&
        lhs.observedUnit == rhs.observedUnit &&
        lhs.status == rhs.status &&
        lhs.affectedEndpoints == rhs.affectedEndpoints &&
        lhs.time == rhs.time &&
        lhs.output == rhs.output &&
        lhs.links == rhs.links &&
        lhs.node == rhs.node
    }
}
