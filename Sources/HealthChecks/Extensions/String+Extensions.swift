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
