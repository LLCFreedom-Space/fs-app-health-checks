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

/// Service that provides Consul health check functionality
public struct ConsulHealthChecks: ConsulHealthChecksProtocol {
    /// Instance of the application as `Application`
    public let app: Application
    
    /// Check with setup options
    /// - Parameters:
    ///   - options: array of `MeasurementType`
    /// - Returns: dictionary `[String: HealthCheckItem]`
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
    
    /// Get response for consul
    /// - Returns: `ClientResponse`
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
    
    /// Get status for consul
    /// - Parameter response: `ClientResponse`
    /// - Returns: `HealthCheckItem`
    func status(_ response: ClientResponse) -> HealthCheckItem {
        guard let url = app.consulConfig?.url else {
            return HealthCheckItem(
                componentId: app.consulConfig?.id,
                componentType: .component,
                status: .fail,
                output: "Consul URL is not configured."
            )
        }
        let path = Constants.consulStatusPath
        return HealthCheckItem(
            componentId: app.consulConfig?.id,
            componentType: .component,
            status: response.status == .ok ? .pass : .fail,
            time: response.status == .ok ?  app.dateTimeISOFormat.string(from: Date()) : nil,
            output: response.status != .ok ? "Error response from uri - \(url + path), with http status - \(response.status)" : nil,
            links: nil,
            node: nil
        )
    }
    
    /// Get response time for consul
    /// - Parameters:
    ///   - response: `ClientResponse`
    ///   - start: `TimeInterval`
    /// - Returns: `HealthCheckItem`
    func responseTime(from response: ClientResponse, _ start: TimeInterval) -> HealthCheckItem {
        guard let url = app.consulConfig?.url else {
            return HealthCheckItem(
                componentId: app.consulConfig?.id,
                componentType: .component,
                status: .fail,
                output: "Consul URL is not configured."
            )
        }
        let path = Constants.consulStatusPath
        return HealthCheckItem(
            componentId: app.consulConfig?.id,
            componentType: .component,
            observedValue: response.status == .ok ? Date().timeIntervalSinceReferenceDate - start : 0,
            observedUnit: "s",
            status: response.status == .ok ? .pass : .fail,
            time: response.status == .ok ? app.dateTimeISOFormat.string(from: Date()) : nil,
            output: response.status != .ok ? "Error response from uri - \(url + path), with http status - \(response.status)" : nil,
            links: nil,
            node: nil
        )
    }
}
