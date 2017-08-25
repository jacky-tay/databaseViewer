//
//  WhereClause.swift
//  UtilityHelper
//
//  Created by Jacky Tay on 29/07/17.
//  Copyright © 2017 JackyTay. All rights reserved.
//

import Foundation

typealias WhereClauseStatement = (prefix: [WhereCategoryDisplay], statement: String, suffix: [WhereCategoryDisplay], index: Int, isLast: Bool)

indirect enum WhereClause {
    case and([WhereClause])
    case or([WhereClause])
    case bracket(WhereClause)
    case base(Statement)
    
    static func canAppend(lhs: WhereClause, rhs: WhereClause) -> Bool {
        switch (lhs, rhs) {
        case (.and, .base), (.and, .bracket), (.or, .base), (.or, .bracket):
            return true
        case (.bracket, base), (.bracket, .and), (.bracket, .or):
            return true
        default:
            return false
        }
    }
    
    static func shouldInsert(lhs: WhereClause, rhs: WhereClause) -> Bool {
        switch (lhs, rhs) {
        case (.base, .and), (.bracket, .and), (.base, .or), (.bracket, .or):
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
        if case .and(_) = self {
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
        if case .and(let list) = self {
            return list.last?.getLast()
        }
        else if case .or(let list) = self {
            return list.last?.getLast()
        }
        else if case .bracket(let clause) = self {
            return clause.getLast()
        }
        return self
    }
    
    func isLastBaseWrapWithBracket() -> Bool {
        if case .and(let list) = self {
            if let last = list.last, last.isBracket(), case .bracket(let clause) = last {
                return clause.isBase()
            }
            else {
                return list.last?.isLastBaseWrapWithBracket() ?? false
            }
        }
        else if case .or(let list) = self {
            if let last = list.last, last.isBracket(), case .bracket(let clause) = last {
                return clause.isBase()
            }
            else {
                return list.last?.isLastBaseWrapWithBracket() ?? false
            }
        }
        else if case .bracket(let clause) = self {
            return clause.isBase()
        }
        return false
    }
    
    func getDescription(row: Int, prefix: [WhereCategoryDisplay] = [], suffix: [WhereCategoryDisplay] = [], isLast: Bool = false) -> WhereClauseStatement? {
        if case .base(let statement) = self {
            // TODO
            return (prefix, statement.description, suffix, row, isLast)
        }
        else if case .and(let list) = self {
            return getDescription(row: row, prefix: prefix + WhereCategoryDisplay.and(0), suffix: suffix, list: list)
        }
        else if case .or(let list) = self {
            return getDescription(row: row, prefix: prefix + WhereCategoryDisplay.or(0), suffix: suffix, list: list)
        }
        else if case .bracket(let clause) = self {
            return clause.getDescription(row: row, prefix: prefix + WhereCategoryDisplay.bracketStart(row), suffix: suffix + WhereCategoryDisplay.bracketEnd(false))
        }
        return nil
    }
    
    private func getDescription(row: Int, prefix: [WhereCategoryDisplay], suffix: [WhereCategoryDisplay], list: [WhereClause]) -> WhereClauseStatement? {
        var count = 0
        var index = -1
        repeat {
            index += 1
            count += list[index].getCount()
        } while index + 1 < list.count && row >= count
        let rowInArray = row - count + list[index].getCount()
        let useIndex = list[index].isBase()
        return list[index].getDescription(row: rowInArray, prefix: prefix.update(to: useIndex ? index : rowInArray), suffix: suffix, isLast: index + 1 == list.count)
    }
    
    func insert(whereClause: WhereClause) -> WhereClause {
        if case .and(let list) = self {
            var array = list
            array.insert(whereClause, at: 0)
            return .and(array)
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
        if case .and(let list) = self {
            var array = list
            array.append(whereClause)
            return .and(array)
        }
        else if case .or(let list) = self {
            var array = list
            array.append(whereClause)
            return .or(array)
        }
        else if case .bracket(let clause) = self {
            if WhereClause.canAppend(lhs: clause, rhs: whereClause) {
                return .bracket(clause.append(whereClause: whereClause))
            }
            else {
                return .bracket(whereClause.insert(whereClause: clause))
            }
        }
        return whereClause
    }
    
    func update(whereClause: WhereClause?, with category: WhereCategory, endLastBracket: Bool) -> WhereClause {
        guard let whereClause = whereClause else {
            return self
        }
        // TODO: ????
        if case .bracket(let clause) = whereClause {
            return .bracket(update(whereClause: clause, with: category, endLastBracket: endLastBracket))
        }
        else if whereClause.isBase() && category == .and {
            return .and([whereClause, self])
        }
        else if whereClause.isOr() && category == .or {
            return .or([whereClause, self])
        }
        else if endLastBracket && whereClause.isAdd() && category == .or {
            return .or([.bracket(whereClause), self])
        }
        else if endLastBracket && whereClause.isOr() && category == .and {
            return .and([.bracket(whereClause), self])
        }
        else if case .and(let list) = whereClause {
            var _list = list
            if category == .and && endLastBracket {
                _list.append(self)
            }
            else {
                let last = _list.removeLast()
                _list.append(update(whereClause: last, with: category, endLastBracket: endLastBracket))
            }
            return .and(_list)
        }
        else if case .or(let list) = whereClause {
            var _list = list
            if category == .or && endLastBracket {
                _list.append(self)
            }
            else {
                let last = _list.removeLast()
                _list.append(update(whereClause: last, with: category, endLastBracket: endLastBracket))
            }
            return .or(_list)
        }
        return self
    }
    
    func getCount() -> Int {
        if case .and(let list) = self {
            return list.reduce(0) { $0 + $1.getCount() }
        }
        else if case .or(let list) = self {
            return list.reduce(0) { $0 + $1.getCount() }
        }
        else if case .bracket(let clause) = self {
            return clause.getCount()
        }
        else if case .base = self {
            return 1
        }
        return 0
    }
}
