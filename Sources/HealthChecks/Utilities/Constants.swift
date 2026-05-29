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
//  Constants.swift
//
//
//  Created by Mykola Buhaiov on 06.02.2024.
//

import Vapor

/// A collection of configuration constants used throughout the application.
public enum Constants {
    /// Default date format used for timestamps in health checks and logs.
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    /// Default URL for connecting to a local Consul server.
    static let consulUrl = "http://127.0.0.1:8500"
    /// Path for retrieving Consul leader status.
    static let consulStatusPath = "/v1/status/leader"
    /// Path for retrieving Consul leader health.
    static let consulHealthPath = "/v1/health/service/consul"
    /// Path for retrieving the health state of any service.
    static let consulHealthAnyPath = "/v1/health/state/any"
    /// Path for retrieving agent-level information.
    static let consulSelfPath = "/v1/agent/self"
}
