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

/// Configuration object for connecting to a Consul service.
///
/// `ConsulConfig` contains all necessary parameters required to establish
/// a connection with a Consul server, including optional authentication credentials.
///
/// - Overview:
/// This structure is used to configure how your application communicates
/// with Consul for service discovery, health checks, or key-value storage.
///
/// - Concurrency:
/// Conforms to `Sendable`, making it safe to use across concurrent contexts.
public struct ConsulConfig: Sendable {
    /// A unique identifier for this Consul configuration within your application.
    ///
    /// This identifier is intended for internal use only and is not related
    /// to any identifier within Consul itself.
    ///
    /// - Example: `"43119325-63f5-4e14-9175-84e0e296c527"`
    public var id: String
    /// The URL of the Consul server to connect to.
    ///
    /// This should include the protocol (`http` or `https`) and the host.
    ///
    /// - Examples:
    ///   - `"http://127.0.0.1:8500"`
    ///   - `"https://xmpl-consul.example.com"`
    public var url: String
    /// The username for authenticating with Consul (optional).
    ///
    /// Provide this value if your Consul instance requires basic authentication.
    ///
    /// - Example: `"username"`
    public var username: String?
    /// The password for authenticating with Consul (optional).
    ///
    /// Used together with `username` when authentication is required.
    ///
    /// - Example: `"password"`
    public var password: String?
    /// The token for authenticating with Consul (optional).
    ///
    /// Used together with `username` when authentication is required.
    ///
    /// - Example: `"token"`
    public var token: String?

    /// Creates a new `ConsulConfig` instance.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this configuration (application-level).
    ///   - url: The URL of the Consul server.
    ///   - username: Optional username for authentication.
    ///   - password: Optional password for authentication.
    ///   - token: Optional token for authentication.
    ///
    /// - Note:
    /// If authentication is not required, both `username` and `password` or only `token`
    /// can be left as `nil`.
    public init(
        id: String,
        url: String,
        username: String? = nil,
        password: String? = nil,
        token: String? = nil
    ) {
        self.id = id
        self.url = url
        self.username = username
        self.password = password
        self.token = token
    }
}
