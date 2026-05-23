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

    /// Retrieves the Redis connection status.
    /// - Returns: A `HealthCheckItem` representing the current connection state.
    public func connection() async -> HealthCheckItem {
        let response = await checkConnection()
        let result = HealthCheckItem(
            componentId: app.redisId,
            componentType: .datastore,
            status: response.lowercased().contains("connected") ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: !response.lowercased().contains("connected") ? response : nil,
            links: nil,
            node: nil
        )
        return result
    }

    /// Measures the Redis response time.
    /// - Returns: A `HealthCheckItem` containing the observed response time in milliseconds and status.
    public func responseTime() async -> HealthCheckItem {
        let dateNow = Date().timeIntervalSince1970
        let connectionDescription = await getActiveConnections()
        let connectionStatus = connectionDescription == .zero ? HealthCheckStatus.fail : HealthCheckStatus.pass
        let result = HealthCheckItem(
            componentId: app.redisId,
            componentType: .datastore,
            observedValue: (Date().timeIntervalSince1970 - dateNow) * 1000,
            observedUnit: "ms",
            status: connectionStatus,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: connectionDescription == .zero ? nil : connectionDescription.description,
            links: nil,
            node: nil
        )
        return result
    }
    
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

    /// Performs health checks based on the provided measurement types.
    /// - Parameter options: An array of `MeasurementType` specifying which checks to perform.
    /// - Returns: A dictionary mapping a string key to the resulting `HealthCheckItem`.
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var result = ["": HealthCheckItem()]
        let measurementTypes = Array(Set(options))
        for type in measurementTypes {
            switch type {
            case .responseTime:
                result["\(ComponentName.redis):\(MeasurementType.responseTime)"] = await responseTime()
            case .connections:
                result["\(ComponentName.redis):\(MeasurementType.connections)"] = await connection()
            default:
                break
            }
        }
        return result
    }
}
