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
//  SystemInfo.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 23.05.2026.
//

import Vapor

/// Represents basic system and application runtime information
/// used in health check and monitoring responses.
public struct SystemInfo: Content {
    /// Current health check status of the application.
    public var status: HealthCheckStatus = .pass
    /// Application name.
    public var appName: String
    /// Current application version.
    public var appVersion: String
    /// Application uptime in seconds.
    public var uptime: TimeInterval
    /// Number of available CPU cores/processors.
    public var processorCount: Int
    /// Operating system version description.
    public var osVersion: String
    /// Total physical memory size in gigabytes.
    public var physicalMemoryGB: Double
    
    /// Creates a new `SystemInfo` instance.
    ///
    /// - Parameters:
    ///   - status: Current health check status.
    ///   - appName: Application name.
    ///   - appVersion: Application version.
    ///   - uptime: Application uptime in seconds.
    ///   - processorCount: Number of CPU cores/processors.
    ///   - osVersion: Operating system version.
    ///   - physicalMemoryGB: Total physical memory in gigabytes.
    init(
        status: HealthCheckStatus,
        appName: String,
        appVersion: String,
        uptime: TimeInterval,
        processorCount: Int,
        osVersion: String,
        physicalMemoryGB: Double
    ) {
        self.status = status
        self.appName = appName
        self.appVersion = appVersion
        self.uptime = uptime
        self.processorCount = processorCount
        self.osVersion = osVersion
        self.physicalMemoryGB = physicalMemoryGB
    }
}
