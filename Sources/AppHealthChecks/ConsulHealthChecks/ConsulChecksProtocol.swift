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
//  ConsulChecksProtocol.swift
//
//
//  Created by Mykola Buhaiov on 07.02.2024.
//

import Vapor

/// Groups func for get consul health check
public protocol ConsulChecksProtocol {
    /// Get response for consul
    /// - Returns: `ClientResponse`
    func getStatus() async -> ClientResponse

    /// Get status for consul
    /// - Parameter response: `ClientResponse`
    /// - Returns: `HealthCheckItem`
    func status(_ response: ClientResponse) -> HealthCheckItem

    /// Get response time for consul
    /// - Parameters:
    ///   - response: `ClientResponse`
    ///   - start: `TimeInterval`
    /// - Returns: `HealthCheckItem`
    func responseTime(from response: ClientResponse, _ start: TimeInterval) -> HealthCheckItem
}
