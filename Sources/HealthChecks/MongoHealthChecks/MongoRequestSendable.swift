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
//  MongoRequestSendable.swift
//
//
//  Created by Mykola Buhaiov on 15.03.2024.
//

import Vapor

/// Protocol defining a sendable MongoDB request handler.
public protocol MongoRequestSendable: Sendable {
    /// Retrieves the number of currently active connections
    /// to the MongoDB instance.
    /// - Returns: Total count of active MongoDB connections.
    /// - Throws: An error if the connection statistics cannot be retrieved.
    func getTotalConnection() async throws -> Int
    /// Checks the current connection state for the MongoDB database.
    /// - Returns: A string describing the connection state
    ///   (for example: `"connected"`).
    /// - Throws: An error if the connection check fails
    ///   or the database is unreachable.
    func checkConnection() async throws -> String
    /// Retrieves the MongoDB server version.
    /// - Returns: A string containing the MongoDB version
    ///   (for example: `"7.0.4"`).
    /// - Throws: An error if the version information cannot be retrieved.
    func getVersion() async throws -> String
}
