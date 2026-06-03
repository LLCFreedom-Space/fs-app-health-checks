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
//  RedisRequestSendable.swift
//
//
//  Created by Mykola Buhaiov on 14.03.2024.
//

import Vapor
import Redis

/// A protocol for sending requests to a Redis server and receiving responses.
public protocol RedisRequestSendable: Sendable {
    /// Retrieves Redis server version and the number of currently connected clients.
    /// - Returns: A tuple containing:
    ///   - `connectedClients`: The number of currently connected clients.
    ///   - `version`: The Redis server version.
    /// - Throws:
    ///   - Any error thrown while executing the Redis command.
    func getDatabaseHealthMetrics() async throws -> (connectedClients: Int, version: String) 
}
