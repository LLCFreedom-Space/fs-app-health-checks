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
//  PsqlRequestSendable.swift
//
//
//  Created by Mykola Buhaiov on 14.03.2024.
//

import Vapor

/// Protocol defining PostgreSQL request operations.
public protocol PsqlRequestSendable: Sendable {
    /// Retrieves the PostgreSQL server version.
    /// - Returns: A string containing the PostgreSQL version
    ///   (for example: `"16.1"`).
    /// - Throws: An error if the version cannot be retrieved.
    func getVersion() async throws -> String
    /// Checks the connection state for a PostgreSQL database.
    /// - Returns: A string describing the connection status
    ///   (for example: `"connected"`).
    /// - Throws: An error if the connection check fails or the database is unreachable.
    func checkConnection() async throws -> String
    /// Retrieves the total number of active PostgreSQL connections.
    /// - Returns: A string representing the number of active connections.
    /// - Throws: An error if the connection statistics cannot be retrieved.
    func getTotalConnection() async throws -> Int
}
