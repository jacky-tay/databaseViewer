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
    case root(Statement)
    
    func insert(statement: Statement) -> WhereClause {
        if case .add(let list) = self {
            var array = list
            array.append(.root(statement))
            return .add(array)
        }
        else if case .or(let list) = self {
            var array = list
            array.append(.root(statement))
            return .or(array)
        }
        else if case .bracket(let list) = self {
            var array = list
            array.append(.root(statement))
            return .bracket(array)
        }
        return .root(statement)
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
        return 1
    }
}
