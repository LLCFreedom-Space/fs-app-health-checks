//
//  MeasurementType.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor

/// Name of the measurement type (a data point type) that the status is reported for.
public enum MeasurementType: String, Content, CaseIterable {
    case utilization
    case responseTime
    case connections
    case uptime
}
