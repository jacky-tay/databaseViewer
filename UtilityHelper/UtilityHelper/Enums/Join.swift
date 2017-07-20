//
//  Join.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

enum Join: String, CustomStringConvertible {
    case full = "FULL"
    case inner = "INNER"
    case left = "LEFT"
    case right = "RIGHT"

    static func getAllJoins() -> [Join] {
        return [.full, .inner, .left, .right]
    }

    var description: String {
        return rawValue.capitalized + " Join"
    }
}
