# fs-app-health-checks

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
![GitHub release (with filter)](https://img.shields.io/github/v/release/LLCFreedom-Space/fs-app-health-checks)
[![Read the Docs](https://readthedocs.org/projects/docs/badge/?version=latest)](https://llcfreedom-space.github.io/fs-app-health-checks/)
![example workflow](https://github.com/LLCFreedom-Space/fs-app-health-checks/actions/workflows/docc.yml/badge.svg?branch=main)
![example workflow](https://github.com/LLCFreedom-Space/fs-app-health-checks/actions/workflows/lint.yml/badge.svg?branch=main)
![example workflow](https://github.com/LLCFreedom-Space/fs-app-health-checks/actions/workflows/test.yml/badge.svg?branch=main)
[![codecov](https://codecov.io/github/LLCFreedom-Space/fs-app-health-checks/graph/badge.svg?token=2EUIA4OGS9)](https://codecov.io/github/LLCFreedom-Space/fs-app-health-checks)

This repository offers a wide collection of health checks features for widely used services and platforms.

## Health Checks Library for Swift

The Health Checks Library for Swift is a simple and easy-to-use way to implement health checks for your server-side Swift applications. It is designed specifically for the Vapor framework and also conforms to the RFC [Health Check Response Format for HTTP APIs](https://datatracker.ietf.org/doc/html/draft-inadarei-api-health-check-06#section-4.6-1).

Features

* A set of pre-defined health checks that cover common server-side functionality, such as database connectivity, HTTP connectivity, and memory usage.
* The ability to create custom health checks to monitor your application's specific needs.
* A simple API that makes it easy to implement health checks in your Vapor application.
* Conforms to the RFC [Health Check Response Format for HTTP APIs](https://datatracker.ietf.org/doc/html/draft-inadarei-api-health-check-06#section-4.6-1).

## Installation

App Health Checks is available with Swift Package Manager.
The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.
Once you have your Swift package set up, adding App Health Checks as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```swift
dependencies: [
    .package(url: "https://github.com/LLCFreedom-Space/fs-app-health-checks.git", from: "1.0.0")
]
```

## Links

LLC Freedom Space – [@LLCFreedomSpace](https://twitter.com/llcfreedomspace) – [support@freedomspace.company](mailto:support@freedomspace.company)

Distributed under the GNU AFFERO GENERAL PUBLIC LICENSE Version 3. See [LICENSE.md][license-url] for more information.

[GitHub](https://github.com/LLCFreedom-Space)

[swift-image]:https://img.shields.io/badge/swift-5.8-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-GPLv3-blue.svg
[license-url]: LICENSE
