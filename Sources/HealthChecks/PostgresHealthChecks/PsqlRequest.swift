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
//  PsqlRequest.swift
//
//
//  Created by Mykola Buhaiov on 14.03.2024.
//

import Vapor
import Fluent
import FluentPostgresDriver

/// Default implementation of `PsqlRequestSendable`
/// used to interact with a PostgreSQL database via a Vapor `Application`.
public struct PsqlRequest: PsqlRequestSendable {
    /// The Vapor application instance.
    public let app: Application
    /// Creates a new `PsqlRequest`.
    /// - Parameter app: The Vapor `Application` instance used to access the database.
    public init(app: Application) {
        self.app = app
    }

    /// Internal shortcut to the configured PostgreSQL database.
    private var postgresDB: (any PostgresDatabase)? {
        app.db(.psql) as? any PostgresDatabase
    }

    /// Retrieves the PostgreSQL server version.
    /// Executes `SELECT version()` and parses the result into a structured format.
    /// - Returns: A string representing the PostgreSQL version (e.g. `"16.1"`).
    /// - Throws: `HealthCheckError` if the database is unavailable, query fails,
    ///           or version cannot be parsed.
    public func getVersion() async throws -> String {
        guard let db = app.db(.psql) as? (any PostgresDatabase) else {
            app.logger.error("No connection to Postgres database.")
            throw HealthCheckError(.cannotConnect, reason: .databaseNotFound)
        }

        do {
            let rows = try await db.simpleQuery("SELECT version()").get()

            guard let row = rows.first?.makeRandomAccess() else {
                app.logger.error("SELECT version() returned no rows.")
                throw HealthCheckError(.emptyResponse, reason: .noRowsReturned)
            }

            guard let rowDescription = row[data: "version"].string else {
                app.logger.error("Row has no 'version' column.", metadata: ["row": "\(row)"])
                throw HealthCheckError(.emptyResponse, reason: .unexpectedState)
            }

            guard let info = self.parsePostgreSQLVersion(rowDescription) else {
                app.logger.error("Failed to parse version string: \(rowDescription).")
                throw HealthCheckError(.parseVersionFailed, reason: .invalidVersionFormat)
            }

            return info.version
        } catch let error as HealthCheckError {
            throw error
        } catch {
            app.logger.error("Failed to query PostgreSQL version.", error: error)
            throw HealthCheckError(.queryFailed, reason: .queryExecutionFailed)
        }
    }

    /// Checks whether the PostgreSQL database is reachable.
    /// Executes a lightweight `SELECT 1` query.
    /// - Returns: `"connected"` if the query succeeds, otherwise `"disconnected"`.
    /// - Throws: `HealthCheckError` if the query execution fails.
    public func checkConnection() async throws -> String {
        guard let db = app.db(.psql) as? (any PostgresDatabase) else {
            app.logger.error("No connection to Postgres database.")
            throw HealthCheckError(.cannotConnect, reason: .databaseNotFound)
        }

        do {
            let rows = try await db.simpleQuery("SELECT 1").get()
            return rows.isEmpty ? "disconnected" : "connected"
        } catch {
            app.logger.error("Failed to check PostgreSQL connection.", error: error)
            throw HealthCheckError(.connectionLost, reason: .queryExecutionFailed)
        }
    }

    /// Returns the number of active connections to the current PostgreSQL database.
    /// Queries `pg_stat_activity` excluding the current backend process.
    /// - Returns: Number of active connections as a string.
    /// - Throws: `HealthCheckError` if query fails or response is invalid.
    public func getTotalConnection() async throws -> Int {
        guard let db = app.db(.psql) as? (any PostgresDatabase) else {
            app.logger.error("No connection to Postgres database.")
            throw HealthCheckError(.cannotConnect, reason: .databaseNotFound)
        }

        let query =
        """
        SELECT COUNT(*) AS count
        FROM pg_stat_activity
        WHERE datname = current_database()
          AND pid != pg_backend_pid()
          AND state IS NOT NULL
        """
        
        do {
            let rows = try await db.simpleQuery(query).get()
            
            guard let row = rows.first?.makeRandomAccess() else {
                app.logger.warning("pg_stat_activity returned no rows.")
                throw HealthCheckError(.emptyResponse, reason: .noRowsReturned)
            }
            guard let count = row[data: "count"].int64 else {
                app.logger.error("pg_stat_activity row has no 'count' column.", metadata: ["row": "\(row)"])
                throw HealthCheckError(.emptyResponse, reason: .unexpectedState)
            }
            return Int(count)
        } catch let error as HealthCheckError {
            throw error
        } catch {
            app.logger.error("Failed to get active connections count.", error: error)
            throw HealthCheckError(.queryFailed, reason: .queryExecutionFailed)
        }
    }

    /// Parses a raw PostgreSQL version string into a structured representation.
    /// This function extracts metadata from the output of:
    /// `SELECT version()`
    /// Expected format example:
    /// `PostgreSQL 16.1 on x86_64-apple-darwin, compiled by ...`
    /// The parser uses a regular expression with named capture groups to extract:
    /// - Database name
    /// - Version
    /// - Architecture
    /// - Operating system
    /// - Compiler information
    /// - Build details
    /// - Compiler version
    /// - System bitness
    ///
    /// - Parameter raw: The raw version string returned by PostgreSQL.
    /// - Returns: A `PostgresVersionInfo` object if parsing succeeds,
    ///            otherwise `nil` if the format does not match expected structure.
    private func parsePostgreSQLVersion(_ raw: String) -> PostgresVersionInfo? {
        let pattern = /^(?<db>[a-zA-Z]+)\s+(?<ver>[\d.]+)\s+on\s+(?<arch>[a-zA-Z0-9_]+)-(?<os>[^,]+),\s+compiled\s+by\s+(?<compiler>[^(]+)\((?<build>[^)]+)\)\s+(?<compVer>[^,]+),\s+(?<bitness>.+)$/

        guard let match = raw.wholeMatch(of: pattern) else { return nil }

        return PostgresVersionInfo(
            dbName: String(match.output.db),
            version: String(match.output.ver),
            architecture: String(match.output.arch),
            osEnvironment: String(match.output.os),
            compiler: match.output.compiler.trimmingCharacters(in: .whitespaces),
            compilerBuild: String(match.output.build),
            compilerVersion: String(match.output.compVer),
            bitness: String(match.output.bitness)
        )
    }

    /// Internal structured representation of parsed PostgreSQL version information.
    /// This type is used to decode and normalize the raw string returned by
    /// `SELECT version()` into strongly typed components for easier debugging,
    /// logging, and future extensibility.
    private struct PostgresVersionInfo: Content {
        /// Database engine name (e.g. `"PostgreSQL"`).
        let dbName: String
        /// Semantic version of PostgreSQL (e.g. `"16.1"`).
        let version: String
        /// CPU architecture the database was built for (e.g. `"x86_64"`).
        let architecture: String
        /// Operating system on which PostgreSQL is running.
        let osEnvironment: String
        /// Compiler used to build PostgreSQL (e.g. `"gcc"`).
        let compiler: String
        /// Specific compiler build information or flags.
        let compilerBuild: String
        /// Compiler version string.
        let compilerVersion: String
        /// System bitness (e.g. `"64-bit"`).
        let bitness: String
    }
}
