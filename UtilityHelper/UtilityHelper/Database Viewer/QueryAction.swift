//
//  QueryAction.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 18/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

protocol QueryActionDelegate: class {
    func didSelect(properties: [(AliasProperty)])
    func didOrderBy(properties: [(AliasPropertyOrder)])
    func didGroupBy(properties: [(AliasProperty)])
    func addRelationship(with: JoinByDatabaseAlias)
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
