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

/// A generic `ConsulConfig` data that can be save in storage.
public struct ConsulConfig {
    /// Is a unique identifier of the consul, in the application scope
    /// Example: `43119325-63f5-4e14-9175-84e0e296c527`
    public let id: String

    /// Consul url
    /// Example: `http://127.0.0.1:8500`, `https://xmpl-consul.example.com`
    public let url: String

    /// Path for get consul status
    /// Example: `/v1/status/leader`
    public let statusPath: String
}
