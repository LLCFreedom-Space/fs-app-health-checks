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
//  MongoRequest.swift
//
//
//  Created by Mykola Buhaiov on 15.03.2024.
//

import Vapor
import MongoCore
import MongoClient

public final class MongoRequest: MongoRequestSendable {
    /// Instance of app as `Application`
    public let app: Application

    /// Initializer for MongoRequest
    /// - Parameter app: `Application`
    public init(app: Application) {
        self.app = app
    }

    // WARNING: - This method create new connection every time, when you use it
    /// Get mongo connection
    /// - Parameter url: `String`
    /// - Returns: `String`
    public func getConnection(by url: String) async throws -> String {
        await app.mongoCluster?.disconnect()
        let mongoCluster = try? MongoCluster(lazyConnectingTo: ConnectionSettings(url))
        let connection = "\(mongoCluster?.connectionState ?? .disconnected)"
        await app.mongoCluster?.disconnect()
        return connection
    }
}
