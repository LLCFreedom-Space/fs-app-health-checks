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
//  MongoChecksProtocol.swift
//
//
//  Created by Mykola Buhaiov on 15.03.2024.
//

import Vapor
import MongoClient

/// Protocol defining health check operations for MongoDB connections.
public protocol MongoChecksProtocol {
    /// Retrieves the current status of the MongoDB connection.
    ///
    /// - Returns: A `HealthCheckItem` representing the health of the MongoDB connection,
    ///   including status and any relevant metadata.
    func connection() async -> HealthCheckItem
    /// Measures the response time of the MongoDB service.
    ///
    /// - Returns: A `HealthCheckItem` containing the observed response time
    ///   in milliseconds and the corresponding health status.
    func responseTime() async -> HealthCheckItem
    /// Retrieves a string representation of the MongoDB connection state.
    ///
    /// - Returns: A `String` describing the current connection state
    ///   (e.g., `"connected"`, `"connecting"`, `"disconnected"`, `"closed"`).
    func getConnection() async -> String
}
