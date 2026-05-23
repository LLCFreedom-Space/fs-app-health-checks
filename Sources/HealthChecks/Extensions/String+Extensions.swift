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
//  String+Extensions.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 22.05.2026.
//

import Vapor

extension String {
    /// Parses Redis `INFO` response into a dictionary.
    /// The Redis INFO format is a newline-separated key-value text:
    /// - Lines starting with `#` are comments and ignored
    /// - Each valid line has format: `key:value`
    /// - Key is taken from start of line up to `:`
    /// - Value is taken from `:` to end of line
    /// - Returns: Dictionary where keys are Redis fields and values are raw string values.
    func parseRedisInfo() -> [String: String] {
        var result: [String: String] = [:]
        let lines = self.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            // Skip comments and empty lines
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else {
                continue
            }
            guard let colonIndex = trimmed.firstIndex(of: ":") else {
                continue
            }
            let key = String(trimmed[..<colonIndex])
            let valueStart = trimmed.index(after: colonIndex)
            let value = String(trimmed[valueStart...])

            result[key] = value
        }
        return result
    }
}
