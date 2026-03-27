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
//  ApplicationHealthChecksProtocol.swift
//
//
//  Created by Mykola Buhaiov on 10.02.2024.
//

import Vapor

/// A protocol defining comprehensive application health checks.
///
/// `ApplicationHealthChecksProtocol` combines multiple protocols to provide
/// a unified interface for performing health checks at the application level.
/// It includes system-level checks (from `ApplicationChecksProtocol`) as well as
/// general check functionality (from `ChecksProtocol`) and is safe for use
/// in concurrent contexts (`Sendable`).
///
/// - Conforms to:
///   - `ApplicationChecksProtocol` — provides system-level checks such as uptime.
///   - `ChecksProtocol` — provides base check functionality for custom components.
///   - `Sendable` — ensures the protocol can be used safely in concurrent Swift code.
///
/// - Purpose:
/// Implement this protocol for services or components that perform
/// application-wide health monitoring, including uptime, external services,
/// and other critical checks.
public protocol ApplicationHealthChecksProtocol: ApplicationChecksProtocol, ChecksProtocol, Sendable {}
