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

    /// Sends a ping request to the Redis server.
    /// This is used to verify connectivity with the Redis instance.
    /// - Returns: A string response from Redis, typically `"PONG"` if successful.
    /// - Throws: `HealthCheckError` if the ping command fails or the connection is unavailable.
    public func getPong() async throws -> String {
        try? await app.asyncBoot()
        do {
            return try await app.redis.ping().get()
        } catch {
            app.logger.error("Redis ping failed.", error: error)
            throw HealthCheckError(.connectionLost, reason: .queryExecutionFailed)
        }
    }

    /// Retrieves the Redis server version.
    /// This method queries `INFO server` and extracts the `redis_version` field.
    /// - Returns: Redis version string (e.g. `"7.2.1"`).
    /// - Throws: `HealthCheckError` if the command fails, response is invalid,
    ///           or version field is missing.
    public func getVersion() async throws -> String {
        try? await app.asyncBoot()

        do {
            let buffer = ByteBufferAllocator().buffer(string: "server")
            let response = try await app.redis.send(
                command: "INFO",
                with: [RESPValue.bulkString(buffer)]
            )

            guard let string = response.string else {
                app.logger.error("Redis INFO server response could not be converted to a string.")
                throw HealthCheckError(.emptyResponse, reason: .redisInvalidResponse)
            }

            let dict = string.parseRedisInfo()

            guard let version = dict["redis_version"] else {
                app.logger.error(
                    "Redis INFO server response missing 'redis_version' field.",
                    metadata: ["availableKeys": "\(dict.keys.joined(separator: ", "))"]
                )
                throw HealthCheckError(.emptyResponse, reason: .redisMissingField)
            }

            return version
        } catch let error as HealthCheckError {
            throw error
        } catch {
            app.logger.error("Failed to retrieve Redis version.", error: error)
            throw HealthCheckError(.queryFailed, reason: .queryExecutionFailed)
        }
    }

    /// Retrieves the number of currently connected Redis clients.
    /// This method queries `INFO clients` and extracts `connected_clients`.
    /// - Returns: Number of connected Redis clients as a string.
    /// - Throws: `HealthCheckError` if the command fails, response is invalid,
    ///           or the required field is missing.
    public func getTotalConnection() async throws -> Int {
        try? await app.asyncBoot()

        do {
            let buffer = ByteBufferAllocator().buffer(string: "clients")
            let response = try await app.redis.send(
                command: "INFO",
                with: [RESPValue.bulkString(buffer)]
            )

            guard let string = response.string else {
                app.logger.error("Redis INFO clients response could not be converted to a string.")
                throw HealthCheckError(.emptyResponse, reason: .redisInvalidResponse)
            }

            let dict = string.parseRedisInfo()

            guard let clients = dict["connected_clients"], let clientsInt = Int(clients) else {
                app.logger.error(
                    "Redis INFO clients response missing 'connected_clients' field.",
                    metadata: ["availableKeys": "\(dict.keys.joined(separator: ", "))"]
                )
                throw HealthCheckError(.emptyResponse, reason: .redisMissingField)
            }

            return clientsInt
        } catch let error as HealthCheckError {
            throw error
        } catch {
            app.logger.error("Failed to retrieve Redis total connections.", error: error)
            throw HealthCheckError(.queryFailed, reason: .queryExecutionFailed)
        }
    }
}
