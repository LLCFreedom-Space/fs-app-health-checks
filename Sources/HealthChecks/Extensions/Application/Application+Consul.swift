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
//  Application+Consul.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 27.03.2026.
//

import Vapor

extension Application {
    // MARK: - Consul

    /// Storage key for Consul configuration.
    private struct ConsulConfigKey: StorageKey {
        typealias Value = ConsulConfig
    }

    /// Consul configuration for the application.
    ///
    /// - Thread-Safety: Should be **immutable** or conform to `Sendable`.
    /// - Example:
    ///   ```swift
    ///   application.consulConfig = ConsulConfig(
    ///       host: "127.0.0.1",
    ///       port: 8500,
    ///       token: "secret-token"
    ///   )
    ///   ```
    public var consulConfig: ConsulConfig? {
        get { storage[ConsulConfigKey.self] }
        set { storage[ConsulConfigKey.self] = newValue }
    }
}
