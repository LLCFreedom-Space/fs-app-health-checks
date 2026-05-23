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
//  PostgresVersionComponents.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 23.05.2026.
//

import Vapor

/// A structured representation of metadata extracted from a raw PostgreSQL version string.
/// Populated by parsing the output of `SELECT version()`, which returns a single string
/// containing the database name, version, build environment, and compiler details.
/// Example raw input:
/// ```
/// PostgreSQL 16.1 on x86_64-apple-darwin, compiled by gcc (GCC) 12.3.0, 64-bit
/// ```
public struct PostgresVersionComponents {
    /// Database engine name (e.g. `"PostgreSQL"`).
    public var dbName: String
    /// Semantic version of the database engine (e.g. `"16.1"`).
    public var version: String
    /// CPU architecture the binary was compiled for (e.g. `"x86_64"`).
    public var architecture: String
    /// Operating system environment reported by the build (e.g. `"apple-darwin"`).
    public var osEnvironment: String
    /// Compiler used to build the database binary (e.g. `"gcc"`).
    public var compiler: String
    /// Compiler-specific build descriptor or flags (e.g. `"GCC"`).
    public var compilerBuild: String
    /// Version string of the compiler (e.g. `"12.3.0"`).
    public var compilerVersion: String
    /// System bitness of the running binary (e.g. `"64-bit"`).
    public var bitness: String
}

extension PostgresVersionComponents {
    /// Creates a `PostgresVersionComponents` instance by parsing a raw PostgreSQL version string.
    /// Uses a regular expression with named capture groups to extract structured metadata
    /// from the output of `SELECT version()`.
    /// Expected format:
    /// ```
    /// PostgreSQL 16.1 on x86_64-apple-darwin, compiled by gcc (GCC) 12.3.0, 64-bit
    /// ```
    /// - Parameter raw: The raw version string returned by PostgreSQL.
    /// - Returns: A fully populated `PostgresVersionComponents` if the string matches
    ///            the expected format; `nil` otherwise.
    public init?(raw: String) {
        let pattern = /^(?<db>[a-zA-Z]+)\s+(?<ver>[\d.]+)\s+on\s+(?<arch>[a-zA-Z0-9_]+)-(?<os>[^,]+),\s+compiled\s+by\s+(?<compiler>[^(]+)\((?<build>[^)]+)\)\s+(?<compVer>[^,]+),\s+(?<bitness>.+)$/

        guard let match = raw.wholeMatch(of: pattern) else { return nil }

        self.dbName = String(match.output.db)
        self.version = String(match.output.ver)
        self.architecture = String(match.output.arch)
        self.osEnvironment = String(match.output.os)
        self.compiler = match.output.compiler.trimmingCharacters(in: .whitespaces)
        self.compilerBuild = String(match.output.build)
        self.compilerVersion = String(match.output.compVer)
        self.bitness = String(match.output.bitness)
    }
}
