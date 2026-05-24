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
//  HealthCheckError.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 22.05.2026.
//

import Vapor

/// A structured error type used to report health-check failures across different services
/// (PostgreSQL, MongoDB, Redis, etc.).
/// Each error carries a ``Kind`` that describes the category of failure and an optional
/// ``Reason`` that provides a more specific cause. Together they produce human-readable
/// descriptions and actionable solutions.
/// ## Example
/// ```swift
/// throw HealthCheckError(.queryFailed, reason: .queryExecutionFailed)
/// ```
public struct HealthCheckError: Error, CustomStringConvertible, CustomDebugStringConvertible {
    // MARK: - Kind

    /// The high-level category of a health-check failure.
    ///
    /// Use `Kind` to branch on the type of problem without needing to inspect
    /// the lower-level ``Reason``.
    public enum Kind: String, Codable, CustomStringConvertible, Equatable, Sendable {
        /// No host in the connection pool could be reached, so no queries can be sent.
        case cannotConnect
        /// A database query was attempted but did not complete successfully.
        case queryFailed
        /// The raw version string returned by PostgreSQL could not be parsed.
        case parseVersionFailed
        /// A query executed successfully but returned an empty result set.
        case emptyResponse
        /// The connection to the database was dropped mid-operation.
        case connectionLost

        /// A human-readable summary of the kind.
        public var description: String {
            switch self {
            case .cannotConnect:
                return "No hosts could be connected with, therefore no queries can be sent at the moment"
            case .queryFailed:
                return "The database query failed to execute successfully"
            case .parseVersionFailed:
                return "The PostgreSQL version string could not be parsed into a structured format"
            case .emptyResponse:
                return "The query returned no rows when at least one was expected"
            case .connectionLost:
                return "The connection to the database was lost during the operation"
            }
        }
    }

    // MARK: - Reason

    /// The specific underlying cause of a health-check failure.
    ///
    /// `Reason` refines the broader ``Kind`` and drives the ``HealthCheckError/recommendedSolution``
    /// text shown to operators.
    public enum Reason: String, Codable, CustomStringConvertible, Equatable, Sendable {
        /// The connection was explicitly closed before the query could run.
        case connectionClosed
        /// The requested database could not be resolved from the connection pool.
        case databaseNotFound
        /// The version string returned by the server does not match the expected pattern.
        case invalidVersionFormat
        /// The query succeeded but the result set contained no rows.
        case noRowsReturned
        /// An exception was thrown while executing the SQL query.
        case queryExecutionFailed
        /// The connection or query result is in a state the health-check logic cannot handle.
        case unexpectedState
        /// The MongoDB database has not been registered in the application configuration.
        case databaseNotConfigured
        /// The expected field was absent from the Redis `INFO` response.
        case redisMissingField
        /// The Redis server response could not be converted to a plain string.
        case redisInvalidResponse

        /// A human-readable summary of the reason.
        public var description: String {
            switch self {
            case .connectionClosed:
                return "The connection was closed, therefore queries could not be executed. This error may occur during rediscovery if the server isn't available"
            case .databaseNotFound:
                return "Database could not be resolved from the connection pool; the identifier may be wrong or the pool is not configured"
            case .invalidVersionFormat:
                return "The raw version string returned by PostgreSQL does not match the expected pattern and cannot be parsed"
            case .noRowsReturned:
                return "The query executed successfully but the result set was empty; the database may be in an inconsistent state"
            case .queryExecutionFailed:
                return "An error was thrown while executing the SQL query; this may indicate a network issue, a timeout, or an invalid SQL statement"
            case .unexpectedState:
                return "The connection or query result is in an unexpected state that the health-check logic cannot handle"
            case .databaseNotConfigured:
                return "The MongoDB is not installed or registered in the application configuration"
            case .redisMissingField:
                return "The Redis INFO response did not contain the expected field"
            case .redisInvalidResponse:
                return "The Redis server response could not be converted to a string"
            }
        }
    }

    // MARK: - Properties

    /// The high-level category of the failure.
    public let kind: Kind

    /// The specific underlying cause, if known.
    public let reason: Reason?

    // MARK: - Initialiser

    /// Creates a new `HealthCheckError`.
    ///
    /// - Parameters:
    ///   - kind: The high-level category of the failure.
    ///   - reason: The specific underlying cause, or `nil` if unknown.
    public init(_ kind: Kind, reason: Reason?) {
        self.kind = kind
        self.reason = reason
    }

    // MARK: - Recommended Solution

    /// A human-readable, operator-facing description of steps that may resolve the error.
    ///
    /// When ``reason`` is `nil`, a generic link to the issue tracker is returned.
    public var recommendedSolution: String {
        guard let reason = reason else {
            return "File a report on https://github.com/LLCFreedom-Space/fs-app-health-checks"
        }

        switch reason {
        case .connectionClosed:
            return """
            - The driver will attempt to reconnect automatically. If this keeps failing, check your host availability.
            - Check if your host is still online and not undergoing maintenance.
            - Verify that SSL settings are correctly configured if required.

            Note: This error may be meaningless if the maintenance is planned.
            """

        case .databaseNotFound:
            return """
            - Ensure the database identifier passed to `app.db(.psql)` is registered in your configuration.
            - Verify that the Fluent/PostgresNIO driver is properly set up before the application starts.
            - Check your environment variables (host, port, username, password, database name).
            """

        case .invalidVersionFormat:
            return """
            - The version string returned by `SELECT version()` does not match the expected pattern.
            - Check if you are running a supported version of PostgreSQL.
            - If the format has changed, update the regex pattern in `parsePostgreSQLVersion(_:)`.
            - File a report on https://github.com/LLCFreedom-Space/fs-app-health-checks if the issue persists.
            """

        case .noRowsReturned:
            return """
            - The query returned zero rows, which is unexpected.
            - Verify that `pg_stat_activity` is accessible with the current database user's privileges.
            - Check that the database is not in a read-only or restricted mode.
            """

        case .queryExecutionFailed:
            return """
            - Check the application logs for the underlying error message.
            - Verify network connectivity between the application and the PostgreSQL server.
            - Ensure the database user has sufficient privileges to execute the query.
            - Check for query timeouts and adjust pool/timeout settings if needed.
            """

        case .unexpectedState:
            return """
            - This is likely an internal logic error. Review the health-check implementation.
            - File a report on https://github.com/LLCFreedom-Space/fs-app-health-checks with reproduction steps.
            """

        case .databaseNotConfigured:
            return """
            - Ensure `app.healthCheckMongoDatabase` is configured before the application starts.
            - Verify that the MongoKitten driver is properly set up in your configuration.
            - Check your environment variables (host, port, username, password, database name).
            """

        case .redisMissingField:
            return """
            - Verify the Redis server version supports the requested INFO section.
            - Check that the field name matches the Redis INFO output format.
            - File a report on https://github.com/LLCFreedom-Space/fs-app-health-checks if the issue persists.
            """

        case .redisInvalidResponse:
            return """
            - Check the Redis server logs for unexpected response formats.
            - Verify network connectivity between the application and the Redis server.
            - Ensure the Redis server is running a supported version.
            """
        }
    }

    // MARK: - CustomStringConvertible

    /// A full description including the kind, reason, and recommended solution.
    public var description: String {
        "\(kind.description): \(reason?.description ?? "Unknown reason")\nSolution(s):\n\(recommendedSolution)"
    }

    /// Identical to ``description``; provided for `CustomDebugStringConvertible` conformance.
    public var debugDescription: String { description }
}
