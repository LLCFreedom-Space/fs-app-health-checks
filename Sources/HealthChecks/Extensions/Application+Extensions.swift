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
//  Application+Extensions.swift
//
//
//  Created by Mykola Buhaiov on 31.01.2024.
//

import Vapor

/// Extension for core type representing a Vapor application.
extension Application {
    /// A `ServiceIdKey` conform to StorageKey protocol
    private struct ServiceIdKey: StorageKey {
        /// Less verbose typealias for `UUID`.
        typealias Value = UUID
    }

    /// Setup `serviceId` in application storage
    public var serviceId: UUID? {
        get { storage[ServiceIdKey.self] }
        set { storage[ServiceIdKey.self] = newValue }
    }

    /// A `ReleaseIdKey` conform to StorageKey protocol
    private struct ReleaseIdKey: StorageKey {
        /// Less verbose typealias for `String`.
        typealias Value = String
    }

    /// Setup `releaseId` in application storage
    public var releaseId: String? {
        get { storage[ReleaseIdKey.self] }
        set { storage[ReleaseIdKey.self] = newValue }
    }

    /// A `psqlIdKey` conform to StorageKey protocol
    private struct PsqlIdKey: StorageKey {
        /// Less verbose typealias for `String`.
        typealias Value = String
    }

    /// Setup `psqlIdKey` in application storage
    public var psqlId: String? {
        get { storage[PsqlIdKey.self] }
        set { storage[PsqlIdKey.self] = newValue }
    }

    /// A `launchTimeKey` conform to StorageKey protocol
    private struct LaunchTimeKey: StorageKey {
        /// Less verbose typealias for `Double`.
        typealias Value = Double
    }

    /// Setup `launchTimeKey` in application storage
    public var launchTime: Double {
        get { storage[LaunchTimeKey.self] ?? Date().timeIntervalSinceReferenceDate }
        set { storage[LaunchTimeKey.self] = newValue }
    }

    /// A `redisIdKey` conform to StorageKey protocol
    private struct RedisIdKey: StorageKey {
        /// Less verbose typealias for `String`.
        typealias Value = String
    }

    /// Setup `redisIdKey` in application storage
    public var redisId: String? {
        get { storage[RedisIdKey.self] }
        set { storage[RedisIdKey.self] = newValue }
    }
}

extension Application {
    /// A `ConsulConfigKey` conform to StorageKey protocol
    private struct ConsulConfigKey: StorageKey {
        /// Less verbose typealias for `ConsulConfig`.
        typealias Value = ConsulConfig
    }

    /// Setup `consulConfig` in application storage
    public var consulConfig: ConsulConfig? {
        get { storage[ConsulConfigKey.self] }
        set { storage[ConsulConfigKey.self] = newValue }
    }
}

extension Application {
    /// A `PostgresHealthChecksKey` conform to StorageKey protocol
    public struct PostgresHealthChecksKey: StorageKey {
        /// Less verbose typealias for `PostgresHealthChecksProtocol`.
        public typealias Value = PostgresHealthChecksProtocol
    }

    /// Setup `psqlHealthChecks` in application storage
    public var psqlHealthChecks: PostgresHealthChecksProtocol? {
        get { storage[PostgresHealthChecksKey.self] }
        set { storage[PostgresHealthChecksKey.self] = newValue }
    }

    /// A `ConsulHealthChecksKey` conform to StorageKey protocol
    public struct ConsulHealthChecksKey: StorageKey {
        /// Less verbose typealias for `ConsulHealthChecksProtocol`.
        public typealias Value = ConsulHealthChecksProtocol
    }

    /// Setup `consulHealthChecks` in application storage
    public var consulHealthChecks: ConsulHealthChecksProtocol? {
        get { storage[ConsulHealthChecksKey.self] }
        set { storage[ConsulHealthChecksKey.self] = newValue }
    }

    /// A `ApplicationHealthChecksKey` conform to StorageKey protocol
    public struct ApplicationHealthChecksKey: StorageKey {
        /// Less verbose typealias for `ApplicationHealthChecksProtocol`.
        public typealias Value = ApplicationHealthChecksProtocol
    }

    /// Setup `applicationHealthChecks` in application storage
    public var applicationHealthChecks: ApplicationHealthChecksProtocol? {
        get { storage[ApplicationHealthChecksKey.self] }
        set { storage[ApplicationHealthChecksKey.self] = newValue }
    }

    /// A `RedisHealthChecksKey` conform to StorageKey protocol
    public struct RedisHealthChecksKey: StorageKey {
        /// Less verbose typealias for `RedisHealthChecksProtocol`.
        public typealias Value = RedisHealthChecksProtocol
    }

    /// Setup `redisHealthChecks` in application storage
    public var redisHealthChecks: RedisHealthChecksProtocol? {
        get { storage[RedisHealthChecksKey.self] }
        set { storage[RedisHealthChecksKey.self] = newValue }
    }
}

extension Application {
    /// Variable of date conform to DateFormatter protocol. ISO 8601 with date time format
    /// Example: `2024-02-01T11:11:59.364`
    public var dateTimeISOFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }
}

extension Application {
    /// `StorageKey` for PsqlRequestKey
    public struct PsqlRequestKey: StorageKey {
        /// PsqlRequestSendable
        public typealias Value = PsqlRequestSendable
    }

    /// Computed property for `PsqlRequestSendable`
    public var psqlRequest: PsqlRequestSendable? {
        get { storage[PsqlRequestKey.self] }
        set { storage[PsqlRequestKey.self] = newValue }
    }
}

extension Application {
    /// `StorageKey` for RedisRequestKey
    public struct RedisRequestKey: StorageKey {
        /// RedisRequestSendable
        public typealias Value = RedisRequestSendable
    }

    /// Computed property for `RedisRequestSendable`
    public var redisRequest: RedisRequestSendable? {
        get { storage[RedisRequestKey.self] }
        set { storage[RedisRequestKey.self] = newValue }
    }
}
