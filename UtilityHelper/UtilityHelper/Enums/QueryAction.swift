//
//  QueryAction.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

enum QueryAction: String, CustomStringConvertible {
    case `default` = "-"
    case execute = "Execute"
    case select = "Select"
    case from = "From"
    case join = "Join"
    case `where` = "Where"
    case groupBy = "Group"
    case having = "Having"
    case orderBy = "Order"

    var description: String {
        switch self {
        case .orderBy, .groupBy:    return rawValue + " By"
        default:    return rawValue
        }
    }
}
