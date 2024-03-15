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
//  Constants.swift
//
//
//  Created by Mykola Buhaiov on 15.03.2024.
//

import Vapor

enum Constants {
    // swiftlint:disable numbers_smell
    /// PostgreSQL version description
    static let psqlVersionDescription = 
        """
        PostgreSQL 14.10 on x86_64-pc-linux-musl, compiled by gcc (Alpine 13.2.1_git20231014) 13.2.1 20231014, 64-bit
        """
    // swiftlint:enable numbers_smell

    /// Default url for consul
    static let consulUrl = "http://127.0.0.1:8500"
}
