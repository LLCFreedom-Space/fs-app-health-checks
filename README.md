# fs-app-health-checks

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
![GitHub release (with filter)](https://img.shields.io/github/v/release/LLCFreedom-Space/fs-app-health-checks)
[![Read the Docs](https://readthedocs.org/projects/docs/badge/?version=latest)](https://llcfreedom-space.github.io/fs-app-health-checks/)
![example workflow](https://github.com/LLCFreedom-Space/fs-app-health-checks/actions/workflows/docc.yml/badge.svg?branch=main)
![example workflow](https://github.com/LLCFreedom-Space/fs-app-health-checks/actions/workflows/lint.yml/badge.svg?branch=main)
![example workflow](https://github.com/LLCFreedom-Space/fs-app-health-checks/actions/workflows/test.yml/badge.svg?branch=main)
![example workflow](https://github.com/LLCFreedom-Space/fs-app-health-checks/actions/workflows/codeql.yml/badge.svg?branch=main)
[![codecov](https://codecov.io/github/LLCFreedom-Space/fs-app-health-checks/graph/badge.svg?token=2EUIA4OGS9)](https://codecov.io/github/LLCFreedom-Space/fs-app-health-checks)

This repository offers a wide collection of health checks features for widely used services and platforms.

# Health Checks Library for Swift

The Health Checks Library for Swift is a simple and easy-to-use way to implement health checks for your server-side Swift applications. It is designed specifically for the Vapor framework and also conforms to the RFC [Health Check Response Format for HTTP APIs](https://datatracker.ietf.org/doc/html/draft-inadarei-api-health-check-06#section-4.6-1).

## ✨ Features

### ✅ Aggregated Application Health Checks
- Aggregates the status of all components into a single `HealthCheck` structure.
- Provides a complete overview of the service status in one request.
- Convenient JSON representation for APIs and dashboards.

### 🛢️ PostgreSQL, MongoDB, Redis Monitoring
- Automatic connection and status checks for databases.
- Measures response time.
- Structured results using `HealthCheckItem`.
- Easy integration with the `Application` object.

### ⚙️ Custom Component Support
- Add custom services or components.
- Supports component types: `component`, `datastore`, `system`.
- Track custom metrics and statuses.

### ⏱️ Response Time & Performance Metrics
- Measures request latency in milliseconds.
- Tracks component performance.
- Supports measurement types: `responseTime`, `uptime`, `connections`, `utilization`.

### 🧾 Human-Readable & Machine-Readable Output
- JSON format for APIs.
- Fields `notes`, `output`, `links` for detailed information.
- Contains `serviceId`, `releaseId`, `version`.

### 🔒 Asynchronous and Concurrency-Safe
- Fully `Sendable` and asynchronous (`async/await`) design.
- Safe for parallel requests.

### 🛠️ Extensible and Modular
- Easily add new protocols for other components.
- Compatible with `Consul`, Kafka, gRPC, etc.
- Can create custom `HealthCheckItem` for additional metrics.

## 🚀 Future Enhancements

- **Kafka Producer**: Integrate Kafka producers to monitor message publishing.
- **Kafka Consumer**: Add support for Kafka consumers to monitor message consumption and processing.
- **gRPC**: Add health checks and metrics for gRPC services.

## Installation

App Health Checks is available with Swift Package Manager.
The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.
Once you have your Swift package set up, adding App Health Checks as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
dependencies: [
    .package(url: "https://github.com/LLCFreedom-Space/fs-app-health-checks.git", from: "x.x.x")
]
```

## List of checks

- **Application** – Basic application health status.
- **ConsulHealthChecks** – Checks the status of your Consul services.
- **MongoHealthChecks** – Checks MongoDB connectivity and status.
- **PostgresHealthChecks** – Checks PostgreSQL connectivity and status.
- **RedisHealthChecks** – Checks Redis connectivity and status.

## Example of result
```swift
{
  "status": "pass",
  "version": "1",
  "releaseId": "1.0.0",
  "serviceId": "43119325-63f5-4e14-9175-84e0e296c527",
  "notes": ["All services operational"],
  "checks": {
    "system": [
      {
        "componentId": "system-uptime",
        "componentType": "system",
        "observedValue": 12345,
        "observedUnit": "s",
        "status": "pass",
        "time": "2026-03-25T17:36:48Z"
      }
    ],
    "datastore": [
      {
        "componentId": "mongo-db-1",
        "componentType": "datastore",
        "observedValue": 12.5,
        "observedUnit": "ms",
        "status": "pass",
        "time": "2026-03-25T17:36:48Z"
      },
      {
        "componentId": "redis-db-1",
        "componentType": "datastore",
        "observedValue": 2.1,
        "observedUnit": "ms",
        "status": "pass",
        "time": "2026-03-25T17:36:48Z"
      },
      {
        "componentId": "postgres-db-1",
        "componentType": "datastore",
        "observedValue": 15.0,
        "observedUnit": "ms",
        "status": "pass",
        "time": "2026-03-25T17:36:48Z"
      }
    ],
    "component": [
      {
        "componentId": "consul-service-1",
        "componentType": "component",
        "observedValue": 15.3,
        "observedUnit": "ms",
        "status": "pass",
        "time": "2026-03-25T17:36:48Z"
      }
    ]
  }
}
```

## Links

LLC Freedom Space – [@LLCFreedomSpace](https://twitter.com/llcfreedomspace) – [support@freedomspace.company](mailto:support@freedomspace.company)

Distributed under the GNU AFFERO GENERAL PUBLIC LICENSE Version 3. See [LICENSE.md][license-url] for more information.

[GitHub](https://github.com/LLCFreedom-Space)

[swift-image]:https://img.shields.io/badge/swift-5.8-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-GPLv3-blue.svg
[license-url]: LICENSE
