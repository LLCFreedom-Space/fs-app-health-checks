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

/// Groups func for get psql request
public protocol PsqlRequestSendable {
    /// Get version description
    /// - Returns: `String`
    func getVersionDescription() async throws -> String

    /// Check connection for database
    /// - Returns: `String`
    func checkConnection(for databaseName: String) async throws -> String
}
