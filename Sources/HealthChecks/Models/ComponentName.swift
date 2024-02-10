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
//  ComponentName.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//

import Vapor

/// Human-readable name for the component
public enum ComponentName: String {
    /// The Central Processing Unit (CPU) is the primary component of a computer that acts as its "control center."
    case cpu
    /// Memory, also known as random access memory (RAM), is a PC component that stores data while the computer runs
    case memory
    /// Redis is an open-source in-memory storage, used as a distributed, in-memory key–value database
    case redis
    /// PostgreSQL also known as Postgres, is a free and open-source relational database management system (RDBMS) emphasizing extensibility
    case postgresql
    /// MongoDB is a source-available, cross-platform, document-oriented database program.
    case mongo
    /// Distributed messaging system between server applications in real time
    case kafka
    /// Consul is a service networking solution to automate network configurations, discover services, and enable secure connectivity across any cloud or runtime.
    case consul
    /// gRPC is a modern open source high performance Remote Procedure Call (RPC) framework that can run in any environment.
    case grpc
}

extension ComponentName: Content {}

extension ComponentName: CaseIterable {}
