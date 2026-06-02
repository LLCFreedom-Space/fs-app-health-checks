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
//  String+ParseRedisInfo.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 01.06.2026.
//

@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing

@Suite("String+ParseRedisInfo tests")
struct ParseRedisInfoTests {
    @Test("Parses valid key-value pairs")
    func validKeyValuePairs() {
        let raw =
        """
        redis_version:7.2.1
        uptime_in_seconds:12345
        connected_clients:3
        """
        let result = raw.parseRedisInfo()
        #expect(result["redis_version"] == "7.2.1")
        #expect(result["uptime_in_seconds"] == "12345")
        #expect(result["connected_clients"] == "3")
    }

    @Test("Skips comment lines starting with #")
    func skipsComments() {
        let raw =
        """
        # Server
        redis_version:7.2.1
        # Clients
        connected_clients:3
        """
        let result = raw.parseRedisInfo()
        #expect(result.keys.contains("redis_version"))
        #expect(result.keys.contains("connected_clients"))
        #expect(result.keys.allSatisfy { !$0.hasPrefix("#") })
    }

    @Test("Skips empty lines")
    func skipsEmptyLines() {
        let raw = "\n\nredis_version:7.2.1\n\n"
        let result = raw.parseRedisInfo()
        #expect(result.count == 1)
        #expect(result["redis_version"] == "7.2.1")
    }

    @Test("Skips lines without colon")
    func skipsLinesWithoutColon() {
        let raw =
        """
        invalid line
        redis_version:7.2.1
        another invalid
        """
        let result = raw.parseRedisInfo()
        #expect(result.count == 1)
        #expect(result["redis_version"] == "7.2.1")
    }

    @Test("Value can contain colons")
    func valueWithColons() {
        let raw = "master_replid:abc:def:123"
        let result = raw.parseRedisInfo()
        #expect(result["master_replid"] == "abc:def:123")
    }

    @Test("Empty string returns empty dictionary")
    func emptyString() {
        let result = "".parseRedisInfo()
        #expect(result.isEmpty)
    }

    @Test("Only comments returns empty dictionary")
    func onlyComments() {
        let raw =
        """
        # Server
        # Clients
        # Memory
        """
        let result = raw.parseRedisInfo()
        #expect(result.isEmpty)
    }

    @Test("Trims whitespace around lines")
    func tripsWhitespace() {
        let raw = "  redis_version:7.2.1  "
        let result = raw.parseRedisInfo()
        #expect(result["redis_version"] == "7.2.1")
    }

    @Test("Parses full Redis INFO block")
    func fullInfoBlock() {
        let raw =
        """
        # Server
        redis_version:7.2.1
        os:Linux 5.15.0 x86_64
        arch_bits:64

        # Clients
        connected_clients:3
        blocked_clients:0

        # Memory
        used_memory:1000000
        """
        let result = raw.parseRedisInfo()
        #expect(result.count == 6)
        #expect(result["redis_version"] == "7.2.1")
        #expect(result["os"] == "Linux 5.15.0 x86_64")
        #expect(result["arch_bits"] == "64")
        #expect(result["connected_clients"] == "3")
        #expect(result["blocked_clients"] == "0")
        #expect(result["used_memory"] == "1000000")
    }
}
