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
//  ConsulConfig.swift
//
//
//  Created by Mykola Buhaiov on 08.02.2024.
//

import Vapor

/// Represents configuration details for connecting to a Consul server.
public struct ConsulConfig {
    /// A unique identifier for this Consul configuration within your application.
    /// This ID is not related to Consul itself and can be used for internal reference.
    /// Example: "43119325-63f5-4e14-9175-84e0e296c527"
    public let id: String
    
    /// The URL of the Consul server to connect to.
    /// Example: "http://127.0.0.1:8500", "https://xmpl-consul.example.com"
    public let url: String
    
    /// The username for authenticating with Consul (optional).
    /// Example: "username"
    public let username: String?
    
    /// The password for authenticating with Consul (optional).
    /// Example: "password"
    public let password: String?
    
    /// Initializes a `ConsulConfig` with the specified details.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for this configuration.
    ///   - url: The URL of the Consul server.
    ///   - username: The username for authentication (optional).
    ///   - password: The password for authentication (optional).
    public init(
        id: String,
        url: String,
        username: String? = nil,
        password: String? = nil
    ) {
        self.id = id
        self.url = url
        self.username = username
        self.password = password
    }
}
