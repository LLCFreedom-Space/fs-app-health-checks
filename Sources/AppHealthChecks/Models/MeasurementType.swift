// FS App Health Checks
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
//  MeasurementType.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//

import Vapor

/// Name of the measurement type (a data point type) that the status is reported for
public enum MeasurementType: String {
    /// An act or instance of making practical or profitable use of something
    case utilization
    /// The time lag between an electronic input and the output signal which depends upon the value of passive components used
    case responseTime
    /// The state of being connected
    case connections
    /// Uptime is a measure of system reliability, expressed as the percentage of time a machine
    case uptime
}

extension MeasurementType: Content {}

extension MeasurementType: CaseIterable {}
