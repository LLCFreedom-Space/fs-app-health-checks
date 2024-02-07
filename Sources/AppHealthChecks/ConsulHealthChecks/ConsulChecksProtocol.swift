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
//  ConsulChecksProtocol.swift
//
//
//  Created by Mykola Buhaiov on 07.02.2024.
//

import Vapor

/// Groups func for get consul health check
public protocol ConsulChecksProtocol {
    /// Get  consul connection
    /// - Parameters:
    ///   - url: `String` on which the application is running. Example - `http://127.0.0.1:8500`, `https://xmpl-consul.example.com`
    ///   - path: `String` the way to get a status for Consul. Example - `/v1/status/leader`
    /// - Returns: `HealthCheckItem`
    func connection(by url: String, and path: String) async -> HealthCheckItem

    /// Get response time from consul
    /// - Parameters:
    ///   - url: `String` on which the application is running. Example - `http://127.0.0.1:8500`, `https://xmpl-consul.example.com`
    ///   - path: `String` the way to get a status for Consul. Example - `/v1/status/leader`
    /// - Returns: `HealthCheckItem`
    func getResponseTime(by url: String, and path: String) async -> HealthCheckItem

    /// Get connection status for consul
    /// - Parameters:
    ///   - url: `String` on which the application is running. Example - `http://127.0.0.1:8500`, `https://xmpl-consul.example.com`
    ///   - path: `String` the way to get a status for Consul. Example - `/v1/status/leader`
    /// - Returns: `HTTPResponseStatus.ok` or `HTTPResponseStatus.notFound` depending on whether the status was obtained from the service
    func getStatus(by url: String, and path: String) async -> HTTPResponseStatus

    /// Check with setup options
    /// - Parameters:
    ///   - url: `String` on which the application is running. Example - `http://127.0.0.1:8500`, `https://xmpl-consul.example.com`
    ///   - path: `String` the way to get a status for Consul. Example - `/v1/status/leader`
    ///   - options: array of `MeasurementType`
    /// - Returns: dictionary `[String: HealthCheckItem]`
    func checkHealth(by url: String, and path: String, for options: [MeasurementType]) async -> [String: HealthCheckItem]
}
