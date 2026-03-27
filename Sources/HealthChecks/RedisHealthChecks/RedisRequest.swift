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
//  RedisRequest.swift
//  
//
//  Created by Mykola Buhaiov on 14.03.2024.
//

import Vapor
import Redis

/// A concrete implementation of `RedisRequestSendable` for interacting with Redis.
///
/// `RedisRequest` provides a simple way to perform Redis operations,
/// such as sending a ping request to verify connectivity.
///
/// - Properties:
///   - `app`: The Vapor `Application` instance used to access the Redis client.
///
/// - Note:
/// This implementation uses the application's Redis configuration
/// and client to execute commands.
public struct RedisRequest: RedisRequestSendable {
    /// Instance of the Vapor application.
    public let app: Application
    /// Initializes a new `RedisRequest` instance.
    ///
    /// - Parameter app: The Vapor `Application` instance.
    public init(app: Application) {
        self.app = app
    }

    /// Sends a ping request to the Redis server and returns the response.
    ///
    /// - Returns: A `String` response from Redis, typically `"PONG"` if successful.
    ///
    /// - Throws: An error if the request fails or the Redis server is unavailable.
    public func getPong() async throws -> String {
        try await app.redis.ping().get()
    }
}
