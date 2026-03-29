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

/// Provides health check functionality for a Consul service.
public struct ConsulHealthChecks: ConsulHealthChecksProtocol {
    /// The instance of the Vapor application.
    public let app: Application
    /// Initializes a new `ConsulHealthChecks` instance.
    ///
    /// - Parameter app: The Vapor `Application` instance.
    public init(app: Application) {
        self.app = app
    }

    /// Performs health checks for the specified measurement types.
    ///
    /// - Parameter options: An array of `MeasurementType` values specifying
    ///   which health checks to perform (e.g., response time, connections).
    /// - Returns: `[String: HealthCheckItem]`
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var result = ["": HealthCheckItem()]
        let measurementTypes = Array(Set(options))
        let dateNow = Date().timeIntervalSince1970
        let response = await getStatus()
        for type in measurementTypes {
            switch type {
            case .responseTime:
                result["\(ComponentName.consul):\(MeasurementType.responseTime)"] = responseTime(from: response, dateNow)
            case .connections:
                result["\(ComponentName.consul):\(MeasurementType.connections)"] = status(response)
            default:
                break
            }
        }
        result[""] = nil
        return result
    }

    /// Retrieves the current status of the Consul service.
    ///
    /// This method performs an HTTP GET request to the Consul status endpoint.
    /// It applies basic authentication if `username` and `password` are configured.
    ///
    /// - Returns: `ClientResponse`
    func getStatus() async -> ClientResponse {
        guard let url = app.consulConfig?.url else {
            app.logger.error("ERROR: Consul URL is not configured.")
            return ClientResponse()
        }
        let path = Constants.consulStatusPath
        let uri = URI(string: url + path)
        var headers = HTTPHeaders()
        if let token = app.consulConfig?.token {
            headers.bearerAuthorization = BearerAuthorization(token: token)
        }
        if let username = app.consulConfig?.username,
           !username.isEmpty,
           let password = app.consulConfig?.password,
           !password.isEmpty {
            headers.basicAuthorization = BasicAuthorization(username: username, password: password)
        }
        do {
            return try await app.client.get(uri, headers: headers)
        } catch {
            app.logger.error("ERROR: Send request by uri - \(uri) and method get fail with error - \(error)")
            return ClientResponse()
        }
    }

    /// Generates a `HealthCheckItem` based on the connection status of the Consul service.
    ///
    /// - Parameter response: The `ClientResponse` from the Consul status request.
    /// - Returns: `HealthCheckItem`
    func status(_ response: ClientResponse) -> HealthCheckItem {
        return HealthCheckItem(
            componentId: app.consulConfig?.id,
            componentType: .component,
            status: response.status == .ok ? .pass : .fail,
            time: response.status == .ok ? app.dateTimeISOFormat.string(from: Date()) : nil,
            output: response.status != .ok ? "Error response from consul, with http status - \(response.status)" : nil,
            links: nil,
            node: nil
        )
    }

    /// Generates a `HealthCheckItem` representing the response time of the Consul service.
    ///
    /// - Parameters:
    ///   - response: The `ClientResponse` from the Consul status request.
    ///   - start: The start time used to calculate response duration.
    /// - Returns: `HealthCheckItem`
    func responseTime(from response: ClientResponse, _ start: TimeInterval) -> HealthCheckItem {
        return HealthCheckItem(
            componentId: app.consulConfig?.id,
            componentType: .component,
            observedValue: response.status == .ok ? (Date().timeIntervalSince1970 - start) * 1000 : 0,
            observedUnit: "ms",
            status: response.status == .ok ? .pass : .fail,
            time: response.status == .ok ? app.dateTimeISOFormat.string(from: Date()) : nil,
            output: response.status != .ok ? "Error response from consul, with http status - \(response.status)" : nil,
            links: nil,
            node: nil
        )
    }
}
