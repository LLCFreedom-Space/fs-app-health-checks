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
//  ConsulHealthChecksProtocol.swift
//
//
//  Created by Mykola Buhaiov on 07.02.2024.
//

import Vapor

/// A protocol defining health check capabilities for a Consul service.
///
/// `ConsulHealthChecksProtocol` provides a standard interface for implementing
/// health checks specific to a Consul instance. It extends `ChecksProtocol`
/// to inherit basic check functionality and conforms to `Sendable` for
/// safe usage in concurrent contexts.
///
/// - Conforms to:
///   - `ChecksProtocol` — provides base health check behavior.
///   - `Sendable` — ensures thread-safe usage in Swift Concurrency.
///
/// - Purpose:
/// Types conforming to this protocol should implement methods to check
/// the availability, response time, and connection status of a Consul service.
public protocol ConsulHealthChecksProtocol: ChecksProtocol, Sendable {}
