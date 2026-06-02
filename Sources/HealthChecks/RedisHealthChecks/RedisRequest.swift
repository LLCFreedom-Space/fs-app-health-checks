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
public struct RedisRequest: RedisRequestSendable {
    /// Instance of the Vapor application.
    public let app: Application
    /// Initializes a new `RedisRequest` instance.
    /// - Parameter app: The Vapor `Application` instance.
    public init(app: Application) {
        self.app = app
    }

    /// Retrieves Redis server version and the number of currently connected clients.
    /// - Returns: A tuple containing:
    ///   - `connectedClients`: The number of currently connected clients.
    ///   - `version`: The Redis server version.
    /// - Throws:
    ///   - `HealthCheckError.responseDecodingFailed` if the Redis response cannot be decoded
    ///     or the required fields are missing.
    ///   - Any error thrown while executing the Redis command.
    public func getDatabaseHealthMetrics() async throws -> (connectedClients: Int, version: String) {
        try? await app.asyncBoot()

        let command = ByteBufferAllocator().buffer(string: "INFO")
        let response = try await app.redis.send(
            command: "INFO",
            with: [RESPValue.bulkString(command)]
        )

        guard let string = response.string else {
            app.logger.error("-------------\(response)")
            throw HealthCheckError.responseDecodingFailed
        }
        let dict = string.parseRedisInfo()

        guard
            let version = dict["redis_version"],
            let clientsString = dict["connected_clients"],
            let connectedClients = Int(clientsString)
        else {
            throw HealthCheckError.responseDecodingFailed
        }
        return (connectedClients, version)
    }
}
