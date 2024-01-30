//
//  ComponentType.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor

/// Human-readable type for the component.
public enum ComponentType: String, Content, CaseIterable {
    case component
    case datastore
    case system
}
