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

/// A service providing health check functionality for Consul services.
///
/// This struct conforms to the `ConsulHealthChecksProtocol` and allows for checking the health status
/// of a Consul service by performing various measurements such as response time and connection status.
public struct ConsulHealthChecks: ConsulHealthChecksProtocol {
    /// The instance of the Vapor application as `Application`.
    public let app: Application
    
    /// Performs health checks for specified measurement types.
    ///
    /// - Parameters:
    ///   - options: An array of `MeasurementType` specifying the types of measurements to perform.
    /// - Returns: A dictionary containing health check items for each specified measurement type.
    public func check(for options: [MeasurementType]) async -> [String: HealthCheckItem] {
        var result = ["": HealthCheckItem()]
        let measurementTypes = Array(Set(options))
        let dateNow = Date().timeIntervalSinceReferenceDate
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
    
    /// Retrieves the status of the Consul service.
    ///
    /// - Returns: A `ClientResponse` containing the status of the Consul service.
    func getStatus() async -> ClientResponse {
        guard let url = app.consulConfig?.url else {
            app.logger.error("ERROR: Consul URL is not configured.")
            return ClientResponse()
        }
        let path = Constants.consulStatusPath
        let uri = URI(string: url + path)
        var headers = HTTPHeaders()
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
    
    /// Creates a `HealthCheckItem` based on the response status of the Consul service.
    ///
    /// - Parameter response: The `ClientResponse` containing the status of the Consul service.
    /// - Returns: A `HealthCheckItem` representing the health status of the Consul service based on connection status.
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
    
    /// Creates a `HealthCheckItem` based on the response time of the Consul service.
    ///
    /// - Parameters:
    ///   - response: The `ClientResponse` containing the status of the Consul service.
    ///   - start: The start time for measuring response time.
    /// - Returns: A `HealthCheckItem` representing the response time of the Consul service.
    func responseTime(from response: ClientResponse, _ start: TimeInterval) -> HealthCheckItem {
        return HealthCheckItem(
            componentId: app.consulConfig?.id,
            componentType: .component,
            observedValue: response.status == .ok ? Date().timeIntervalSinceReferenceDate - start : 0,
            observedUnit: "s",
            status: response.status == .ok ? .pass : .fail,
            time: response.status == .ok ? app.dateTimeISOFormat.string(from: Date()) : nil,
            output: response.status != .ok ? "Error response from consul, with http status - \(response.status)" : nil,
            links: nil,
            node: nil
        )
    }
}
