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
//  PsqlHealthChecksProtocol.swift
//  
//
//  Created by Mykola Buhaiov on 31.01.2024.
//

import Vapor
import FluentPostgresDriver

/// Groups func for get psql health check
public protocol PsqlHealthChecksProtocol {
    /// Get psql health using authorize parameters
    /// - Parameters:
    ///   - hostname: `String`
    ///   - port: `Int`
    ///   - username: `String`
    ///   - password: `String`
    ///   - database: `String`
    ///   - tls: optional `PostgresConnection.Configuration.TLS`
    /// - Returns: `HealthCheckItem`
    func checkConnection(
        hostname: String,
        port: Int,
        username: String,
        password: String,
        database: String,
        tls: PostgresConnection.Configuration.TLS?
    ) async -> HealthCheckItem
    
    /// Get psql health using url connection
    /// - Parameter url: `String`
    /// - Returns: `HealthCheckItem`
    func checkConnection(by url: String) async throws -> HealthCheckItem
    
    /// Check health psql connection
    /// - Returns: `String`
    func checkConnection() async -> String
}
