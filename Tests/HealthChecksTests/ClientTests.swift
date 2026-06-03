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
//  ClientTests.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 02.06.2026.
//

@testable import HealthChecksMocks
@testable import HealthChecks
import VaporTesting
import Testing

@Suite("Client tests")
struct ClientTests {
    @Test("Delegating returns same instance")
    func delegatingReturnsSameInstance() {
        let firstLoop = EmbeddedEventLoop()
        let secondLoop = EmbeddedEventLoop()
        
        let client = MockClient(
            eventLoop: firstLoop,
            clientResponse: ClientResponse(status: .ok)
        )
        let delegated = client.delegating(to: secondLoop) as? MockClient
        #expect(delegated?.eventLoop === secondLoop)
    }
}
