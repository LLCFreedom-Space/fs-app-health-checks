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
    /// Retrieves the PostgreSQL version description.
    /// - Returns: A `String` containing the PostgreSQL version.
    func getVersionDescription() async throws -> String
    /// Checks the connection state for a specific PostgreSQL database.
    /// - Parameter databaseName: The name of the PostgreSQL database to check.
    /// - Returns: A `String` describing the connection status, e.g., `"active"` or an error message.
    func checkConnection(for databaseName: String) async throws -> String
}
