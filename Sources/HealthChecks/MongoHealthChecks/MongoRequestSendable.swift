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
/// Conforming types are responsible for providing MongoDB connection information
/// in an asynchronous and concurrency-safe manner.
public protocol MongoRequestSendable: Sendable {
    /// Retrieves the connection description for a given MongoDB URL.
    /// - Parameter url: The MongoDB connection URL.
    /// - Returns: A `String` describing the connection status, e.g., `"connected"` or `"disconnected"`.
    func getConnection(by url: String) async -> String
}
