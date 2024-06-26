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
//  PostgresChecksProtocol.swift
//
//
//  Created by Mykola Buhaiov on 31.01.2024.
//

import Vapor

/// Groups func for get psql health check
public protocol PostgresChecksProtocol {
    /// Get Postgres connection
    /// - Returns: `HealthCheckItem`
    func connection() async -> HealthCheckItem
    
    /// Get psql response time
    /// - Returns: `HealthCheckItem`
    func responseTime() async -> HealthCheckItem
    
    /// Get psql version
    /// - Returns: `String`
    func getVersion() async -> String

    /// Check connection for database
    /// - Returns: `String`
    func checkConnection() async -> String
}
