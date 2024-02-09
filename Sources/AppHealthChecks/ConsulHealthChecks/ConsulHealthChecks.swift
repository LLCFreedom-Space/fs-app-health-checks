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

    /// Get connection status for consul
    /// - Returns: `String`
    public func getStatus() async -> String {
        let url = app.consulConfig?.url ?? Constants.consulUrl
        let path = Constants.consulStatusPath
        let uri = URI(string: url + path)
        var headers = HTTPHeaders()
        if let username = app.consulConfig?.username, !username.isEmpty, let password = app.consulConfig?.password, !password.isEmpty {
            headers.basicAuthorization = BasicAuthorization(username: username, password: password)
        }
        let status = try? await app.client.get(uri, headers: headers).status
        return status == .ok ? "Consul response status: \(String(describing: status))" : "ERROR: Consul response was not a successful HTTP status code, by uri: \(uri) response code: \(String(describing: status))"
    }

    /// Check with setup options
    /// - Parameters:
    ///   - options: array of `MeasurementType`
    /// - Returns: dictionary `[String: HealthCheckItem]`
    public func checkHealth(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var result = ["": HealthCheckItem()]
        let measurementTypes = Array(Set(options))
        let dateNow = Date().timeIntervalSinceReferenceDate
        let connectionDescription = await getStatus()
        let responseTime = HealthCheckItem(
            componentId: app.consulConfig?.id,
            componentType: .component,
            observedValue: Date().timeIntervalSinceReferenceDate - dateNow,
            observedUnit: "s",
            status: !connectionDescription.contains("ERROR:") ? .pass : .fail,
            time: app.dateTimeISOFormat.string(from: Date()),
            output: connectionDescription.contains("ERROR:") ? connectionDescription : nil,
            links: nil,
            node: nil
        )
        for type in measurementTypes {
            switch type {
            case .responseTime:
                result["\(ComponentName.consul):\(MeasurementType.responseTime)"] = responseTime
            default:
                break
            }
        }
        return result
    }
}
