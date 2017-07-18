//
//  QueryAction.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

typealias TablePropertyPair = (database: String, table: String, property: String)

protocol QueryActionDelegate: class {
    func didSelect(properties: [(TablePropertyPair)])
    func didOrderBy(properties: [(TablePropertyPair)])
    func didGroupBy(properties: [(TablePropertyPair)])
    func addRelationship(between left: DatabaseTablePair, and right: DatabaseTablePair, joinType: Join)
}

enum QueryAction: String, CustomStringConvertible {
    case `default` = ""
    case join = "Join", execute = "Execute", `where` = "Where", orderBy = "Order", groupBy = "Group", select = "Select", having = "Having"

    var description: String {
        switch self {
        case .orderBy, .groupBy:    return rawValue + " By"
        default:    return rawValue
        }
    }
}
