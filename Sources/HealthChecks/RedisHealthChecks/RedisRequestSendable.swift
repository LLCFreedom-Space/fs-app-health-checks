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
    /// Sends a ping request to the Redis server.
    /// - Returns: A string response from Redis (typically `"PONG"`).
    /// - Throws: An error if the Redis server is unreachable or the request fails.
    func getPong() async throws -> String
    /// Retrieves the Redis server version.
    /// - Returns: A string representing the Redis version (e.g. `"7.2.4"`).
    /// - Throws: An error if the version information cannot be retrieved.
    func getVersion() async throws -> String
    /// Retrieves the total number of active Redis connections.
    /// - Returns: A string representing the number of active connections.
    /// - Throws: An error if connection statistics cannot be retrieved.
    func getTotalConnection() async throws -> Int
}
