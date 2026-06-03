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
//  HealthChecks.swift
//
//
//  Created by Mykola Buhaiov on 30.01.2024.
//

import Vapor

/// A utility struct for performing general health check operations.
public enum HealthChecks {
    /// Extracts the major version from a full server version string.
    /// - Parameter serverVersion: The full version string of the server (e.g., `"1.2.3"`).
    /// - Returns: The major version as a `String` (e.g., `"1"`), or `nil`
    public static func getPublicVersion(from version: String?) -> String? {
        guard let version = version, version.contains(".") else {
            return nil
        }
        let components = version.components(separatedBy: ".")

        guard let first = components.first, !first.isEmpty, Int(first) != nil else {
            return nil
        }
        return components.first
    }
}
