//
//  ComponentType.swift
//
//
//  Created by Mykola Buhaiov on 29.01.2024.
//  Copyright © 2024 Freedom Space LLC
//  All rights reserved: http://opensource.org/licenses/MIT
//

import Vapor

/// SHOULD be present if componentName is present. It's a type of the component and could be one of:
public enum ComponentType: String, Content, CaseIterable {
    case component
    case datastore
    case system
}
