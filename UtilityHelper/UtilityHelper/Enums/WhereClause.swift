//
//  WhereClause.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 29/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

typealias WhereClauseStatement = (prefix: [WhereCategory], statement: String, suffix: [WhereCategory], index: Int, isLast: Bool)

indirect enum WhereClause {
    case add([WhereClause])
    case or([WhereClause])
    case bracket(WhereClause?)
    case base(Statement)
    
    static func canAppend(lhs: WhereClause, rhs: WhereClause) -> Bool {
        switch (lhs, rhs) {
        case (.add, .base), (.add, .bracket), (.or, .base), (.or, .bracket):
            return true
        default:
            return false
        }
    }
    
    func isBase() -> Bool {
        if case .base(_) = self {
            return true
        }
        return false
    }
    
    func isAdd() -> Bool {
        if case .add(_) = self {
            return true
        }
        return false
    }
    
    func isOr() -> Bool {
        if case .or(_) = self {
            return true
        }
        return false
    }
    
    func isBracket() -> Bool {
        if case .bracket(_) = self {
            return true
        }
        return false
    }
    
    func getLast() -> WhereClause? {
        if case .add(let list) = self {
            return list.last?.getLast()
        }
        else if case .or(let list) = self {
            return list.last?.getLast()
        }
        else if case .bracket(let clause) = self {
            return clause?.getLast()
        }
        return self
    }
    
    func getDescription(row: Int, prefix: [WhereCategory] = [], suffix: [WhereCategory] = [], isLast: Bool = false) -> WhereClauseStatement? {
        if case .base(let statement) = self {
            // TODO
            return (prefix, statement.description, suffix, row, isLast)
        }
        else if case .add(let list) = self {
            return getDescription(row: row, prefix: prefix + WhereCategory.and, suffix: suffix, list: list)
        }
        else if case .or(let list) = self {
            return getDescription(row: row, prefix: prefix + WhereCategory.or, suffix: suffix, list: list)
        }
        else if case .bracket(let clause) = self {
            return clause?.getDescription(row: row, prefix: prefix + WhereCategory.bracketStart, suffix: suffix + WhereCategory.bracketEnd)
        }
        return nil
    }
    
    private func getDescription(row: Int, prefix: [WhereCategory], suffix: [WhereCategory], list: [WhereClause]) -> WhereClauseStatement? {
        var count = 0
        var index = -1
        repeat {
            index += 1
            count += list[index].getCount()
        } while index + 1 < list.count && row >= count
        return list[index].getDescription(row: row - count + list[index].getCount(), prefix: prefix, suffix: suffix, isLast: index + 1 == list.count)
    }
    
    func insert(whereClause: WhereClause) -> WhereClause {
        if case .add(let list) = self {
            var array = list
            array.insert(whereClause, at: 0)
            return .add(array)
        }
        else if case .or(let list) = self {
            var array = list
            array.insert(whereClause, at: 0)
            return .or(array)
        }
        else {
            return whereClause.append(whereClause: self)
        }
    }
    
    func append(whereClause: WhereClause) -> WhereClause {
        if case .add(let list) = self {
            var array = list
            array.append(whereClause)
            return .add(array)
        }
        else if case .or(let list) = self {
            var array = list
            array.append(whereClause)
            return .or(array)
        }
        else if case .bracket(let clause) = self, clause == nil {
            return .bracket(whereClause)
        }
        return whereClause
    }
    
    func getCount() -> Int {
        if case .add(let list) = self {
            return list.reduce(0) { $0 + $1.getCount() }
        }
        else if case .or(let list) = self {
            return list.reduce(0) { $0 + $1.getCount() }
        }
        else if case .bracket(let clause) = self {
            return clause?.getCount() ?? 0
        }
        else if case .base = self {
            return 1
        }
        return 0
    }
}
