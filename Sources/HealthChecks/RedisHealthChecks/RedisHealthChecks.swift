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
//  RedisHealthChecks.swift
//  
//
//  Created by Mykola Buhaiov on 21.02.2024.
//

import Vapor
import Redis

/// Service that provides redis health check functionality
public struct RedisHealthChecks: RedisHealthChecksProtocol {
    /// Instance of the application.
    public let app: Application
    /// Initializes a new `RedisHealthChecks` instance.
    /// - Parameter app: The `Application` instance.
    public init(app: Application) {
        self.app = app
    }

    /// Measures the Redis response time.
    /// - Returns: A `HealthCheckItem` containing the observed response time in milliseconds and status.
    public func responseTime() async -> HealthCheckItem {
        let dateNow = Date().timeIntervalSince1970
        async let connectionDescription = checkConnection()
        async let version = getVersion()
        let (connections, resolvedVersion) = await (connectionDescription, version)
        let isConnected = connections.localizedCaseInsensitiveContains("connected")
        return HealthCheckItem(
            componentId: app.redisId,
            componentType: .datastore,
            observedValue: (Date().timeIntervalSince1970 - dateNow) * 1000,
            observedUnit: "ms",
            status: isConnected ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: isConnected ? nil : connections,
            links: nil,
            node: nil,
            version: resolvedVersion
        )
    }

    /// Retrieves the Redis connection status.
    /// - Returns: A `HealthCheckItem` representing the current connection state.
    public func connection() async -> HealthCheckItem {
        async let activeConnections = getActiveConnections()
        async let version = getVersion()
        let (connections, resolvedVersion) = await (activeConnections, version)
        let isFailed = connections == .zero
        let connectionStatus = isFailed ? HealthCheckStatus.fail : HealthCheckStatus.pass
        return HealthCheckItem(
            componentId: app.redisId,
            componentType: .datastore,
            status: connectionStatus,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: isFailed ? connections.description : nil,
            links: nil,
            node: nil,
            version: resolvedVersion
        )
    }
    
    /// Checks the connection for the Redis database.
    /// - Returns: A `String` describing the connection status.
    public func checkConnection() async -> String {
        guard let redisRequest = app.redisRequest else {
            app.logger.error("RedisRequest in app not set. Check your configuration, need to set `app.redisRequest`")
            return "disconnected"
        }
        do {
            let respone = try await redisRequest.getPong()
            guard respone.lowercased() == "pong" else {
                return "disconnected"
            }
            return "connected"
        } catch {
            return "disconnected"
        }
    }
    
    /// Returns the total number of active Redis connections.
    /// - Returns: The number of active Redis connections,
    ///   or `0` if the value cannot be retrieved.
    public func getActiveConnections() async -> Int {
        guard let redisRequest = app.redisRequest else {
            app.logger.error("RedisRequest in app not set. Check your configuration, need to set `app.redisRequest`")
            return .zero
        }
        do {
            return try await redisRequest.getTotalConnection()
        } catch {
            return .zero
        }
    }
    
    /// Returns the Redis server version.
    /// - Returns: The Redis server version string,
    ///   or `"No version"` if unavailable.
    public func getVersion() async -> String {
        guard let redisRequest = app.redisRequest else {
            app.logger.error("RedisRequest in app not set. Check your configuration, need to set `app.redisRequest`")
            return "No version"
        }
        do {
            return try await redisRequest.getVersion()
        } catch {
            return "No version"
        }
    }

    /// Performs health checks based on the provided measurement types.
    /// - Parameter options: An array of `MeasurementType` specifying which checks to perform.
    /// - Returns: A dictionary mapping a string key to the resulting `HealthCheckItem`.
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var results: [String: HealthCheckItem] = [:]
        let measurementTypes = Array(Set(options))
        for type in measurementTypes {
            switch type {
            case .responseTime:
                results["\(ComponentName.redis):\(MeasurementType.responseTime)"] = await responseTime()
            case .connections:
                results["\(ComponentName.redis):\(MeasurementType.connections)"] = await connection()
            default:
                break
            }
        }
        return results
    }
}
