//
//  HealthCheckResponse.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor

/// A generic `HealthCheck` data that can be sent in response.
public struct HealthCheckResponse: Content {
    /// Indicates whether the service status is acceptable or not. API publishers SHOULD use following values for the field:
    /// `pass`: healthy (acceptable aliases: `ok` to support Node's Terminus and `up` for Java's SpringBoot),
    /// `fail`: unhealthy (acceptable aliases: `error` to support Node's Terminus and `down` for Java's SpringBoot), and
    /// `warn`: healthy, with some concerns.
    /// The value of the status field is case-insensitive and is tightly related with the HTTP response code returned by the health endpoint.
    /// For `pass` status, HTTP response code in the 2xx-3xx range MUST be used. For "fail" status, HTTP response code in the 4xx-5xx range MUST be used.
    /// In case of the `warn` status, endpoints MUST return HTTP status in the 2xx-3xx range, and additional information SHOULD be provided, utilizing optional fields of the response.
    /// A health endpoint is only meaningful in the context of the component it indicates the health of.
    /// It has no other meaning or purpose. As such, its health is a conduit to the health of the component.
    /// Clients SHOULD assume that the HTTP response code returned by the health endpoint is applicable to the entire component (e.g. a larger API or a microservice).
    ///  This is compatible with the behavior that current infrastructural tooling expects: load-balancers, service discoveries and others, utilizing health-checks.
    public var status: HealthCheckStatus?
    /// Public version of the service
    public var version: Int?
    /// In well-designed APIs, backwards-compatible changes in the service should not update a version number.
    /// APIs usually change their version number as infrequently as possible, to preserve stable interface.
    /// However, implementation of an API may change much more frequently,
    /// which leads to the importance of having separate `release number` or `releaseId` that is different from the public version of the API.
    public var releaseId: String?
    /// Array of notes relevant to current state of health
    public var notes: [String]?
    /// Raw error output, in case of `fail` or `warn` states. This field SHOULD be omitted for `pass` state.
    public var output: String?
    /// Is an object that provides detailed health statuses of additional downstream systems and endpoints which can affect the overall health of the main API.
    /// Please refer to the `The Checks Object` section for more information
    public var checks: [String: [HealthCheckData]]?
    /// Is an object containing link relations and URIs [RFC3986] for external links that MAY contain more information about the health of the endpoint.
    /// All values of this object SHALL be URIs. Keys MAY also be URIs.
    /// Per web-linking standards [RFC8288] a link relationship SHOULD either be a common/registered one or be indicated as a URI, to avoid name clashes. If a `self` link is provided, it MAY be used by clients to check health via HTTP response code, as mentioned above
    public var links: [String: String]?
    /// Is a unique identifier of the service, in the application scope
    public var serviceId: UUID?
    /// Is a human-friendly description of the service
    public var description: String?
}
