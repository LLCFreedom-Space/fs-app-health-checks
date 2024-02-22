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
import Fluent
import Redis

/// Service that provides redis health check functionality
public struct RedisHealthChecks: RedisHealthChecksProtocol {
    /// Instance of app as `Application`
    public let app: Application

    /// Get  redis connection
    /// - Returns: `HealthCheckItem`
    public func connection() async -> HealthCheckItem {
        let dateNow = Date().timeIntervalSinceReferenceDate
        let response = await pong()
        let result = HealthCheckItem(
            componentId: app.redisId,
            componentType: .datastore,
            observedValue: Date().timeIntervalSinceReferenceDate - dateNow,
            observedUnit: "s",
            status: response.lowercased().contains("pong") ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: !response.lowercased().contains("pong") ? response : nil,
            links: nil,
            node: nil
        )
        return result
    }

    /// Get response time from redis
    /// - Returns: `HealthCheckItem`
    public func getResponseTime() async -> HealthCheckItem {
        let dateNow = Date().timeIntervalSinceReferenceDate
        let response = await pong()
        let result = HealthCheckItem(
            componentId: app.redisId,
            componentType: .datastore,
            observedValue: Date().timeIntervalSinceReferenceDate - dateNow,
            observedUnit: "s",
            status: response.lowercased().contains("pong") ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: !response.lowercased().contains("pong") ? response : nil,
            links: nil,
            node: nil
        )
        return result
    }

    /// Get pong from redis
    /// - Returns: `String`
    public func pong() async -> String {
        let result = try? await app.redis.ping().get()
        var connectionDescription = "ERROR: No connect to Redis database"
        if let result, result.lowercased().contains("pong") {
            connectionDescription = result
        }
        return connectionDescription
    }

    /// Check with setup options
    /// - Parameter options: array of `MeasurementType`
    /// - Returns: dictionary `[String: HealthCheckItem]`
    public func checkHealth(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var result = ["": HealthCheckItem()]
        let measurementTypes = Array(Set(options))
        for type in measurementTypes {
            switch type {
            case .responseTime:
                result["\(ComponentName.redis):\(MeasurementType.responseTime)"] = await getResponseTime()
            case .connections:
                result["\(ComponentName.redis):\(MeasurementType.connections)"] = await connection()
            default:
                break
            }
        }
        return result
    }
}
