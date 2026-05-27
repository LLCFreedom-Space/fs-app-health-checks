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
//  RedisChecksProtocol.swift
//
//
//  Created by Mykola Buhaiov on 21.02.2024.
//

import Vapor

/// Protocol defining Redis health check operations.
public protocol RedisChecksProtocol {
    /// Retrieves the PostgreSQL connection status.
    /// - Returns: A `HealthCheckItem` representing the connection state.
    func connection() async -> HealthCheckItem
    /// Measures the PostgreSQL response time.
    /// - Returns: A `HealthCheckItem` containing the response time metric.
    func responseTime() async -> HealthCheckItem
    /// Checks the connection for the PostgreSQL database.
    /// - Returns: A `String` describing the database connection status, e.g., `"connected"` or `"disconnected"`.
    func checkConnection() async -> String
    /// Retrieves the MongoDB server version.
    /// - Returns: A string containing the MongoDB version
    ///   (for example: `"7.0.4"`).
    /// - Throws: An error if the version information cannot be retrieved.
    func getVersion() async -> String
}
