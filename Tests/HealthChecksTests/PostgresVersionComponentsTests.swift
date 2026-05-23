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
//  PostgresVersionComponentsTests.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 23.05.2026.
//

@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Postgres version components tests")
struct PostgresVersionComponentsTests {
    @Test("Postgres version components init")
    func healthCheckItemEquatable() async throws {
        let raw = "PostgreSQL 16.1 on x86_64-apple-darwin, compiled by gcc (GCC) 12.3.0, 64-bit"
        let sut = try #require(PostgresVersionComponents(raw: raw))
        
        #expect(sut.dbName == "PostgreSQL")
        #expect(sut.version == "16.1")
        #expect(sut.architecture == "x86_64")
        #expect(sut.osEnvironment == "apple-darwin")
        #expect(sut.compiler == "gcc")
        #expect(sut.compilerBuild == "GCC")
        #expect(sut.compilerVersion == "12.3.0")
        #expect(sut.bitness == "64-bit")
    }

    @Test("Postgres version components init returns nil on invalid input")
    func invalidInput() {
        #expect(PostgresVersionComponents(raw: "") == nil)
        #expect(PostgresVersionComponents(raw: "invalid string") == nil)
        #expect(PostgresVersionComponents(raw: "PostgreSQL 16.1") == nil)
    }
}
