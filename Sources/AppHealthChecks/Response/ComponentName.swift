//
//  ComponentName.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor

/// Human-readable name for the component
public enum ComponentName: String, Content, CaseIterable {
    case cpu
    case memory
    case redis
    case postgresql
    case mongo
    case kafka
    case consul
    case grpc
}
