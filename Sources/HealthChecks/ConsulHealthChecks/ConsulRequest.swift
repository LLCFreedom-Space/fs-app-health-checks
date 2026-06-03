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
//  ConsulRequest.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 29.05.2026.
//

import Vapor

/// Concrete implementation of `ConsulRequestSendable` for interacting with Consul.
public struct ConsulRequest: ConsulRequestSendable {
    /// Instance of app as `Application`
    public let app: Application
    /// Initializer for MongoRequest
    /// - Parameter app: `Application`
    public init(app: Application) {
        self.app = app
    }
    
    public func checkConnection() async throws {
        guard let url = app.consulConfig?.url, !url.isEmpty else {
            throw HealthCheckError.urlNotConfigured
        }
        let uri = URI(string: url + Constants.consulStatusPath)
        let response = try await app.client.get(uri)
        guard response.status == .ok else {
            throw HealthCheckError.unexpectedStatusCode
        }
    }
}
