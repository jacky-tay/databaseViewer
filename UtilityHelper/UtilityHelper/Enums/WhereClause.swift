//
//  WhereClause.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 29/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

indirect enum WhereClause {
    case add([WhereClause])
    case or([WhereClause])
    case bracket([WhereClause])
    case base(Statement?)
    
    func isBase() -> Bool {
        if case .base(_) = self {
            return true
        }
        return false
    }
    
    func getDescription(row: Int) -> String {
        if case .base(let statement) = self {
            return statement?.description ?? ""
        }
        else if case .add(let list) = self {
            return list[row].getDescription(row: row)
        }
        else if case .or(let list) = self {
            return list[row].getDescription(row: row)
        }
        else if case .bracket(let list) = self {
            return list[row].getDescription(row: row)
        }
        return ""
    }
    
    func insert(statement: Statement) -> WhereClause {
        if case .add(let list) = self {
            var array = list
            array.append(.base(statement))
            return .add(array)
        }
        else if case .or(let list) = self {
            var array = list
            array.append(.base(statement))
            return .or(array)
        }
        else if case .bracket(let list) = self {
            var array = list
            array.append(.base(statement))
            return .bracket(array)
        }
        return .base(statement)
    }
    
    func getCount() -> Int {
        if case .add(let list) = self {
            return list.reduce(0) { $0 + $1.getCount() }
        }
        else if case .or(let list) = self {
            return list.reduce(0) { $0 + $1.getCount() }
        }
        else if case .bracket(let list) = self {
            return list.reduce(0) { $0 + $1.getCount() }
        }
        else if case .base(let statement) = self {
            return statement != nil ? 1 : 0
        }
        return 0
    }
}
