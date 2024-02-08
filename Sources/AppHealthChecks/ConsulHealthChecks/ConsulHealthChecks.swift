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
//  ConsulHealthChecks.swift
//
//
//  Created by Mykola Buhaiov on 07.02.2024.
//

import Vapor

/// Service that provides consul health check functionality
public struct ConsulHealthChecks: ConsulHealthChecksProtocol {
    /// Instance of app as `Application`
    public let app: Application

    /// Get response time from consul
    /// - Returns: `HealthCheckItem`
    public func getResponseTime() async -> HealthCheckItem {
        let url = app.consulConfigData?.url ?? Constants.consulUrl
        let path = app.consulConfigData?.statusPath ?? Constants.consulStatusPath
        let dateNow = Date().timeIntervalSinceReferenceDate
        let status = await getStatus()
        let result = HealthCheckItem(
            componentId: app.consulConfigData?.id,
            componentType: .component,
            observedValue: Date().timeIntervalSinceReferenceDate - dateNow,
            observedUnit: "s",
            status: status == .ok ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: status != .ok ? "\(url + path)" : nil,
            links: nil,
            node: nil
        )
        return result
    }

    /// Get connection status for consul
    /// - Returns: `HTTPResponseStatus.ok` or `HTTPResponseStatus.notFound` depending on whether the status was obtained from the service
    public func getStatus() async -> HTTPResponseStatus {
        var status: HTTPResponseStatus = .notFound
        let url = app.consulConfigData?.url ?? Constants.consulUrl
        let path = app.consulConfigData?.statusPath ?? Constants.consulStatusPath
        let uri = URI(string: url + path)
        do {
            status = try await app.client.get(uri).status
            app.logger.debug("Consul status - \(String(describing: status)). Consul url: \(url), path: \(path)")
        } catch {
            app.logger.error("Get consul status by uri: \(uri) fail with error: \(error)")
        }
        return status
    }

    /// Check with setup options
    /// - Parameters:
    ///   - options: array of `MeasurementType`
    /// - Returns: dictionary `[String: HealthCheckItem]`
    public func checkHealth(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var result = ["": HealthCheckItem()]
        let measurementTypes = Array(Set(options))
        for type in measurementTypes {
            switch type {
            case .responseTime:
                result["\(ComponentName.consul):\(MeasurementType.responseTime)"] = await getResponseTime()
            default:
                break
            }
        }
        return result
    }
}
