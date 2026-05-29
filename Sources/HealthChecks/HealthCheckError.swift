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
//  Created by Mykola Buhaiov on 29.05.2026.
//

import Vapor

public enum HealthCheckError: Error {
    /// The service URL is absent or empty in the application configuration.
    case urlNotConfigured
    /// The service responded with an HTTP status code outside the expected range.
    case unexpectedStatusCode
    /// The service instance is not registered in the application container.
    case serviceNotSetup

    /// A human-readable summary of the reason.
    public var description: String {
        switch self {
        case .urlNotConfigured:
            return "The service URL is not set in the application configuration."
        case .unexpectedStatusCode:
            return "The service returned an unexpected HTTP status code, indicating it may be unavailable or unhealthy."
        case .serviceNotSetup:
            return "The service is not registered in the application container."
        }
    }
}
