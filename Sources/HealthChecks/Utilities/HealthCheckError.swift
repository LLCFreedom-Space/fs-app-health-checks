//
//  HealthCheckError.swift
//  fs-app-health-checks
//
//  Created by Mykola Buhaiov on 22.05.2026.
//

import Vapor

public struct HealthCheckError: Error, CustomStringConvertible, CustomDebugStringConvertible {
    // MARK: - Kind

    public enum Kind: String, Codable, CustomStringConvertible, Equatable, Sendable {
        /// Існуючий: неможливо підключитися до жодного хоста.
        case cannotConnect
        /// Запит до БД завершився помилкою.
        case queryFailed
        /// Не вдалося розпарсити рядок версії PostgreSQL.
        case parseVersionFailed
        /// Запит виконався, але повернув порожній результат.
        case emptyResponse
        /// З'єднання було втрачено під час виконання операції.
        case connectionLost

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

    public enum Reason: String, Codable, CustomStringConvertible, Equatable, Sendable {
        /// Існуючий: з'єднання було закрито.
        case connectionClosed
        /// База даних не знайдена або недоступна через пул з'єднань.
        case databaseNotFound
        /// Рядок версії має несподіваний формат.
        case invalidVersionFormat
        /// `pg_stat_activity` або інший запит не повернув жодного рядка.
        case noRowsReturned
        /// Виняток, кинутий під час виконання запиту (мережа, тайм-аут тощо).
        case queryExecutionFailed
        /// Рядок стану з'єднання знаходиться в несподіваному стані.
        case unexpectedState
        case databaseNotConfigured
        case redisMissingField
        /// Відповідь Redis не може бути перетворена на рядок.
        case redisInvalidResponse
        
        public var description: String {
            switch self {
            case .connectionClosed:
                return "The connection was closed, therefore queries could not be executed. This error may occur during rediscovery if the server isn't available"
            case .databaseNotFound:
                return "The PostgreSQL database could not be resolved from the connection pool; the identifier may be wrong or the pool is not configured"
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

    public let kind: Kind
    public let reason: Reason?

    public init(_ kind: Kind, reason: Reason?) {
        self.kind = kind
        self.reason = reason
    }

    // MARK: - Recommended Solution

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

    public var debugDescription: String { description }
    public var description: String {
        "\(kind.description): \(reason?.description ?? "Unknown reason")\nSolution(s):\n\(recommendedSolution)"
    }
}
